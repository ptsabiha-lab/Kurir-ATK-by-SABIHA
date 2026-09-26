# Kurir ATK — Flutter App

Aplikasi client (Android, iOS, Web) untuk **Kurir ATK**, mengonsumsi REST API Laravel di folder [`../backend`](../backend).

## Status

- ✅ Autentikasi: Register, Login, Logout, cek sesi (token Sanctum tersimpan aman via `flutter_secure_storage`)
- ✅ Katalog produk, keranjang, checkout, riwayat & pembatalan pesanan (pelanggan)
- ✅ Tugas pengiriman & update status (kurir)
- ✅ Kelola pesanan & tugaskan kurir (admin)

## Setup

### Android Studio

1. **Open** → pilih folder `mobile/` ini
2. Tunggu *Pub get* selesai, pilih emulator Android, tekan **Run ▶**

### Terminal

```bash
flutter pub get
```

### Menjalankan aplikasi

Sesuaikan `API_BASE_URL` dengan alamat backend Laravel:

```bash
# Web (Chrome)
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api

# Android emulator (otomatis memakai 10.0.2.2 = alias localhost dari host)
flutter run -d emulator-5554

# HP Android fisik (satu Wi-Fi, backend dijalankan dengan --host=0.0.0.0)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api

# iOS simulator
flutter run -d "iPhone 15" --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Jika `API_BASE_URL` tidak di-set, default-nya `http://10.0.2.2:8000/api` di Android dan `http://127.0.0.1:8000/api` di platform lain (lihat `lib/config/api_config.dart`).

### Build APK

```bash
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

Versi APK (versionName/versionCode) diambil dari `version:` di `pubspec.yaml`, yang diatur oleh `scripts/release.sh` di root repo.

## Struktur

```
lib/
├── config/          # Base URL API & versi aplikasi
├── models/          # User, Product, Category, Order, Delivery
├── services/        # API client (Dio), auth, katalog, pesanan, token storage
├── providers/       # State: auth, katalog, keranjang, sinyal refresh pesanan
├── widgets/         # Komponen bersama (daftar berhalaman, chip status, dll.)
├── screens/
│   ├── auth/        # Login, Register
│   ├── home/        # Menu bawah sesuai role, Profil
│   ├── catalog/     # Daftar & detail produk
│   ├── cart/        # Keranjang & checkout
│   ├── orders/      # Daftar & detail pesanan (+ aksi admin)
│   └── deliveries/  # Tugas pengiriman kurir
└── main.dart
```

## Keamanan

- Token disimpan di **Keychain (iOS)** / **Keystore-backed EncryptedSharedPreferences (Android)** via `flutter_secure_storage` — bukan `SharedPreferences` biasa yang bisa dibaca root/rooted device.
- Token otomatis dihapus saat server merespons `401 Unauthenticated`.
- Tidak ada credential yang di-hardcode di source code.
