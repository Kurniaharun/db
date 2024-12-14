-- Load KeceHub Lib
local KeceHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Main Window
local Window = KeceHub:MakeWindow({
    Name = "KECE HUB TRUE V2",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "KeceHubV2"
})

-- Tab: Status
local StatusTab = Window:MakeTab({
    Name = "Status",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local startTime = os.clock()

-- Update Status Info
StatusTab:AddLabel("Name Display: " .. game.Players.LocalPlayer.DisplayName)
StatusTab:AddLabel("Username: " .. game.Players.LocalPlayer.Name)
StatusTab:AddLabel("Status SC: VIP (REAL)")
StatusTab:AddLabel("Time Running: 0s")
StatusTab:AddLabel("FPS: Calculating...")

task.spawn(function()
    while true do
        local timeRunning = math.floor(os.clock() - startTime)
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        StatusTab:UpdateLabel(3, "Time Running: " .. timeRunning .. "s")
        StatusTab:UpdateLabel(4, "FPS: " .. fps)
        task.wait(1)
    end
end)

-- Tab: Script (Free) (Main)
local FreeTab = Window:MakeTab({
    Name = "Script (Free)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Toggles
FreeTab:AddToggle({
    Name = "Bypass ON/OFF",
    Default = false,
    Callback = function(value)
        if value then
            KeceHub:MakeNotification({
                Name = "Info",
                Content = "Bypass Enabled",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            KeceHub:MakeNotification({
                Name = "Info",
                Content = "Bypass Disabled",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

FreeTab:AddToggle({
    Name = "Clear Report ON/OFF",
    Default = false,
    Callback = function(value)
        if value then
            KeceHub:MakeNotification({
                Name = "Info",
                Content = "Clear Report Enabled",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            KeceHub:MakeNotification({
                Name = "Info",
                Content = "Clear Report Disabled",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

-- Buttons
FreeTab:AddButton({
    Name = "COKKA HUB NO KEY",
    Callback = function()
        _G.Key = "Xzt7M9IAfF"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/UserDevEthical/Loadstring/main/CokkaHub.lua"))()
    end
})

FreeTab:AddButton({
    Name = "RedzHub V2 (Smooth)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Source.lua"))()
    end
})

FreeTab:AddButton({
    Name = "ANDEPZAI OP (TRIAL)",
    Callback = function()
        repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AnDepZaiHub/AnDepZaiHubBeta/refs/heads/main/AnDepZaiHubNewUpdated.lua"))()
    end
})

FreeTab:AddButton({
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
        -- Hapus backtick dari input dan simpan Job ID
        jobID = value:gsub("`", "")
        if jobID ~= "" then
            game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", jobID)
        end
    end
})

-- Initialize UI
KeceHub:Init()
