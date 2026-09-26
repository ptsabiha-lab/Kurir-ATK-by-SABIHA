# Kurir ATK by SABIHA

Aplikasi kurir & pengadaan Alat Tulis Kantor (ATK) untuk instansi pemerintahan, lembaga bisnis swasta, sekolah, dan umum.

**Versi saat ini: lihat file [`VERSION`](VERSION)** • Riwayat perubahan: [`CHANGELOG.md`](CHANGELOG.md)

## Struktur Folder

```
Kurir-ATK-by-SABIHA/
├── backend/            ← Laravel API (PHP) — pengembangan aktif
├── mobile/             ← Aplikasi Flutter — buka folder ini di Android Studio
├── versions/           ← Arsip kode sumber per versi (tidak diedit)
│   └── v1.0/
│       ├── backend/
│       └── mobile/
├── scripts/release.sh  ← Membuat versi baru
├── setup.sh            ← Setup otomatis backend
├── VERSION
└── CHANGELOG.md
```

## Menjalankan (Development)

### 1. Backend Laravel

```bash
bash setup.sh
cd backend && php artisan serve --host=0.0.0.0
```

`--host=0.0.0.0` diperlukan agar backend bisa diakses dari emulator/HP.

### 2. Aplikasi Android di Android Studio

1. Android Studio → **File → Open** → pilih folder **`mobile/android`**
   (tanpa plugin Flutter pun bisa; kalau plugin Flutter terpasang, boleh buka `mobile/`)
2. Tunggu *Gradle Sync* selesai
3. Pilih device (HP via USB atau emulator), konfigurasi **app**, tekan **Run ▶**

> Mac Intel dengan RAM 8 GB akan sangat lambat menjalankan emulator.
> Lebih cepat uji langsung di HP (lihat bagian berikut).

### 3. Install di HP Android pribadi

**Cara A — kabel USB (dari Android Studio):**
1. Di HP: *Settings → About phone* → ketuk **Build number** 7x → kembali ke *Settings → System → Developer options* → aktifkan **USB debugging**
2. Colok HP ke Mac, izinkan "Allow USB debugging"
3. HP akan muncul di daftar device Android Studio → tekan **Run ▶**

**Cara B — file APK (tanpa kabel):**
```bash
cd mobile && flutter build apk --release
```
Kirim `mobile/build/app/outputs/flutter-apk/app-release.apk` ke HP (WhatsApp/Drive/Bluetooth), buka file-nya, izinkan *Install unknown apps*.

**Menghubungkan HP ke backend:**
1. HP & Mac harus di **Wi-Fi yang sama**
2. Jalankan backend dengan `cd backend && php artisan serve --host=0.0.0.0`
3. Cari IP Mac: `ipconfig getifaddr en0` (mis. `192.168.1.10`)
4. Di aplikasi, halaman login → ikon **⚙** (kanan atas) → isi `192.168.1.10:8000` → **Tes Koneksi** → **Simpan**

Jika tes koneksi gagal: cek firewall Mac (*System Settings → Network → Firewall*) dan pastikan Wi-Fi tidak memblokir antar-perangkat (Wi-Fi kantor/kampus/tamu sering begitu — pakai hotspot HP sebagai alternatif).

### Akun Demo

| Role | Email | Password | Menu di aplikasi |
|---|---|---|---|
| Customer | customer@kuriratk.test | password | Katalog, Keranjang, Pesanan, Profil |
| Kurir | kurir@kuriratk.test | password | Pengiriman, Profil |
| Admin | admin@kuriratk.test | password | Kelola Pesanan, Katalog, Profil |

### Alur Lengkap

1. **Customer** pilih produk → keranjang → checkout
2. **Admin** buka pesanan → *Tugaskan Kurir*
3. **Kurir** buka tugas → *Barang Sudah Diambil* → *Mulai Antar* → *Sudah Diterima*
4. **Customer** melihat status pesanan berubah menjadi *Diterima*

## Membuat Versi Baru

Setiap versi disimpan sebagai folder terpisah di `versions/`. Setelah fitur untuk versi berikutnya selesai dikerjakan di `backend/` dan `mobile/`:

```bash
bash scripts/release.sh 1.1
```

Skrip ini akan:
- menaikkan versi aplikasi (`mobile/pubspec.yaml` → `1.1.0+2`; build number = versionCode Android otomatis +1)
- memperbarui `VERSION` dan menambah entri di `CHANGELOG.md` (isi daftar perubahannya)
- menyalin `backend/` dan `mobile/` ke `versions/v1.1/`

Lalu commit & push ke GitHub:

```bash
git add -A && git commit -m "release: v1.1" && git push
```

Folder versi lama **tidak boleh diubah** — skrip menolak menimpa versi yang sudah ada.

## Tech Stack

- **Backend**: Laravel 13 (PHP 8.3), Sanctum token auth, SQLite (dev) / MySQL (production)
- **Mobile**: Flutter (Android, iOS, Web), Provider, Dio, flutter_secure_storage

Dokumentasi API ada di [`backend/README.md`](backend/README.md).

## Roadmap

- [ ] Upload gambar produk
- [ ] Notifikasi status pesanan (push/email)
- [ ] Payment gateway
- [ ] Kelola produk & kategori dari aplikasi (admin)
