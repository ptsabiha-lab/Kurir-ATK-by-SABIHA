#!/bin/bash
# Setup otomatis backend Laravel untuk Kurir ATK.
# Jalankan dari root folder project: bash setup.sh

set -e

cd "$(dirname "$0")/backend" 2>/dev/null || {
  echo "ERROR: Folder 'backend' tidak ditemukan."
  echo "Pastikan script ini ada di root folder Kurir-ATK-by-SABIHA."
  exit 1
}

if [ ! -f "artisan" ]; then
  echo "ERROR: File 'artisan' tidak ditemukan di folder backend/."
  exit 1
fi

echo "==> Folder project terverifikasi."

echo "==> Menginstall dependency PHP (composer install)..."
composer install

if [ ! -f ".env" ]; then
  echo "==> Membuat file .env dari .env.example..."
  cp .env.example .env
else
  echo "==> File .env sudah ada, dilewati."
fi

if ! grep -q "^APP_KEY=base64" .env 2>/dev/null; then
  echo "==> Generate application key..."
  php artisan key:generate
else
  echo "==> APP_KEY sudah ada, dilewati."
fi

if [ ! -f "database/database.sqlite" ]; then
  echo "==> Membuat file database SQLite..."
  touch database/database.sqlite
else
  echo "==> Database SQLite sudah ada, dilewati."
fi

echo "==> Menjalankan migration..."
php artisan migrate --force

USER_COUNT=$(php artisan tinker --execute="echo \App\Models\User::count();" 2>/dev/null | tail -1)
if [ "$USER_COUNT" = "0" ]; then
  echo "==> Menjalankan seeder (data demo)..."
  php artisan db:seed --force
else
  echo "==> Database sudah punya data, seeder dilewati."
fi

echo ""
echo "=================================================="
echo "  SETUP SELESAI!"
echo "=================================================="
echo ""
echo "Langkah berikutnya:"
echo "  1. Jalankan backend:"
echo "       cd backend && php artisan serve --host=0.0.0.0"
echo "  2. Buka folder 'mobile' di Android Studio, jalankan emulator, lalu tekan Run."
echo "     (Emulator otomatis terhubung ke http://10.0.2.2:8000/api)"
echo ""
echo "Akun demo:"
echo "  Admin    : admin@kuriratk.test / password"
echo "  Kurir    : kurir@kuriratk.test / password"
echo "  Customer : customer@kuriratk.test / password"
echo ""
