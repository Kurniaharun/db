const express = require('express');
const path = require('path');
const cors = require('cors');
const session = require('express-session');
const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Auto-set Supabase credentials (fallback jika env tidak ada)
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://xyvbbguhmqcrvqumvddc.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5dmJiZ3VobXFjcnZxdW12ZGRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxODExNDAsImV4cCI6MjA3NTc1NzE0MH0.J_f_5WAJdb6A2k05kSUuQCS3iSo56pMR9omOnxie4vU';

// Password untuk admin
const ADMIN_PASSWORD = 'Kurr123@';

// Store untuk device tracking (dalam production gunakan Redis atau database)
const deviceSessions = new Map();
const userSessions = new Map();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Session middleware
app.use(session({
    secret: 'reseller-whitelist-secret-key-2024',
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: false,
        maxAge: 30 * 60 * 1000 // 30 menit
    }
}));

// Helper functions
function generateKey() {
    return crypto.randomBytes(16).toString('hex');
}

function getDeviceId(req) {
    return req.headers['user-agent'] + req.ip;
}

function isDeviceAllowed(key, deviceId) {
    const keyData = deviceSessions.get(key);
    if (!keyData) return false;
    
    // Jika device sama, allow
    if (keyData.deviceId === deviceId) return true;
    
    // Jika device berbeda, cek apakah sudah 30 menit
    const now = Date.now();
    if (now - keyData.lastActivity > 30 * 60 * 1000) {
        // Update device
        keyData.deviceId = deviceId;
        keyData.lastActivity = now;
        return true;
    }
    
    return false;
}

function updateDeviceActivity(key, deviceId) {
    const keyData = deviceSessions.get(key);
    if (keyData) {
        keyData.lastActivity = Date.now();
        keyData.deviceId = deviceId;
    }
}

// Middleware untuk cek admin auth
function requireAdminAuth(req, res, next) {
    if (req.session && req.session.adminAuthenticated) {
        return next();
    } else {
        if (req.accepts('html')) {
            return res.redirect('/admin/login');
        }
        return res.status(401).json({ 
            error: 'Unauthorized', 
            message: 'Admin access required' 
        });
    }
}

// Middleware untuk cek key auth
function requireKeyAuth(req, res, next) {
    const key = req.headers['x-api-key'] || req.body.key || req.query.key;
    const deviceId = getDeviceId(req);
    
    if (!key) {
        return res.status(401).json({ 
            error: 'Unauthorized', 
            message: 'API key required' 
        });
    }
    
    if (!isDeviceAllowed(key, deviceId)) {
        return res.status(403).json({ 
            error: 'Device not allowed', 
            message: 'Device limit exceeded or session expired' 
        });
    }
    
    // Update activity
    updateDeviceActivity(key, deviceId);
    
    req.key = key;
    req.deviceId = deviceId;
    next();
}

// Admin login
app.post('/api/admin/login', (req, res) => {
    const { password } = req.body;
    
    if (password === ADMIN_PASSWORD) {
        req.session.adminAuthenticated = true;
        res.json({ 
            success: true, 
            message: 'Admin login berhasil!' 
        });
    } else {
        res.status(401).json({ 
            success: false, 
            message: 'Password admin salah!' 
        });
    }
});

// Admin logout
app.post('/api/admin/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({ 
                success: false, 
                message: 'Gagal logout' 
            });
        }
        res.json({ 
            success: true, 
            message: 'Admin logout berhasil!' 
        });
    });
});

// Cek status admin
app.get('/api/admin/status', (req, res) => {
    res.json({ 
        authenticated: !!(req.session && req.session.adminAuthenticated) 
    });
});

// Create new key
app.post('/api/admin/create-key', requireAdminAuth, (req, res) => {
    const { username, limit = 25 } = req.body;
    
    if (!username) {
        return res.status(400).json({
            success: false,
            message: 'Username diperlukan'
        });
    }
    
    const key = generateKey();
    const deviceId = getDeviceId(req);
    
    // Simpan key data
    deviceSessions.set(key, {
        username,
        limit: parseInt(limit),
        deviceId,
        lastActivity: Date.now(),
        createdAt: new Date().toISOString()
    });
    
    res.json({
        success: true,
        message: 'Key berhasil dibuat',
        data: {
            key,
            username,
            limit: parseInt(limit)
        }
    });
});

// Delete key
app.delete('/api/admin/delete-key/:key', requireAdminAuth, (req, res) => {
    const { key } = req.params;
    
    if (deviceSessions.has(key)) {
        deviceSessions.delete(key);
        res.json({
            success: true,
            message: 'Key berhasil dihapus'
        });
    } else {
        res.status(404).json({
            success: false,
            message: 'Key tidak ditemukan'
        });
    }
});

// List all keys
app.get('/api/admin/keys', requireAdminAuth, (req, res) => {
    const keys = Array.from(deviceSessions.entries()).map(([key, data]) => ({
        key,
        username: data.username,
        limit: data.limit,
        createdAt: data.createdAt,
        lastActivity: new Date(data.lastActivity).toLocaleString(),
        isActive: Date.now() - data.lastActivity < 30 * 60 * 1000
    }));
    
    res.json({
        success: true,
        data: keys
    });
});

// Update user limit
app.put('/api/admin/update-limit', requireAdminAuth, (req, res) => {
    const { key, newLimit } = req.body;
    
    if (!key || !newLimit) {
        return res.status(400).json({
            success: false,
            message: 'Key dan limit baru diperlukan'
        });
    }
    
    const keyData = deviceSessions.get(key);
    if (!keyData) {
        return res.status(404).json({
            success: false,
            message: 'Key tidak ditemukan'
        });
    }
    
    keyData.limit = parseInt(newLimit);
    
    res.json({
        success: true,
        message: 'Limit berhasil diupdate',
        data: {
            key,
            username: keyData.username,
            newLimit: parseInt(newLimit)
        }
    });
});

// User login dengan key
app.post('/api/user/login', (req, res) => {
    const { key } = req.body;
    const deviceId = getDeviceId(req);
    
    if (!key) {
        return res.status(400).json({
            success: false,
            message: 'Key diperlukan'
        });
    }
    
    const keyData = deviceSessions.get(key);
    if (!keyData) {
        return res.status(404).json({
            success: false,
            message: 'Key tidak valid'
        });
    }
    
    if (!isDeviceAllowed(key, deviceId)) {
        return res.status(403).json({
            success: false,
            message: 'Device limit exceeded atau session expired. Coba lagi dalam 30 menit.'
        });
    }
    
    // Set user session
    req.session.userAuthenticated = true;
    req.session.userKey = key;
    req.session.username = keyData.username;
    
    res.json({
        success: true,
        message: 'Login berhasil',
        data: {
            username: keyData.username,
            limit: keyData.limit
        }
    });
});

// User logout
app.post('/api/user/logout', (req, res) => {
    const key = req.session.userKey;
    
    if (key && deviceSessions.has(key)) {
        // Reset device untuk allow login di device lain
        const keyData = deviceSessions.get(key);
        keyData.deviceId = null;
        keyData.lastActivity = 0;
    }
    
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({ 
                success: false, 
                message: 'Gagal logout' 
            });
        }
        res.json({ 
            success: true, 
            message: 'Logout berhasil!' 
        });
    });
});

// Cek status user
app.get('/api/user/status', (req, res) => {
    const isAuthenticated = !!(req.session && req.session.userAuthenticated);
    let userData = null;
    
    if (isAuthenticated) {
        const key = req.session.userKey;
        const keyData = deviceSessions.get(key);
        if (keyData) {
            userData = {
                username: keyData.username,
                limit: keyData.limit
            };
        }
    }
    
    res.json({ 
        authenticated: isAuthenticated,
        user: userData
    });
});

// Serve halaman admin login
app.get('/admin/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin-login.html'));
});

// Serve halaman admin
app.get('/admin', requireAdminAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin.html'));
});

// Serve halaman user login
app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'user-login.html'));
});

// Serve halaman user (dilindungi dengan key)
app.get('/', (req, res) => {
    if (req.session && req.session.userAuthenticated) {
        res.sendFile(path.join(__dirname, 'public', 'user.html'));
    } else {
        res.redirect('/login');
    }
});

// API endpoint untuk mendapatkan konfigurasi Supabase (dilindungi dengan key)
app.get('/api/config', requireKeyAuth, (req, res) => {
    const config = {
        supabaseUrl: SUPABASE_URL,
        supabaseKey: SUPABASE_ANON_KEY
    };
    
    res.json(config);
});

// Whitelist operations (dilindungi dengan key)
app.post('/api/whitelist/add', requireKeyAuth, async (req, res) => {
    try {
        const { username } = req.body;
        const key = req.key;
        const keyData = deviceSessions.get(key);
        
        if (!username) {
            return res.status(400).json({
                success: false,
                message: 'Username diperlukan'
            });
        }
        
        // Import Supabase client
        const { createClient } = require('@supabase/supabase-js');
        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        
        // Cek limit
        const { data: currentCount, error: countError } = await supabase
            .from('whitelist')
            .select('count', { count: 'exact', head: true });
        
        if (countError) {
            return res.status(500).json({
                success: false,
                message: 'Gagal mengecek limit: ' + countError.message
            });
        }
        
        if (currentCount >= keyData.limit) {
            return res.status(403).json({
                success: false,
                message: `Limit whitelist tercapai (${keyData.limit}). Tidak bisa menambah lagi.`
            });
        }
        
        // Cek apakah username sudah ada
        const { data: existing, error: checkError } = await supabase
            .from('whitelist')
            .select('username')
            .eq('username', username)
            .single();
        
        if (existing) {
            return res.status(400).json({
                success: false,
                message: `Username "${username}" sudah ada di whitelist!`
            });
        }
        
        // Tambah username baru
        const { data, error } = await supabase
            .from('whitelist')
            .insert([{ username: username }])
            .select();
        
        if (error) {
            return res.status(500).json({
                success: false,
                message: 'Gagal menambah ke whitelist: ' + error.message
            });
        }
        
        res.json({
            success: true,
            message: `Username "${username}" berhasil ditambahkan ke whitelist!`
        });
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan: ' + error.message
        });
    }
});

app.delete('/api/whitelist/delete', requireKeyAuth, async (req, res) => {
    try {
        const { username } = req.body;
        
        if (!username) {
            return res.status(400).json({
                success: false,
                message: 'Username diperlukan'
            });
        }
        
        // Import Supabase client
        const { createClient } = require('@supabase/supabase-js');
        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        
        const { data, error } = await supabase
            .from('whitelist')
            .delete()
            .eq('username', username)
            .select();
        
        if (error) {
            return res.status(500).json({
                success: false,
                message: 'Gagal menghapus dari whitelist: ' + error.message
            });
        }
        
        if (data && data.length > 0) {
            res.json({
                success: true,
                message: `Username "${username}" berhasil dihapus dari whitelist!`
            });
        } else {
            res.status(404).json({
                success: false,
                message: `Username "${username}" tidak ditemukan di whitelist!`
            });
        }
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan: ' + error.message
        });
    }
});

app.get('/api/whitelist/check', requireKeyAuth, async (req, res) => {
    try {
        const { username } = req.query;
        
        if (!username) {
            return res.status(400).json({
                success: false,
                message: 'Username diperlukan'
            });
        }
        
        // Import Supabase client
        const { createClient } = require('@supabase/supabase-js');
        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        
        const { data, error } = await supabase
            .from('whitelist')
            .select('username')
            .eq('username', username)
            .single();
        
        if (error && error.code !== 'PGRST116') {
            return res.status(500).json({
                success: false,
                message: 'Gagal mengecek whitelist: ' + error.message
            });
        }
        
        if (data) {
            res.json({
                success: true,
                message: `Username "${username}" ADA di whitelist!`,
                found: true
            });
        } else {
            res.json({
                success: true,
                message: `Username "${username}" TIDAK ADA di whitelist!`,
                found: false
            });
        }
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan: ' + error.message
        });
    }
});

// Raw endpoint untuk menampilkan username dalam format JSON (tidak dilindungi)
app.get('/raw', async (req, res) => {
    try {
        // Import Supabase client
        const { createClient } = require('@supabase/supabase-js');
        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        
        // Ambil semua username dari database
        const { data, error } = await supabase
            .from('whitelist')
            .select('username')
            .order('username');
        
        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }
        
        // Format username dalam JSON
        const usernames = data.map(item => item.username);
        const jsonResponse = {
            whitelist: usernames
        };
        
        // Set header untuk JSON
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.setHeader('Cache-Control', 'no-cache');
        
        // Kirim response dengan pretty print
        res.send(JSON.stringify(jsonResponse, null, 2));
        
    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        activeKeys: deviceSessions.size
    });
});

// Auto cleanup expired sessions setiap 5 menit
setInterval(() => {
    const now = Date.now();
    for (const [key, data] of deviceSessions.entries()) {
        if (now - data.lastActivity > 30 * 60 * 1000) {
            deviceSessions.delete(key);
            console.log(`Auto cleanup: Key ${key} expired`);
        }
    }
}, 5 * 60 * 1000);

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Reseller Whitelist Server berjalan di port ${PORT}`);
    console.log(`👑 Admin Panel: http://localhost:${PORT}/admin`);
    console.log(`👤 User Login: http://localhost:${PORT}/login`);
    console.log(`🔗 Raw Link: http://localhost:${PORT}/raw`);
    
    // Cek environment variables
    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_ANON_KEY) {
        console.log('🔧 Menggunakan konfigurasi default Supabase');
        console.log('📝 URL:', SUPABASE_URL);
        console.log('🔑 Key:', SUPABASE_ANON_KEY.substring(0, 20) + '...');
    } else {
        console.log('✅ Menggunakan environment variables');
    }
});
