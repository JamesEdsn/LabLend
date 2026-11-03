# How to Run — LabLend

Panduan ini ditujukan untuk menjalankan LabLend secara lokal di Windows menggunakan Flutter Web (Chrome), backend Express, dan database MySQL.

## 1. Prasyarat

Pastikan aplikasi berikut sudah terpasang dan dapat dipanggil dari terminal:

- Flutter SDK dan Dart SDK.
- Node.js dan npm.
- MySQL Server (MySQL Workbench boleh digunakan untuk mengelola database).
- Google Chrome.
- Visual Studio Code atau editor lain.

## 2. Siapkan Database MySQL

1. Jalankan MySQL Server.
2. Buka MySQL Workbench atau client MySQL.
3. Buat database jika belum ada:

```sql
CREATE DATABASE lablend_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

## 3. Siapkan dan Jalankan Backend

Buka terminal baru di root repository LabLend, lalu jalankan:

```bat
cd backend
npm ci
```

Buat file `.env` lokal dari template:

```bat
copy .env.example .env
```

Buka `backend/.env` lalu ganti `USER` dan `PASSWORD` dengan kredensial MySQL lokal. Jangan commit file `.env` ke Git.

Contoh format `backend/.env`:

```env
DATABASE_URL="mysql://USER:PASSWORD@localhost:3306/lablend_db"
PORT=3000
```

Jalankan dari folder `backend`:

```bat
npx prisma generate
npx prisma migrate deploy
npm run dev
```

Jika database lokal sudah pernah dibuat menggunakan `prisma db push` dan migrasi awal belum pernah diterapkan, jangan menjalankan `migrate deploy` secara membabi buta pada database yang berisi data. Untuk lingkungan pengembangan yang sesuai, periksa schema dan gunakan `npx prisma db push` jika memang itu metode sinkronisasi yang dipilih. Jangan menghapus database yang berisi data penting hanya untuk memperbaiki migrasi.

Backend secara default berjalan di `http://localhost:3000`. Biarkan terminal backend tetap terbuka.

### Pemeriksaan Backend

Buka browser ke `http://localhost:3000/`. Respons yang diharapkan memuat pesan `LabLend API is running`.

Untuk melihat riwayat peminjaman, buka `http://localhost:3000/api/peminjaman`. Jika belum ada data, respons yang diharapkan adalah respons sukses dengan `data` berupa array kosong.

## 4. Jalankan Aplikasi Flutter

Buka terminal kedua di root repository, bukan di folder `backend`:

```bat
flutter pub get
flutter run -d chrome
```

Pastikan backend masih berjalan. Konfigurasi URL API saat ini adalah `http://localhost:3000/api`, yang sesuai untuk Flutter Web dan backend pada komputer yang sama.

## 5. Jalankan Pengujian

### Pengujian Flutter

Jalankan dari root repository:

```bat
flutter analyze
flutter test
```

### Pengujian Backend

Buka terminal lain:

```bat
cd backend
npm test
npm run build
```

Tes backend menggunakan repository in-memory/mock untuk memeriksa validasi dan respons HTTP tanpa memerlukan database sungguhan. Pengujian CRUD dengan MySQL tetap harus dilakukan terpisah sebagai smoke test integrasi.

## 6. Skenario Smoke Test Manual

1. Pastikan MySQL, backend, dan aplikasi Flutter berjalan.
2. Tambahkan peminjaman dengan nama alat, jumlah positif, dan tanggal `YYYY-MM-DD` yang valid.
3. Pastikan aplikasi menampilkan pesan berhasil.
4. Buka Riwayat dan pastikan catatan baru muncul.
5. Edit catatan, simpan, lalu pastikan nilainya berubah.
6. Hapus catatan dan konfirmasi penghapusan.
7. Uji form kosong, jumlah `0`, tanggal dengan format salah, dan tanggal kalender yang tidak mungkin seperti `2026-02-30`.
8. Untuk menguji error state, hentikan backend sementara lalu muat ulang Riwayat. Pastikan aplikasi menampilkan error dan tombol Coba Lagi. Nyalakan kembali backend lalu coba lagi.
9. Untuk menguji empty state Riwayat, pastikan tidak ada record peminjaman di database.

## 7. Troubleshooting

- **`DATABASE_URL belum diatur`** — pastikan `backend/.env` ada dan nama variabelnya benar.
- **Koneksi MySQL gagal** — periksa MySQL Server aktif, port, username, password, dan nama database.
- **Port 3000 sudah digunakan** — hentikan proses lain yang memakai port tersebut atau ubah `PORT` pada `backend/.env` dan sesuaikan `baseUrl` di `lib/features/peminjaman/services/api_service.dart`.
- **Peminjaman gagal karena tanggal** — gunakan format `YYYY-MM-DD`, misalnya `2026-11-15`, bukan format tanggal berbahasa Indonesia.
- **Riwayat gagal dimuat** — pastikan backend berjalan terlebih dahulu dan endpoint `http://localhost:3000/api/peminjaman` dapat dibuka.
- **Prisma Client belum ditemukan** — dari folder `backend`, jalankan `npx prisma generate` setelah konfigurasi `.env` disiapkan.

## 8. Catatan Ruang Lingkup

Versi sumber ini telah menyediakan form peminjaman, riwayat, CRUD record peminjaman, validasi, Riverpod state, dan REST API. Katalog alat saat ini masih berupa daftar statis di repository Flutter. Autentikasi/role pengguna, persetujuan pinjaman, perubahan stok otomatis, dan isolasi data per pengguna belum tersedia pada kode saat audit. Lihat `checklist_mvp.md` untuk status tiap fitur.
