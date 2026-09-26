#!/bin/bash
# Install aplikasi Kurir ATK ke HP Android lewat kabel USB.
# Panduan lengkap: INSTALL_HP.md
#
# Pemakaian (dari folder flutter_app):
#   bash install_hp.sh          -> build versi di pubspec.yaml lalu install ke HP
#   bash install_hp.sh sambung  -> hanya sambungkan ulang HP ke backend
#                                  (dipakai setelah kabel dicabut lalu dicolok lagi)

set -e
cd "$(dirname "$0")"

PORT=8000
API_BASE_URL="http://127.0.0.1:${PORT}/api"
PACKAGE="com.kuriratk.kurir_atk"
APK="build/app/outputs/flutter-apk/app-release.apk"

gagal() {
  echo ""
  echo "ERROR: $1"
  exit 1
}

# --- 1. Cari adb (bawaan Android SDK) ---------------------------------------
ADB="$(command -v adb || true)"
if [ -z "$ADB" ]; then
  for kandidat in \
    "$ANDROID_HOME/platform-tools/adb" \
    "$HOME/Library/Android/sdk/platform-tools/adb" \
    "$HOME/Android/Sdk/platform-tools/adb"; do
    if [ -x "$kandidat" ]; then
      ADB="$kandidat"
      break
    fi
  done
fi
[ -n "$ADB" ] || gagal "adb tidak ditemukan. Install Android SDK Platform-Tools (lihat INSTALL_HP.md, Persiapan langkah 1)."

# --- 2. Pastikan tepat 1 HP tersambung & sudah diizinkan ---------------------
"$ADB" start-server >/dev/null 2>&1
DEVICES="$("$ADB" devices | tail -n +2 | grep -v '^$' || true)"

if echo "$DEVICES" | grep -q "unauthorized"; then
  gagal "HP belum mengizinkan laptop ini. Buka layar HP, tekan 'Izinkan' pada pop-up 'Izinkan USB debugging?', lalu jalankan script lagi."
fi

SERIALS="$(echo "$DEVICES" | awk '$2 == "device" {print $1}')"
JUMLAH="$(echo "$SERIALS" | grep -c . || true)"

[ "$JUMLAH" -ge 1 ] || gagal "HP tidak terdeteksi. Cek kabel data, pastikan USB debugging aktif, dan mode USB = 'Transfer file'."
[ "$JUMLAH" -eq 1 ] || gagal "Terdeteksi $JUMLAH perangkat. Colokkan hanya 1 HP (dan tutup emulator)."

SERIAL="$SERIALS"
MODEL="$("$ADB" -s "$SERIAL" shell getprop ro.product.model | tr -d '\r')"
echo "==> HP terdeteksi: $MODEL ($SERIAL)"

# --- 3. Sambungkan localhost:8000 di HP ke backend di laptop ------------------
sambungkan() {
  "$ADB" -s "$SERIAL" reverse "tcp:${PORT}" "tcp:${PORT}" >/dev/null
  echo "==> HP tersambung ke backend laptop (port ${PORT})."
  if command -v curl >/dev/null 2>&1 && ! curl -s -o /dev/null "http://127.0.0.1:${PORT}/api/products"; then
    echo "    PERINGATAN: backend belum jalan. Buka terminal lain lalu jalankan:"
    echo "      php artisan serve"
  fi
}

if [ "$1" = "sambung" ]; then
  sambungkan
  exit 0
fi

# --- 4. Build APK release -----------------------------------------------------
command -v flutter >/dev/null 2>&1 || gagal "flutter tidak ditemukan. Pastikan Flutter SDK sudah terinstall dan ada di PATH."

VERSI="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
VERSI_NAMA="${VERSI%%+*}"
VERSI_KODE="${VERSI##*+}"
echo "==> Versi yang akan diinstall: $VERSI_NAMA (build $VERSI_KODE)"

KODE_TERPASANG="$("$ADB" -s "$SERIAL" shell dumpsys package "$PACKAGE" 2>/dev/null \
  | grep -m1 -o 'versionCode=[0-9]*' | cut -d= -f2 || true)"
if [ -n "$KODE_TERPASANG" ]; then
  echo "    Di HP saat ini terpasang build $KODE_TERPASANG."
  if [ "$VERSI_KODE" -lt "$KODE_TERPASANG" ]; then
    gagal "Nomor build baru ($VERSI_KODE) lebih kecil dari yang terpasang ($KODE_TERPASANG). Naikkan angka setelah '+' di pubspec.yaml."
  fi
fi

echo "==> flutter pub get..."
flutter pub get

echo "==> Build APK release (beberapa menit)..."
flutter build apk --release --dart-define=API_BASE_URL="$API_BASE_URL"

[ -f "$APK" ] || gagal "File APK tidak ditemukan di $APK."

mkdir -p rilis
SALINAN="rilis/kurir-atk-v${VERSI_NAMA}.apk"
cp "$APK" "$SALINAN"
echo "==> Salinan APK disimpan di: flutter_app/$SALINAN"

# --- 5. Install ke HP (update, data login tetap tersimpan) --------------------
echo "==> Menginstall ke HP..."
if ! HASIL="$("$ADB" -s "$SERIAL" install -r "$APK" 2>&1)" || ! echo "$HASIL" | grep -q "Success"; then
  echo "$HASIL"
  if echo "$HASIL" | grep -q "INSTALL_FAILED_UPDATE_INCOMPATIBLE"; then
    gagal "Aplikasi di HP dibuat dari laptop lain (tanda tangan beda). Hapus dulu aplikasinya: \"$ADB\" uninstall $PACKAGE  lalu jalankan script lagi. (Data login di HP akan hilang.)"
  fi
  gagal "Install gagal. Lihat pesan di atas. Pastikan juga 'Install via USB' diizinkan di Opsi Developer (HP Xiaomi/Oppo/Vivo)."
fi
echo "==> Install berhasil."

sambungkan

"$ADB" -s "$SERIAL" shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true

echo ""
echo "=================================================="
echo "  SELESAI: Kurir ATK v$VERSI_NAMA terpasang di $MODEL"
echo "=================================================="
echo "Aplikasi bisa login selama HP tercolok ke laptop dan"
echo "'php artisan serve' berjalan. Kalau kabel dicabut-colok, jalankan:"
echo "  bash install_hp.sh sambung"
