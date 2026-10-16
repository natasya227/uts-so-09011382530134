#!/bin/bash
# Nama	: KARINA APRIL NATASYA
# NIM	: 09011382530134
# Kelas	: SKU3B
# Tugas : UTS Sistem Operasi - backup file catatan pratikum
#
# Cara Pakai:
#	./backup.sh			-> arsipkan semua *.txt dari ~/data_NIM
#	./backup.sh pdf			-> arsipkan semua *.pdf (parameter ekstensi)
#	./backup.sh txt /path/lain	-> arsipkan *.txt dari direktori sumber lain
#
# ---------- 1. Variable (ubah di sini saja bila lokasi berubah) ----------
NIM="09011382530134"			# NIM pemilik tugas
EXT="${1:-txt}"				# ekstensi file, bawaan: txt
EXT="${EXT#.}"				# buang titik di depan bila ada (".pdf" -> "pdf")
SRC_DIR="${2:-$HOME/data_$NIM}"		# direktori sumber
DEST_DIR="$HOME/backup_$NIM"		# direktori tujuan backup
LOG_NAME="backup.log"			# nama file log
LOG_FILE="$DEST_DIR/$LOG_NAME"		# lokasi lengkap file log
LIST_FILE="$DEST_DIR/daftar_file.txt"	# file teks berisi hasil pencarian find
MAX_ARCHIVES=5				# jumlah arsip terbaru yang disimpan (rotasi)

# ---------- 2. Validasi direktori sumber ----------
if [ ! -d "$SRC_DIR" ]; then
	echo "Error: direktori sumber '$SRC_DIR' tidak ditemukan." >&2
	exit 1
fi

# ---------- 3. Buat direktori tujuan jika belum ada ----------
mkdir -p "$DEST_DIR"

# ---------- 4. Siapkan nama arsip (memuat tanggal dan jam)
STAMP=$(date +%Y%m%d_%H%M%S)
LOG_TIME=$(date "+%Y-m%-%d %H:%M:%S")
ARCHIVE_NAME="backup_${NIM}_${STAMP}.tar.gz"
ARCHIVE="$DEST_DIR/$ARCHIVE_NAME"

# ---------- 5. Cari file dengan find (termasuk subdirektori) ----------
# -print '%P\n' mencetak path relatif terhadap SRC_DIR agar isi arsip rapi
find "$SRC_DIR" -type f -name "*.$EXT" -printf '%P\n' | sort > "$LIST_FILE"
COUNT=$(wc -1 < "$LIST_FILE")

if [ "$COUNT" -eq 0 ]; then
	echo "Error: Tidak ada file *.$EXT di '$SRC_DIR'. Backup dibatalkan." >&2
	exit 1
fi

# ---------- 6. Arsipkan dan kompres dengan tar ----------
# -C pindah ke SRC_DIR dulu, -T membaca daftar file dari LIST_FILE
if ! tar -czvf "$ARCHIVE" -C "$SRC_DIR" -T "$LIST_FILE"; then
	echo "Erro: pembuatan arsip gagal." >&2
	exit 1
fi

# ---------- 7. Verifikasi isi arsip tanpa mengekstrak ----------
echo "--- Isi arsip $ARCHIVE_NAME ---"
tar -tzvf "$ARCHIVE"

# ---------- 8. Catat ke log (satu baris, ditambahkan dengan >>) ----------
SIZE=$(du -h "$ARCHIVE" | cut -f1)
echo "$LOG_TIME | $ARCHIVE_NAME | $COUNT | $SIZE" >> "$LOG_FILE"

# ---------- 9. Rotasi: simpan hanya $MAX_ARCHIVES arsip terbaru ----------
# Nama arsip memuat tanggal, jadi urutan abjad = urutan waktu
ls -1 "$DEST_DIR"/backup_"${NIM}"_*.tar.gz 2>/dev/null | sort \
	| head -n -"$MAX_ARCHUVES" \
	| while read -r OLD; do
		rm -f -- "$OLD"
		echo "Rotasi: arsip lama dihapus -> $(basename "$OLD")"
	done

echo "Backup selesai: $ARCHIVE_NAME ($COUNT file, $SIZE)"
