--[[
╔══════════════════════════════════════════════════════════════╗
║   ROBLOX 2026 BUY UI + PURCHASE UI + SETTINGS PANEL         ║
║   ✅ Executor Compatible (paste vào executor là chạy)        ║
║   ✅ Draggable Settings Panel                                 ║
║   ✅ Đổi Robux, Item Name, Item Price                        ║
║   ✅ 2026 Roblox Icons dùng ImageLabel rbxassetid            ║
║   ✅ Full animation: Spring, Elastic, Ripple, Shimmer        ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ── Services ──────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local Player    = Players.LocalPlayer
local Mouse     = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ── ICONS (Roblox 2026 official asset IDs) ────────────────────
-- Robux icon mới nhất của Roblox (hexagon R)
local ICON = {
    ROBUX        = "rbxassetid://14869809956",   -- Robux ⬡ icon chính thức
    ROBLOX_LOGO  = "rbxassetid://10723602295",   -- Logo Roblox vuông trắng
    ROBLOX_PLUS  = "rbxassetid://11803541855",   -- Roblox Premium badge
    SHOP         = "rbxassetid://11803558150",   -- Cửa hàng / bag icon
    SETTINGS_COG = "rbxassetid://104919049969988", -- Bánh răng settings (from creator-docs)
    CHECKMARK    = "rbxassetid://9894440655",    -- Dấu tick tròn
    CLOSE        = "rbxassetid://14038363283",   -- X icon
    COIN_STACK   = "rbxassetid://11803545855",   -- Coin stack
}

-- ── THEME (Roblox 2026 dark palette) ──────────────────────────
local C = {
    BG          = Color3.fromRGB(25,  25,  30),
    MODAL       = Color3.fromRGB(30,  30,  38),
    SURFACE     = Color3.fromRGB(40,  40,  50),
    SURFACE2    = Color3.fromRGB(48,  48,  60),
    ACCENT      = Color3.fromRGB(51,  95,  255),   -- Roblox Blue #335FFF
    ACCENT_H    = Color3.fromRGB(35,  70,  220),
    ACCENT_P    = Color3.fromRGB(20,  50,  180),
    SUCCESS     = Color3.fromRGB(45,  195, 120),
    SUCCESS_D   = Color3.fromRGB(30,  140,  80),
    TEXT        = Color3.fromRGB(242, 242, 243),   -- Athens Gray (Roblox brand)
    TEXT2       = Color3.fromRGB(160, 160, 180),
    TEXT3       = Color3.fromRGB(110, 110, 135),
    BORDER      = Color3.fromRGB(55,  55,  70),
    GOLD        = Color3.fromRGB(255, 200,  55),   -- Robux gold
    DANGER      = Color3.fromRGB(230,  60,  60),
    OVERLAY     = Color3.fromRGB(0,    0,   0),
    PANEL_TITLE = Color3.fromRGB(55,  55,  70),
    PLUS_BG     = Color3.fromRGB(35,  35,  48),
}

-- ── Tween presets ─────────────────────────────────────────────
local TS = TweenService
local function ti(t, s, d) return TweenInfo.new(t, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out) end
local T_SPRING  = ti(0.45, Enum.EasingStyle.Back)
local T_ELASTIC = ti(0.55, Enum.EasingStyle.Elastic)
local T_SMOOTH  = ti(0.28, Enum.EasingStyle.Quart)
local T_FAST    = ti(0.16, Enum.EasingStyle.Quart)
local T_LINEAR  = ti(1.8,  Enum.EasingStyle.Linear)

local function tw(obj, info, props, cb)
    local t = TS:Create(obj, info, props)
    if cb then t.Completed:Connect(cb) end
    t:Play(); return t
end

-- ── State ─────────────────────────────────────────────────────
local STATE = {
    robux     = 3098112,
    itemName  = "Donation",
    itemPrice = 10000,
}

-- ═══════════════════════════════════════════════════════════════
--  UTILITY BUILDERS
-- ═══════════════════════════════════════════════════════════════

local function corner(parent, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 12); c.Parent = parent; return c
end
local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke"); s.Color = color or C.BORDER; s.Thickness = thickness or 1.5; s.Parent = parent; return s
end
local function pad(parent, t,b,l,r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent; return p
end

local function Frame(parent, size, pos, bg, r, name)
    local f = Instance.new("Frame")
    f.Name = name or "Frame"; f.Size = size; f.Position = pos or UDim2.new()
    f.BackgroundColor3 = bg or C.SURFACE; f.BorderSizePixel = 0; f.Parent = parent
    if r then corner(f, r) end; return f
end

local function Label(parent, text, sz, pos, fs, font, color, ax, name)
    local l = Instance.new("TextLabel")
    l.Name = name or "Lbl"; l.Size = sz; l.Position = pos or UDim2.new()
    l.Text = text; l.TextSize = fs or 15
    l.Font = font or Enum.Font.GothamMedium
    l.TextColor3 = color or C.TEXT
    l.BackgroundTransparency = 1; l.BorderSizePixel = 0
    l.TextXAlignment = ax or Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent; return l
end

local function Img(parent, id, sz, pos, color, name)
    local i = Instance.new("ImageLabel")
    i.Name = name or "Img"; i.Size = sz; i.Position = pos or UDim2.new()
    i.Image = id or ""; i.ImageColor3 = color or Color3.new(1,1,1)
    i.BackgroundTransparency = 1; i.BorderSizePixel = 0
    i.ScaleType = Enum.ScaleType.Fit; i.Parent = parent; return i
end

local function Btn(parent, text, sz, pos, bg, tc, r, name)
    local b = Instance.new("TextButton")
    b.Name = name or "Btn"; b.Size = sz; b.Position = pos or UDim2.new()
    b.Text = text; b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = tc or C.TEXT
    b.BackgroundColor3 = bg or C.ACCENT
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Parent = parent
    if r then corner(b, r) end; return b
end

local function ImgBtn(parent, id, sz, pos, bg, icolor, r, name)
    local b = Instance.new("ImageButton")
    b.Name = name or "ImgBtn"; b.Size = sz; b.Position = pos or UDim2.new()
    b.Image = id or ""; b.ImageColor3 = icolor or Color3.new(1,1,1)
    b.BackgroundColor3 = bg or Color3.fromRGB(0,0,0)
    b.BackgroundTransparency = bg and 0 or 1
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Parent = parent
    if r then corner(b, r) end; return b
end

local function fmtN(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,","")
end

-- ── Ripple ────────────────────────────────────────────────────
local function ripple(btn, color)
    btn.ClipsDescendants = true
    btn.MouseButton1Click:Connect(function()
        local r = Instance.new("Frame")
        r.Size = UDim2.new(0,0,0,0); r.AnchorPoint = Vector2.new(0.5,0.5)
        r.Position = UDim2.new(0.5,0,0.5,0)
        r.BackgroundColor3 = color or Color3.new(1,1,1)
        r.BackgroundTransparency = 0.65; r.BorderSizePixel = 0
        r.ZIndex = btn.ZIndex + 2; r.Parent = btn
        corner(r, 999)
        local abs = btn.AbsoluteSize
        local mx = math.max(abs.X, abs.Y) * 2.4
        tw(r, ti(0.55, Enum.EasingStyle.Quart),
            {Size = UDim2.new(0,mx,0,mx), BackgroundTransparency = 1},
            function() r:Destroy() end)
    end)
end

-- ── Button hover/press ────────────────────────────────────────
local function btnFX(b, nc, hc, pc)
    b.MouseEnter:Connect(function() tw(b, T_FAST, {BackgroundColor3 = hc or nc}) end)
    b.MouseLeave:Connect(function() tw(b, T_FAST, {BackgroundColor3 = nc}) end)
    b.MouseButton1Down:Connect(function()
        tw(b, T_FAST, {BackgroundColor3 = pc or hc or nc})
        tw(b, T_FAST, {Size = UDim2.new(b.Size.X.Scale, -4, b.Size.Y.Scale, -3)})
    end)
    b.MouseButton1Up:Connect(function()
        tw(b, T_SPRING, {Size = UDim2.new(b.Size.X.Scale, 0, b.Size.Y.Scale, 0)})
        tw(b, T_FAST, {BackgroundColor3 = nc})
    end)
end

-- ── Shimmer loop ──────────────────────────────────────────────
local function shimmer(parent)
    local s = Frame(parent, UDim2.new(0.35,0,1,0), UDim2.new(-0.4,0,0,0),
        Color3.new(1,1,1), 0, "Shimmer")
    s.BackgroundTransparency = 0.82; s.ZIndex = (parent.ZIndex or 1) + 1
    s.ClipsDescendants = false
    local g = Instance.new("UIGradient"); g.Rotation = 20
    g.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.5,0.6),
        NumberSequenceKeypoint.new(1,1),
    }; g.Parent = s
    local function loop()
        s.Position = UDim2.new(-0.4,0,0,0)
        tw(s, T_LINEAR, {Position = UDim2.new(1.1,0,0,0)}, function()
            task.wait(2.8); loop()
        end)
    end; loop()
end

-- ── Overlay ───────────────────────────────────────────────────
local function overlay(gui, zi)
    local o = Frame(gui, UDim2.new(1,0,1,0), UDim2.new(), C.OVERLAY, 0, "Overlay")
    o.BackgroundTransparency = 1; o.ZIndex = zi or 10
    o.Active = true; return o
end

-- ── Modal open/close ─────────────────────────────────────────
local function modalIn(modal, ov, targetH)
    modal.Size = UDim2.new(0, 440, 0, 0)
    tw(ov, T_SMOOTH, {BackgroundTransparency = 0.4})
    tw(modal, T_SPRING, {Size = UDim2.new(0, 440, 0, targetH)})
end

local function modalOut(modal, ov, gui, cb)
    tw(ov, T_SMOOTH, {BackgroundTransparency = 1})
    tw(modal, T_SMOOTH, {Size = UDim2.new(0, 440, 0, 0)}, function()
        gui:Destroy(); if cb then cb() end
    end)
end

-- ── Close X button ────────────────────────────────────────────
local function closeBtn(parent, zi)
    local b = Frame(parent, UDim2.new(0,34,0,34),
        UDim2.new(1,-44,0,11), Color3.fromRGB(50,50,65), 999, "CloseBtn")
    b.ZIndex = zi or 12
    -- X icon dùng ImageLabel
    local xi = Img(b, ICON.CLOSE, UDim2.new(0,16,0,16),
        UDim2.new(0.5,-8,0.5,-8), C.TEXT2, "XIcon")
    xi.ZIndex = (zi or 12) + 1
    -- Convert to button
    local realBtn = Instance.new("TextButton")
    realBtn.Size = UDim2.new(1,0,1,0); realBtn.BackgroundTransparency = 1
    realBtn.Text = ""; realBtn.ZIndex = (zi or 12) + 2; realBtn.Parent = b
    b.MouseEnter:Connect(function() tw(b, T_FAST, {BackgroundColor3 = Color3.fromRGB(80,60,80)}) end)
    b.MouseLeave:Connect(function() tw(b, T_FAST, {BackgroundColor3 = Color3.fromRGB(50,50,65)}) end)
    realBtn.Name = "ClickArea"
    return b, realBtn
end

-- ═══════════════════════════════════════════════════════════════
--  PURCHASE COMPLETE UI
-- ═══════════════════════════════════════════════════════════════
local function showPurchaseComplete(onClose)
    local gui = Instance.new("ScreenGui")
    gui.Name = "PC_Gui"; gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = PlayerGui

    local ov = overlay(gui, 10)

    local modal = Frame(gui, UDim2.new(0,440,0,0),
        UDim2.new(0.5,0,0.5,0), C.MODAL, 22, "Modal")
    modal.AnchorPoint = Vector2.new(0.5,0.5); modal.ZIndex = 11
    modal.ClipsDescendants = true
    stroke(modal, C.BORDER, 1.5)

    -- Title
    local title = Label(modal, "Purchase completed",
        UDim2.new(1,-56,0,52), UDim2.new(0,20,0,0),
        22, Enum.Font.GothamBold, C.TEXT, Enum.TextXAlignment.Left, "Title")
    title.ZIndex = 12

    -- Close
    local cFrame, cReal = closeBtn(modal, 12)

    -- Check circle
    local ring = Frame(modal, UDim2.new(0,0,0,0),
        UDim2.new(0.5,0,0,58), C.MODAL, 999, "Ring")
    ring.AnchorPoint = Vector2.new(0.5,0); ring.ZIndex = 12
    stroke(ring, C.SUCCESS, 3)

    -- Checkmark image inside ring
    local ckImg = Img(ring, ICON.CHECKMARK,
        UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.5,0), C.SUCCESS, "CheckImg")
    ckImg.AnchorPoint = Vector2.new(0.5,0.5); ckImg.ZIndex = 13
    ckImg.ImageTransparency = 1

    -- Robux icon + amount row (shows what was bought)
    local boughtRow = Frame(modal, UDim2.new(1,-40,0,32),
        UDim2.new(0,20,0,170), Color3.new(0,0,0), 0, "BoughtRow")
    boughtRow.BackgroundTransparency = 1; boughtRow.ZIndex = 12

    local rbxIcon2 = Img(boughtRow, ICON.ROBUX,
        UDim2.new(0,20,0,20), UDim2.new(0,0,0.5,-10), C.GOLD, "RbxIco")
    rbxIcon2.ZIndex = 13

    local boughtLbl = Label(boughtRow,
        "You have successfully bought  " .. STATE.itemName,
        UDim2.new(1,-28,1,0), UDim2.new(0,26,0,0),
        14, Enum.Font.GothamMedium, C.TEXT2,
        Enum.TextXAlignment.Center, "BoughtLbl")
    boughtLbl.ZIndex = 13; boughtLbl.TextTransparency = 1

    -- OK button
    local okBtn = Btn(modal, "OK",
        UDim2.new(1,-40,0,52), UDim2.new(0,20,1,-70),
        C.ACCENT, C.TEXT, 12, "OKBtn")
    okBtn.TextSize = 16; okBtn.ZIndex = 12; okBtn.BackgroundTransparency = 1
    local og = Instance.new("UIGradient"); og.Rotation = 0
    og.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80,115,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40,75,220)),
    }; og.Parent = okBtn
    btnFX(okBtn, C.ACCENT, C.ACCENT_H, C.ACCENT_P)
    ripple(okBtn)

    -- Animate IN
    tw(ov, T_SMOOTH, {BackgroundTransparency = 0.4})
    modal.Size = UDim2.new(0,440,0,0)
    tw(modal, T_SPRING, {Size = UDim2.new(0,440,0,280)}, function()
        -- Ring bounce in
        tw(ring, T_ELASTIC, {Size = UDim2.new(0,78,0,78)}, function()
            -- Checkmark pop
            tw(ckImg, T_ELASTIC, {
                Size = UDim2.new(0,44,0,44),
                Position = UDim2.new(0.5,-22,0.5,-22),
                ImageTransparency = 0,
            })
        end)
        task.wait(0.2)
        tw(boughtLbl, T_SMOOTH, {TextTransparency = 0})
        tw(okBtn, T_SMOOTH, {BackgroundTransparency = 0})
    end)

    local function close()
        modalOut(modal, ov, gui, onClose)
    end
    cReal.MouseButton1Click:Connect(close)
    okBtn.MouseButton1Click:Connect(close)
end

-- ═══════════════════════════════════════════════════════════════
--  BUY ITEM UI
-- ═══════════════════════════════════════════════════════════════
local function showBuyUI(onClose)
    local iName  = STATE.itemName
    local iPrice = STATE.itemPrice
    local pRobux = STATE.robux

    local gui = Instance.new("ScreenGui")
    gui.Name = "Buy_Gui"; gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = PlayerGui

    local ov = overlay(gui, 10)

    local modal = Frame(gui, UDim2.new(0,440,0,0),
        UDim2.new(0.5,0,0.5,0), C.MODAL, 22, "Modal")
    modal.AnchorPoint = Vector2.new(0.5,0.5); modal.ZIndex = 11
    modal.ClipsDescendants = true
    stroke(modal, C.BORDER, 1.5)

    -- ── HEADER ──────────────────────────────────────────────
    local header = Frame(modal, UDim2.new(1,0,0,60),
        UDim2.new(), Color3.new(0,0,0), 0, "Header")
    header.BackgroundTransparency = 1; header.ZIndex = 12

    -- Shop icon + "Buy item" title
    local shopIco = Img(header, ICON.SHOP,
        UDim2.new(0,26,0,26), UDim2.new(0,16,0.5,-13), C.TEXT, "ShopIco")
    shopIco.ZIndex = 13

    local titleLbl = Label(header, "Buy item",
        UDim2.new(0,140,0,36), UDim2.new(0,50,0.5,-18),
        21, Enum.Font.GothamBold, C.TEXT, Enum.TextXAlignment.Left)
    titleLbl.ZIndex = 13

    -- Balance row right side
    local balRow = Frame(header, UDim2.new(0,160,0,34),
        UDim2.new(1,-210,0.5,-17), Color3.new(0,0,0), 0, "BalRow")
    balRow.BackgroundTransparency = 1; balRow.ZIndex = 12

    -- Robux icon
    local rIco = Img(balRow, ICON.ROBUX,
        UDim2.new(0,22,0,22), UDim2.new(0,0,0.5,-11), C.GOLD, "RIco")
    rIco.ZIndex = 13

    local balLbl = Label(balRow, fmtN(pRobux),
        UDim2.new(1,-28,1,0), UDim2.new(0,28,0,0),
        15, Enum.Font.GothamBold, C.TEXT, Enum.TextXAlignment.Left, "BalLbl")
    balLbl.ZIndex = 13

    -- Close
    local cFrame, cReal = closeBtn(header, 13)

    -- Divider
    local div = Frame(modal, UDim2.new(1,-32,0,1),
        UDim2.new(0,16,0,60), C.BORDER, 0, "Div")
    div.ZIndex = 12

    -- ── ITEM CARD ───────────────────────────────────────────
    local card = Frame(modal, UDim2.new(1,-40,0,100),
        UDim2.new(0,20,0,74), C.SURFACE, 16, "Card")
    card.ZIndex = 12
    stroke(card, C.BORDER, 1)

    -- Item icon placeholder (coin stack)
    local itemIco = Img(card, ICON.COIN_STACK,
        UDim2.new(0,36,0,36), UDim2.new(0,12,0.5,-18), C.GOLD, "ItemIco")
    itemIco.ZIndex = 13

    local iNameLbl = Label(card, iName,
        UDim2.new(1,-64,0,28), UDim2.new(0,56,0,16),
        17, Enum.Font.GothamBold, C.TEXT, Enum.TextXAlignment.Left, "IName")
    iNameLbl.ZIndex = 13

    -- Price row in card
    local priceRow = Frame(card, UDim2.new(0,160,0,28),
        UDim2.new(0,56,0,52), Color3.new(0,0,0), 0, "PriceRow")
    priceRow.BackgroundTransparency = 1; priceRow.ZIndex = 12

    local pIco = Img(priceRow, ICON.ROBUX,
        UDim2.new(0,22,0,22), UDim2.new(0,0,0.5,-11), C.GOLD, "PIco")
    pIco.ZIndex = 13

    local priceLbl = Label(priceRow, fmtN(iPrice),
        UDim2.new(1,-28,1,0), UDim2.new(0,28,0,0),
        20, Enum.Font.GothamBold, C.TEXT, Enum.TextXAlignment.Left, "PriceLbl")
    priceLbl.ZIndex = 13

    -- ── BUY BUTTON ──────────────────────────────────────────
    local buyBtn = Btn(modal, "Buy",
        UDim2.new(1,-40,0,52), UDim2.new(0,20,0,188),
        C.ACCENT, C.TEXT, 14, "BuyBtn")
    buyBtn.TextSize = 17; buyBtn.ZIndex = 12; buyBtn.BackgroundTransparency = 1
    local bg2 = Instance.new("UIGradient"); bg2.Rotation = 0
    bg2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(90,125,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45,80,225)),
    }; bg2.Parent = buyBtn
    btnFX(buyBtn, C.ACCENT, C.ACCENT_H, C.ACCENT_P)
    ripple(buyBtn)

    -- ── ROBLOX PLUS BAR ─────────────────────────────────────
    local plusBar = Frame(modal, UDim2.new(1,-40,0,48),
        UDim2.new(0,20,0,252), C.PLUS_BG, 12, "PlusBar")
    plusBar.ZIndex = 12; plusBar.ClipsDescendants = true
    stroke(plusBar, C.BORDER, 1)
    shimmer(plusBar)

    local plusIco = Img(plusBar, ICON.ROBLOX_PLUS,
        UDim2.new(0,26,0,26), UDim2.new(0,10,0.5,-13), C.TEXT, "PlusIco")
    plusIco.ZIndex = 14

    Label(plusBar, "Get 10% off with Roblox Premium",
        UDim2.new(1,-160,1,0), UDim2.new(0,44,0,0),
        13, Enum.Font.GothamMedium, C.TEXT2,
        Enum.TextXAlignment.Left, "PlusTxt").ZIndex = 13

    local trialBtn = Btn(plusBar, "Get free trial",
        UDim2.new(0,108,0,30), UDim2.new(1,-118,0.5,-15),
        Color3.new(0,0,0), C.TEXT2, 8, "TrialBtn")
    trialBtn.BackgroundTransparency = 1; trialBtn.TextSize = 13; trialBtn.ZIndex = 14
    local uLine = Frame(trialBtn, UDim2.new(1,0,0,1),
        UDim2.new(0,0,1,-2), C.TEXT2, 0, "ULine")
    uLine.ZIndex = 15
    trialBtn.MouseEnter:Connect(function()
        tw(trialBtn, T_FAST, {TextColor3 = C.TEXT})
        tw(uLine, T_FAST, {BackgroundColor3 = C.TEXT})
    end)
    trialBtn.MouseLeave:Connect(function()
        tw(trialBtn, T_FAST, {TextColor3 = C.TEXT2})
        tw(uLine, T_FAST, {BackgroundColor3 = C.TEXT2})
    end)

    -- ── ANIMATE IN ──────────────────────────────────────────
    tw(ov, T_SMOOTH, {BackgroundTransparency = 0.4})
    tw(modal, T_SPRING, {Size = UDim2.new(0,440,0,316)}, function()
        tw(buyBtn, T_SMOOTH, {BackgroundTransparency = 0})
    end)

    local function close(cb)
        tw(ov, T_SMOOTH, {BackgroundTransparency = 1})
        tw(modal, T_SMOOTH, {Size = UDim2.new(0,440,0,0)}, function()
            gui:Destroy(); if cb then cb() end
        end)
    end

    cReal.MouseButton1Click:Connect(function() close(onClose) end)
    ov.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then close(onClose) end
    end)

    buyBtn.MouseButton1Click:Connect(function()
        close(function()
            -- Trừ robux giả lập
            STATE.robux = math.max(0, STATE.robux - STATE.itemPrice)
            task.wait(0.1)
            showPurchaseComplete()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  SETTINGS PANEL (Draggable)
-- ═══════════════════════════════════════════════════════════════
local function buildSettings()
    -- Destroy cũ nếu có
    if PlayerGui:FindFirstChild("Settings_Gui") then
        PlayerGui:FindFirstChild("Settings_Gui"):Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Settings_Gui"; gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 5; gui.Parent = PlayerGui

    -- ── MAIN PANEL ──────────────────────────────────────────
    local panel = Frame(gui, UDim2.new(0,320,0,0),
        UDim2.new(0.5,-160,0.5,-220), C.MODAL, 18, "Panel")
    panel.ZIndex = 20; panel.ClipsDescendants = false
    stroke(panel, C.BORDER, 1.5)

    -- Drop shadow
    local shadow = Frame(gui, UDim2.new(0,340,0,20),
        UDim2.new(0,0,0,0), Color3.new(0,0,0), 22, "Shadow")
    shadow.BackgroundTransparency = 0.65; shadow.ZIndex = 19
    shadow.Parent = gui

    -- ── TITLE BAR (drag handle) ──────────────────────────────
    local titleBar = Frame(panel, UDim2.new(1,0,0,52),
        UDim2.new(), C.PANEL_TITLE, 0, "TitleBar")
    titleBar.ZIndex = 21
    -- Top corners rounded only
    local tcorner = Instance.new("UICorner"); tcorner.CornerRadius = UDim.new(0,18); tcorner.Parent = titleBar
    -- Fix bottom corners straight
    local tfix = Frame(titleBar, UDim2.new(1,0,0,20),
        UDim2.new(0,0,1,-20), C.PANEL_TITLE, 0, "Fix")
    tfix.ZIndex = 21

    -- Settings icon + title
    local settIco = Img(titleBar, ICON.SETTINGS_COG,
        UDim2.new(0,24,0,24), UDim2.new(0,14,0.5,-12), C.TEXT, "SettIco")
    settIco.ZIndex = 22

    Label(titleBar, "Roblox UI Settings",
        UDim2.new(1,-90,1,0), UDim2.new(0,46,0,0),
        16, Enum.Font.GothamBold, C.TEXT, Enum.TextXAlignment.Left, "TitleLbl").ZIndex = 22

    -- Roblox logo top right
    local rLogoBtn = ImgBtn(titleBar, ICON.ROBLOX_LOGO,
        UDim2.new(0,28,0,28), UDim2.new(1,-42,0.5,-14),
        nil, C.TEXT, 6, "RLogoBtn")
    rLogoBtn.ZIndex = 22

    -- ── DRAG LOGIC ──────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = panel.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
                         i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            -- sync shadow
            shadow.Position = UDim2.new(
                panel.Position.X.Scale, panel.Position.X.Offset + 10,
                panel.Position.Y.Scale, panel.Position.Y.Offset + 10)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ── CONTENT ─────────────────────────────────────────────
    local content = Frame(panel, UDim2.new(1,0,1,-52),
        UDim2.new(0,0,0,52), Color3.new(0,0,0), 0, "Content")
    content.BackgroundTransparency = 1; content.ZIndex = 21

    -- helper: section row
    local function row(yOffset, labelTxt, zi)
        local r = Frame(content, UDim2.new(1,-24,0,36),
            UDim2.new(0,12,0,yOffset), Color3.new(0,0,0), 0, "Row_"..labelTxt)
        r.BackgroundTransparency = 1; r.ZIndex = zi or 21
        Label(r, labelTxt, UDim2.new(0,110,1,0), UDim2.new(),
            13, Enum.Font.GothamMedium, C.TEXT2,
            Enum.TextXAlignment.Left).ZIndex = (zi or 21) + 1
        return r
    end

    -- helper: input box
    local function inputBox(parent, defaultTxt, xPos, wide, zi)
        local bg = Frame(parent, UDim2.new(0,wide,0,30),
            UDim2.new(0,xPos,0.5,-15), C.SURFACE2, 8, "InputBG")
        bg.ZIndex = zi or 22
        stroke(bg, C.BORDER, 1)
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1,-16,1,0); tb.Position = UDim2.new(0,8,0,0)
        tb.Text = defaultTxt; tb.TextSize = 14
        tb.Font = Enum.Font.GothamMedium
        tb.TextColor3 = C.TEXT; tb.PlaceholderColor3 = C.TEXT3
        tb.BackgroundTransparency = 1; tb.BorderSizePixel = 0
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.ClearTextOnFocus = false; tb.ZIndex = (zi or 22) + 1; tb.Parent = bg
        bg.MouseEnter:Connect(function() tw(bg, T_FAST, {BackgroundColor3 = C.SURFACE}) end)
        bg.MouseLeave:Connect(function() tw(bg, T_FAST, {BackgroundColor3 = C.SURFACE2}) end)
        tb.Focused:Connect(function() tw(bg, T_FAST, {BackgroundColor3 = C.SURFACE})
            stroke(bg, C.ACCENT, 1.5) end)
        tb.FocusLost:Connect(function() stroke(bg, C.BORDER, 1.5) end)
        return tb, bg
    end

    -- ── ROW 1: Robux Balance ─────────────────────────────────
    local r1 = row(12, "Robux Balance", 21)
    -- Icon
    local rbxIco3 = Img(r1, ICON.ROBUX,
        UDim2.new(0,18,0,18), UDim2.new(0,112,0.5,-9), C.GOLD, "rIco")
    rbxIco3.ZIndex = 22
    local tbRobux, _ = inputBox(r1, fmtN(STATE.robux), 136, 136, 22)

    -- ── ROW 2: Item Name ─────────────────────────────────────
    local r2 = row(60, "Item Name", 21)
    local tbName, _ = inputBox(r2, STATE.itemName, 112, 160, 22)

    -- ── ROW 3: Item Price ────────────────────────────────────
    local r3 = row(108, "Item Price (R$)", 21)
    local pIco2 = Img(r3, ICON.ROBUX,
        UDim2.new(0,18,0,18), UDim2.new(0,112,0.5,-9), C.GOLD, "rIco2")
    pIco2.ZIndex = 22
    local tbPrice, _ = inputBox(r3, fmtN(STATE.itemPrice), 136, 136, 22)

    -- ── DIVIDER ──────────────────────────────────────────────
    local sepY = 156
    local sep = Frame(content, UDim2.new(1,-24,0,1),
        UDim2.new(0,12,0,sepY), C.BORDER, 0, "Sep")
    sep.ZIndex = 21

    -- ── APPLY BUTTON ─────────────────────────────────────────
    local applyBtn = Btn(content, "✓  Apply Settings",
        UDim2.new(1,-24,0,38), UDim2.new(0,12,0,sepY+10),
        C.SUCCESS, C.TEXT, 10, "ApplyBtn")
    applyBtn.TextSize = 14; applyBtn.ZIndex = 22
    local ag = Instance.new("UIGradient"); ag.Rotation = 0
    ag.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55,210,130)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30,155,85)),
    }; ag.Parent = applyBtn
    btnFX(applyBtn, C.SUCCESS, C.SUCCESS_D, Color3.fromRGB(20,120,65))
    ripple(applyBtn, Color3.new(1,1,1))

    applyBtn.MouseButton1Click:Connect(function()
        -- Parse robux
        local rRaw = (tbRobux.Text or ""):gsub(",","")
        local rVal = tonumber(rRaw)
        if rVal and rVal >= 0 then STATE.robux = math.floor(rVal) end

        -- Parse name
        local nm = tbName.Text or ""
        if nm ~= "" then STATE.itemName = nm end

        -- Parse price
        local pRaw = (tbPrice.Text or ""):gsub(",","")
        local pVal = tonumber(pRaw)
        if pVal and pVal >= 0 then STATE.itemPrice = math.floor(pVal) end

        -- Update display fields
        tbRobux.Text  = fmtN(STATE.robux)
        tbName.Text   = STATE.itemName
        tbPrice.Text  = fmtN(STATE.itemPrice)

        -- Flash green feedback
        tw(applyBtn, T_FAST, {BackgroundColor3 = Color3.fromRGB(20,220,100)}, function()
            tw(applyBtn, T_SMOOTH, {BackgroundColor3 = C.SUCCESS})
        end)
    end)

    -- ── ROW: BUY UI BUTTON ───────────────────────────────────
    local buyUIBtn = Btn(content, "",
        UDim2.new(1,-24,0,44), UDim2.new(0,12,0,sepY+60),
        C.ACCENT, C.TEXT, 12, "BuyUIBtn")
    buyUIBtn.ZIndex = 22
    local bBg = Instance.new("UIGradient"); bBg.Rotation = 0
    bBg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(90,125,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45,80,225)),
    }; bBg.Parent = buyUIBtn
    -- Icon + label inside
    local bIco = Img(buyUIBtn, ICON.SHOP,
        UDim2.new(0,22,0,22), UDim2.new(0,14,0.5,-11), C.TEXT, "BIco")
    bIco.ZIndex = 23
    Label(buyUIBtn, "Open  Buy Item  UI",
        UDim2.new(1,-48,1,0), UDim2.new(0,44,0,0),
        14, Enum.Font.GothamBold, C.TEXT,
        Enum.TextXAlignment.Left).ZIndex = 23
    btnFX(buyUIBtn, C.ACCENT, C.ACCENT_H, C.ACCENT_P)
    ripple(buyUIBtn)

    -- ── ROW: PURCHASE COMPLETE BUTTON ────────────────────────
    local pcBtn = Btn(content, "",
        UDim2.new(1,-24,0,44), UDim2.new(0,12,0,sepY+116),
        Color3.fromRGB(38,150,95), C.TEXT, 12, "PCBtn")
    pcBtn.ZIndex = 22
    local pcBg = Instance.new("UIGradient"); pcBg.Rotation = 0
    pcBg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55,210,130)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30,155,85)),
    }; pcBg.Parent = pcBtn
    local pcIco = Img(pcBtn, ICON.CHECKMARK,
        UDim2.new(0,22,0,22), UDim2.new(0,14,0.5,-11), C.TEXT, "PCIco")
    pcIco.ZIndex = 23
    Label(pcBtn, "Open  Purchase Complete  UI",
        UDim2.new(1,-48,1,0), UDim2.new(0,44,0,0),
        14, Enum.Font.GothamBold, C.TEXT,
        Enum.TextXAlignment.Left).ZIndex = 23
    btnFX(pcBtn,
        Color3.fromRGB(38,150,95),
        Color3.fromRGB(28,120,75),
        Color3.fromRGB(20,90,55))
    ripple(pcBtn)

    -- ── TOTAL HEIGHT ─────────────────────────────────────────
    local totalH = 52 + sepY + 116 + 44 + 16
    -- Animate panel open
    panel.Size = UDim2.new(0,320,0,0)
    tw(panel, T_SPRING, {Size = UDim2.new(0,320,0,totalH)}, function()
        shadow.Size = UDim2.new(0,340,0,totalH+8)
        shadow.Position = UDim2.new(
            panel.Position.X.Scale, panel.Position.X.Offset+10,
            panel.Position.Y.Scale, panel.Position.Y.Offset+10)
    end)

    -- ── BUTTON CLICKS ─────────────────────────────────────────
    buyUIBtn.MouseButton1Click:Connect(function()
        showBuyUI()
    end)
    pcBtn.MouseButton1Click:Connect(function()
        showPurchaseComplete()
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  ENTRY POINT — chạy ngay khi paste vào executor
-- ═══════════════════════════════════════════════════════════════
buildSettings()

print([[
╔══════════════════════════════════════╗
║  ✅ Roblox 2026 Buy UI Loaded!       ║
║  Settings panel đã mở tự động.      ║
║  Đổi thông số → Apply → bấm nút.    ║
╚══════════════════════════════════════╝
]])
