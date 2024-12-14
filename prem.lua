-- Load KeceHub Library
local KeceHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Main Window
local Window = KeceHub:MakeWindow({
    Name = "KECE HUB TRUE V2",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "KeceHubV2"
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
StatusTab:AddLabel("Name Display: " .. game.Players.LocalPlayer.DisplayName)
StatusTab:AddLabel("Username: " .. game.Players.LocalPlayer.Name)
StatusTab:AddLabel("Status SC: VIP (REAL)")
StatusTab:AddLabel("Ping: Calculating...")
StatusTab:AddLabel("Bypass Status: OFF")

-- Update Ping and Bypass Status
task.spawn(function()
    while true do
        -- Calculate Ping
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        -- Update Labels
        StatusTab:UpdateLabel(3, "Ping: " .. ping)
        StatusTab:UpdateLabel(4, "Bypass Status: " .. (bypassStatus and "ON" or "OFF"))
        task.wait(1)
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
    Name = "Clear Report ON/OFF",
    Default = false,
    Callback = function(value)
        KeceHub:MakeNotification({
            Name = "Info",
            Content = "Clear Report " .. (value and "Enabled" or "Disabled"),
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

MainTab:AddButton({
    Name = "ANDEPZAI OP (TRIAL)",
    Callback = function()
        repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AnDepZaiHub/AnDepZaiHubBeta/refs/heads/main/AnDepZaiHubNewUpdated.lua"))()
    end
})

MainTab:AddButton({
    Name = "Auto Chest",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VGB-VGB-VGB/-VGB-Chest-Farm--/refs/heads/main/ChestFarmByVGBTeam"))()
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

-- Initialize UI
KeceHub:Init()
