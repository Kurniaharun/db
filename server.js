const express = require('express');
const path = require('path');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Auto-set Supabase credentials (fallback jika env tidak ada)
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://xyvbbguhmqcrvqumvddc.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5dmJiZ3VobXFjcnZxdW12ZGRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxODExNDAsImV4cCI6MjA3NTc1NzE0MH0.J_f_5WAJdb6A2k05kSUuQCS3iSo56pMR9omOnxie4vU';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Serve static files
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API endpoint untuk mendapatkan konfigurasi Supabase
app.get('/api/config', (req, res) => {
    const config = {
        supabaseUrl: SUPABASE_URL,
        supabaseKey: SUPABASE_ANON_KEY
    };
    
    res.json(config);
});

// Raw endpoint untuk menampilkan username per line (seperti raw.githubusercontent.com)
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
            return res.status(500).send(`Error: ${error.message}`);
        }

        // Format username per line
        const usernames = data.map(item => item.username).join('\n');
        
        // Set header untuk raw text
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.setHeader('Cache-Control', 'no-cache');
        
        // Kirim response
        res.send(usernames || '');
        
    } catch (error) {
        res.status(500).send(`Error: ${error.message}`);
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
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
