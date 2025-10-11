-- Template Script untuk menggunakan Whitelist Library
-- Cara pakai: Ganti URL_SCRIPT_SELANJUTNYA dengan URL script Anda

-- URL script selanjutnya (ganti dengan URL script Anda)
local NEXT_SCRIPT_URL = "https://your-script-url.com/raw"

-- Set URL untuk next script (akan otomatis dijalankan jika whitelisted)
_G.NextScriptURL = NEXT_SCRIPT_URL

-- Load Whitelist Library
local WhitelistLib = loadstring(game:HttpGet("https://your-whitelist-lib-url.com/raw"))()

-- Script Anda akan otomatis berjalan jika user whitelisted
-- Jika tidak whitelisted, user akan melihat kontak WhatsApp
-- UI akan hilang otomatis dan script selanjutnya akan jalan

print("🔒 Whitelist Library loaded!")
print("📋 Next script will auto-load if whitelisted")
print("📱 Contact WhatsApp if not whitelisted: +62 853 5118 7520")
