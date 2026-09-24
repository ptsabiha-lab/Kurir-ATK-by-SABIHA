#!/bin/bash
# Setup otomatis backend Laravel untuk Kurir ATK.
# Jalankan dari dalam folder project: bash setup.sh

set -e

if [ ! -f "artisan" ]; then
  echo "ERROR: File 'artisan' tidak ditemukan di folder ini."
  echo "Pastikan Anda menjalankan script ini dari dalam folder Kurir-ATK-by-SABIHA."
  echo "Coba: cd ~/Documents/Kurir-ATK-by-SABIHA lalu jalankan lagi: bash setup.sh"
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
echo "  1. Jalankan backend:  php artisan serve"
echo "  2. Di terminal BARU, jalankan Flutter:"
echo "       cd flutter_app"
echo "       flutter pub get"
echo "       flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api"
echo ""
echo "Akun demo:"
echo "  Admin    : admin@kuriratk.test / password"
echo "  Kurir    : kurir@kuriratk.test / password"
echo "  Customer : customer@kuriratk.test / password"
echo ""
