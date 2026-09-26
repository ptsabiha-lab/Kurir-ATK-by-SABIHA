# Kurir ATK — Flutter App

Aplikasi client (Android, iOS, Web) untuk **Kurir ATK**, mengonsumsi REST API Laravel di folder induk (`../`).

## Status

- ✅ Autentikasi: Register, Login, Logout, cek sesi (token Sanctum tersimpan aman via `flutter_secure_storage`)
- 🚧 Katalog produk, pemesanan, tracking pengiriman — menyusul

## Setup

```bash
flutter pub get
```

### Menjalankan aplikasi

Sesuaikan `API_BASE_URL` dengan alamat backend Laravel:

```bash
# Web (Chrome)
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api

# Android emulator (10.0.2.2 = alias localhost dari host)
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000/api

# iOS simulator
flutter run -d "iPhone 15" --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

### Install ke HP Android fisik (kabel USB)

Lihat **[INSTALL_HP.md](INSTALL_HP.md)** — cukup `bash install_hp.sh`, caranya sama untuk setiap versi.

Jika `API_BASE_URL` tidak di-set, default-nya `http://127.0.0.1:8000/api` (lihat `lib/config/api_config.dart`).

## Struktur

```
lib/
├── config/       # Konfigurasi (base URL API)
├── models/       # Model data (User, dst.)
├── services/     # API client (Dio) & secure token storage
├── providers/    # State management (ChangeNotifier)
├── screens/
│   ├── auth/     # Login, Register
│   └── home/     # Halaman utama setelah login
└── main.dart
```

## Keamanan

- Token disimpan di **Keychain (iOS)** / **Keystore-backed EncryptedSharedPreferences (Android)** via `flutter_secure_storage` — bukan `SharedPreferences` biasa yang bisa dibaca root/rooted device.
- Token otomatis dihapus saat server merespons `401 Unauthenticated`.
- Tidak ada credential yang di-hardcode di source code.
