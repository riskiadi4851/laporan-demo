#!/data/data/com.termux/files/usr/bin/sh
# Skrip Termux: download_and_install.sh (disesuaikan untuk FreelaporanPro-1.2.0.apk)
# Gunakan: chmod +x download_and_install.sh
# Contoh: ./download_and_install.sh https://example.com/apk/FreelaporanPro-1.2.0.apk
# Jika tidak memberikan argumen, skrip akan menggunakan URL default (ganti URL default ini sesuai server Anda).

DEFAULT_APK_URL="https://example.com/apk/FreelaporanPro-1.2.0.apk"

if [ -z "$1" ]; then
  APK_URL="$DEFAULT_APK_URL"
else
  APK_URL="$1"
fi

echo "[*] URL APK: $APK_URL"

# Pastikan izin storage sudah diberikan (jika Termux mendukung)
termux-setup-storage 2>/dev/null || true

DOWNLOAD_DIR="$HOME/storage/shared/Download"
mkdir -p "$DOWNLOAD_DIR"
APK_NAME="$(basename "$APK_URL")"
APK_PATH="$DOWNLOAD_DIR/$APK_NAME"

echo "[*] Mengunduh $APK_URL ke $APK_PATH ..."
# prefer curl, fallback to wget
if command -v curl >/dev/null 2>&1; then
  curl -L --progress-bar -o "$APK_PATH" "$APK_URL"
else
  wget -q -O "$APK_PATH" "$APK_URL"
fi

if [ ! -f "$APK_PATH" ]; then
  echo "[!] Unduhan gagal atau file tidak ditemukan di $APK_PATH"
  exit 2
fi

echo "[*] Unduhan selesai."

# Coba buka installer menggunakan termux-open (jika tersedia), lalu am intent, lalu pm install (root)
if command -v termux-open >/dev/null 2>&1; then
  echo "[*] Membuka file dengan termux-open..."
  termux-open "$APK_PATH"
  echo "[*] Bila tidak muncul installer, cek notifikasi dan berikan izin pemasangan dari sumber tidak dikenal."
  exit 0
fi

# fallback: gunakan am (Activity Manager) untuk membuka installer
if command -v am >/dev/null 2>&1; then
  echo "[*] Menjalankan intent untuk membuka installer..."
  am start -a android.intent.action.VIEW -d "file://$APK_PATH" -t "application/vnd.android.package-archive" --user 0 || \
    am start -a android.intent.action.VIEW -d "content://$APK_PATH" -t "application/vnd.android.package-archive" --user 0
  echo "[*] Jika installer tidak muncul, coba buka file manager dan ketuk $APK_PATH"
  exit 0
fi

# Jika perangkat mempunyai pm dan user root, bisa install langsung
if command -v pm >/dev/null 2>&1; then
  echo "[*] Mencoba pm install (membutuhkan akses root)..."
  pm install -r "$APK_PATH" && echo "[*] Terpasang." && exit 0
fi

echo "[!] Tidak dapat langsung membuka installer otomatis di Termux. Silakan buka file manager, pergi ke folder Download, lalu ketuk $APK_NAME untuk memasang."