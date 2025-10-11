-- 🗄️ Setup Database Supabase untuk Whitelist Manager
-- Jalankan script ini di SQL Editor di Supabase Dashboard

-- 1. Buat tabel whitelist
CREATE TABLE IF NOT EXISTS whitelist (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Buat index untuk performa
CREATE INDEX IF NOT EXISTS idx_whitelist_username ON whitelist(username);

-- 3. Enable Row Level Security
ALTER TABLE whitelist ENABLE ROW LEVEL SECURITY;

-- 4. Buat policy untuk akses public
CREATE POLICY "Allow public access" ON whitelist
    FOR ALL USING (true);

-- 5. Insert data contoh
INSERT INTO whitelist (username) VALUES 
    ('arix12'),
    ('asaw1'),
    ('adcasaww1')
ON CONFLICT (username) DO NOTHING;

-- ✅ Selesai! Tabel whitelist sudah siap digunakan
