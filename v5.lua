local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local OpenButton = Instance.new("TextButton")
local StatusTabButton = Instance.new("TextButton")
local FeaturesTabButton = Instance.new("TextButton")

local StatusFrame = Instance.new("Frame")
local FeaturesFrame = Instance.new("Frame")

-- Properties
ScreenGui.Parent = game.CoreGui

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Visible = true
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.BackgroundTransparency = 0.2

TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "KECE HUB V5"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 24
TitleLabel.BackgroundTransparency = 1

MinimizeButton.Parent = MainFrame
MinimizeButton.Position = UDim2.new(0, 340, 0, 10)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundTransparency = 0.5
MinimizeButton.BorderSizePixel = 0

CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Position = UDim2.new(0, 370, 0, 10)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BorderSizePixel = 0
CloseButton.BackgroundTransparency = 0.5

OpenButton.Parent = ScreenGui
OpenButton.Position = UDim2.new(0.3, 0, 0.3, 0)
OpenButton.Size = UDim2.new(0, 100, 0, 50)
OpenButton.Text = "Open"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Visible = false
OpenButton.Draggable = true
OpenButton.BackgroundTransparency = 0.5

StatusTabButton.Parent = MainFrame
StatusTabButton.Position = UDim2.new(0, 0, 0, 50)
StatusTabButton.Size = UDim2.new(0.5, 0, 0, 30)
StatusTabButton.Text = "Status"
StatusTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusTabButton.BackgroundTransparency = 0.5

FeaturesTabButton.Parent = MainFrame
FeaturesTabButton.Position = UDim2.new(0.5, 0, 0, 50)
FeaturesTabButton.Size = UDim2.new(0.5, 0, 0, 30)
FeaturesTabButton.Text = "Features"
FeaturesTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FeaturesTabButton.BackgroundTransparency = 0.5

StatusFrame.Parent = MainFrame
StatusFrame.Position = UDim2.new(0, 0, 0, 80)
StatusFrame.Size = UDim2.new(1, 0, 1, -80)
StatusFrame.Visible = true

FeaturesFrame.Parent = MainFrame
FeaturesFrame.Position = UDim2.new(0, 0, 0, 80)
FeaturesFrame.Size = UDim2.new(1, 0, 1, -80)
FeaturesFrame.Visible = false

-- Animations
MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true, function()
        MainFrame.Visible = false
        OpenButton.Visible = true
    end)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MainFrame:TweenSize(UDim2.new(0, 400, 0, 300), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
    OpenButton.Visible = false
end)

StatusTabButton.MouseButton1Click:Connect(function()
    StatusFrame.Visible = true
    FeaturesFrame.Visible = false
end)

FeaturesTabButton.MouseButton1Click:Connect(function()
    StatusFrame.Visible = false
    FeaturesFrame.Visible = true
end)

-- Status Labels
local StatusLabels = {"STATUS SC: VIP", "DEV: tiktok @lawwonlyone", "INFO: Penjual SC ini hanya @lawwonlyone"}
for i, label in ipairs(StatusLabels) do
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = StatusFrame
    StatusLabel.Position = UDim2.new(0, 10, 0, (i - 1) * 30)
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Text = label
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.BackgroundTransparency = 1
end

-- Features Buttons
local FeatureButtons = {
    {Name = "Redz Hub", URL = "https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Source.lua"},
    {Name = "COKKA HUB", URL = "https://raw.githubusercontent.com/UserDevEthical/Loadstring/main/CokkaHub.lua"},
    {Name = "Speed Hub", URL = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua"},
    {Name = "Mokuro Hub", URL = "https://auth.quartyz.com/scripts/Loader.lua"},
    {
        Name = "W Azure",
        URL = [[
            getgenv().Team = "Pirates"
            getgenv().AutoLoad = false -- Will Load Script On Server Hop
            getgenv().SlowLoadUi = false
            getgenv().ForceUseSilentAimDashModifier = false -- Force turn on silent aim, if error then executor problem
            getgenv().ForceUseWalkSpeedModifier = false -- Force turn on Walk Speed Modifier, if error then executor problem
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/3b2169cf53bc6104dabe8e19562e5cc2.lua"))()
        ]]
    }
}

for i, feature in ipairs(FeatureButtons) do
    local FeatureButton = Instance.new("TextButton")
    FeatureButton.Parent = FeaturesFrame
    FeatureButton.Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 40)
    FeatureButton.Size = UDim2.new(0.9, 0, 0, 30)
    FeatureButton.Text = feature.Name
    FeatureButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    FeatureButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FeatureButton.BorderSizePixel = 0
    FeatureButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet(feature.URL))()
    end)
end
