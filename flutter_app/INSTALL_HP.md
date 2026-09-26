# Install Aplikasi ke HP Android (lewat Kabel USB)

Caranya **selalu sama untuk setiap versi**. Bagian A cukup dikerjakan sekali.
Bagian B diulang setiap kali ada versi baru.

---

## A. Persiapan (sekali saja)

### 1. Di laptop

- Flutter SDK sudah terinstall (cek: `flutter --version`).
- Android SDK sudah terinstall (biasanya ikut Android Studio). Cek: `flutter doctor` —
  baris **Android toolchain** harus centang hijau. Kalau ada tanda silang, jalankan
  `flutter doctor --android-licenses` lalu jawab `y` semua.

### 2. Di HP: aktifkan Opsi Developer

1. Buka **Setelan → Tentang ponsel**.
2. Ketuk **Nomor bentukan / Build number** sebanyak **7 kali** sampai muncul
   "Anda sekarang developer".
   - Xiaomi: ketuk **Versi MIUI / HyperOS**.
   - Samsung: **Tentang ponsel → Informasi perangkat lunak → Nomor bentukan**.
3. Kembali ke Setelan, buka **Opsi Developer** (biasanya di **Sistem** atau
   **Setelan tambahan**).
4. Aktifkan **USB debugging**.
5. Khusus Xiaomi/Oppo/Vivo: aktifkan juga **Install via USB**
   (kadang diminta login akun Mi / masukkan SIM).

### 3. Colok HP pertama kali

1. Colok HP ke laptop pakai **kabel data** (bukan kabel charge saja).
2. Kalau muncul pilihan mode USB di HP, pilih **Transfer file**.
3. Muncul pop-up **"Izinkan USB debugging?"** → centang
   **"Selalu izinkan dari komputer ini"** → **Izinkan**.

---

## B. Install / Update Versi (ulangi setiap versi baru)

### Langkah 1 — Nyalakan backend (Terminal 1)

```bash
cd ~/Documents/Kurir-ATK-by-SABIHA
php artisan serve
```

Biarkan terminal ini tetap terbuka.

### Langkah 2 — Install ke HP (Terminal 2)

Colok HP, lalu:

```bash
cd ~/Documents/Kurir-ATK-by-SABIHA/flutter_app
bash install_hp.sh
```

Script ini otomatis:
1. Mengecek HP tersambung & sudah diizinkan.
2. Build APK release sesuai versi di `pubspec.yaml`.
3. Menyimpan salinan APK di `flutter_app/rilis/kurir-atk-v<versi>.apk`.
4. Menginstall ke HP sebagai **update** (data login tidak hilang).
5. Menyambungkan HP ke backend di laptop, lalu membuka aplikasinya.

Selesai kalau muncul tulisan **SELESAI: Kurir ATK v... terpasang**.

### Kabel dicabut lalu dicolok lagi?

Tidak perlu install ulang. Cukup:

```bash
bash install_hp.sh sambung
```

---

## C. Cara Naik Versi

Buka `flutter_app/pubspec.yaml`, ubah baris `version:`:

```yaml
version: 1.1.0+2
#        ^^^^^ ^
#        |     └─ nomor build: WAJIB selalu naik (+1) setiap versi baru
#        └─────── nama versi yang terlihat user
```

| Versi | Tulis di pubspec.yaml |
|---|---|
| 1.1   | `version: 1.1.0+2` (sekarang) |
| 1.2   | `version: 1.2.0+3` |
| 1.2.1 | `version: 1.2.1+4` |
| 2.0   | `version: 2.0.0+5` |

Lalu ulangi **Bagian B**. Kalau nomor build lupa dinaikkan jadi lebih kecil,
script akan menolak dan memberi tahu.

---

## Catatan Penting

- **Aplikasi hanya bisa login selama HP tercolok ke laptop** dan `php artisan serve`
  jalan, karena backend-nya masih di laptop. Supaya bisa dipakai tanpa kabel,
  backend perlu di-online-kan ke server/hosting dengan HTTPS (tahap berikutnya).
- **Selalu build dari laptop yang sama.** APK saat ini ditandatangani dengan kunci
  debug milik laptop. Kalau build dari laptop lain, HP akan menolak update
  (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`) dan aplikasi lama harus dihapus dulu
  (data login hilang). Sebelum dibagikan ke banyak orang / Play Store, perlu dibuat
  *release keystore* sendiri.

## Masalah Umum

| Pesan | Solusi |
|---|---|
| `HP tidak terdeteksi` | Ganti kabel data, pilih mode **Transfer file**, cek USB debugging aktif. Cek manual: `adb devices` |
| `HP belum mengizinkan laptop ini` | Lihat layar HP, tekan **Izinkan** di pop-up USB debugging. |
| `adb tidak ditemukan` | Install Android Studio / Android SDK Platform-Tools, lalu cek `flutter doctor`. |
| `INSTALL_FAILED_USER_RESTRICTED` | Aktifkan **Install via USB** di Opsi Developer, atau tekan **Install** di pop-up HP saat proses install. |
| Aplikasi terbuka tapi gagal login / "tidak bisa terhubung" | Pastikan `php artisan serve` jalan, lalu `bash install_hp.sh sambung`. |
