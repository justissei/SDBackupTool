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
echo -e "${CYAN}======= Pilih Storage untuk Restore =======${RESET}"
TARGET="/storage/emulated/0"  # Termux default storage
echo -e "  ${BLUE}1) InternalStorage${RESET}"

read -p "Masukkan folder backup di storage: " BACKUP
[ ! -d "$BACKUP" ] && echo -e "${CROSS} Folder tidak ditemukan!" && exit 1

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
echo -e "\nRestore selesai! Tekan ENTER untuk keluar..."
read
