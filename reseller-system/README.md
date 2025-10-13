# Reseller System

Sistem reseller dengan manajemen whitelist dan access key yang dilengkapi dengan pembatasan device dan auto logout.

## Fitur Utama

### 🔐 Sistem Autentikasi
- **Admin Panel**: Login dengan password `Kurr123@`
- **User Login**: Menggunakan access key yang dibuat admin
- **Session Management**: Auto logout setiap 30 menit
- **Device Limitation**: Hanya 1 device per key

### 🛡️ Admin Panel
- **Manajemen Key**: Create/Delete access key
- **Manajemen User**: Update limit whitelist per user
- **Overview**: Statistik sistem realtime
- **Realtime Monitoring**: Socket.IO untuk update realtime

### 📊 User Dashboard
- **Whitelist Management**: Add/Delete/Check whitelist
- **Limit Control**: Default 25 whitelist, bisa diubah admin
- **Raw Link**: Generate link mentah semua whitelist
- **Session Info**: Informasi session dan auto logout

### 🔄 Realtime Features
- **Auto Logout**: Setiap 30 menit otomatis logout
- **Device Check**: Real-time monitoring device aktif
- **Session Expiry**: Notifikasi via Socket.IO
- **Force Logout**: Button logout manual

## Instalasi

1. **Clone/Download proyek**
```bash
cd reseller-system
```

2. **Install dependencies**
```bash
npm install
```

3. **Setup database**
```bash
# Database akan otomatis dibuat saat pertama kali menjalankan server
```

4. **Jalankan server**
```bash
npm start
# atau untuk development
npm run dev
```

5. **Akses aplikasi**
- **Login Page**: http://localhost:3000
- **Admin Panel**: http://localhost:3000/admin
- **User Dashboard**: http://localhost:3000/dashboard

## Konfigurasi

### Database
- Menggunakan SQLite3
- File database: `./database/reseller.db`
- Schema otomatis dibuat dari `./database/schema.sql`

### Port
- Default: 3000
- Bisa diubah via environment variable `PORT`

### Admin Credentials
- **Username**: admin
- **Password**: Kurr123@

## Struktur Proyek

```
reseller-system/
├── public/                 # Frontend files
│   ├── login.html         # Halaman login user
│   ├── admin.html         # Admin panel
│   └── dashboard.html     # User dashboard
├── server/
│   └── app.js            # Main server file
├── database/
│   ├── schema.sql        # Database schema
│   └── reseller.db       # SQLite database (auto-created)
├── package.json          # Dependencies
└── README.md            # Documentation
```

## API Endpoints

### Admin Endpoints
- `POST /api/admin/login` - Login admin
- `POST /api/admin/create-key` - Buat access key baru
- `POST /api/admin/delete-key` - Hapus access key
- `GET /api/admin/keys` - Daftar semua keys
- `GET /api/admin/users` - Daftar semua users
- `POST /api/admin/update-limit` - Update limit user

### User Endpoints
- `POST /api/user/login` - Login dengan key
- `POST /api/user/logout` - Logout user
- `POST /api/user/add-whitelist` - Tambah whitelist
- `POST /api/user/delete-whitelist` - Hapus whitelist
- `GET /api/user/whitelist` - Daftar whitelist
- `GET /api/user/raw-link` - Generate raw link

## Keamanan

### Device Limitation
- Setiap key hanya bisa digunakan di 1 device
- Device diidentifikasi berdasarkan User-Agent + IP
- Session aktif akan memblokir login di device lain

### Session Management
- Auto logout setiap 30 menit
- Session disimpan di memory dan database
- Real-time monitoring via Socket.IO

### Rate Limiting
- 100 requests per 15 menit per IP
- Helmet.js untuk security headers
- CORS protection

## Penggunaan

### Untuk Admin
1. Login ke `/admin` dengan password `Kurr123@`
2. Buat access key baru di tab "Manajemen Key"
3. Kelola limit user di tab "Manajemen User"
4. Monitor aktivitas di tab "Overview"

### Untuk User
1. Login di halaman utama dengan access key
2. Tambah whitelist di tab "Whitelist"
3. Generate raw link di tab "Raw Link"
4. Monitor session di tab "Overview"

## Troubleshooting

### Database Error
```bash
# Hapus database dan restart server
rm database/reseller.db
npm start
```

### Port Already in Use
```bash
# Ubah port di environment
PORT=3001 npm start
```

### Session Issues
- Clear browser localStorage
- Restart server untuk reset semua session

## Dependencies

- **express**: Web framework
- **socket.io**: Real-time communication
- **sqlite3**: Database
- **bcryptjs**: Password hashing
- **uuid**: Generate unique IDs
- **cors**: Cross-origin requests
- **helmet**: Security headers
- **express-rate-limit**: Rate limiting

## License

MIT License - Silakan gunakan sesuai kebutuhan.
