-- Load KeceHub Library
local KeceHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Variables
local keyValid = false
local userKey = ""
local requiredKey = "alokhamil"

-- Key Input Window
local KeyWindow = KeceHub:MakeWindow({
    Name = "KECE HUB V5 - Key Validation",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "KeceHubV5"
})

local KeyTab = KeyWindow:MakeTab({
    Name = "KEY",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

KeyTab:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        userKey = value
        if userKey == requiredKey then
            keyValid = true
            KeceHub:MakeNotification({
                Name = "Key Valid",
                Content = "Access Granted!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            KeyWindow:Destroy()
            initMainUI() -- Initialize main UI after key validation
        else
            KeceHub:MakeNotification({
                Name = "Key Invalid",
                Content = "Please enter a valid key.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

-- Function to Initialize Main UI
function initMainUI()
    -- Main Window
    local Window = KeceHub:MakeWindow({
        Name = "KECE HUB V5",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "KeceHubV5"
    })

    -- Tab: Status
    local StatusTab = Window:MakeTab({
        Name = "Status",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    StatusTab:AddLabel("STATUS SC: VIP")
    StatusTab:AddLabel("BYPASS : SAFE")
    StatusTab:AddLabel("INFO: Penjual SC ini hanya @lawwstore")

    -- Tab: Main
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    MainTab:AddButton({
        Name = "COKKA HUB KEY",
        Callback = function()
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
        Name = "Mokuro Hub",
        Callback = function()
            loadstring(game:HttpGet("https://auth.quartyz.com/scripts/Loader.lua"))()
        end
    })

    -- Tab: Banana
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
                Name = "Key Copied",
                Content = "The key link has been copied to your clipboard!",
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
            userKey = value
        end
    })

    BananaTab:AddButton({
        Name = "Start",
        Callback = function()
            if userKey ~= "" then
                getgenv().Key = userKey
                loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
            else
                KeceHub:MakeNotification({
                    Name = "Key Required",
                    Content = "Please input your key before starting.",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    })

    -- Tab: Alchemy
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

    -- Tab: Kaitun
    local KaitunTab = Window:MakeTab({
        Name = "Kaitun",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    KaitunTab:AddButton({
        Name = "Run Kaitun",
        Callback = function()
            loadstring(game:HttpGet("https://pastebin.com/raw/ZMsXgHhF"))()
        end
    })
end

-- Override Welcome Message
local notificationFrame = game:GetService("CoreGui"):FindFirstChild("Orion"):FindFirstChild("Notifications")
if notificationFrame then
    for _, child in pairs(notificationFrame:GetChildren()) do
        if child.Name == "Welcome" then
            child.Message.Text = "KECE HUB V5"
        end
    end
end
