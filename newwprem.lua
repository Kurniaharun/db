-- Load KeceHub Library
local KeceHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Main Window
local Window = KeceHub:MakeWindow({
    Name = "KECE HUB V4",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "KeceHubV4"
})

-- Variables
local bypassStatus = false
local clearLogStatus = false
local reportStatus = false
local startTime = os.clock()
local savedKey = ""

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

-- Update Ping and Status
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
    Name = "Clear Log ON/OFF",
    Default = false,
    Callback = function(value)
        clearLogStatus = value
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Clear Log " .. (value and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

MainTab:AddToggle({
    Name = "Fake Report ON/OFF",
    Default = false,
    Callback = function(value)
        reportStatus = value
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Fake Report " .. (value and "Enabled" or "Disabled"),
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
    Name = "RedzHub V2 (Smooth)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Source.lua"))()
    end
})

-- Tab: Join Server
local ServerTab = Window:MakeTab({
    Name = "Join Server",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local jobID = ""

ServerTab:AddTextbox({
    Name = "Input Job ID",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        -- Hapus karakter backtick dan simpan Job ID
        jobID = value:gsub("`", "")
        if jobID ~= "" then
            game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", jobID)
        end
    end
})

-- Tab: Special
local SpecialTab = Window:MakeTab({
    Name = "SPECIAL",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SpecialTab:AddButton({
    Name = "Get Key",
    Callback = function()
        setclipboard("https://ads.luarmor.net/get_key?for=VHFslhWdrPey")
        KeceHub:MakeNotification({
            Name = "Key Copied",
            Content = "Key link has been copied to clipboard!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

SpecialTab:AddTextbox({
    Name = "Input Key",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        savedKey = value
        KeceHub:MakeNotification({
            Name = "Key Saved",
            Content = "Key has been saved!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

SpecialTab:AddButton({
    Name = "Start",
    Callback = function()
        if savedKey == "" then
            KeceHub:MakeNotification({
                Name = "Error",
                Content = "Please input a key first!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            getgenv().Key = savedKey
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
        end
    end
})

-- Initialize UI
KeceHub:Init()

-- Override Welcome Message
local notificationFrame = game:GetService("CoreGui"):FindFirstChild("Orion"):FindFirstChild("Notifications")
if notificationFrame then
    for _, child in pairs(notificationFrame:GetChildren()) do
        if child.Name == "Welcome" then
            child.Message.Text = "KECE HUB V4"
        end
    end
end
