# 🔐 Whitelist Manager

Aplikasi web untuk mengelola daftar username yang diizinkan (whitelist) menggunakan Supabase sebagai database. Siap untuk di-deploy ke Heroku tanpa konfigurasi manual!

## ✨ Fitur

- ➕ **Add Whitelist**: Tambah username ke daftar whitelist
- 🗑️ **Delete Whitelist**: Hapus username dari daftar whitelist  
- 🔍 **Check Whitelist**: Cek apakah username ada di whitelist
- 📋 **Get Raw Link**: Ambil semua username dalam format raw (per line)
- 📋 **Copy to Clipboard**: Salin hasil raw link ke clipboard
- 🌐 **Heroku Ready**: Siap di-deploy ke Heroku dengan environment variables
- 📊 **Real-time Stats**: Tampilkan statistik whitelist secara real-time
- 🔄 **Auto Status Check**: Cek status server otomatis

## 🚀 Quick Start

### Option 1: One-Click Deploy ke Heroku (Recommended)
```bash
# Windows
deploy.bat

# Linux/Mac
chmod +x deploy.sh
./deploy.sh
```
**✅ Environment variables sudah AUTO-SET! Tidak perlu konfigurasi manual!**

### Option 2: Manual Deploy
1. **Setup Supabase**: Jalankan `supabase_setup.sql` di Supabase Dashboard
2. **Deploy ke Heroku**: Ikuti panduan di `DEPLOYMENT.md`
3. **Done!** Aplikasi langsung online

### Option 3: Run Local
1. **Install Dependencies**: `npm install`
2. **Run Server**: `npm start`
3. **Open**: http://localhost:3000

## 📁 Struktur File

```
├── server.js               # Express server dengan auto-configured Supabase
├── package.json            # Dependencies dan scripts
├── Procfile               # Heroku deployment config
├── deploy.sh              # Auto deploy script (Linux/Mac)
├── deploy.bat             # Auto deploy script (Windows)
├── public/
│   └── index.html         # Frontend aplikasi (no config needed)
├── supabase_setup.sql     # Script SQL untuk setup database
├── env.example            # Template environment variables
├── .gitignore            # Git ignore rules
├── DEPLOYMENT.md         # Panduan deployment ke Heroku
└── README.md             # Dokumentasi ini
```

## 🗄️ Database Schema

### Tabel `whitelist`
- `id`: Primary key (auto increment)
- `username`: Username yang diwhitelist (unique)
- `created_at`: Timestamp pembuatan
- `updated_at`: Timestamp update terakhir

### Functions yang Tersedia
- `get_whitelist_raw()`: Ambil semua username sebagai text
- `bulk_insert_whitelist(usernames[])`: Insert multiple username sekaligus
- `bulk_delete_whitelist(usernames[])`: Delete multiple username sekaligus
- `check_multiple_whitelist(usernames[])`: Check multiple username sekaligus

## 🔧 Konfigurasi

### Row Level Security (RLS)
Script setup menggunakan RLS dengan policy public untuk kemudahan testing. Untuk produksi, sesuaikan policy sesuai kebutuhan keamanan.

### Customization
Anda dapat mengubah:
- Warna tema di CSS
- Nama tabel dan kolom di SQL
- Policy keamanan di Supabase

## 📱 Responsive Design

Aplikasi sudah responsive dan dapat digunakan di:
- Desktop
- Tablet  
- Mobile

## 🛡️ Keamanan

- Menggunakan Supabase RLS untuk kontrol akses
- Input validation di frontend
- Error handling yang komprehensif

## 🎨 UI/UX Features

- Modern gradient design
- Loading indicators
- Success/error notifications
- Copy to clipboard functionality
- Keyboard support (Enter key)

## 📝 Contoh Output Raw Link

```
arix12
asaw1
adcasaww1
```

## 🔄 Update dan Maintenance

Untuk update database schema atau menambah fitur:
1. Edit `supabase_setup.sql`
2. Jalankan script di Supabase SQL Editor
3. Update `index.html` jika diperlukan

## 🆘 Troubleshooting

### Error "Could not find the table 'public.whitelist'"
**Solusi**: Jalankan script `setup_database.sql` di Supabase Dashboard
1. Buka Supabase Dashboard → SQL Editor
2. Copy-paste isi `setup_database.sql`
3. Klik "Run"
4. Refresh halaman aplikasi

### Error "Failed to connect to Supabase"
- Pastikan URL dan Key sudah benar
- Cek koneksi internet
- Pastikan project Supabase aktif

### Error "Table doesn't exist"
- Jalankan script `setup_database.sql` terlebih dahulu
- Pastikan script berhasil dijalankan tanpa error

### Error "Permission denied"
- Cek RLS policy di Supabase
- Pastikan policy mengizinkan operasi yang diperlukan

## 📞 Support

Jika mengalami masalah, cek:
1. Console browser untuk error JavaScript
2. Network tab untuk error API
3. Supabase logs di dashboard

---

**Dibuat dengan ❤️ menggunakan HTML, CSS, JavaScript, dan Supabase**
