
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ SYSTEM INFO ]]
local executorName = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown Executor"
local isMobile = game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC"

-- [[ GLOBALS & CONFIG ]]
getgenv().robux = 10000
getgenv().Config = {
    TargetPlayer = "",
    MathAnswer = ""
}

-- [[ CREATE COMPACT WINDOW FOR MOBILE COMFORT ]]
local Window = Fluent:CreateWindow({
    Title = "🌌🚀SPACEHUB",
    SubTitle = "Free", -- SUBTITLE RETAINED
    TabWidth = 120, -- Reduced tab width for mobile
    Size = UDim2.fromOffset(460, 340), -- Compact size for mobile screens
    Acrylic = true, -- Luxurious blurred glass effect
    Theme = "Amethyst", -- Amethyst Purple theme
    MinimizeKey = Enum.KeyCode.LeftControl 
})

-- [[ TABS DEFINITION - ONLY FREE FEATURES ]]
local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Dupe = Window:AddTab({ Title = "Dupe", Icon = "copy" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" })
}

-- [[ TAB: HOME ]]
Tabs.Home:AddParagraph({
    Title = "User Information",
    Content = "Current Executor: " .. executorName .. "\nPlatform: " .. isMobile .. "\n\nWelcome to the Free Edition of SPACEHUB."
})
Tabs.Home:AddButton({
    Title = "Copy Discord Link",
    Description = "Click to copy official invite URL",
    Callback = function()
        setclipboard("https://discord.gg/YzCCWz5q7H")
        Fluent:Notify({Title = "System", Content = "Discord link copied to clipboard!", Duration = 3})
    end
})

-- [[ TAB: DUPE SYSTEM (MATH VERIFICATION) ]]
local num1 = math.random(1, 10)
local num2 = math.random(1, 10)
local correctResult = num1 + num2

Tabs.Dupe:AddSection("Security Check")
Tabs.Dupe:AddParagraph({
    Title = "Solve Math to Unlock",
    Content = "Solve this to unlock the Dupe script: " .. num1 .. " + " .. num2 .. " = ?"
})
Tabs.Dupe:AddInput("MathAnswerInput", {
    Title = "Enter Answer",
    Default = "",
    Placeholder = "Type result here...",
    Numeric = true,
    Callback = function(Value) getgenv().Config.MathAnswer = Value end
})
Tabs.Dupe:AddButton({
    Title = "Verify & Execute Dupe Script",
    Description = "Launches Huy Vuong Fruit Dupe if answer is correct",
    Callback = function()
        if tonumber(getgenv().Config.MathAnswer) == correctResult then
            Fluent:Notify({Title = "Correct Answer!", Content = "Dupe script is launching...", Duration = 3})
            loadstring(game:HttpGet("https://raw.githubusercontent.com/spaispacehub-cyber/SPAISPACE-HUB-X-BROOKHAVEN-VIP/refs/heads/main/Huy%20Vuong%20dupe.lua"))()
        else
            Fluent:Notify({Title = "Wrong Answer!", Content = "Please check your math and try again.", Duration = 3})
        end
    end
})

-- [[ TAB: VISUAL & GIFTER (FAKE GIFT V1) ]]
Tabs.Visual:AddSection("Fake Gifter System v1")
Tabs.Visual:AddInput("RobuxVal", {
    Title = "Set Fake Robux Amount",
    Default = "10000",
    Numeric = true,
    Callback = function(v) getgenv().robux = tonumber(v) or 10000 end
})
Tabs.Visual:AddButton({
    Title = "Execute Fake Gifter Dragon",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/FakeGifterDragon.lua"))()
    end
})

-- [[ TAB: PLAYER HUB (STEAL OUTFIT) ]]
Tabs.Player:AddSection("Identity Stealer")
Tabs.Player:AddInput("TargetPlayer", {
    Title = "Target Username",
    Default = "",
    Callback = function(v) getgenv().Config.TargetPlayer = v end
})
Tabs.Player:AddButton({
    Title = "Steal Outfit",
    Callback = function()
        local target = game.Players:FindFirstChild(getgenv().Config.TargetPlayer)
        local localChar = game.Players.LocalPlayer.Character
        if target and target.Character and localChar then
            for _, v in pairs(localChar:GetChildren()) do 
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then 
                    v:Destroy() 
                end 
            end
            for _, v in pairs(target.Character:GetChildren()) do 
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then 
                    v:Clone().Parent = localChar 
                end 
            end
            Fluent:Notify({Title = "Success", Content = "Identity Cloned!", Duration = 3})
        end
    end
})

-- [[ FINALIZE MENU ]]
Window:SelectTab(1)
Fluent:Notify({
    Title = "SPACEHUB Free",
    Content = "SPACEHUB Free Loaded Successfully!",
    Duration = 5
})