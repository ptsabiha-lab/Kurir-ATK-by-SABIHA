# 🗄️ Database Setup - MySQL Configuration

## Status Saat Ini
✅ **Database**: MySQL 8.0+  
✅ **Host**: localhost (127.0.0.1)  
✅ **Port**: 3306  
✅ **Database Name**: `kurir_atk_db`  

---

## 📋 Setup MySQL

### 1. Install MySQL (Jika belum ada)

**Ubuntu/Debian:**
```bash
sudo apt-get install mysql-server
sudo mysql_secure_installation
```

**macOS (Homebrew):**
```bash
brew install mysql@8.0
mysql.server start
```

**Windows:**
- Download dari: https://dev.mysql.com/downloads/mysql/
- Atau gunakan XAMPP/WAMP

---

### 2. Buat Database

```bash
mysql -u root -p

# Di MySQL prompt:
CREATE DATABASE kurir_atk_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'kurir_user'@'localhost' IDENTIFIED BY 'password_anda';
GRANT ALL PRIVILEGES ON kurir_atk_db.* TO 'kurir_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

### 3. Update .env Configuration

Edit file `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kurir_atk_db
DB_USERNAME=kurir_user
DB_PASSWORD=password_anda
```

**Atau gunakan root (untuk development):**
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kurir_atk_db
DB_USERNAME=root
DB_PASSWORD=
```

---

### 4. Run Migrations

```bash
# Generate APP_KEY jika belum ada
php artisan key:generate

# Run migrations
php artisan migrate

# Jika ingin reset (caution - hapus semua data):
php artisan migrate:fresh
```

---

### 5. Verify Connection

```bash
php artisan tinker

# Jalankan:
DB::connection()->getPdo();
# Jika berhasil, akan show: PDOConnection

exit
```

---

## 📊 Database Tables Structure

### Tables yang sudah dibuat:

1. **institutions** - Data instansi/organisasi
2. **users** - User authentication
3. **categories** - Kategori produk/barang
4. **products** - Produk/barang ATK
5. **orders** - Pesanan/pengadaan
6. **order_items** - Detail item dalam order
7. **deliveries** - Status pengiriman courier
8. **cache** - Cache data
9. **jobs** - Queue jobs
10. **personal_access_tokens** - API tokens

---

## 🔧 Useful Commands

```bash
# Lihat semua tables
php artisan tinker
DB::select("SHOW TABLES");

# Lihat struktur table
php artisan tinker
DB::select("DESCRIBE products");

# Fresh migration (reset semua)
php artisan migrate:fresh --seed

# Create new migration
php artisan make:migration create_table_name

# Run seeder
php artisan db:seed
```

---

## ✅ Checklist

- [ ] MySQL terinstall dan running
- [ ] Database `kurir_atk_db` dibuat
- [ ] User credentials di `.env` correct
- [ ] APP_KEY di `.env` di-generate (`php artisan key:generate`)
- [ ] Migrations berhasil (`php artisan migrate`)
- [ ] Connection verified (`php artisan tinker` + `DB::connection()->getPdo()`)

---

## 🚨 Troubleshooting

**Error: "SQLSTATE[HY000]: General error: 1030"**
```bash
# Restart MySQL
sudo systemctl restart mysql
```

**Error: "Access denied for user 'root'@'localhost'"**
```bash
# Reset MySQL root password
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';"
```

**Error: "Unknown database 'kurir_atk_db'"**
```bash
# Create database lagi
mysql -u root -p < database/schema.sql
```

---

## 📞 Next Steps

1. Setup MySQL di environment Anda
2. Update credentials di `.env`
3. Run `php artisan migrate`
4. Start building! 🚀
