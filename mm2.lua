-- ============================================================
-- DARKFORGE-X MM2 ULTIMATE HUB v3.1 (Có Auto Shoot)
-- Shadow-Core Mode | Ethical Testing Only
-- ============================================================

-- ========== KIỂM TRA GAME ==========
if game.PlaceId ~= 142823291 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚠️ Sai Game",
        Text = "Vui lòng vào Murder Mystery 2!",
        Duration = 5
    })
    return
end

-- ========== LOAD RAYFIELD UI ==========
local Rayfield
local loadRayfield = syn and syn.request or http and http.request or request
if loadRayfield then
    local response = loadRayfield({
        Url = "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
        Method = "GET"
    })
    Rayfield = loadstring(response.Body)()
else
    Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
end

if not Rayfield then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Lỗi",
        Text = "Không thể load Rayfield!",
        Duration = 5
    })
    return
end
-- ========== BIẾN TOÀN CỤC ==========
_G.DarkForge = _G.DarkForge or {
    Walkspeed = 16,
    Jumppower = 50,
    AutoFarm = false,
    ESP = false,
    Aimbot = false,
    SilentAim = false,
    GodMode = false,
    Noclip = false,
    Fly = false,
    InfiniteJump = false,
    SpeedHack = false,
    AntiAFK = false,
    TeleportToCoins = false,
    AutoCollect = false,
    HitboxExtender = false,
    HitboxSize = 5,
    SpamKnife = false,
    RevealRoles = false,
    AutoKill = false,
    TeleportToMurderer = false,
    AutoGun = false,
    ServerHop = false,
    Rejoin = false,
    AutoShoot = false,          -- 🆕 Auto Shoot
    ShootDelay = 0.5,           -- 🆕 Delay giữa các phát bắn
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

-- ========== HÀM TIỆN ÍCH ==========
local function GetAlivePlayers()
    local alive = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            table.insert(alive, v)
        end
    end
    return alive
end

local function GetNearestPlayer()
    local nearest, dist = nil, math.huge
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    for _, v in pairs(GetAlivePlayers()) do
        local targetRoot = v.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local d = (root.Position - targetRoot.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
            end
        end
    end
    return nearest
end

local function GetCoins()
    local coins = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Coin" then
            table.insert(coins, v)
        end
    end
    return coins
end

local function TeleportTo(position)
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

local function Notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = nil
    })
end

-- Hàm bắn súng (Auto Shoot)
local function Shoot(target)
    if not Remotes then return end
    local shootRemote = Remotes:FindFirstChild("Shoot") or Remotes:FindFirstChild("GunHit") or Remotes:FindFirstChild("Fire")
    if shootRemote then
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                shootRemote:FireServer(hrp)
            end
        else
            -- Bắn vào hướng trống (không target)
            local mouse = LocalPlayer:GetMouse()
            shootRemote:FireServer(mouse.Hit.p)
        end
    else
        -- Fallback: gửi sự kiện bắn qua tool
        local gun = Character:FindFirstChildOfClass("Tool")
        if gun and gun:FindFirstChild("RemoteEvent") then
            gun.RemoteEvent:FireServer()
        end
    end
end
-- ========== TẠO WINDOW CHÍNH ==========
local Window = Rayfield:CreateWindow({
    Name = "🔥 DarkForge-X MM2 Hub",
    Icon = 0,
    LoadingTitle = "DarkForge-X",
    LoadingSubtitle = "Shadow-Core Active",
    Theme = "Dark",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "DarkForge_MM2_Config"
    },
    KeySystem = false,
    Discord = { Enabled = false }
})

-- ========== TAB 1: COMBAT ==========
local CombatTab = Window:CreateTab("⚔️ Combat", nil)
local CombatSection = CombatTab:CreateSection("⚡ Tấn Công")

-- Aimbot
CombatTab:CreateToggle({
    Name = "🎯 Aimbot (Auto Aim)",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.Aimbot = value end
})

-- Silent Aim
CombatTab:CreateToggle({
    Name = "🔇 Silent Aim (Không rung)",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.SilentAim = value end
})

-- 🆕 Auto Shoot (bắn tự động)
CombatTab:CreateToggle({
    Name = "🔫 Auto Shoot (Tự động bắn)",
    CurrentValue = false,
    Callback = function(value)
        _G.DarkForge.AutoShoot = value
        Notify("Auto Shoot", value and "✅ Đã bật" or "❌ Đã tắt", 2)
    end
})

-- Slider điều chỉnh tốc độ bắn
CombatTab:CreateSlider({
    Name = "⏱️ Tốc độ bắn (giây)",
    Range = {0.1, 2.0},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(value)
        _G.DarkForge.ShootDelay = value
        Notify("Shoot Delay", value .. "s", 1)
    end
})

-- Kill All
CombatTab:CreateButton({
    Name = "💀 Kill All",
    Callback = function()
        for _, v in pairs(GetAlivePlayers()) do
            local target = v.Character
            if target then
                local hrp = target:FindFirstChild("HumanoidRootPart")
                if hrp and Remotes then
                    local knifeRemote = Remotes:FindFirstChild("KnifeHit")
                    if knifeRemote then knifeRemote:FireServer(hrp) end
                end
            end
        end
        Notify("Kill All", "💀 Đã giết tất cả!", 2)
    end
})

-- Auto Get Gun
CombatTab:CreateToggle({
    Name = "🔫 Auto Get Gun",
    CurrentValue = false,
    Callback = function(value)
        _G.DarkForge.AutoGun = value
        if value and Remotes then
            local gunRemote = Remotes:FindFirstChild("Gun")
            if gunRemote then gunRemote:FireServer() end
        end
    end
})

-- Spam Knife
CombatTab:CreateToggle({
    Name = "🔪 Spam Knife",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.SpamKnife = value end
})

-- Hitbox Extender
CombatTab:CreateSlider({
    Name = "📦 Hitbox Extender",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        _G.DarkForge.HitboxSize = value
        _G.DarkForge.HitboxExtender = true
    end
})

-- Speed / Jump
local MovementSection = CombatTab:CreateSection("🏃 Di Chuyển")
CombatTab:CreateSlider({
    Name = "💨 Speed Hack",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value)
        _G.DarkForge.Walkspeed = value
        _G.DarkForge.SpeedHack = true
        if Humanoid then Humanoid.WalkSpeed = value end
    end
})
CombatTab:CreateSlider({
    Name = "🦘 Jump Power",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        _G.DarkForge.Jumppower = value
        if Humanoid then Humanoid.JumpPower = value end
    end
})
CombatTab:CreateToggle({
    Name = "♾️ Infinite Jump",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.InfiniteJump = value end
})
CombatTab:CreateToggle({
    Name = "🌀 Noclip",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.Noclip = value end
})
CombatTab:CreateToggle({
    Name = "✈️ Fly (Nhấn F để bay)",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.Fly = value end
})

-- ========== TAB 2: FARM ==========
local FarmTab = Window:CreateTab("💰 Farm", nil)
local FarmSection = FarmTab:CreateSection("🤖 Auto Farm")
FarmTab:CreateToggle({
    Name = "🪙 Auto Farm Coin",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.AutoFarm = value end
})
FarmTab:CreateToggle({
    Name = "🧹 Auto Collect",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.AutoCollect = value end
})
FarmTab:CreateToggle({
    Name = "🔄 Teleport to Coins",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.TeleportToCoins = value end
})
FarmTab:CreateButton({
    Name = "⚡ Bật Farm All",
    Callback = function()
        _G.DarkForge.AutoFarm = true
        _G.DarkForge.AutoCollect = true
        _G.DarkForge.TeleportToCoins = true
        Notify("Farm All", "✅ Đã bật tất cả!", 3)
    end
})
FarmTab:CreateButton({
    Name = "⏹️ Tắt Farm All",
    Callback = function()
        _G.DarkForge.AutoFarm = false
        _G.DarkForge.AutoCollect = false
        _G.DarkForge.TeleportToCoins = false
        Notify("Farm All", "❌ Đã tắt tất cả!", 2)
    end
})

local ESPSection = FarmTab:CreateSection("👁️ ESP & X-Ray")
FarmTab:CreateToggle({
    Name = "👁️ ESP",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.ESP = value end
})
FarmTab:CreateToggle({
    Name = "🎭 Reveal Roles",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.RevealRoles = value end
})

-- ========== TAB 3: UTILITY ==========
local UtilityTab = Window:CreateTab("🛠️ Utility", nil)
local UtilitySection = UtilityTab:CreateSection("🔧 Tiện Ích")
UtilityTab:CreateToggle({
    Name = "🛡️ God Mode",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.GodMode = value end
})
UtilityTab:CreateToggle({
    Name = "💤 Anti AFK",
    CurrentValue = false,
    Callback = function(value) _G.DarkForge.AntiAFK = value end
})
UtilityTab:CreateButton({
    Name = "🔪 TP to Murderer",
    Callback = function()
        for _, v in pairs(GetAlivePlayers()) do
            local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then TeleportTo(hrp.Position); Notify("TP", "Đã TP đến Murderer", 2); break end
        end
    end
})
UtilityTab:CreateButton({
    Name = "🔫 TP to Sheriff",
    Callback = function()
        for _, v in pairs(GetAlivePlayers()) do
            local char = v.Character
            if char and char:FindFirstChild("Gun") then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then TeleportTo(hrp.Position); Notify("TP", "Đã TP đến Sheriff", 2); break end
            end
        end
    end
})
UtilityTab:CreateButton({
    Name = "🔄 Server Hop",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
        Notify("Server Hop", "Đang chuyển sever...", 3)
    end
})
UtilityTab:CreateButton({
    Name = "🔁 Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        Notify("Rejoin", "Đang vào lại...", 3)
    end
})
UtilityTab:CreateButton({
    Name = "🗑️ Destroy GUI",
    Callback = function() Window:Destroy() end
})

-- ========== TAB 4: SETTINGS ==========
local SettingsTab = Window:CreateTab("⚙️ Settings", nil)
SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = {"Default", "Dark", "Light", "Amber", "Blood"},
    CurrentOption = "Dark",
    Callback = function(option) Rayfield:ChangeTheme(option) end
})
SettingsTab:CreateButton({
    Name = "💾 Save Config",
    Callback = function() Notify("Config", "✅ Đã lưu!", 2) end
})
SettingsTab:CreateButton({
    Name = "🔄 Reset Config",
    Callback = function()
        _G.DarkForge = {
            Walkspeed = 16, Jumppower = 50, AutoFarm = false, ESP = false,
            Aimbot = false, SilentAim = false, GodMode = false, Noclip = false,
            Fly = false, InfiniteJump = false, SpeedHack = false, AntiAFK = false,
            TeleportToCoins = false, AutoCollect = false, HitboxExtender = false,
            HitboxSize = 5, SpamKnife = false, RevealRoles = false, AutoKill = false,
            TeleportToMurderer = false, AutoGun = false, ServerHop = false, Rejoin = false,
            AutoShoot = false, ShootDelay = 0.5
        }
        Notify("Config", "🔄 Đã reset!", 2)
    end
})
-- ========== LOOP XỬ LÝ CHÍNH ==========
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            if not hum then return end

            -- Speed Hack
            if _G.DarkForge.SpeedHack then hum.WalkSpeed = _G.DarkForge.Walkspeed end

            -- Infinite Jump
            if _G.DarkForge.InfiniteJump then
                hum.JumpPower = _G.DarkForge.Jumppower
                -- Xử lý jump liên tục (gắn vào phím space)
            end

            -- God Mode
            if _G.DarkForge.GodMode then
                hum.Health = hum.MaxHealth
                if not char:FindFirstChild("ForceField") then
                    local ff = Instance.new("ForceField")
                    ff.Parent = char
                end
            end

            -- Noclip
            if _G.DarkForge.Noclip then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end

            -- ESP
            if _G.DarkForge.ESP then
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character then
                        local target = v.Character
                        if not target:FindFirstChild("Highlight") then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                            hl.Parent = target
                        end
                    end
                end
            else
                for _, v in pairs(Players:GetPlayers()) do
                    if v.Character then
                        local hl = v.Character:FindFirstChild("Highlight")
                        if hl then hl:Destroy() end
                    end
                end
            end

            -- Reveal Roles
            if _G.DarkForge.RevealRoles then
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character then
                        local tag = v.Character:FindFirstChild("NameTag")
                        if tag then
                            if v.Character:FindFirstChild("Gun") then
                                tag.Text = "🔫 Sheriff"
                            elseif v.Character:FindFirstChild("Knife") then
                                tag.Text = "🔪 Murderer"
                            else
                                tag.Text = "👤 Innocent"
                            end
                        end
                    end
                end
            end

            -- Auto Farm Coins
            if _G.DarkForge.AutoFarm then
                local coins = GetCoins()
                for _, coin in pairs(coins) do
                    if coin and coin.Parent then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - coin.Position).Magnitude
                            if dist < 50 then
                                firetouchinterest(hrp, coin, 0)
                                firetouchinterest(hrp, coin, 1)
                            elseif _G.DarkForge.TeleportToCoins and dist > 30 then
                                TeleportTo(coin.Position)
                            end
                        end
                    end
                end
            end

            -- Auto Collect
            if _G.DarkForge.AutoCollect then
                local coins = GetCoins()
                for _, coin in pairs(coins) do
                    if coin and coin.Parent then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - coin.Position).Magnitude < 20 then
                            firetouchinterest(hrp, coin, 0)
                            firetouchinterest(hrp, coin, 1)
                        end
                    end
                end
            end

            -- Aimbot (xoay người)
            if _G.DarkForge.Aimbot then
                local target = GetNearestPlayer()
                if target and target.Character then
                    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if targetHRP and hrp then
                        local direction = (targetHRP.Position - hrp.Position).Unit
                        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + direction * 100)
                    end
                end
            end

            -- Silent Aim (tấn công không cần ngắm)
            if _G.DarkForge.SilentAim then
                local target = GetNearestPlayer()
                if target and target.Character then
                    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and Remotes then
                        local knifeRemote = Remotes:FindFirstChild("KnifeHit")
                        if knifeRemote then knifeRemote:FireServer(targetHRP) end
                    end
                end
            end

            -- Spam Knife
            if _G.DarkForge.SpamKnife then
                for _, v in pairs(GetAlivePlayers()) do
                    local target = v.Character
                    if target then
                        local hrp = target:FindFirstChild("HumanoidRootPart")
                        if hrp and Remotes then
                            local knifeRemote = Remotes:FindFirstChild("KnifeHit")
                            if knifeRemote then knifeRemote:FireServer(hrp) end
                        end
                    end
                end
            end

            -- Hitbox Extender
            if _G.DarkForge.HitboxExtender then
                for _, v in pairs(GetAlivePlayers()) do
                    local target = v.Character
                    if target then
                        local hrp = target:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(_G.DarkForge.HitboxSize, _G.DarkForge.HitboxSize, _G.DarkForge.HitboxSize)
                        end
                    end
                end
            end

            -- Anti AFK
            if _G.DarkForge.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end
end)

-- ========== AUTO SHOOT LOOP RIÊNG ==========
spawn(function()
    local lastShoot = 0
    while task.wait(0.05) do
        pcall(function()
            if _G.DarkForge.AutoShoot then
                local now = tick()
                if now - lastShoot >= _G.DarkForge.ShootDelay then
                    local target = GetNearestPlayer()
                    if target and target.Character then
                        -- Kiểm tra có súng chưa? Nếu chưa thì tự động lấy
                        if not Character:FindFirstChildOfClass("Tool") or not Character:FindFirstChild("Gun") then
                            if Remotes and Remotes:FindFirstChild("Gun") then
                                Remotes.Gun:FireServer()
                            end
                        end
                        -- Bắn
                        Shoot(target)
                        lastShoot = now
                    end
                end
            end
        end)
    end
end)

-- ========== FLY CONTROLS ==========
spawn(function()
    LocalPlayer:GetMouse().KeyDown:connect(function(key)
        if key == "F" then
            _G.DarkForge.Fly = not _G.DarkForge.Fly
            local flying = _G.DarkForge.Fly
            if flying then
                local hrp = Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = Vector3.new(0, 10, 0)
                    bv.MaxForce = Vector3.new(4000, 4000, 4000)
                    bv.Parent = hrp
                end
            else
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BodyVelocity") then v:Destroy() end
                end
            end
        end
    end)
end)

-- ========== THÔNG BÁO KHỞI ĐỘNG ==========
Notify("🔥 DarkForge-X MM2 Hub", "Đã tải thành công! Nhấn K để mở UI\nAuto Shoot đã sẵn sàng!", 5)
print("✅ DarkForge-X MM2 Ultimate Hub loaded!")