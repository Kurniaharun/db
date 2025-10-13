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
const resellerSessions = new Map();
const upgradeKeys = new Map(); // Store untuk upgrade keys

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

// Helper function untuk reseller authentication
function isResellerKeyValid(key, deviceId) {
    const keyData = resellerSessions.get(key);
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

function updateResellerActivity(key, deviceId) {
    const keyData = resellerSessions.get(key);
    if (keyData) {
        keyData.lastActivity = Date.now();
        keyData.deviceId = deviceId;
    }
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

// Middleware untuk cek reseller key auth
function requireResellerAuth(req, res, next) {
    const key = req.headers['x-api-key'] || req.body.key || req.query.key;
    const deviceId = getDeviceId(req);
    
    if (!key) {
        return res.status(401).json({ 
            error: 'Unauthorized', 
            message: 'Reseller key required' 
        });
    }
    
    if (!isResellerKeyValid(key, deviceId)) {
        return res.status(403).json({ 
            error: 'Device not allowed', 
            message: 'Key sedang digunakan di device lain atau session expired' 
        });
    }
    
    // Update activity
    updateResellerActivity(key, deviceId);
    
    req.resellerKey = key;
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

// Create reseller key
app.post('/api/admin/create-reseller-key', requireAdminAuth, (req, res) => {
    const { username, limit = 25 } = req.body;
    
    if (!username) {
        return res.status(400).json({
            success: false,
            message: 'Username diperlukan'
        });
    }
    
    const key = generateKey();
    const deviceId = getDeviceId(req);
    
    // Simpan reseller key data
    resellerSessions.set(key, {
        username,
        limit: parseInt(limit),
        deviceId: null, // Belum ada device yang login
        lastActivity: 0,
        createdAt: new Date().toISOString(),
        type: 'reseller'
    });
    
    res.json({
        success: true,
        message: 'Reseller key berhasil dibuat',
        data: {
            key,
            username,
            limit: parseInt(limit)
        }
    });
});

// Create upgrade key
app.post('/api/admin/create-upgrade-key', requireAdminAuth, (req, res) => {
    const { resellerKey } = req.body;
    
    if (!resellerKey) {
        return res.status(400).json({
            success: false,
            message: 'Reseller key diperlukan'
        });
    }
    
    // Cek apakah reseller key ada
    const resellerData = resellerSessions.get(resellerKey);
    if (!resellerData) {
        return res.status(404).json({
            success: false,
            message: 'Reseller key tidak ditemukan'
        });
    }
    
    const upgradeKey = generateKey();
    
    // Simpan upgrade key
    upgradeKeys.set(upgradeKey, {
        resellerKey,
        createdAt: new Date().toISOString(),
        used: false
    });
    
    res.json({
        success: true,
        message: 'Upgrade key berhasil dibuat',
        data: {
            upgradeKey,
            resellerUsername: resellerData.username,
            currentLimit: resellerData.limit
        }
    });
});

// Delete key
app.delete('/api/admin/delete-key/:key', requireAdminAuth, (req, res) => {
    const { key } = req.params;
    
    let deleted = false;
    let keyType = '';
    
    // Try to delete from device sessions (user keys)
    if (deviceSessions.has(key)) {
        deviceSessions.delete(key);
        deleted = true;
        keyType = 'user';
    }
    
    // Try to delete from reseller sessions
    if (resellerSessions.has(key)) {
        resellerSessions.delete(key);
        deleted = true;
        keyType = 'reseller';
    }
    
    if (deleted) {
        res.json({
            success: true,
            message: `${keyType} key berhasil dihapus`
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
    // Combine both device sessions (user keys) and reseller sessions
    const userKeys = Array.from(deviceSessions.entries()).map(([key, data]) => ({
        key,
        username: data.username,
        limit: data.limit,
        createdAt: data.createdAt,
        lastActivity: new Date(data.lastActivity).toLocaleString(),
        isActive: Date.now() - data.lastActivity < 30 * 60 * 1000,
        type: 'user'
    }));
    
    const resellerKeys = Array.from(resellerSessions.entries()).map(([key, data]) => ({
        key,
        username: data.username,
        limit: data.limit,
        createdAt: data.createdAt,
        lastActivity: data.lastActivity > 0 ? new Date(data.lastActivity).toLocaleString() : 'Never',
        isActive: data.lastActivity > 0 && Date.now() - data.lastActivity < 30 * 60 * 1000,
        type: 'reseller'
    }));
    
    const allKeys = [...userKeys, ...resellerKeys];
    
    res.json({
        success: true,
        data: allKeys
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

// ===== RESELLER ENDPOINTS =====

// Reseller login
app.post('/api/reseller/login', (req, res) => {
    const { key } = req.body;
    const deviceId = getDeviceId(req);
    
    if (!key) {
        return res.status(400).json({
            success: false,
            message: 'Key diperlukan'
        });
    }
    
    const resellerData = resellerSessions.get(key);
    if (!resellerData) {
        return res.status(404).json({
            success: false,
            message: 'Key tidak valid'
        });
    }
    
    if (!isResellerKeyValid(key, deviceId)) {
        return res.status(403).json({
            success: false,
            message: 'Key sedang digunakan di device lain atau session expired. Coba lagi dalam 30 menit.'
        });
    }
    
    // Set reseller session
    req.session.resellerAuthenticated = true;
    req.session.resellerKey = key;
    req.session.resellerUsername = resellerData.username;
    
    res.json({
        success: true,
        message: 'Login reseller berhasil',
        data: {
            username: resellerData.username,
            limit: resellerData.limit
        }
    });
});

// Reseller logout
app.post('/api/reseller/logout', (req, res) => {
    const key = req.resellerKey || req.session.resellerKey;
    
    if (key && resellerSessions.has(key)) {
        // Reset device untuk allow login di device lain
        const resellerData = resellerSessions.get(key);
        resellerData.deviceId = null;
        resellerData.lastActivity = 0;
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
            message: 'Reseller logout berhasil!' 
        });
    });
});

// Get reseller stats
app.get('/api/reseller/stats', requireResellerAuth, async (req, res) => {
    try {
        const resellerKey = req.resellerKey;
        const resellerData = resellerSessions.get(resellerKey);
        
        if (!resellerData) {
            return res.status(404).json({
                success: false,
                message: 'Reseller data tidak ditemukan'
            });
        }
        
        // Import Supabase client
        const { createClient } = require('@supabase/supabase-js');
        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        
        // Hitung jumlah user yang ditambahkan oleh reseller ini
        const { data: userCount, error: countError } = await supabase
            .from('whitelist')
            .select('count', { count: 'exact', head: true });
        
        if (countError) {
            return res.status(500).json({
                success: false,
                message: 'Gagal menghitung user: ' + countError.message
            });
        }
        
        const usedSlots = userCount || 0;
        const remainingSlots = Math.max(0, resellerData.limit - usedSlots);
        
        res.json({
            success: true,
            data: {
                username: resellerData.username,
                limit: resellerData.limit,
                usedSlots,
                remainingSlots
            }
        });
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan: ' + error.message
        });
    }
});

// Get reseller users
app.get('/api/reseller/users', requireResellerAuth, async (req, res) => {
    try {
        // Import Supabase client
        const { createClient } = require('@supabase/supabase-js');
        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        
        // Ambil semua user dari whitelist
        const { data, error } = await supabase
            .from('whitelist')
            .select('username')
            .order('username');
        
        if (error) {
            return res.status(500).json({
                success: false,
                message: 'Gagal mengambil data user: ' + error.message
            });
        }
        
        res.json({
            success: true,
            data: data || []
        });
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan: ' + error.message
        });
    }
});

// Add user by reseller
app.post('/api/reseller/add-user', requireResellerAuth, async (req, res) => {
    try {
        const { username } = req.body;
        const resellerKey = req.resellerKey;
        const resellerData = resellerSessions.get(resellerKey);
        
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
        
        if (currentCount >= resellerData.limit) {
            return res.status(403).json({
                success: false,
                message: `Limit whitelist tercapai (${resellerData.limit}). Tidak bisa menambah lagi.`
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

// Delete user by reseller
app.delete('/api/reseller/delete-user', requireResellerAuth, async (req, res) => {
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

// Check user by reseller
app.get('/api/reseller/check-user', requireResellerAuth, async (req, res) => {
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
                data: { found: true }
            });
        } else {
            res.json({
                success: true,
                message: `Username "${username}" TIDAK ADA di whitelist!`,
                data: { found: false }
            });
        }
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan: ' + error.message
        });
    }
});

// Upgrade reseller limit
app.post('/api/reseller/upgrade-limit', requireResellerAuth, async (req, res) => {
    try {
        const { upgradeKey } = req.body;
        const resellerKey = req.resellerKey;
        
        if (!upgradeKey) {
            return res.status(400).json({
                success: false,
                message: 'Upgrade key diperlukan'
            });
        }
        
        // Cek apakah upgrade key valid
        const upgradeData = upgradeKeys.get(upgradeKey);
        if (!upgradeData) {
            return res.status(404).json({
                success: false,
                message: 'Upgrade key tidak valid'
            });
        }
        
        if (upgradeData.used) {
            return res.status(400).json({
                success: false,
                message: 'Upgrade key sudah digunakan'
            });
        }
        
        if (upgradeData.resellerKey !== resellerKey) {
            return res.status(403).json({
                success: false,
                message: 'Upgrade key tidak cocok dengan reseller key Anda'
            });
        }
        
        // Update reseller limit
        const resellerData = resellerSessions.get(resellerKey);
        if (!resellerData) {
            return res.status(404).json({
                success: false,
                message: 'Reseller data tidak ditemukan'
            });
        }
        
        const newLimit = resellerData.limit + 25;
        resellerData.limit = newLimit;
        
        // Mark upgrade key as used
        upgradeData.used = true;
        upgradeData.usedAt = new Date().toISOString();
        
        res.json({
            success: true,
            message: 'Limit berhasil diupgrade!',
            data: {
                newLimit,
                addedSlots: 25
            }
        });
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan: ' + error.message
        });
    }
});

// Serve halaman admin login
app.get('/admin/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin-login.html'));
});

// Serve halaman admin
app.get('/admin', requireAdminAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin.html'));
});


// Serve halaman reseller login
app.get('/reseller-login', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'reseller-login.html'));
});

// Serve halaman reseller dashboard
app.get('/reseller-dashboard', (req, res) => {
    if (req.session && req.session.resellerAuthenticated) {
        res.sendFile(path.join(__dirname, 'public', 'reseller-dashboard.html'));
    } else {
        res.redirect('/reseller-login');
    }
});

// Serve halaman utama
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});


// API endpoint untuk mendapatkan konfigurasi Supabase (dilindungi dengan key)
app.get('/api/config', requireKeyAuth, (req, res) => {
    const config = {
        supabaseUrl: SUPABASE_URL,
        supabaseKey: SUPABASE_ANON_KEY
    };
    
    res.json(config);
});

// Admin whitelist operations (tidak perlu key auth)
app.post('/api/whitelist/add', requireAdminAuth, async (req, res) => {
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

app.delete('/api/whitelist/delete', requireAdminAuth, async (req, res) => {
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

app.get('/api/whitelist/check', requireAdminAuth, async (req, res) => {
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
    
    // Cleanup device sessions
    for (const [key, data] of deviceSessions.entries()) {
        if (now - data.lastActivity > 30 * 60 * 1000) {
            deviceSessions.delete(key);
            console.log(`Auto cleanup: Device key ${key} expired`);
        }
    }
    
    // Cleanup reseller sessions
    for (const [key, data] of resellerSessions.entries()) {
        if (data.lastActivity > 0 && now - data.lastActivity > 30 * 60 * 1000) {
            resellerSessions.delete(key);
            console.log(`Auto cleanup: Reseller key ${key} expired`);
        }
    }
    
    // Cleanup expired upgrade keys (24 jam)
    for (const [key, data] of upgradeKeys.entries()) {
        if (now - new Date(data.createdAt).getTime() > 24 * 60 * 60 * 1000) {
            upgradeKeys.delete(key);
            console.log(`Auto cleanup: Upgrade key ${key} expired`);
        }
    }
}, 5 * 60 * 1000);

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Reseller Whitelist Server berjalan di port ${PORT}`);
    console.log(`👑 Admin Panel: http://localhost:${PORT}/admin`);
    console.log(`👤 User Login: http://localhost:${PORT}/login`);
    console.log(`🏪 Reseller Login: http://localhost:${PORT}/reseller-login`);
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


