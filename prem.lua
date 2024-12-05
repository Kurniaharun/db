-- Load Orion Lib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Main Window
local Window = OrionLib:MakeWindow({
    Name = "KECE HUB V1",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ServerChangerV1"
})

-- Tab: Script (Free)
local FreeTab = Window:MakeTab({
    Name = "Script (Free)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

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

-- Tab: Script (Premium)
local PremiumTab = Window:MakeTab({
    Name = "Script (Premium)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PremiumTab:AddButton({
    Name = "Azure HUB (PREM)",
    Callback = function()
        script_key = "DZBfAwjroFfqrzkvGMhzSiLxIiPcTAhD"
        getgenv().Team = "Pirates"
        getgenv().FixCrash = false
        getgenv().FixCrash2 = false
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/3b2169cf53bc6104dabe8e19562e5cc2.lua"))()
    end
})

PremiumTab:AddButton({
    Name = "Banana HUB (PREM)",
    Callback = function()
        repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
        getgenv().Key = "95af14f32c213c968f476784"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
    end
})

PremiumTab:AddButton({
    Name = "MARU HUB (PREM)",
    Callback = function()
        getgenv().Key = "MARU-DGRS4-KHYB-4UQ9S-ACWZ-ATS9X"
        getgenv().id = "1098577806398607432"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xshiba/MaruBitkub/main/Mobile.lua"))()
    end
})

-- Tab: Server
local ServerTab = Window:MakeTab({
    Name = "Server",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local jobID = ""

ServerTab:AddTextbox({
    Name = "Input Job ID",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        jobID = value:gsub("`", "") -- Filter backtick character
        writefile("SavedJobID.txt", jobID) -- Auto-save Job ID
    end
})

ServerTab:AddButton({
    Name = "Join Job ID",
    Callback = function()
        if jobID ~= "" then
            game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", jobID)
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Please input a valid Job ID!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

ServerTab:AddToggle({
    Name = "Auto Join Job",
    Default = false,
    Callback = function(value)
        if value and jobID ~= "" then
            while value do
                game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", jobID)
                task.wait(1) -- Prevent spamming
            end
        end
    end
})

ServerTab:AddButton({
    Name = "Hop to Less Player Server",
    Callback = function()
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end
})

ServerTab:AddButton({
    Name = "Hop to Random Server",
    Callback = function()
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end
})

-- Load Saved Job ID if Available
if isfile("SavedJobID.txt") then
    jobID = readfile("SavedJobID.txt")
end

-- Initialize UI
OrionLib:Init()
