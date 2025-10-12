const express = require('express');
const path = require('path');
const cors = require('cors');
const session = require('express-session');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Auto-set Supabase credentials (fallback jika env tidak ada)
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://xyvbbguhmqcrvqumvddc.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5dmJiZ3VobXFjcnZxdW12ZGRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxODExNDAsImV4cCI6MjA3NTc1NzE0MH0.J_f_5WAJdb6A2k05kSUuQCS3iSo56pMR9omOnxie4vU';

// Password untuk autentikasi
const ADMIN_PASSWORD = 'Laww123@';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Session middleware
app.use(session({
    secret: 'whitelist-manager-secret-key-2024',
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: false, // Set to true jika menggunakan HTTPS
        maxAge: 24 * 60 * 60 * 1000 // 24 jam
    }
}));

// Middleware untuk cek autentikasi
function requireAuth(req, res, next) {
    if (req.session && req.session.authenticated) {
        return next();
    } else {
        // Jika request untuk halaman HTML, redirect ke login
        if (req.accepts('html')) {
            return res.redirect('/login');
        }
        // Jika request API, return JSON error
        return res.status(401).json({ 
            error: 'Unauthorized', 
            message: 'Password diperlukan untuk mengakses halaman ini' 
        });
    }
}

// API endpoint untuk login
app.post('/api/login', (req, res) => {
    const { password } = req.body;
    
    if (password === ADMIN_PASSWORD) {
        req.session.authenticated = true;
        res.json({ 
            success: true, 
            message: 'Login berhasil!' 
        });
    } else {
        res.status(401).json({ 
            success: false, 
            message: 'Password salah!' 
        });
    }
});

// API endpoint untuk logout
app.post('/api/logout', (req, res) => {
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

// API endpoint untuk cek status login
app.get('/api/auth-status', (req, res) => {
    res.json({ 
        authenticated: !!(req.session && req.session.authenticated) 
    });
});

// Serve halaman login
app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

// Serve static files - dilindungi dengan password
app.get('/', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API endpoint untuk mendapatkan konfigurasi Supabase - dilindungi dengan password
app.get('/api/config', requireAuth, (req, res) => {
    const config = {
        supabaseUrl: SUPABASE_URL,
        supabaseKey: SUPABASE_ANON_KEY
    };
    
    res.json(config);
});

// Raw endpoint untuk menampilkan username dalam format JSON
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

// Health check endpoint - dilindungi dengan password
app.get('/api/health', requireAuth, (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server berjalan di port ${PORT}`);
    console.log(`📱 Buka http://localhost:${PORT} untuk mengakses aplikasi`);
    console.log(`🔗 Raw link: http://localhost:${PORT}/raw`);
    
    // Cek environment variables
    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_ANON_KEY) {
        console.log('🔧 Menggunakan konfigurasi default Supabase');
        console.log('📝 URL:', SUPABASE_URL);
        console.log('🔑 Key:', SUPABASE_ANON_KEY.substring(0, 20) + '...');
    } else {
        console.log('✅ Menggunakan environment variables dari Heroku');
    }
});
