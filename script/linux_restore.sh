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

# ======== Fungsi restore folder ========
restore_folder() {
    SRC="$1"
    DEST="$2"
    FOLDERNAME=$(basename "$SRC")
    mkdir -p "$DEST/$FOLDERNAME"

    if [ -d "$DEST/$FOLDERNAME" ] && [ "$(ls -A "$DEST/$FOLDERNAME")" ]; then
        echo -e "${WARN} Kamu sudah restore folder $FOLDERNAME sebelumnya!"
        read -p "Lanjut restore folder ini? (y/n): " yn
        [[ "$yn" != [Yy] ]] && echo -e "${CROSS} Skip $FOLDERNAME" && return
    fi

    echo -e "${YELLOW}Restore $FOLDERNAME...${RESET}"
    for f in "$SRC"/*; do
        cp -r "$f" "$DEST/$FOLDERNAME/" 2>/dev/null
        echo -ne "${CYAN}Copying $(basename "$f")...${RESET}\r"
    done
    echo -e "\n${CHECK} Restore $FOLDERNAME selesai!"
}

# ======== Menu Restore ========
clear
echo -e "${CYAN}======= Pilih Drive untuk Restore =======${RESET}"
mapfile -t DRIVE_LINES < <(lsblk -ln -o NAME,MOUNTPOINT,SIZE | grep -E '/run/media|/mnt')
[ ${#DRIVE_LINES[@]} -eq 0 ] && echo -e "${CROSS} Ga ada drive yang terpasang." && exit 1

# Display drives
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

read -p "Pilih nomor drive untuk restore: " DRIVE_CHOICE
DRIVE_INDEX=$((DRIVE_CHOICE-1))
BACKUP="${DRIVES[$DRIVE_INDEX]}"
[ -z "$BACKUP" ] || [ ! -d "$BACKUP" ] && echo -e "${CROSS} Pilihan tidak valid!" && exit 1
echo -e "${GREEN}Restore dari drive: $BACKUP${RESET}"

# Scan folder backup
mapfile -t FOLDERS < <(find "$BACKUP" -maxdepth 1 -mindepth 1 -type d ! -name ".*")
[ ${#FOLDERS[@]} -eq 0 ] && echo -e "${CROSS} Ga ada folder di backup!" && exit 1

echo -e "${CYAN}Folder yang tersedia di backup:${RESET}"
for i in "${!FOLDERS[@]}"; do
    BASENAME=$(basename "${FOLDERS[$i]}")
    echo -e "  ${BLUE}$((i+1))) $BASENAME${RESET}"
done

read -p "Masukkan nomor folder yang mau di-restore (pisahkan pake spasi): " -a CHOICES
for INDEX in "${CHOICES[@]}"; do
    INDEX=$((INDEX-1))
    [ -d "${FOLDERS[$INDEX]}" ] && restore_folder "${FOLDERS[$INDEX]}" "$USERDIR" || echo -e "${CROSS} Folder ${FOLDERS[$INDEX]} ga ditemukan!"
done

echo -e "\nSelesai! Tekan ENTER untuk kembali ke menu..."
read
