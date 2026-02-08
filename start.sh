#!/bin/bash

# ======== 1️⃣ Warna ========
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# ======== 2️⃣ Landing Page / Menu ========
while true; do
    clear
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${CYAN}       SD Card Backup Tool - Landing      ${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${GREEN}Pilih opsi:${RESET}"
    echo -e "  ${BLUE}1) Backup${RESET}"
    echo -e "  ${BLUE}2) Restore${RESET}"
    echo -e "  ${RED}3) Exit${RESET}"
    read -p "Masukkan nomor pilihan: " CHOICE
    CHOICE=$(echo "$CHOICE" | tr -d '[:space:]')

    case $CHOICE in
        1)
            # Panggil script backup terpisah
            if [ -f "./script/linux_backup.sh" ]; then
                ./script/linux_backup.sh
            else
                echo -e "${RED}backup.sh tidak ditemukan!${RESET}"
                read -p "Tekan ENTER untuk kembali ke menu..."
            fi
            ;;
        2)
            # Panggil script restore terpisah
            if [ -f "./script/linux_restore.sh" ]; then
                ./script/linux_restore.sh
            else
                echo -e "${RED}restore.sh tidak ditemukan!${RESET}"
                read -p "Tekan ENTER untuk kembali ke menu..."
            fi
            ;;
        3)
            echo -e "${RED}Keluar...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${RESET}"
            sleep 1
            ;;
    esac
done
5