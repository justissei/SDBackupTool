#!/bin/bash
USERDIR=/home/justissei

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
PACKAGES=(coreutils findutils gvfs rsync)
echo -e "${CYAN}Cek dependencies...${RESET}"
sudo pacman -Sy --noconfirm >/dev/null

for PKG in "${PACKAGES[@]}"; do
    if ! pacman -Qi $PKG &> /dev/null; then
        echo -e "${YELLOW}$PKG belum ada, install...${RESET}"
        sudo pacman -S --noconfirm $PKG >/dev/null
    else
        echo -e "${CHECK} $PKG udah ada, skip."
    fi
done
echo -e "${GREEN}Semua dependencies siap!${RESET}"
sleep 1

# ======== Fungsi scan & tampil drive ========
scan_drives() {
    local paths=() labels=() sizes=()
    while read -r DEV MOUNT SIZE; do
        [ -z "$MOUNT" ] && continue
        [ ! -d "$MOUNT" ] && continue
        LABEL=$(lsblk -no LABEL "$DEV")
        [ -z "$LABEL" ] && LABEL=$(basename "$MOUNT")
        paths+=("$MOUNT")
        labels+=("$LABEL")
        sizes+=("$SIZE")
    done < <(lsblk -ln -o NAME,MOUNTPOINT,SIZE | grep -E '/run/media|/mnt')
    echo "${paths[@]}"
    echo "${labels[@]}"
    echo "${sizes[@]}"
}

display_drives() {
    DRIVES=()
    for i in "${!DRIVE_LINES[@]}"; do
        DEV=$(echo "${DRIVE_LINES[$i]}" | awk '{print "/dev/"$1}')
        MOUNT=$(echo "${DRIVE_LINES[$i]}" | awk '{print $2}')
        SIZE=$(echo "${DRIVE_LINES[$i]}" | awk '{print $3}')
        LABEL=$(lsblk -no LABEL "$DEV")
        [ -z "$LABEL" ] && LABEL=$(basename "$MOUNT")
        echo -e "  ${BLUE}$((i+1))) $LABEL ($SIZE)${RESET}"
        DRIVES[$i]="$MOUNT"
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

    echo -e "${YELLOW}BaS[$i]="$MOUNT"
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

    echo -e "${YELLOW}Bacckup $FOLDERNAME...${RESET}"
    for f in "$SRC"/*; do
        cp -r "$f" "$DEST/$FOLDERNAME/" 2>/dev/null
        echo -ne "${CYAN}Copying $(basename "$f")...${RESET}\r"
    done
    echo -e "\n${CHECK} Backup $FOLDERNAME selesai!"
}

# ======== Menu Backup ========
clear
echo -e "${CYAN}======= Pilih Drive untuk Backup =======${RESET}"
mapfile -t DRIVE_LINES < <(lsblk -ln -o NAME,MOUNTPOINT,SIZE | grep -E '/run/media|/mnt')
[ ${#DRIVE_LINES[@]} -eq 0 ] && echo -e "${CROSS} Ga ada drive yang terpasang." && exit 1
display_drives
read -p "Pilih nomor drive untuk backup: " DRIVE_CHOICE
DRIVE_INDEX=$((DRIVE_CHOICE-1))
TARGET="${DRIVES[$DRIVE_INDEX]}"
[ -z "$TARGET" ] || [ ! -d "$TARGET" ] && echo -e "${CROSS} Pilihan tidak valid!" && exit 1
echo -e "${GREEN}Target backup: $TARGET${RESET}"

# Scan folder user (skip hidden)
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
echo -e "\nSelesai! Tekan ENTER untuk kembali ke menu..."
read
