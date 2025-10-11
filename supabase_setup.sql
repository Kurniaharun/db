-- Script SQL untuk setup database Supabase Whitelist Manager
-- Jalankan script ini di SQL Editor di Supabase Dashboard

-- 1. Buat tabel whitelist
CREATE TABLE IF NOT EXISTS whitelist (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Buat index untuk performa yang lebih baik
CREATE INDEX IF NOT EXISTS idx_whitelist_username ON whitelist(username);

-- 3. Buat trigger untuk update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_whitelist_updated_at 
    BEFORE UPDATE ON whitelist 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 4. Enable Row Level Security (RLS)
ALTER TABLE whitelist ENABLE ROW LEVEL SECURITY;

-- 5. Buat policy untuk akses public (sesuaikan dengan kebutuhan keamanan Anda)
-- PERINGATAN: Policy ini memungkinkan semua orang untuk read/write
-- Untuk produksi, buat policy yang lebih ketat

-- Policy untuk SELECT (read)
CREATE POLICY "Allow public read access" ON whitelist
    FOR SELECT USING (true);

-- Policy untuk INSERT (create)
CREATE POLICY "Allow public insert access" ON whitelist
    FOR INSERT WITH CHECK (true);

-- Policy untuk UPDATE (update)
CREATE POLICY "Allow public update access" ON whitelist
    FOR UPDATE USING (true);

-- Policy untuk DELETE (delete)
CREATE POLICY "Allow public delete access" ON whitelist
    FOR DELETE USING (true);

-- 6. Insert beberapa data contoh (opsional)
INSERT INTO whitelist (username) VALUES 
    ('arix12'),
    ('asaw1'),
    ('adcasaww1')
ON CONFLICT (username) DO NOTHING;

-- 7. Buat view untuk melihat statistik whitelist
CREATE OR REPLACE VIEW whitelist_stats AS
SELECT 
    COUNT(*) as total_users,
    MIN(created_at) as first_created,
    MAX(created_at) as last_created
FROM whitelist;

-- 8. Buat function untuk mendapatkan semua username sebagai text
CREATE OR REPLACE FUNCTION get_whitelist_raw()
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
BEGIN
    SELECT string_agg(username, E'\n' ORDER BY username) 
    INTO result
    FROM whitelist;
    
    RETURN COALESCE(result, '');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Grant permissions untuk function
GRANT EXECUTE ON FUNCTION get_whitelist_raw() TO anon, authenticated;

-- 10. Buat function untuk bulk insert username
CREATE OR REPLACE FUNCTION bulk_insert_whitelist(usernames TEXT[])
RETURNS INTEGER AS $$
DECLARE
    inserted_count INTEGER := 0;
    username_item TEXT;
BEGIN
    FOREACH username_item IN ARRAY usernames
    LOOP
        BEGIN
            INSERT INTO whitelist (username) VALUES (username_item);
            inserted_count := inserted_count + 1;
        EXCEPTION WHEN unique_violation THEN
            -- Skip jika username sudah ada
            CONTINUE;
        END;
    END LOOP;
    
    RETURN inserted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions untuk bulk insert function
GRANT EXECUTE ON FUNCTION bulk_insert_whitelist(TEXT[]) TO anon, authenticated;

-- 11. Buat function untuk bulk delete username
CREATE OR REPLACE FUNCTION bulk_delete_whitelist(usernames TEXT[])
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM whitelist 
    WHERE username = ANY(usernames);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions untuk bulk delete function
GRANT EXECUTE ON FUNCTION bulk_delete_whitelist(TEXT[]) TO anon, authenticated;

-- 12. Buat function untuk check multiple usernames sekaligus
CREATE OR REPLACE FUNCTION check_multiple_whitelist(usernames TEXT[])
RETURNS TABLE(username TEXT, is_whitelisted BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.username,
        CASE WHEN w.username IS NOT NULL THEN TRUE ELSE FALSE END as is_whitelisted
    FROM unnest(usernames) as u(username)
    LEFT JOIN whitelist w ON u.username = w.username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions untuk check multiple function
GRANT EXECUTE ON FUNCTION check_multiple_whitelist(TEXT[]) TO anon, authenticated;

-- Selesai! Database siap digunakan
-- 
-- CARA PENGGUNAAN:
-- 1. Buka Supabase Dashboard
-- 2. Pergi ke SQL Editor
-- 3. Copy dan paste script ini
-- 4. Klik "Run" untuk menjalankan script
-- 5. Pergi ke Settings > API untuk mendapatkan URL dan Key
-- 6. Masukkan URL dan Key ke aplikasi HTML
