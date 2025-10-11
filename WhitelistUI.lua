-- Whitelist Check Library untuk Roblox (No UI Version)
-- Library yang bisa digunakan untuk script lain dengan sistem environment

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Environment untuk script selanjutnya
local WhitelistEnv = {
    isWhitelisted = false,
    username = player.Name,
    onWhitelisted = function() end,
    onNotWhitelisted = function() end
}

-- Fungsi untuk menampilkan notif Roblox
local function showNotification(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

-- Fungsi untuk kick player
local function kickPlayer(reason)
    player:Kick(reason)
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

-- Fungsi untuk handle hasil whitelist check
local function handleWhitelistResult(isWhitelisted)
    WhitelistEnv.isWhitelisted = isWhitelisted
    
    if isWhitelisted then
        print("✅ WHITELISTED")
        showNotification("Access Granted", "Welcome to the server!", 3)
        WhitelistEnv.onWhitelisted()
    else
        print("❌ NOT WHITELISTED")
        showNotification("NOT WHITELISTED", "CONTACT: +62 853 5118 7520", 5)
        
        -- Kick player setelah 3 detik
        spawn(function()
            wait(3)
            kickPlayer("NOT WHITELISTED\nCONTACT: +62 853 5118 7520")
        end)
        
        WhitelistEnv.onNotWhitelisted()
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
    -- Auto check on load
    spawn(function()
        wait(1) -- Wait 1 detik
        print("🚀 Starting whitelist check for:", player.Name)
        local isWhitelisted = checkWhitelist(player.Name)
        handleWhitelistResult(isWhitelisted)
        
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
    print("❌ Whitelist check failed! Player will be kicked.")
end

-- Export environment untuk script lain
_G.WhitelistEnv = WhitelistEnv

-- Jalankan script
main()

print("🔒 Whitelist Library (No UI) telah dimuat!")
print("📋 Username yang dicek: " .. player.Name)
