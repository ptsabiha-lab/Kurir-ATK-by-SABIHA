# Kurir ATK by SABIHA

Aplikasi kurir & pengadaan Alat Tulis Kantor (ATK) untuk instansi pemerintahan, lembaga bisnis swasta, sekolah, dan umum. Backend berbasis **Laravel API** (token auth via Sanctum), dirancang untuk dikonsumsi oleh aplikasi **Flutter** (Android, iOS, dan Web).

## Tech Stack

- **Backend**: Laravel 13 (PHP 8.3), REST API
- **Auth**: Laravel Sanctum (token-based, cocok untuk mobile & web)
- **Database**: SQLite (development) — bisa diganti MySQL/PostgreSQL untuk production
- **Frontend (rencana)**: Flutter (Android, iOS, Web) — project terpisah, mengonsumsi API ini

## Struktur Data

| Tabel | Deskripsi |
|---|---|
| `users` | Akun dengan role: `admin`, `customer`, `kurir` |
| `institutions` | Instansi/lembaga pemesan (pemerintahan, swasta, pendidikan, lainnya) |
| `categories` | Kategori produk ATK |
| `products` | Produk ATK (harga dalam rupiah, stok, satuan) |
| `orders` | Pesanan (status: pending → confirmed → processing → shipped → delivered / cancelled) |
| `order_items` | Detail item per pesanan |
| `deliveries` | Penugasan kurir & tracking pengiriman |

## Setup Lokal

```bash
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
php artisan serve
```

### Akun Demo (dari seeder)

| Role | Email | Password |
|---|---|---|
| Admin | admin@kuriratk.test | password |
| Kurir | kurir@kuriratk.test | password |
| Customer | customer@kuriratk.test | password |

## Endpoint API Utama

Base URL: `/api`

**Publik:**
- `POST /register` — daftar akun baru
- `POST /login` — login, mengembalikan token Sanctum
- `GET /categories`, `GET /products` — lihat katalog

**Perlu token (`Authorization: Bearer <token>`):**
- `POST /logout`, `GET /me`
- `GET|POST /institutions`, `GET|POST /orders`, `GET|POST /deliveries`
- `POST|PUT|DELETE /categories`, `/products` (khusus admin)
- `PUT /deliveries/{id}` (admin atau kurir yang ditugaskan)

## Keamanan

- Password di-hash otomatis (bcrypt, via cast `hashed`)
- Autentikasi berbasis token (Sanctum), bukan session cookie — aman untuk multi-platform
- Rate limiting pada login (mencegah brute force)
- Otorisasi berbasis role (admin/kurir/customer) di setiap controller
- Transaksi database + row locking saat membuat order (mencegah race condition stok)
- `.env` dan `database/*.sqlite` tidak ikut ter-commit ke Git

## Roadmap

- [ ] Aplikasi Flutter (Android/iOS/Web) yang mengonsumsi API ini
- [ ] Upload gambar produk
- [ ] Notifikasi status pesanan (push/email)
- [ ] Payment gateway
