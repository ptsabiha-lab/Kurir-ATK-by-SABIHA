#!/bin/bash
# Membuat rilis versi baru Kurir ATK.
#
# Pemakaian (dari folder root repo):
#   bash scripts/release.sh 1.1
#   bash scripts/release.sh 1.1 --tag     # sekalian commit + git tag v1.1
#
# Yang dilakukan:
#   1. Menaikkan versi aplikasi Flutter (pubspec.yaml & lib/config/app_info.dart).
#      Build number (versionCode Android) otomatis +1 dari versi sebelumnya.
#   2. Menulis file VERSION dan menambah entri di CHANGELOG.md.
#   3. Menyalin backend/ dan mobile/ ke versions/v<versi>/ sebagai arsip
#      kode sumber versi tersebut (tanpa vendor, build, .env, database).

set -euo pipefail

cd "$(dirname "$0")/.."

VERSION_INPUT="${1:-}"
DO_TAG="${2:-}"

if [[ ! "$VERSION_INPUT" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Pemakaian: bash scripts/release.sh <versi> [--tag]"
  echo "Contoh   : bash scripts/release.sh 1.1"
  exit 1
fi

# "1.1" -> nama folder v1.1, versi semantik 1.1.0
FOLDER_VERSION="$VERSION_INPUT"
if [[ "$VERSION_INPUT" =~ ^[0-9]+\.[0-9]+$ ]]; then
  SEMVER="$VERSION_INPUT.0"
else
  SEMVER="$VERSION_INPUT"
fi
TARGET="versions/v$FOLDER_VERSION"

if [ -e "$TARGET" ]; then
  echo "ERROR: $TARGET sudah ada. Versi yang sudah dirilis tidak boleh ditimpa."
  exit 1
fi

PUBSPEC="mobile/pubspec.yaml"
APP_INFO="mobile/lib/config/app_info.dart"

OLD_BUILD=$(grep -E '^version: ' "$PUBSPEC" | sed -E 's/.*\+([0-9]+)$/\1/')
NEW_BUILD=$((OLD_BUILD + 1))
if [ "$(cat VERSION 2>/dev/null)" = "$FOLDER_VERSION" ]; then
  # Rilis pertama dari versi yang sudah tercatat (mis. v1.0): build number tetap.
  NEW_BUILD=$OLD_BUILD
fi

echo "==> Versi baru : $SEMVER (build $NEW_BUILD) -> folder $TARGET"

sed -i.bak -E "s/^version: .*/version: $SEMVER+$NEW_BUILD/" "$PUBSPEC" && rm "$PUBSPEC.bak"
sed -i.bak -E "s/(version = ')[^']*(')/\1$SEMVER\2/; s/(buildNumber = )[0-9]+/\1$NEW_BUILD/" "$APP_INFO" && rm "$APP_INFO.bak"
echo "$FOLDER_VERSION" > VERSION

TODAY=$(date +%Y-%m-%d)
if ! grep -q "^## \[v$FOLDER_VERSION\]" CHANGELOG.md; then
  awk -v header="## [v$FOLDER_VERSION] - $TODAY" '
    !done && /^## / { print header; print ""; print "- (tulis perubahan di sini)"; print ""; done=1 }
    { print }
  ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
  echo "==> Entri baru ditambahkan di CHANGELOG.md — jangan lupa isi daftar perubahannya."
fi

echo "==> Menyalin kode sumber ke $TARGET ..."
mkdir -p "$TARGET"
rsync -a \
  --exclude 'vendor/' --exclude 'node_modules/' \
  --exclude '.env' --exclude 'database/*.sqlite' \
  --exclude 'storage/logs/*.log' --exclude 'storage/framework/cache/data/*' \
  --exclude 'storage/framework/sessions/*' --exclude 'storage/framework/views/*.php' \
  --exclude '.phpunit.result.cache' --exclude '.phpunit.cache/' \
  backend/ "$TARGET/backend/"
rsync -a \
  --exclude 'build/' --exclude '.dart_tool/' --exclude '.idea/' --exclude '*.iml' \
  --exclude '.flutter-plugins-dependencies' --exclude 'android/local.properties' \
  --exclude 'android/.gradle/' --exclude 'android/app/.cxx/' --exclude 'ios/Pods/' \
  --exclude 'ios/Flutter/Generated.xcconfig' --exclude 'ios/Flutter/flutter_export_environment.sh' \
  mobile/ "$TARGET/mobile/"

cat > "$TARGET/README.md" <<EOF
# Kurir ATK — Versi $FOLDER_VERSION

Arsip kode sumber **Kurir ATK by SABIHA versi $FOLDER_VERSION** (dirilis $TODAY).
Aplikasi: \`$SEMVER\` (build $NEW_BUILD).

Folder ini hanya arsip — pengembangan aktif ada di \`backend/\` dan \`mobile/\` di root repo.
Daftar perubahan versi ini ada di [CHANGELOG.md](../../CHANGELOG.md).

## Menjalankan versi ini

\`\`\`bash
cd versions/v$FOLDER_VERSION/backend
composer install && cp .env.example .env && php artisan key:generate
touch database/database.sqlite && php artisan migrate --seed
php artisan serve
\`\`\`

Lalu buka folder \`versions/v$FOLDER_VERSION/mobile\` di Android Studio dan tekan Run.
EOF

echo ""
echo "==> Selesai. Arsip versi $FOLDER_VERSION ada di $TARGET"

if [ "$DO_TAG" = "--tag" ] && grep -q "(tulis perubahan di sini)" CHANGELOG.md; then
  echo "CATATAN: CHANGELOG.md masih berisi placeholder, commit & tag dilewati."
  echo "Isi CHANGELOG.md, lalu: git add -A && git commit -m \"release: v$FOLDER_VERSION\" && git tag v$FOLDER_VERSION"
elif [ "$DO_TAG" = "--tag" ]; then
  git add VERSION CHANGELOG.md "$PUBSPEC" "$APP_INFO" "$TARGET"
  git commit -m "release: v$FOLDER_VERSION"
  git tag -a "v$FOLDER_VERSION" -m "Kurir ATK v$FOLDER_VERSION"
  echo "==> Commit & tag v$FOLDER_VERSION dibuat. Upload ke GitHub dengan:"
  echo "      git push && git push origin v$FOLDER_VERSION"
else
  echo "Langkah berikutnya:"
  echo "  1. Isi daftar perubahan di CHANGELOG.md"
  echo "  2. git add -A && git commit -m \"release: v$FOLDER_VERSION\""
  echo "  3. git push"
fi
