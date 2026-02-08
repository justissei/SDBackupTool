# SD Card Backup Tool

Backup dan restore folder di Linux & Termux.  
Start lewat ./start.sh, backup/restore di folder script/.

---

## Struktur

start.sh
script/
 ├─ linux_backup.sh
 └─ linux_restore.sh
README.md

---

## Cara Pakai

1. Pastikan start.sh & script executable:
chmod +x start.sh script/*.sh
2. Jalankan:
./start.sh
3. Pilih menu: Backup / Restore / Exit

---

## Catatan

- Scan folder otomatis sesuai OS.
- Termux masih belom bisa menggunakna tools ini.  
- Setelah backup/restore selesai, kembali ke menu utama.  
- Dependencies Linux: coreutils, findutils, gvfs, rsync.
