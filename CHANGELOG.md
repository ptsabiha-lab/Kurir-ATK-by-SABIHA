# Changelog — Kurir ATK by SABIHA

Semua perubahan penting per versi. Arsip kode sumber setiap versi ada di folder [`versions/`](versions/).

## [v1.1] - 2026-09-26

Menggabungkan fitur v1.0 dengan redesain UI biru — sebelumnya keduanya ada di
branch terpisah sehingga APK yang terpasang di HP hanya berisi salah satunya
(tampilan lama tanpa menu kurir, atau tampilan baru tanpa keranjang/pesanan).

### Aplikasi (mobile/)
- Tampilan baru bertema biru untuk semua role: splash, login/daftar, Beranda,
  Katalog, detail produk, Akun
- Menu bawah per role: pelanggan Beranda/Katalog/Keranjang/Pesanan/Akun,
  kurir Pengiriman/Akun, admin Pesanan/Katalog/Akun
- Tombol "Tambah" di detail produk kini benar-benar masuk keranjang
  (sebelumnya hanya pesan "segera hadir"); tab Pesanan menampilkan riwayat asli
- Ikon aplikasi & layar pembuka Android memakai logo Kurir ATK (bukan logo Flutter)
- Perbaikan: total & tombol Checkout di Keranjang berantakan/hilang akibat tema tombol
- Perbaikan: notifikasi "ditambahkan ke keranjang" tidak pernah hilang dan menutupi tombol Checkout
- Warna layar keranjang, pesanan, dan pengiriman diselaraskan dengan tema

## [v1.0] - 2026-09-26

Rilis pertama aplikasi Android (Flutter) + backend Laravel.

### Aplikasi (mobile/)
- Login, daftar akun, logout, sesi tersimpan aman di perangkat
- Katalog produk: pencarian, filter kategori, detail produk
- Keranjang belanja: tambah/ubah jumlah (dibatasi stok), badge jumlah di menu
- Checkout dengan alamat pengiriman & catatan
- Riwayat & detail pesanan, pembatalan pesanan yang masih menunggu konfirmasi
- **Kurir**: daftar tugas pengiriman, detail tujuan & barang, update status
  (Diambil → Dalam Perjalanan → Terkirim / Gagal dengan alasan)
- **Admin**: kelola semua pesanan (filter status), ubah status, tugaskan kurir
- Menu bawah menyesuaikan role (pelanggan / kurir / admin)
- Android: izin internet, nama aplikasi "Kurir ATK", URL API otomatis `10.0.2.2` di emulator
- Versi aplikasi & alamat server tampil di halaman Profil
- Alamat server bisa diatur dari aplikasi (ikon ⚙ di halaman login) + tombol Tes Koneksi — APK sama bisa dipakai di HP mana pun

### Backend (backend/)
- REST API Laravel + Sanctum: auth, katalog, pesanan, pengiriman, instansi
- `GET /api/couriers` (admin) untuk memilih kurir
- Membatalkan pesanan kini mengembalikan stok dan menyimpan riwayat (status `cancelled`), tidak lagi menghapus data
- Menugaskan kurir memvalidasi role kurir dan otomatis mengubah pesanan menjadi `processing`
- Pelanggan bisa melihat pengiriman untuk pesanannya sendiri
- Dependency composer dikunci ke PHP 8.3
- Feature test alur pesanan & pengiriman
