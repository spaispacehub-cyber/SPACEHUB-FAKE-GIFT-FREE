--[[
╔══════════════════════════════════════════════════════════════╗
║   ROBLOX 2026 BUY UI — ANIMATION FIX                        ║
║   Buy UI  : dim bg + scale 92→100% in 0.18s                 ║
║   Purchase : fast pop in + clean check icon                  ║
║   Settings : draggable, đổi robux/name/price                 ║
╚══════════════════════════════════════════════════════════════╝
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ── Icons (Roblox 2026 official asset IDs) ────────────────────
local ICON = {
    ROBUX        = "rbxassetid://14869809956",
    ROBLOX_LOGO  = "rbxassetid://10723602295",
    ROBLOX_PLUS  = "rbxassetid://11803541855",
    SHOP         = "rbxassetid://11803558150",
    SETTINGS_COG = "rbxassetid://104919049969988",
    CHECKMARK    = "rbxassetid://9894440655",
    COIN_STACK   = "rbxassetid://11803545855",
}

-- ── Palette ───────────────────────────────────────────────────
local C = {
    BG      = Color3.fromRGB(25,  25,  30),
    MODAL   = Color3.fromRGB(30,  30,  38),
    SURFACE = Color3.fromRGB(40,  40,  50),
    SURF2   = Color3.fromRGB(48,  48,  60),
    ACCENT  = Color3.fromRGB(51,  95, 255),   -- #335FFF
    ACC_H   = Color3.fromRGB(35,  70, 220),
    ACC_P   = Color3.fromRGB(22,  52, 185),
    SUCCESS = Color3.fromRGB(45, 195, 120),
    SUCC_D  = Color3.fromRGB(30, 140,  80),
    TEXT    = Color3.fromRGB(242,242,243),
    TEXT2   = Color3.fromRGB(160,160,180),
    TEXT3   = Color3.fromRGB(110,110,135),
    BORDER  = Color3.fromRGB(55,  55,  70),
    GOLD    = Color3.fromRGB(255,200,  55),
    OVERLAY = Color3.fromRGB(0,    0,   0),
    PLUS_BG = Color3.fromRGB(35,  35,  48),
}

-- ── Tween helpers ─────────────────────────────────────────────
local TS = TweenService
local function ti(t,s,d) return TweenInfo.new(t,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out) end

-- KEY animation constants (match Roblox 2026 feel)
local T_MODAL_IN  = ti(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)  -- popup scale-in
local T_MODAL_OUT = ti(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In)   -- popup scale-out
local T_DIM_IN    = ti(0.22, Enum.EasingStyle.Linear)                            -- bg dim
local T_DIM_OUT   = ti(0.18, Enum.EasingStyle.Linear)
local T_PC_IN     = ti(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)  -- purchase complete pop
local T_CHECK     = ti(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)  -- check appear
local T_FAST      = ti(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local T_BTN       = ti(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local T_SPRING    = ti(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)  -- settings open

local function tw(obj,info,props,cb)
    local t = TS:Create(obj,info,props)
    if cb then t.Completed:Connect(cb) end
    t:Play(); return t
end

-- ── State ─────────────────────────────────────────────────────
local S = { robux=3098112, itemName="Donation", itemPrice=10000 }

-- ═══════════════════════════════════════════════════════════════
-- WIDGET BUILDERS
-- ═══════════════════════════════════════════════════════════════
local function corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=p;return c end
local function stroke(p,col,th) local s=Instance.new("UIStroke");s.Color=col or C.BORDER;s.Thickness=th or 1.5;s.Parent=p;return s end

local function Fr(parent,sz,pos,bg,r,name)
    local f=Instance.new("Frame");f.Name=name or "F";f.Size=sz;f.Position=pos or UDim2.new()
    f.BackgroundColor3=bg or C.MODAL;f.BorderSizePixel=0;f.Parent=parent
    if r then corner(f,r) end;return f
end
local function Lb(parent,txt,sz,pos,fs,font,col,ax,name)
    local l=Instance.new("TextLabel");l.Name=name or "L";l.Size=sz;l.Position=pos or UDim2.new()
    l.Text=txt;l.TextSize=fs or 15;l.Font=font or Enum.Font.GothamMedium
    l.TextColor3=col or C.TEXT;l.BackgroundTransparency=1;l.BorderSizePixel=0
    l.TextXAlignment=ax or Enum.TextXAlignment.Left;l.TextTruncate=Enum.TextTruncate.AtEnd
    l.Parent=parent;return l
end
local function Im(parent,id,sz,pos,col,name)
    local i=Instance.new("ImageLabel");i.Name=name or "I";i.Size=sz;i.Position=pos or UDim2.new()
    i.Image=id or "";i.ImageColor3=col or Color3.new(1,1,1)
    i.BackgroundTransparency=1;i.BorderSizePixel=0;i.ScaleType=Enum.ScaleType.Fit
    i.Parent=parent;return i
end
local function Bt(parent,txt,sz,pos,bg,tc,r,name)
    local b=Instance.new("TextButton");b.Name=name or "B";b.Size=sz;b.Position=pos or UDim2.new()
    b.Text=txt;b.TextSize=15;b.Font=Enum.Font.GothamBold
    b.TextColor3=tc or C.TEXT;b.BackgroundColor3=bg or C.ACCENT
    b.BorderSizePixel=0;b.AutoButtonColor=false;b.Parent=parent
    if r then corner(b,r) end;return b
end

local function fmtN(n) return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","") end

-- Subtle horizontal flash on button (Roblox 2026 press feel)
local function btnFlash(btn)
    btn.ClipsDescendants = true
    local flash = Fr(btn, UDim2.new(0,40,1,0), UDim2.new(-0.15,0,0,0), Color3.new(1,1,1), 0, "Flash")
    flash.BackgroundTransparency = 1; flash.ZIndex = btn.ZIndex + 2
    local g = Instance.new("UIGradient"); g.Rotation = 0
    g.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.5,0.55),
        NumberSequenceKeypoint.new(1,1),
    }; g.Parent = flash
    tw(flash, ti(0.38,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
        {Position=UDim2.new(1.15,0,0,0), BackgroundTransparency=0.6}, function()
        flash:Destroy()
    end)
end

-- Press state + flash
local function btnFX(b, nc, hc, pc)
    b.MouseEnter:Connect(function() tw(b,T_FAST,{BackgroundColor3=hc or nc}) end)
    b.MouseLeave:Connect(function() tw(b,T_FAST,{BackgroundColor3=nc}) end)
    b.MouseButton1Down:Connect(function()
        tw(b,T_BTN,{BackgroundColor3=pc or hc or nc})
        -- subtle scale-down feel via size
        tw(b,T_BTN,{Size=UDim2.new(b.Size.X.Scale,b.Size.X.Offset-2,b.Size.Y.Scale,b.Size.Y.Offset-2)})
    end)
    b.MouseButton1Up:Connect(function()
        tw(b,T_FAST,{BackgroundColor3=nc})
        tw(b,T_FAST,{Size=UDim2.new(b.Size.X.Scale,b.Size.X.Offset+2,b.Size.Y.Scale,b.Size.Y.Offset+2)})
    end)
    b.MouseButton1Click:Connect(function() btnFlash(b) end)
end

-- Shimmer on Roblox Plus bar
local function shimmer(parent)
    parent.ClipsDescendants = true
    local s = Fr(parent,UDim2.new(0.32,0,1,0),UDim2.new(-0.35,0,0,0),Color3.new(1,1,1),0,"Shim")
    s.BackgroundTransparency=0.80;s.ZIndex=(parent.ZIndex or 1)+1
    local g=Instance.new("UIGradient");g.Rotation=15
    g.Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.5,0.65),
        NumberSequenceKeypoint.new(1,1),
    };g.Parent=s
    local function loop()
        s.Position=UDim2.new(-0.35,0,0,0)
        tw(s,ti(1.9,Enum.EasingStyle.Linear),{Position=UDim2.new(1.1,0,0,0)},function()
            task.wait(2.6);loop()
        end)
    end;loop()
end

-- Dim overlay
local function makeOverlay(gui,zi)
    local o=Fr(gui,UDim2.new(1,0,1,0),UDim2.new(),C.OVERLAY,0,"Overlay")
    o.BackgroundTransparency=1;o.ZIndex=zi or 10;o.Active=true;return o
end

-- Roblox-style close X (frame + transparent button on top)
local function makeClose(parent,zi)
    local f=Fr(parent,UDim2.new(0,32,0,32),UDim2.new(1,-44,0,12),Color3.fromRGB(50,50,65),999,"CloseF")
    f.ZIndex=zi or 12
    Im(f,nil,UDim2.new(0,14,0,14),UDim2.new(0.5,-7,0.5,-7),C.TEXT2,"XI").ZIndex=(zi or 12)+1
    -- Draw X manually since asset may not load
    local xl=Lb(f,"✕",UDim2.new(1,0,1,0),UDim2.new(),17,Enum.Font.GothamBold,C.TEXT2,Enum.TextXAlignment.Center,"XT")
    xl.ZIndex=(zi or 12)+1
    local btn=Instance.new("TextButton");btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1;btn.Text="";btn.ZIndex=(zi or 12)+2;btn.Parent=f
    f.MouseEnter:Connect(function() tw(f,T_FAST,{BackgroundColor3=Color3.fromRGB(80,55,80)})
        tw(xl,T_FAST,{TextColor3=C.TEXT}) end)
    f.MouseLeave:Connect(function() tw(f,T_FAST,{BackgroundColor3=Color3.fromRGB(50,50,65)})
        tw(xl,T_FAST,{TextColor3=C.TEXT2}) end)
    return f,btn
end

-- ═══════════════════════════════════════════════════════════════
-- PURCHASE COMPLETE UI
-- Animation: fast pop-in (0.18s) + check appears cleanly
-- ═══════════════════════════════════════════════════════════════
local function showPurchaseComplete(existingOv, existingGui, onClose)
    -- Reuse overlay if passed (chuyển từ Buy UI)
    local gui, ov
    if existingGui then
        gui = existingGui; ov = existingOv
    else
        gui = Instance.new("ScreenGui")
        gui.Name="PC_Gui";gui.ResetOnSpawn=false
        gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=PlayerGui
        ov = makeOverlay(gui,10)
        -- dim bg immediately (already dimmed if coming from Buy)
        tw(ov,T_DIM_IN,{BackgroundTransparency=0.4})
    end

    -- Modal — start at 93% scale, animate to 100%
    local W, H = 440, 272
    local modal = Fr(gui, UDim2.new(0,W,0,H), UDim2.new(0.5,0,0.5,0), C.MODAL, 20, "PCModal")
    modal.AnchorPoint = Vector2.new(0.5,0.5); modal.ZIndex = 11
    stroke(modal, C.BORDER, 1.5)

    -- Scale wrapper trick: use Size to simulate scale from 93%→100%
    local startW = math.floor(W * 0.93)
    local startH = math.floor(H * 0.93)
    modal.Size = UDim2.new(0, startW, 0, startH)
    modal.BackgroundTransparency = 0.3

    -- Title
    Lb(modal,"Purchase completed",UDim2.new(1,-56,0,52),UDim2.new(0,20,0,0),
        20,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left,"Title").ZIndex=12

    -- Close X
    local _,cBtn = makeClose(modal,12)

    -- Check ring — visible immediately but subtle
    local ringSize = 72
    local ring = Fr(modal,UDim2.new(0,ringSize,0,ringSize),
        UDim2.new(0.5,-(ringSize/2),0,60),C.MODAL,999,"Ring")
    ring.ZIndex=12; stroke(ring,C.SUCCESS,2.5)

    -- Tick inside ring (text-based, reliable across all games)
    local tick = Lb(ring,"✓",UDim2.new(1,0,1,0),UDim2.new(),
        30,Enum.Font.GothamBold,C.SUCCESS,Enum.TextXAlignment.Center,"Tick")
    tick.ZIndex=13; tick.TextTransparency=1

    -- Sub text
    local sub = Lb(modal,"You have successfully bought",
        UDim2.new(1,-40,0,24),UDim2.new(0,20,0,148),
        14,Enum.Font.GothamMedium,C.TEXT2,Enum.TextXAlignment.Center,"Sub")
    sub.ZIndex=12; sub.TextTransparency=1

    -- OK button
    local okBtn = Bt(modal,"OK",UDim2.new(1,-40,0,50),UDim2.new(0,20,1,-66),
        C.ACCENT,C.TEXT,12,"OKBtn")
    okBtn.TextSize=16;okBtn.ZIndex=12;okBtn.BackgroundTransparency=0
    -- gradient
    local og=Instance.new("UIGradient");og.Rotation=0
    og.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(85,120,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(42,78,225)),
    };og.Parent=okBtn
    btnFX(okBtn,C.ACCENT,C.ACC_H,C.ACC_P)

    -- ── ANIMATE IN ──────────────────────────────────────────
    -- 1) Scale pop: 93%→100% in 0.18s
    tw(modal, T_PC_IN, {
        Size = UDim2.new(0,W,0,H),
        BackgroundTransparency = 0
    }, function()
        -- 2) Check tick fades in cleanly
        tw(tick, T_CHECK, {TextTransparency=0})
        -- 3) Sub text right after
        task.wait(0.06)
        tw(sub, T_CHECK, {TextTransparency=0})
    end)

    -- ── CLOSE ───────────────────────────────────────────────
    local function close()
        tw(ov, T_DIM_OUT, {BackgroundTransparency=1})
        tw(modal, T_MODAL_OUT, {
            Size = UDim2.new(0, math.floor(W*0.93), 0, math.floor(H*0.93)),
            BackgroundTransparency = 0.4
        }, function() gui:Destroy(); if onClose then onClose() end end)
    end
    cBtn.MouseButton1Click:Connect(close)
    okBtn.MouseButton1Click:Connect(close)
end

-- ═══════════════════════════════════════════════════════════════
-- BUY ITEM UI
-- Animation: dim bg (0.22s) + modal scale 92%→100% (0.20s)
-- Buy press: subtle press state + horizontal flash
-- ═══════════════════════════════════════════════════════════════
local function showBuyUI(onClose)
    local iName  = S.itemName
    local iPrice = S.itemPrice
    local pRobux = S.robux

    local gui = Instance.new("ScreenGui")
    gui.Name="Buy_Gui";gui.ResetOnSpawn=false
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=PlayerGui

    local ov = makeOverlay(gui,10)

    local W, H = 440, 316
    -- Modal starts at 92% size
    local sW = math.floor(W*0.92)
    local sH = math.floor(H*0.92)

    local modal = Fr(gui,UDim2.new(0,sW,0,sH),UDim2.new(0.5,0,0.5,0),C.MODAL,22,"BuyModal")
    modal.AnchorPoint=Vector2.new(0.5,0.5);modal.ZIndex=11
    modal.BackgroundTransparency=0.35
    modal.ClipsDescendants=true
    stroke(modal,C.BORDER,1.5)

    -- ── DIM BG ── starts immediately
    tw(ov, T_DIM_IN, {BackgroundTransparency=0.45})

    -- ── MODAL SCALE IN ── 0.20s quart out
    tw(modal, T_MODAL_IN, {
        Size=UDim2.new(0,W,0,H),
        BackgroundTransparency=0
    })

    -- ── HEADER ──────────────────────────────────────────────
    local hdr = Fr(modal,UDim2.new(1,0,0,58),UDim2.new(),C.MODAL,0,"Hdr")
    hdr.BackgroundTransparency=1;hdr.ZIndex=12

    Im(hdr,ICON.SHOP,UDim2.new(0,24,0,24),UDim2.new(0,16,0.5,-12),C.TEXT,"ShopI").ZIndex=13
    Lb(hdr,"Buy item",UDim2.new(0,130,0,34),UDim2.new(0,48,0.5,-17),
        20,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left).ZIndex=13

    -- Balance (right)
    local balRow=Fr(hdr,UDim2.new(0,155,0,32),UDim2.new(1,-205,0.5,-16),C.MODAL,0,"Bal")
    balRow.BackgroundTransparency=1;balRow.ZIndex=12
    Im(balRow,ICON.ROBUX,UDim2.new(0,20,0,20),UDim2.new(0,0,0.5,-10),C.GOLD,"BI").ZIndex=13
    Lb(balRow,fmtN(pRobux),UDim2.new(1,-26,1,0),UDim2.new(0,26,0,0),
        15,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left,"BLbl").ZIndex=13

    local _,cBtn = makeClose(hdr,13)

    -- Divider
    Fr(modal,UDim2.new(1,-32,0,1),UDim2.new(0,16,0,58),C.BORDER,0,"Div").ZIndex=12

    -- ── ITEM CARD ───────────────────────────────────────────
    local card=Fr(modal,UDim2.new(1,-40,0,96),UDim2.new(0,20,0,72),C.SURFACE,14,"Card")
    card.ZIndex=12;stroke(card,C.BORDER,1)
    Im(card,ICON.COIN_STACK,UDim2.new(0,34,0,34),UDim2.new(0,12,0.5,-17),C.GOLD,"CI").ZIndex=13
    Lb(card,iName,UDim2.new(1,-62,0,26),UDim2.new(0,52,0,14),
        17,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left).ZIndex=13

    local pr=Fr(card,UDim2.new(0,160,0,26),UDim2.new(0,52,0,50),C.SURFACE,0,"PR")
    pr.BackgroundTransparency=1;pr.ZIndex=12
    Im(pr,ICON.ROBUX,UDim2.new(0,20,0,20),UDim2.new(0,0,0.5,-10),C.GOLD,"RI").ZIndex=13
    Lb(pr,fmtN(iPrice),UDim2.new(1,-26,1,0),UDim2.new(0,26,0,0),
        20,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left,"PL").ZIndex=13

    -- ── BUY BUTTON ──────────────────────────────────────────
    local buyBtn=Bt(modal,"Buy",UDim2.new(1,-40,0,52),UDim2.new(0,20,0,184),
        C.ACCENT,C.TEXT,12,"BuyBtn")
    buyBtn.TextSize=17;buyBtn.ZIndex=12
    local bg2=Instance.new("UIGradient");bg2.Rotation=0
    bg2.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(90,125,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(42,78,228)),
    };bg2.Parent=buyBtn
    btnFX(buyBtn,C.ACCENT,C.ACC_H,C.ACC_P)

    -- ── ROBLOX PLUS BAR ─────────────────────────────────────
    local plus=Fr(modal,UDim2.new(1,-40,0,46),UDim2.new(0,20,0,250),C.PLUS_BG,12,"Plus")
    plus.ZIndex=12;stroke(plus,C.BORDER,1)
    shimmer(plus)
    Im(plus,ICON.ROBLOX_PLUS,UDim2.new(0,24,0,24),UDim2.new(0,10,0.5,-12),C.TEXT,"PlusI").ZIndex=14
    Lb(plus,"Get 10% off with Roblox Premium",UDim2.new(1,-158,1,0),UDim2.new(0,42,0,0),
        12,Enum.Font.GothamMedium,C.TEXT2,Enum.TextXAlignment.Left).ZIndex=13
    local tBtn=Bt(plus,"Get free trial",UDim2.new(0,106,0,28),UDim2.new(1,-116,0.5,-14),
        C.MODAL,C.TEXT2,8,"TBtn")
    tBtn.BackgroundTransparency=1;tBtn.TextSize=12;tBtn.ZIndex=14
    local uLine=Fr(tBtn,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-2),C.TEXT2,0,"UL")
    uLine.ZIndex=15
    tBtn.MouseEnter:Connect(function()tw(tBtn,T_FAST,{TextColor3=C.TEXT});tw(uLine,T_FAST,{BackgroundColor3=C.TEXT})end)
    tBtn.MouseLeave:Connect(function()tw(tBtn,T_FAST,{TextColor3=C.TEXT2});tw(uLine,T_FAST,{BackgroundColor3=C.TEXT2})end)

    -- ── CLOSE / BUY ──────────────────────────────────────────
    local function closeModal(cb)
        tw(ov,T_DIM_OUT,{BackgroundTransparency=1})
        tw(modal,T_MODAL_OUT,{
            Size=UDim2.new(0,sW,0,sH),
            BackgroundTransparency=0.4
        }, function() gui:Destroy(); if cb then cb() end end)
    end

    cBtn.MouseButton1Click:Connect(function() closeModal(onClose) end)
    ov.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then closeModal(onClose) end
    end)

    buyBtn.MouseButton1Click:Connect(function()
        -- 1) Press feedback (already handled by btnFX + flash)
        buyBtn.Active = false  -- prevent double-click
        -- 2) Brief pause (Roblox has ~0.3s before transitioning)
        task.wait(0.28)
        -- 3) Close Buy UI, then open Purchase Complete reusing same overlay
        tw(modal, T_MODAL_OUT, {
            Size=UDim2.new(0,sW,0,sH),
            BackgroundTransparency=0.5
        }, function()
            modal:Destroy()
            S.robux = math.max(0, S.robux - S.itemPrice)
            -- Show Purchase Complete in same gui/overlay (no re-dim)
            showPurchaseComplete(ov, gui)
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SETTINGS PANEL (Draggable, executor-compatible)
-- ═══════════════════════════════════════════════════════════════
local function buildSettings()
    if PlayerGui:FindFirstChild("Settings_Gui") then
        PlayerGui:FindFirstChild("Settings_Gui"):Destroy()
    end

    local gui=Instance.new("ScreenGui")
    gui.Name="Settings_Gui";gui.ResetOnSpawn=false
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder=5;gui.Parent=PlayerGui

    -- Drop shadow
    local shadow=Fr(gui,UDim2.new(0,336,0,20),UDim2.new(0.5,-158,0.5,-214),
        Color3.new(0,0,0),20,"Shadow")
    shadow.BackgroundTransparency=0.62;shadow.ZIndex=19

    -- Panel
    local panel=Fr(gui,UDim2.new(0,320,0,0),UDim2.new(0.5,-160,0.5,-210),
        C.MODAL,18,"Panel")
    panel.ZIndex=20;stroke(panel,C.BORDER,1.5)

    -- Title bar
    local tbar=Fr(panel,UDim2.new(1,0,0,50),UDim2.new(),Color3.fromRGB(40,40,52),0,"TBar")
    tbar.ZIndex=21;corner(tbar,18)
    -- flatten bottom of title bar
    Fr(tbar,UDim2.new(1,0,0,18),UDim2.new(0,0,1,-18),Color3.fromRGB(40,40,52),0,"Flat").ZIndex=21

    Im(tbar,ICON.SETTINGS_COG,UDim2.new(0,22,0,22),UDim2.new(0,14,0.5,-11),C.TEXT,"GearI").ZIndex=22
    Lb(tbar,"Roblox UI Settings",UDim2.new(1,-90,1,0),UDim2.new(0,44,0,0),
        15,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left).ZIndex=22
    Im(tbar,ICON.ROBLOX_LOGO,UDim2.new(0,26,0,26),UDim2.new(1,-40,0.5,-13),C.TEXT,"RLogo").ZIndex=22

    -- Drag
    local drag,ds,sp=false,nil,nil
    tbar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then
            drag=true;ds=i.Position;sp=panel.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or
                     i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            panel.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
            shadow.Position=UDim2.new(panel.Position.X.Scale,panel.Position.X.Offset+8,
                panel.Position.Y.Scale,panel.Position.Y.Offset+8)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)

    -- Content
    local cont=Fr(panel,UDim2.new(1,0,1,-50),UDim2.new(0,0,0,50),C.MODAL,0,"Cont")
    cont.BackgroundTransparency=1;cont.ZIndex=21;corner(cont,18)

    -- Input row helper
    local function inputRow(y, labelTxt, defaultVal)
        local rF=Fr(cont,UDim2.new(1,-24,0,38),UDim2.new(0,12,0,y),C.MODAL,0,"Row")
        rF.BackgroundTransparency=1;rF.ZIndex=21
        Lb(rF,labelTxt,UDim2.new(0,112,1,0),UDim2.new(),
            13,Enum.Font.GothamMedium,C.TEXT2,Enum.TextXAlignment.Left).ZIndex=22
        -- input bg
        local ibg=Fr(rF,UDim2.new(0,168,0,32),UDim2.new(0,114,0.5,-16),C.SURF2,8,"IBg")
        ibg.ZIndex=22;stroke(ibg,C.BORDER,1)
        local tb=Instance.new("TextBox");tb.Size=UDim2.new(1,-16,1,0);tb.Position=UDim2.new(0,8,0,0)
        tb.Text=defaultVal;tb.TextSize=14;tb.Font=Enum.Font.GothamMedium
        tb.TextColor3=C.TEXT;tb.PlaceholderColor3=C.TEXT3
        tb.BackgroundTransparency=1;tb.BorderSizePixel=0
        tb.TextXAlignment=Enum.TextXAlignment.Left;tb.ClearTextOnFocus=false
        tb.ZIndex=23;tb.Parent=ibg
        local sk=stroke(ibg,C.BORDER,1)
        tb.Focused:Connect(function() sk.Color=C.ACCENT;sk.Thickness=2 end)
        tb.FocusLost:Connect(function() sk.Color=C.BORDER;sk.Thickness=1 end)
        ibg.MouseEnter:Connect(function() tw(ibg,T_FAST,{BackgroundColor3=C.SURFACE}) end)
        ibg.MouseLeave:Connect(function() tw(ibg,T_FAST,{BackgroundColor3=C.SURF2}) end)
        return tb
    end

    local tbRobux = inputRow(10,  "Robux Balance", fmtN(S.robux))
    local tbName  = inputRow(60,  "Item Name",     S.itemName)
    local tbPrice = inputRow(110, "Item Price (R$)",fmtN(S.itemPrice))

    -- Sep
    Fr(cont,UDim2.new(1,-24,0,1),UDim2.new(0,12,0,158),C.BORDER,0,"Sep").ZIndex=21

    -- Apply
    local aBtn=Bt(cont,"✓  Apply Settings",UDim2.new(1,-24,0,38),UDim2.new(0,12,0,168),
        C.SUCCESS,C.TEXT,10,"ABtn");aBtn.TextSize=14;aBtn.ZIndex=22
    local ag=Instance.new("UIGradient");ag.Rotation=0
    ag.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(55,210,130)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(30,155,85)),
    };ag.Parent=aBtn
    btnFX(aBtn,C.SUCCESS,C.SUCC_D,Color3.fromRGB(20,120,65))

    aBtn.MouseButton1Click:Connect(function()
        local rv=tonumber((tbRobux.Text or ""):gsub(",",""))
        if rv and rv>=0 then S.robux=math.floor(rv) end
        local nm=tbName.Text or ""; if nm~="" then S.itemName=nm end
        local pv=tonumber((tbPrice.Text or ""):gsub(",",""))
        if pv and pv>=0 then S.itemPrice=math.floor(pv) end
        tbRobux.Text=fmtN(S.robux);tbName.Text=S.itemName;tbPrice.Text=fmtN(S.itemPrice)
        tw(aBtn,T_FAST,{BackgroundColor3=Color3.fromRGB(20,230,105)},function()
            tw(aBtn,ti(0.4),{BackgroundColor3=C.SUCCESS}) end)
    end)

    -- Sep2
    Fr(cont,UDim2.new(1,-24,0,1),UDim2.new(0,12,0,216),C.BORDER,0,"Sep2").ZIndex=21

    -- Buy UI Button
    local bBtn=Bt(cont,"",UDim2.new(1,-24,0,44),UDim2.new(0,12,0,226),C.ACCENT,C.TEXT,12,"BBtn")
    bBtn.ZIndex=22
    local bbg=Instance.new("UIGradient");bbg.Rotation=0
    bbg.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(90,125,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(42,78,225)),
    };bbg.Parent=bBtn
    Im(bBtn,ICON.SHOP,UDim2.new(0,22,0,22),UDim2.new(0,12,0.5,-11),C.TEXT,"BBI").ZIndex=23
    Lb(bBtn,"Open  Buy Item  UI",UDim2.new(1,-46,1,0),UDim2.new(0,42,0,0),
        14,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left).ZIndex=23
    btnFX(bBtn,C.ACCENT,C.ACC_H,C.ACC_P);btnFlash(bBtn)

    -- Purchase Complete Button
    local pcBtnColor = Color3.fromRGB(38,150,95)
    local pBtn=Bt(cont,"",UDim2.new(1,-24,0,44),UDim2.new(0,12,0,282),pcBtnColor,C.TEXT,12,"PBtn")
    pBtn.ZIndex=22
    local pbg=Instance.new("UIGradient");pbg.Rotation=0
    pbg.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(55,210,130)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(30,155,85)),
    };pbg.Parent=pBtn
    Im(pBtn,ICON.CHECKMARK,UDim2.new(0,22,0,22),UDim2.new(0,12,0.5,-11),C.TEXT,"PCI").ZIndex=23
    Lb(pBtn,"Open  Purchase Complete  UI",UDim2.new(1,-46,1,0),UDim2.new(0,42,0,0),
        14,Enum.Font.GothamBold,C.TEXT,Enum.TextXAlignment.Left).ZIndex=23
    btnFX(pBtn,pcBtnColor,C.SUCC_D,Color3.fromRGB(20,110,60))

    -- Panel open animation (spring, settings only)
    local totalH = 50 + 10 + 38 + 50 + 38 + 44 + 44 + 24 -- ~340
    panel.Size=UDim2.new(0,320,0,0)
    tw(panel,T_SPRING,{Size=UDim2.new(0,320,0,totalH)},function()
        shadow.Size=UDim2.new(0,336,0,totalH+8)
        shadow.Position=UDim2.new(panel.Position.X.Scale,panel.Position.X.Offset+8,
            panel.Position.Y.Scale,panel.Position.Y.Offset+8)
    end)

    bBtn.MouseButton1Click:Connect(function() showBuyUI() end)
    pBtn.MouseButton1Click:Connect(function() showPurchaseComplete() end)
end

-- ═══════════════════════════════════════════════════════════════
buildSettings()
print("✅ [BuyUI 2026] Loaded — Settings panel open!")
