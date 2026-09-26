# Kurir ATK — Versi 1.1

Arsip kode sumber **Kurir ATK by SABIHA versi 1.1** (dirilis 2026-09-26).
Aplikasi: `1.1.0` (build 2).

Folder ini hanya arsip — pengembangan aktif ada di `backend/` dan `mobile/` di root repo.
Daftar perubahan versi ini ada di [CHANGELOG.md](../../CHANGELOG.md).

## Menjalankan versi ini

```bash
cd versions/v1.1/backend
composer install && cp .env.example .env && php artisan key:generate
touch database/database.sqlite && php artisan migrate --seed
php artisan serve
```

Lalu buka folder `versions/v1.1/mobile` di Android Studio dan tekan Run.
