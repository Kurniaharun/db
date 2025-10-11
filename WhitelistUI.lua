-- Whitelist Check UI Library untuk Roblox
-- Library yang bisa digunakan untuk script lain dengan sistem environment

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Environment untuk script selanjutnya
local WhitelistEnv = {
    isWhitelisted = false,
    username = player.Name,
    onWhitelisted = function() end,
    onNotWhitelisted = function() end
}

-- Fungsi untuk membuat UI Library Futuristic
local function createWhitelistUI()
    -- ScreenGui utama
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WhitelistLib"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    -- Background blur effect
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 20
    blurEffect.Parent = game.Lighting
    
    -- Frame utama dengan gradient
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Border glow effect
    local borderGlow = Instance.new("UIStroke")
    borderGlow.Color = Color3.fromRGB(0, 255, 255)
    borderGlow.Thickness = 2
    borderGlow.Transparency = 0.3
    borderGlow.Parent = mainFrame
    
    -- Animated border glow
    spawn(function()
        while mainFrame.Parent do
            for i = 0, 1, 0.02 do
                if not mainFrame.Parent then break end
                borderGlow.Transparency = 0.3 + (math.sin(i * math.pi) * 0.2)
                wait(0.05)
            end
        end
    end)
    
    -- Title dengan efek neon
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ ACCESS VERIFICATION ⚡"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.fromRGB(0, 200, 255)
    title.Parent = mainFrame
    
    -- Animated title glow
    spawn(function()
        while title.Parent do
            for i = 0, 1, 0.02 do
                if not title.Parent then break end
                title.TextStrokeTransparency = 0.5 + (math.sin(i * math.pi * 2) * 0.3)
                wait(0.03)
            end
        end
    end)
    
    -- Username display dengan style futuristic
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Size = UDim2.new(1, -20, 0, 30)
    usernameLabel.Position = UDim2.new(0, 10, 0, 60)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "USER: " .. string.upper(player.Name)
    usernameLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    usernameLabel.TextScaled = true
    usernameLabel.Font = Enum.Font.Code
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = mainFrame
    
    -- Status label dengan animasi loading
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 35)
    statusLabel.Position = UDim2.new(0, 10, 0, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: SCANNING..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Loading dots animation
    spawn(function()
        local dots = ""
        while statusLabel.Parent and statusLabel.Text:find("SCANNING") do
            dots = dots .. "."
            if #dots > 3 then dots = "" end
            statusLabel.Text = "STATUS: SCANNING" .. dots
            wait(0.5)
        end
    end)
    
    -- Progress bar background
    local progressBG = Instance.new("Frame")
    progressBG.Name = "ProgressBG"
    progressBG.Size = UDim2.new(1, -20, 0, 8)
    progressBG.Position = UDim2.new(0, 10, 0, 145)
    progressBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    progressBG.BorderSizePixel = 0
    progressBG.Parent = mainFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBG
    
    -- Progress bar fill
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBG
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(1, 0)
    progressFillCorner.Parent = progressFill
    
    -- Animate progress bar
    spawn(function()
        for i = 0, 1, 0.02 do
            if not progressFill.Parent then break end
            progressFill.Size = UDim2.new(i, 0, 1, 0)
            wait(0.05)
        end
    end)
    
    -- Contact info frame (akan muncul jika not whitelisted)
    local contactFrame = Instance.new("Frame")
    contactFrame.Name = "ContactFrame"
    contactFrame.Size = UDim2.new(1, -20, 0, 80)
    contactFrame.Position = UDim2.new(0, 10, 1, -90)
    contactFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 15)
    contactFrame.BorderSizePixel = 0
    contactFrame.Visible = false
    contactFrame.Parent = mainFrame
    
    local contactCorner = Instance.new("UICorner")
    contactCorner.CornerRadius = UDim.new(0, 10)
    contactCorner.Parent = contactFrame
    
    local contactBorder = Instance.new("UIStroke")
    contactBorder.Color = Color3.fromRGB(255, 100, 100)
    contactBorder.Thickness = 2
    contactBorder.Parent = contactFrame
    
    local contactTitle = Instance.new("TextLabel")
    contactTitle.Size = UDim2.new(1, 0, 0, 25)
    contactTitle.Position = UDim2.new(0, 0, 0, 5)
    contactTitle.BackgroundTransparency = 1
    contactTitle.Text = "⚠️ ACCESS DENIED ⚠️"
    contactTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    contactTitle.TextScaled = true
    contactTitle.Font = Enum.Font.GothamBold
    contactTitle.Parent = contactFrame
    
    local contactText = Instance.new("TextLabel")
    contactText.Size = UDim2.new(1, -10, 0, 20)
    contactText.Position = UDim2.new(0, 5, 0, 30)
    contactText.BackgroundTransparency = 1
    contactText.Text = "Contact WhatsApp for access:"
    contactText.TextColor3 = Color3.fromRGB(255, 200, 200)
    contactText.TextScaled = true
    contactText.Font = Enum.Font.Gotham
    contactText.TextXAlignment = Enum.TextXAlignment.Left
    contactText.Parent = contactFrame
    
    local whatsappLabel = Instance.new("TextLabel")
    whatsappLabel.Name = "WhatsAppLabel"
    whatsappLabel.Size = UDim2.new(1, -10, 0, 25)
    whatsappLabel.Position = UDim2.new(0, 5, 0, 50)
    whatsappLabel.BackgroundTransparency = 1
    whatsappLabel.Text = "📱 +62 853 5118 7520"
    whatsappLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    whatsappLabel.TextScaled = true
    whatsappLabel.Font = Enum.Font.GothamBold
    whatsappLabel.TextXAlignment = Enum.TextXAlignment.Left
    whatsappLabel.Parent = contactFrame
    
    -- Animated whatsapp glow
    spawn(function()
        while whatsappLabel.Parent do
            for i = 0, 1, 0.02 do
                if not whatsappLabel.Parent then break end
                whatsappLabel.TextStrokeTransparency = 0.5 + (math.sin(i * math.pi * 2) * 0.3)
                wait(0.05)
            end
        end
    end)
    
    return screenGui, statusLabel, contactFrame, progressFill
end

-- Fungsi untuk membersihkan string dari karakter tersembunyi
local function cleanString(str)
    if not str then return "" end
    -- Remove all whitespace, newlines, carriage returns, tabs
    str = string.gsub(str, "%s+", "")
    str = string.gsub(str, "\r", "")
    str = string.gsub(str, "\n", "")
    str = string.gsub(str, "\t", "")
    return str
end

-- Fungsi untuk mengecek whitelist dari API (JSON Format) - Anti HTTP Block
local function checkWhitelist(username)
    local success, result = pcall(function()
        -- Gunakan game:HttpGet untuk bypass anti-http
        local response = game:HttpGet("https://testveo-1e65aed90f2f.herokuapp.com/raw")
        
        print("🔍 Checking whitelist for:", username)
        print("📋 Raw response:", response)
        
        -- Parse JSON response
        local data = HttpService:JSONDecode(response)
        
        if data and data.whitelist then
            print("📝 Total whitelist entries:", #data.whitelist)
            
            for i, whitelistedUser in pairs(data.whitelist) do
                print("Entry " .. i .. ":", "'" .. whitelistedUser .. "'")
                
                -- Check exact match
                if whitelistedUser == username then
                    print("✅ Username found in whitelist! (exact match)")
                    return true
                end
                
                -- Check case-insensitive match
                if string.lower(whitelistedUser) == string.lower(username) then
                    print("✅ Username found in whitelist! (case-insensitive match)")
                    return true
                end
            end
            
            print("❌ Username not found in whitelist")
            return false
        else
            print("❌ Invalid JSON format or missing whitelist array")
            return false
        end
    end)
    
    if success then
        return result
    else
        warn("Error checking whitelist: " .. tostring(result))
        return false
    end
end

-- Fungsi untuk update status UI dan environment
local function updateStatus(statusLabel, contactFrame, isWhitelisted)
    WhitelistEnv.isWhitelisted = isWhitelisted
    
    if isWhitelisted then
        statusLabel.Text = "STATUS: ✅ ACCESS GRANTED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Success animation
        spawn(function()
            for i = 0, 1, 0.05 do
                if not statusLabel.Parent then break end
                statusLabel.TextStrokeTransparency = 0.5 + (math.sin(i * math.pi * 4) * 0.3)
                wait(0.1)
            end
        end)
        
        -- Auto cleanup setelah 3 detik jika whitelisted
        spawn(function()
            wait(3)
            -- Fade out animation
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local fadeOut = TweenService:Create(statusLabel.Parent.Parent, tweenInfo, {BackgroundTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                statusLabel.Parent.Parent:Destroy() -- Destroy UI
                WhitelistEnv.onWhitelisted() -- Call callback
            end)
        end)
    else
        statusLabel.Text = "STATUS: ❌ ACCESS DENIED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        -- Show contact frame dengan animasi
        contactFrame.Visible = true
        contactFrame.BackgroundTransparency = 1
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local fadeIn = TweenService:Create(contactFrame, tweenInfo, {BackgroundTransparency = 0})
        fadeIn:Play()
        
        -- Error animation
        spawn(function()
            for i = 0, 1, 0.05 do
                if not statusLabel.Parent then break end
                statusLabel.TextStrokeTransparency = 0.5 + (math.sin(i * math.pi * 6) * 0.3)
                wait(0.1)
            end
        end)
        
        WhitelistEnv.onNotWhitelisted() -- Call callback
    end
end

-- Fungsi untuk menjalankan script selanjutnya dari URL
local function loadNextScript(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result then
        print("🚀 Loading next script from:", url)
        loadstring(result)()
    else
        warn("❌ Failed to load next script from:", url)
    end
end

-- Main function
local function main()
    local screenGui, statusLabel, contactFrame, progressFill = createWhitelistUI()
    
    -- Auto check on load
    spawn(function()
        wait(2) -- Wait for UI to load and progress bar to fill
        print("🚀 Starting whitelist check for:", player.Name)
        local isWhitelisted = checkWhitelist(player.Name)
        updateStatus(statusLabel, contactFrame, isWhitelisted)
        
        -- Show result in chat
        if isWhitelisted then
            print("🎉 " .. player.Name .. " is WHITELISTED!")
        else
            print("❌ " .. player.Name .. " is NOT whitelisted")
        end
    end)
end

-- Setup environment callbacks
WhitelistEnv.onWhitelisted = function()
    print("✅ Whitelist check passed! Loading next script...")
    
    -- Cleanup blur effect
    if game.Lighting:FindFirstChild("BlurEffect") then
        game.Lighting.BlurEffect:Destroy()
    end
    
    -- Script akan otomatis load script selanjutnya dari URL
    -- URL bisa di-set di bagian atas script
    if _G.NextScriptURL then
        local success, result = pcall(function()
            return game:HttpGet(_G.NextScriptURL)
        end)
        
        if success and result then
            print("🚀 Executing next script...")
            loadstring(result)()
        else
            warn("❌ Failed to load next script from:", _G.NextScriptURL)
        end
    else
        print("⚠️ No next script URL set. Use _G.NextScriptURL = 'your-url' to set next script.")
    end
end

WhitelistEnv.onNotWhitelisted = function()
    print("❌ Whitelist check failed! Contact WhatsApp for access.")
    print("📱 WhatsApp: +62 853 5118 7520")
end

-- Export environment untuk script lain
_G.WhitelistEnv = WhitelistEnv

-- Jalankan script
main()

print("🔒 Whitelist Library telah dimuat!")
print("📋 Username yang dicek: " .. player.Name)
print("📱 Contact WhatsApp: 0853 5118 7520")
