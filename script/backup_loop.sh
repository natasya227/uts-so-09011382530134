#! /bin/bash
# NAMA	: KARINA APRIL NATASYA
# NIM	: 09011382530134
# Kelas	: SKU3B
# Tugas : UTS Sistem Operasi - Menjalankan backup.sh berulang di background
#
# Cara pakai:
#	./backup_loop.sh &			-> jeda bawaan 60 detik
#	./backup_loop.sh 10 &			-> jeda 10 detik (untuk perulangan)

# ---------- Variabel ----------
# Prioritas: argumen pertama, lalu variabel lingkungan INTERVAL, lalu 60 detik
INTERVAL="${1:-${INTERVAL:-60}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"	# folder tempat script ini berbeda
BACKUP_SCRIPT="$SCRIPT_DIR/backup.sh"
SLEEP_PID=""

# ---------- Penanganan kill (SIGTREM) dan Ctrl+C (SIGINT) ----------
berhenti() {
	echo "backup_loop.sh (PID $$) dihentikan."
	[ -n "$SLEEP_PID" ] && kill "$SLEEP_PID" 2>/dev/null
	exit 0
}
trap berhenti SIGTERM SIGINT

echo "backup_loop.sh berjalan (PID $$), INTERVAL=${INTERVAL} detik."

# ---------- Perulangan utama ----------
while true; do
	"$BACKUP_SCRIPT"
	# sleep dijalankan di latar lalu ditunggu dengan wait,
	# supaya kill langsung direspons tanpa menunggu sleep selesai
	sleep "$INTERVAL" &
	SLEEP_PID=$!
	wait "$SLEEP_PID"
done
