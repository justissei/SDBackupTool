#!/data/data/com.termux/files/usr/bin/bash
USERDIR=/data/data/com.termux/files/home

# ======== Warna & simbol ========
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"
CHECK="${GREEN}[✔]${RESET}"
CROSS="${RED}[✖]${RESET}"
WARN="${YELLOW}[⚠]${RESET}"

# ======== Cek dependencies ========
PACKAGES=(coreutils findutils rsync)
echo -e "${CYAN}Cek dependencies...${RESET}"
for PKG in "${PACKAGES[@]}"; do
    if ! command -v $PKG &> /dev/null; then
        echo -e "${YELLOW}$PKG belum ada, install...${RESET}"
        pkg install -y $PKG >/dev/null
    else
        echo -e "${CHECK} $PKG udah ada, skip."
    fi
done
echo -e "${GREEN}Semua dependencies siap!${RESET}"
sleep 1

# ======== Fungsi scan & tampil storage ========
scan_drives() {
    local paths=() labels=()
    # Termux: gunakan path storage
    paths+=("/storage/emulated/0")
    labels+=("InternalStorage")
    echo "${paths[@]}"
    echo "${labels[@]}"
}

display_drives() {
    DRIVES=()
    for i in "${!DRIVE_LABELS[@]}"; do
        echo -e "  ${BLUE}$((i+1))) ${DRIVE_LABELS[$i]}${RESET}"
        DRIVES[$i]="${DRIVE_PATHS[$i]}"
    done
}

# ======== Fungsi backup folder ========
backup_folder() {
    SRC="$1"
    DEST="$2"
    FOLDERNAME=$(basename "$SRC")
    mkdir -p "$DEST/$FOLDERNAME"

    if [ -d "$DEST/$FOLDERNAME" ] && [ "$(ls -A "$DEST/$FOLDERNAME")" ]; then
        echo -e "${WARN} Kamu sudah backup folder $FOLDERNAME sebelumnya!"
        read -p "Lanjut backup folder ini? (y/n): " yn
        [[ "$yn" != [Yy] ]] && echo -e "${CROSS} Skip $FOLDERNAME" && return
    fi

    echo -e "${YELLOW}Backup $FOLDERNAME...${RESET}"
    for f in "$SRC"/*; do
        cp -r "$f" "$DEST/$FOLDERNAME/" 2>/dev/null
        echo -ne "${CYAN}Copying $(basename "$f")...${RESET}\r"
    done
    echo -e "\n${CHECK} Backup $FOLDERNAME selesai!"
}

# ======== Menu Backup ========
clear
echo -e "${CYAN}======= Pilih Storage untuk Backup =======${RESET}"
mapfile -t DRIVE_PATHS < <(scan_drives)
mapfile -t DRIVE_LABELS < <(scan_drives)
display_drives

read -p "Pilih nomor storage untuk backup: " DRIVE_CHOICE
DRIVE_INDEX=$((DRIVE_CHOICE-1))
TARGET="${DRIVES[$DRIVE_INDEX]}"
[ -z "$TARGET" ] && echo -e "${CROSS} Pilihan tidak valid!" && exit 1
echo -e "${GREEN}Target backup: $TARGET${RESET}"

# Scan folder user
mapfile -d '' FOLDERS < <(find "$USERDIR" -maxdepth 1 -mindepth 1 -type d ! -name ".*" -print0)
echo -e "${CYAN}Folder yang tersedia untuk backup:${RESET}"
for i in "${!FOLDERS[@]}"; do
    F="${FOLDERS[$i]%$'\0'}"
    BASENAME=$(basename "$F")
    echo -e "  ${BLUE}$((i+1))) $BASENAME${RESET}"
    FOLDERS[$i]=$F
done

read -p "Masukkan nomor folder yang mau di-backup (pisahkan pake spasi): " -a CHOICES
for INDEX in "${CHOICES[@]}"; do
    INDEX=$((INDEX-1))
    [ -d "${FOLDERS[$INDEX]}" ] && backup_folder "${FOLDERS[$INDEX]}" "$TARGET" || echo -e "${CROSS} Folder ${FOLDERS[$INDEX]} ga ditemukan!"
done
echo -e "\nBackup selesai! Tekan ENTER untuk keluar..."
read
