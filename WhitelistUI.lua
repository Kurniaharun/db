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
    
    -- Store blur effect reference untuk cleanup
    _G.WhitelistBlurEffect = blurEffect
    
    -- Frame utama dengan AI-style gradient
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- AI-style border dengan multiple strokes
    local borderGlow1 = Instance.new("UIStroke")
    borderGlow1.Color = Color3.fromRGB(0, 255, 255)
    borderGlow1.Thickness = 3
    borderGlow1.Transparency = 0.2
    borderGlow1.Parent = mainFrame
    
    local borderGlow2 = Instance.new("UIStroke")
    borderGlow2.Color = Color3.fromRGB(100, 0, 255)
    borderGlow2.Thickness = 1
    borderGlow2.Transparency = 0.5
    borderGlow2.Parent = mainFrame
    
    -- Animated AI border glow
    spawn(function()
        while mainFrame.Parent do
            for i = 0, 1, 0.01 do
                if not mainFrame.Parent then break end
                borderGlow1.Transparency = 0.2 + (math.sin(i * math.pi * 3) * 0.3)
                borderGlow2.Transparency = 0.5 + (math.cos(i * math.pi * 2) * 0.2)
                wait(0.02)
            end
        end
    end)
    
    -- AI-style title dengan efek matrix
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "> AI_VERIFICATION_SYSTEM <"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.Code
    title.TextStrokeTransparency = 0.3
    title.TextStrokeColor3 = Color3.fromRGB(0, 200, 255)
    title.Parent = mainFrame
    
    -- AI title animation
    spawn(function()
        while title.Parent do
            for i = 0, 1, 0.02 do
                if not title.Parent then break end
                title.TextStrokeTransparency = 0.3 + (math.sin(i * math.pi * 4) * 0.4)
                wait(0.03)
            end
        end
    end)
    
    -- AI-style username display
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Size = UDim2.new(1, -20, 0, 25)
    usernameLabel.Position = UDim2.new(0, 10, 0, 40)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "USER_ID: " .. string.upper(player.Name)
    usernameLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    usernameLabel.TextScaled = true
    usernameLabel.Font = Enum.Font.Code
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = mainFrame
    
    -- AI-style status dengan terminal effect
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 70)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: SCANNING_DATABASE..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- AI loading animation dengan terminal effect
    spawn(function()
        local loadingTexts = {
            "STATUS: SCANNING_DATABASE...",
            "STATUS: ANALYZING_USER_DATA...",
            "STATUS: CHECKING_WHITELIST...",
            "STATUS: VERIFYING_ACCESS..."
        }
        local currentIndex = 1
        
        while statusLabel.Parent and statusLabel.Text:find("SCANNING") or statusLabel.Text:find("ANALYZING") or statusLabel.Text:find("CHECKING") or statusLabel.Text:find("VERIFYING") do
            statusLabel.Text = loadingTexts[currentIndex]
            currentIndex = currentIndex + 1
            if currentIndex > #loadingTexts then currentIndex = 1 end
            wait(0.8)
        end
    end)
    
    -- AI-style progress bar dengan glow effect
    local progressBG = Instance.new("Frame")
    progressBG.Name = "ProgressBG"
    progressBG.Size = UDim2.new(1, -20, 0, 8)
    progressBG.Position = UDim2.new(0, 10, 0, 100)
    progressBG.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    progressBG.BorderSizePixel = 0
    progressBG.Parent = mainFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBG
    
    -- Progress bar border
    local progressBorder = Instance.new("UIStroke")
    progressBorder.Color = Color3.fromRGB(0, 255, 255)
    progressBorder.Thickness = 1
    progressBorder.Transparency = 0.3
    progressBorder.Parent = progressBG
    
    -- Progress bar fill dengan gradient effect
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
    
    -- Progress bar glow
    local progressGlow = Instance.new("UIStroke")
    progressGlow.Color = Color3.fromRGB(100, 255, 255)
    progressGlow.Thickness = 2
    progressGlow.Transparency = 0.5
    progressGlow.Parent = progressFill
    
    -- Animate progress bar dengan AI effect
    spawn(function()
        for i = 0, 1, 0.015 do
            if not progressFill.Parent then break end
            progressFill.Size = UDim2.new(i, 0, 1, 0)
            progressGlow.Transparency = 0.5 + (math.sin(i * math.pi * 8) * 0.3)
            wait(0.03)
        end
    end)
    
    -- AI-style contact info (akan muncul jika not whitelisted)
    local contactLabel = Instance.new("TextLabel")
    contactLabel.Name = "ContactLabel"
    contactLabel.Size = UDim2.new(1, -20, 0, 30)
    contactLabel.Position = UDim2.new(0, 10, 0, 115)
    contactLabel.BackgroundTransparency = 1
    contactLabel.Text = "> CONTACT_ADMIN: +62 853 5118 7520 <"
    contactLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    contactLabel.TextScaled = true
    contactLabel.Font = Enum.Font.Code
    contactLabel.TextXAlignment = Enum.TextXAlignment.Center
    contactLabel.TextStrokeTransparency = 0.3
    contactLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
    contactLabel.Visible = false
    contactLabel.Parent = mainFrame
    
    -- AI contact animation
    spawn(function()
        while contactLabel.Parent do
            for i = 0, 1, 0.02 do
                if not contactLabel.Parent then break end
                if contactLabel.Visible then
                    contactLabel.TextStrokeTransparency = 0.3 + (math.sin(i * math.pi * 6) * 0.4)
                end
                wait(0.05)
            end
        end
    end)
    
    return screenGui, statusLabel, contactLabel, progressFill
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
local function updateStatus(statusLabel, contactLabel, isWhitelisted)
    WhitelistEnv.isWhitelisted = isWhitelisted
    
    if isWhitelisted then
        statusLabel.Text = "STATUS: ACCESS_GRANTED ✓"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Auto cleanup setelah 2 detik jika whitelisted
        spawn(function()
            wait(2)
            
            -- Cleanup blur effect dulu
            if _G.WhitelistBlurEffect then
                _G.WhitelistBlurEffect:Destroy()
                _G.WhitelistBlurEffect = nil
            end
            
            -- Destroy UI langsung tanpa tween yang rumit
            local screenGui = statusLabel.Parent.Parent.Parent
            if screenGui then
                screenGui:Destroy()
            end
            
            -- Call callback
            WhitelistEnv.onWhitelisted()
        end)
    else
        statusLabel.Text = "STATUS: ACCESS_DENIED ✗"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        -- Show contact label
        contactLabel.Visible = true
        
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
    local screenGui, statusLabel, contactLabel, progressFill = createWhitelistUI()
    
    -- Auto check on load
    spawn(function()
        wait(2) -- Wait for UI to load and progress bar to fill
        print("🚀 Starting whitelist check for:", player.Name)
        local isWhitelisted = checkWhitelist(player.Name)
        updateStatus(statusLabel, contactLabel, isWhitelisted)
        
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
    
    -- Double cleanup blur effect (backup)
    if _G.WhitelistBlurEffect then
        _G.WhitelistBlurEffect:Destroy()
        _G.WhitelistBlurEffect = nil
    end
    
    -- Cleanup any remaining UI elements
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("WhitelistLib") then
        playerGui.WhitelistLib:Destroy()
    end
    
    -- Force cleanup semua UI yang mungkin tertinggal
    for _, child in pairs(playerGui:GetChildren()) do
        if child.Name == "WhitelistLib" then
            child:Destroy()
        end
    end
    
    -- Script akan otomatis load script selanjutnya dari URL
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
