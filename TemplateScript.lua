-- Template Script untuk Whitelist Library
-- Cara pakai: Ganti URL script Anda di bawah ini

-- Ganti dengan URL script Anda
local script = "https://your-script-url.com/raw"

-- Load Whitelist Library
loadstring(game:HttpGet("https://your-whitelist-lib-url.com/raw"))()

-- Set script selanjutnya
_G.NextScriptURL = script

-- Selesai! Script Anda akan otomatis jalan jika user whitelisted
