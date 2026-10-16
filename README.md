# uts-so-09011382530134
# UTS Sistem Operasi - backup Otomatis dengan Shell script

## 1. Identitas

| Keterangan | Isi |
|---|---|
| Nama | KARINA APRIL NATASYA |
| NIM | 09011382530134
| Kelas | SKU3B

## 2. Deskripsi

Proyek ini berisi tiga *shell script* untuk membackup file catatn pratikum.

- 'script/backup.sh'
1. Membaca variabel di bagian atas script  (NIM, direktori sumber, direktori tujuan, nama log)
2. Membuat '~/backup_NIM' dengan 'mkdir -p' jika belum ada.
3. Mencari semua file '.txt' (termasuk subdirektori) dengan 'find', lalu menyimpan daftarnya ke '~/backup_NIM/daftar_file.txt'.
4. Mengarsipkan dan mengompresi file hasil pencarian dengan 'tar -czvf' menjadi 'backup_NIM_TANGGAL_JAM.tar.gz'.
5. Menampilkan isi arsip dengan 'tar -tzvf' tanpa mengekstrak.
6. Menambahkan satu baris ke '~/backup_NIM/backup.log' dengan '>>' (format: 'tanggal jam | nama arsip | jumlah file | ukuran').
7. Menghapus arsip lama sehingga hanya 5 arsip terbaru yang disimpan (rotasi).
- 'script/backup_loop.sh': menjalankan 'backup.sh' berulang dengan 'while true' dan 'sleep $INTERVAL' (bawaan 60 detik), dijalankan di *background* dengan '&' dan dihentikan dengan 'kill".
- 'script/alias.sh': berisi alias 'bk001' untuk menjalankan 'backup.sh'.

## 3. Cara menjalankan

Persiapan (sekali saja):

''' bash
cd ~/uts-so-09011382530134
chmod +x script/*.sh

'''bash
# backup sekali jalan
./script/backup.sh

# backup berulang di background (jeda bawaan 60 detik)
./script/backup_loop.sh &

# backup berulangan dengan jeda 5 detik
./script/backup_loop.sh 5 &

# hentikan loop
jobs -l		# lihat nomor job dan PID
kill %1		# atau: kill PID

# alias (setelah barisnya disalin ke ~/.bashrc
source ~/.bashrc
bk001
'''

## 4. Fitur pengembangan

**a. Rotasi arsip** - 'backup.sh' hanya menyimpan 5 arsip terbaru (variabel 'MAX_ARCHIVES'). cara mencoba: jalankan './script/backup.sh' lebih dari 5 kali (beri jeda minimal 1 detik), lalu cek 'ls ~/backup_09011382530134'. Akan tersisa 5 arsip dan muncul pesan 'Rotasi: arsip lama dihapus -> ...'.

**b. Parameter** - ekstensi file dan direktori sumber dapat diberikan sebagai argumen.

'''bash
./script/backup.sh pdf			# arsipkan *.pdf
./script/backup.sh ~/folder_lain	# arsipkan *.txt dari folder lain
'''

## 5. Bukti Job control

'''bash
./backup_loop.sh 5 &					# [1] 9062
backup_loop.sh berjalan (PID 9062), INTERVAL=5detik	# ---Isi arsip backup_09011382530134_20261016_163801.tar.gz---
							# Backup selesai: backup_09011382530134_20261016_163801.tar.gz ( file, 4.0k)
jobs -l							# [1] 9062
fg							# bawa ke foreground
# tekan Ctrl+Z						# hentikan sementara 
bg							# lanjutkan di background
ps x | grep backup_loop					# lihat proses
kill %1							# hentikan (atau kill PID)
'''

## 6. Kendala

| Error | Penyebab | Solusi |
|---|---|---|
| No such file or directory untuk backup.sh | Salah folder atau salah nama | cd ~/uts-so-09011382530134/script
| Permission denied saat ./script/backup.sh | Belum chmod +x | chmod +x script/backup.sh
| Authentication failed saat push | Salah memasukan token repository | Masukkan ulang token dengan benar


