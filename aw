--!strict
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local baitParts = workspace.BaitParts:GetChildren()
local wormPlaceCount = #baitParts
local teleporting = false
local humanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WormAutoCollectUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local InnerFrame = Instance.new("Frame")
InnerFrame.Size = UDim2.new(1, -10, 1, -10)
InnerFrame.Position = UDim2.new(0, 5, 0, 5)
InnerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InnerFrame.BorderSizePixel = 0
InnerFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐛 Worm Collector"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = InnerFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 35)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Text = "[OFF] Auto Collect Worm"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.TextSize = 14
ToggleButton.Parent = InnerFrame

local RejoinButton = Instance.new("TextButton")
RejoinButton.Size = UDim2.new(1, -20, 0, 30)
RejoinButton.Position = UDim2.new(0, 10, 0, 75)
RejoinButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RejoinButton.Text = "🔁 Rejoin Server"
RejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinButton.Font = Enum.Font.Gotham
RejoinButton.TextSize = 14
RejoinButton.Parent = InnerFrame

-- Fungsi ambil worm di 1 titik
local function tpAndCollectWorm(position)
    humanoidRootPart.CFrame = CFrame.new(position)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(2.25)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Toggle logic
local function toggleTeleport()
    teleporting = not teleporting
    ToggleButton.Text = teleporting and "[ON] Auto Collect Worm" or "[OFF] Auto Collect Worm"

    if teleporting then
        coroutine.wrap(function()
            while teleporting do
                local randomIndex = math.random(1, wormPlaceCount)
                local targetPosition = baitParts[randomIndex].Position
                tpAndCollectWorm(targetPosition)
                task.wait(2)
            end
        end)()
    end
end

-- Rejoin logic
local function rejoinServer()
    local ts = game:GetService("TeleportService")
    ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

-- Button callbacks
ToggleButton.MouseButton1Click:Connect(toggleTeleport)
RejoinButton.MouseButton1Click:Connect(rejoinServer)

-- Hide UI with Ctrl + Left Click
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        InnerFrame.Visible = not InnerFrame.Visible
    end
end)
