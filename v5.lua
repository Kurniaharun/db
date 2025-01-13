-- Load KeceHub Library
local KeceHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Main Window
local Window = KeceHub:MakeWindow({
    Name = "KECE HUB V5",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "KeceHubV5"
})

-- Variables
local bypassStatus = false
local startTime = os.clock()

-- Tab: Status
local StatusTab = Window:MakeTab({
    Name = "Status",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Status Display
StatusTab:AddLabel("STATUS SC: VIP")
StatusTab:AddLabel("DEV: tiktok @lawwstore")
StatusTab:AddLabel("INFO: Penjual SC ini hanya @lawwstore")

-- Update Ping and Bypass Status
task.spawn(function()
    while true do
        task.wait(1) -- Interval pembaruan setiap 1 detik
    end
end)

-- Tab: Main
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Toggles
MainTab:AddToggle({
    Name = "Bypass ON/OFF",
    Default = false,
    Callback = function(value)
        bypassStatus = value
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Bypass " .. (value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

MainTab:AddToggle({
    Name = "Anti Report",
    Default = false,
    Callback = function(value)
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Anti Report " .. (value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

MainTab:AddToggle({
    Name = "Clear Log",
    Default = false,
    Callback = function(value)
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Clear Log " .. (value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- Buttons
MainTab:AddButton({
    Name = "COKKA HUB NO KEY",
    Callback = function()
        _G.Key = "Xzt7M9IAfF"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/UserDevEthical/Loadstring/main/CokkaHub.lua"))()
    end
})

MainTab:AddButton({
    Name = "Speed Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
    end
})

MainTab:AddButton({
    Name = "RedzHub V2 (Smooth)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Source.lua"))()
    end
})

MainTab:AddButton({
    Name = "Mokuro Hub",
    Callback = function()
        loadstring(game:HttpGet("https://auth.quartyz.com/scripts/Loader.lua"))()
    end
})

-- Tab: BANANA
local BananaTab = Window:MakeTab({
    Name = "BANANA",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

BananaTab:AddButton({
    Name = "Get Key",
    Callback = function()
        setclipboard("https://ads.luarmor.net/get_key?for=VHFslhWdrPey")
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Key URL copied to clipboard!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

BananaTab:AddTextbox({
    Name = "Input Key",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        _G.Key = value
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Key Saved!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

BananaTab:AddButton({
    Name = "Start",
    Callback = function()
        if _G.Key and _G.Key ~= "" then
            repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
            getgenv().Key = _G.Key
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
        else
            KeceHub:MakeNotification({
                Name = "Error",
                Content = "Please input a valid key!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

-- Tab: ALCHEMY
local AlchemyTab = Window:MakeTab({
    Name = "ALCHEMY",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AlchemyTab:AddButton({
    Name = "Start",
    Callback = function()
        loadstring(game:HttpGet("https://scripts.alchemyhub.xyz"))()
    end
})

-- Tab: KAITUN
local KaitunTab = Window:MakeTab({
    Name = "KAITUN",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

KaitunTab:AddButton({
    Name = "Start Kaitun",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/ZMsXgHhF"))()
    end
})

-- Initialize UI
KeceHub:Init()

-- Override Welcome Message
local notificationFrame = game:GetService("CoreGui"):FindFirstChild("Orion"):FindFirstChild("Notifications")
if notificationFrame then
    for _, child in pairs(notificationFrame:GetChildren()) do
        if child.Name == "Welcome" then
            child.Message.Text = "KECE HUB V5"
        end
    end
end