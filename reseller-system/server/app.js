const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 menit
    max: 100 // limit setiap IP ke 100 requests per windowMs
});
app.use(limiter);

// Database setup
const db = new sqlite3.Database('./database/reseller.db');

// Initialize database
db.serialize(() => {
    const fs = require('fs');
    const schema = fs.readFileSync('./database/schema.sql', 'utf8');
    db.exec(schema);
});

// Store active sessions
const activeSessions = new Map();
const deviceSessions = new Map();

// Helper functions
function generateKey() {
    return uuidv4().replace(/-/g, '').substring(0, 16);
}

function getDeviceId(req) {
    return req.headers['user-agent'] + req.ip;
}

// Routes
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/public/login.html');
});

app.get('/admin', (req, res) => {
    res.sendFile(__dirname + '/public/admin.html');
});

app.get('/dashboard', (req, res) => {
    res.sendFile(__dirname + '/public/dashboard.html');
});

// Admin login
app.post('/api/admin/login', async (req, res) => {
    const { username, password } = req.body;
    
    if (username === 'admin' && password === 'Kurr123@') {
        const sessionId = uuidv4();
        activeSessions.set(sessionId, { 
            type: 'admin', 
            username: 'admin',
            loginTime: Date.now()
        });
        
        res.json({ 
            success: true, 
            sessionId,
            message: 'Login admin berhasil' 
        });
    } else {
        res.status(401).json({ 
            success: false, 
            message: 'Username atau password salah' 
        });
    }
});

// Create access key
app.post('/api/admin/create-key', (req, res) => {
    const { sessionId } = req.body;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    const keyValue = generateKey();
    
    db.run('INSERT INTO access_keys (key_value) VALUES (?)', [keyValue], function(err) {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal membuat key' });
        } else {
            res.json({ 
                success: true, 
                key: keyValue,
                message: 'Key berhasil dibuat' 
            });
        }
    });
});

// Delete access key
app.post('/api/admin/delete-key', (req, res) => {
    const { sessionId, keyId } = req.body;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    db.run('UPDATE access_keys SET is_active = 0 WHERE id = ?', [keyId], function(err) {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal menghapus key' });
        } else {
            res.json({ success: true, message: 'Key berhasil dihapus' });
        }
    });
});

// Get all keys
app.get('/api/admin/keys', (req, res) => {
    const { sessionId } = req.query;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    db.all('SELECT * FROM access_keys WHERE is_active = 1', (err, rows) => {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal mengambil data keys' });
        } else {
            res.json({ success: true, keys: rows });
        }
    });
});

// Get all users
app.get('/api/admin/users', (req, res) => {
    const { sessionId } = req.query;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    db.all(`
        SELECT u.*, ul.limit_count 
        FROM users u 
        LEFT JOIN user_limits ul ON u.id = ul.user_id 
        WHERE u.is_admin = 0
    `, (err, rows) => {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal mengambil data users' });
        } else {
            res.json({ success: true, users: rows });
        }
    });
});

// Update user limit
app.post('/api/admin/update-limit', (req, res) => {
    const { sessionId, userId, newLimit } = req.body;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    db.run(`
        INSERT OR REPLACE INTO user_limits (user_id, limit_count, updated_at) 
        VALUES (?, ?, CURRENT_TIMESTAMP)
    `, [userId, newLimit], function(err) {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal update limit' });
        } else {
            res.json({ success: true, message: 'Limit berhasil diupdate' });
        }
    });
});

// User login dengan key
app.post('/api/user/login', (req, res) => {
    const { key } = req.body;
    const deviceId = getDeviceId(req);
    
    // Cek apakah key valid
    db.get('SELECT * FROM access_keys WHERE key_value = ? AND is_active = 1', [key], (err, keyRow) => {
        if (err || !keyRow) {
            return res.status(401).json({ success: false, message: 'Key tidak valid' });
        }
        
        // Cek apakah ada session aktif untuk key ini
        db.get(`
            SELECT * FROM user_sessions 
            WHERE key_id = ? AND is_active = 1 
            ORDER BY last_activity DESC LIMIT 1
        `, [keyRow.id], (err, activeSession) => {
            if (err) {
                return res.status(500).json({ success: false, message: 'Database error' });
            }
            
            // Jika ada session aktif dan bukan device yang sama
            if (activeSession && activeSession.device_id !== deviceId) {
                return res.status(403).json({ 
                    success: false, 
                    message: 'Key sedang digunakan di device lain. Silakan logout terlebih dahulu.' 
                });
            }
            
            // Buat atau update session
            const sessionId = uuidv4();
            const deviceInfo = req.headers['user-agent'];
            
            if (activeSession) {
                // Update existing session
                db.run(`
                    UPDATE user_sessions 
                    SET device_id = ?, device_info = ?, last_activity = CURRENT_TIMESTAMP, is_active = 1
                    WHERE id = ?
                `, [deviceId, deviceInfo, activeSession.id]);
            } else {
                // Create new session
                db.run(`
                    INSERT INTO user_sessions (user_id, key_id, device_id, device_info, is_active)
                    VALUES (?, ?, ?, ?, 1)
                `, [keyRow.user_id || null, keyRow.id, deviceId, deviceInfo]);
            }
            
            // Store in memory
            activeSessions.set(sessionId, {
                type: 'user',
                keyId: keyRow.id,
                deviceId: deviceId,
                loginTime: Date.now()
            });
            
            deviceSessions.set(keyRow.id, {
                sessionId: sessionId,
                deviceId: deviceId,
                lastActivity: Date.now()
            });
            
            res.json({ 
                success: true, 
                sessionId,
                message: 'Login berhasil' 
            });
        });
    });
});

// Logout user
app.post('/api/user/logout', (req, res) => {
    const { sessionId } = req.body;
    
    if (!activeSessions.has(sessionId)) {
        return res.status(401).json({ success: false, message: 'Session tidak valid' });
    }
    
    const session = activeSessions.get(sessionId);
    
    if (session.type === 'user') {
        // Deactivate session in database
        db.run('UPDATE user_sessions SET is_active = 0 WHERE key_id = ?', [session.keyId]);
        
        // Remove from memory
        deviceSessions.delete(session.keyId);
    }
    
    activeSessions.delete(sessionId);
    
    res.json({ success: true, message: 'Logout berhasil' });
});

// Add whitelist
app.post('/api/user/add-whitelist', (req, res) => {
    const { sessionId, domain } = req.body;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'user') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    const session = activeSessions.get(sessionId);
    
    // Cek limit user
    db.get(`
        SELECT ul.limit_count, COUNT(w.id) as current_count
        FROM user_limits ul
        LEFT JOIN whitelist w ON ul.user_id = w.user_id
        WHERE ul.user_id = (SELECT user_id FROM access_keys WHERE id = ?)
        GROUP BY ul.user_id
    `, [session.keyId], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, message: 'Database error' });
        }
        
        const limit = result ? result.limit_count : 25;
        const current = result ? result.current_count : 0;
        
        if (current >= limit) {
            return res.status(400).json({ 
                success: false, 
                message: `Limit whitelist tercapai (${limit}). Hubungi admin untuk menambah limit.` 
            });
        }
        
        // Add to whitelist
        db.run(`
            INSERT INTO whitelist (user_id, domain)
            VALUES ((SELECT user_id FROM access_keys WHERE id = ?), ?)
        `, [session.keyId, domain], function(err) {
            if (err) {
                res.status(500).json({ success: false, message: 'Gagal menambah whitelist' });
            } else {
                res.json({ success: true, message: 'Whitelist berhasil ditambahkan' });
            }
        });
    });
});

// Delete whitelist
app.post('/api/user/delete-whitelist', (req, res) => {
    const { sessionId, whitelistId } = req.body;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'user') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    db.run('DELETE FROM whitelist WHERE id = ?', [whitelistId], function(err) {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal menghapus whitelist' });
        } else {
            res.json({ success: true, message: 'Whitelist berhasil dihapus' });
        }
    });
});

// Get whitelist
app.get('/api/user/whitelist', (req, res) => {
    const { sessionId } = req.query;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'user') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    const session = activeSessions.get(sessionId);
    
    db.all(`
        SELECT w.* FROM whitelist w
        JOIN access_keys ak ON w.user_id = ak.user_id
        WHERE ak.id = ?
    `, [session.keyId], (err, rows) => {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal mengambil whitelist' });
        } else {
            res.json({ success: true, whitelist: rows });
        }
    });
});

// Get raw link
app.get('/api/user/raw-link', (req, res) => {
    const { sessionId } = req.query;
    
    if (!activeSessions.has(sessionId) || activeSessions.get(sessionId).type !== 'user') {
        return res.status(401).json({ success: false, message: 'Unauthorized' });
    }
    
    const session = activeSessions.get(sessionId);
    
    db.all(`
        SELECT w.domain FROM whitelist w
        JOIN access_keys ak ON w.user_id = ak.user_id
        WHERE ak.id = ?
    `, [session.keyId], (err, rows) => {
        if (err) {
            res.status(500).json({ success: false, message: 'Gagal mengambil raw link' });
        } else {
            const domains = rows.map(row => row.domain).join('\n');
            res.json({ success: true, rawLink: domains });
        }
    });
});

// Socket.IO untuk realtime monitoring
io.on('connection', (socket) => {
    console.log('User connected:', socket.id);
    
    socket.on('join-admin', (sessionId) => {
        if (activeSessions.has(sessionId) && activeSessions.get(sessionId).type === 'admin') {
            socket.join('admin');
        }
    });
    
    socket.on('join-user', (sessionId) => {
        if (activeSessions.has(sessionId) && activeSessions.get(sessionId).type === 'user') {
            socket.join('user');
        }
    });
    
    socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
    });
});

// Auto logout setiap 30 menit
setInterval(() => {
    const now = Date.now();
    const thirtyMinutes = 30 * 60 * 1000;
    
    for (const [sessionId, session] of activeSessions.entries()) {
        if (now - session.loginTime > thirtyMinutes) {
            if (session.type === 'user') {
                // Deactivate session in database
                db.run('UPDATE user_sessions SET is_active = 0 WHERE key_id = ?', [session.keyId]);
                deviceSessions.delete(session.keyId);
            }
            activeSessions.delete(sessionId);
            
            // Notify via socket
            io.to('admin').emit('session-expired', { sessionId, type: session.type });
            io.to('user').emit('session-expired', { sessionId, type: session.type });
        }
    }
}, 60000); // Check setiap menit

// Update last activity setiap 5 menit
setInterval(() => {
    for (const [keyId, session] of deviceSessions.entries()) {
        db.run('UPDATE user_sessions SET last_activity = CURRENT_TIMESTAMP WHERE key_id = ?', [keyId]);
    }
}, 5 * 60 * 1000);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server berjalan di port ${PORT}`);
});
