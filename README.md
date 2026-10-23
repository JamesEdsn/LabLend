# 📦 LabLend

### Laboratory Inventory & Borrowing Management Application

**LabLend** adalah aplikasi berbasis Flutter untuk membantu digitalisasi proses peminjaman dan pengelolaan riwayat inventaris laboratorium kampus. Aplikasi ini menggunakan Riverpod untuk state management, REST API untuk komunikasi dengan backend, serta MySQL sebagai basis data.

---

## 📖 Daftar Isi

- [Deskripsi Masalah](#-deskripsi-masalah)
- [Profil Target Pengguna](#-profil-target-pengguna)
- [Manfaat Aplikasi](#-manfaat-aplikasi)
- [Fitur Inti (MVP)](#-fitur-inti-mvp)
- [Fitur yang Tidak Dikerjakan](#-fitur-yang-tidak-dikerjakan)
- [Kriteria Keberhasilan](#-kriteria-keberhasilan)
- [Arsitektur](#-arsitektur)
- [Struktur Repository](#-struktur-repository)
- [Tech Stack](#-tech-stack)
- [Memulai](#-memulai)
- [Cara Pakai](#-cara-pakai)
- [Pengujian](#-pengujian)
- [Lisensi](#-lisensi)
- [Kontak](#-kontak)

---

## 🧩 Deskripsi Masalah

Proses peminjaman perangkat keras laboratorium kampus sering kali masih mengandalkan pencatatan manual. Mahasiswa yang membutuhkan perangkat seperti mikrokontroler ESP32, sensor ultrasonik HC-SR04, router MikroTik, atau kabel jaringan harus memastikan ketersediaan alat sebelum menggunakannya untuk praktikum maupun pengerjaan proyek.

Sistem pencatatan manual memiliki beberapa kendala:

- **Informasi sulit diakses:** Mahasiswa harus bertanya langsung kepada pengelola laboratorium untuk mengetahui informasi peminjaman.
- **Risiko kesalahan pencatatan:** Data peminjaman yang dicatat secara manual berpotensi tidak lengkap atau keliru.
- **Riwayat kurang terorganisasi:** Pengelola laboratorium dapat mengalami kesulitan ketika perlu mencari atau memperbarui data peminjaman.
- **Pengelolaan kurang efisien:** Pencatatan dan pencarian data secara manual membutuhkan waktu tambahan.

LabLend dikembangkan sebagai solusi digital sederhana untuk membantu proses pencatatan, pengambilan, pembaruan, dan penghapusan data peminjaman melalui aplikasi.

## 👤 Profil Target Pengguna

LabLend dirancang untuk mendukung kebutuhan dua kelompok pengguna utama di lingkungan kampus.

**1. Mahasiswa — Peminjam**

- Membutuhkan perangkat laboratorium untuk praktikum, tugas kuliah, dan proyek.
- Membutuhkan formulir peminjaman yang mudah digunakan.
- Ingin melihat kembali data peminjaman yang pernah dicatat.

**2. Asisten Laboratorium / Teknisi — Pengelola**

- Bertanggung jawab terhadap inventaris laboratorium.
- Membutuhkan pencatatan peminjaman yang lebih terorganisasi.
- Memerlukan cara yang lebih praktis untuk melihat, memperbarui, dan menghapus data peminjaman.

> Catatan: Pembagian peran di atas merupakan target penggunaan aplikasi. Implementasi autentikasi, otorisasi, dan pemisahan akses setiap peran bergantung pada pengembangan fitur berikutnya.

## 💡 Manfaat Aplikasi

- **Digitalisasi pencatatan:** Data peminjaman disimpan dalam basis data, bukan hanya pada buku catatan.
- **Pengelolaan data lebih praktis:** Data dapat dibuat, dilihat, diperbarui, dan dihapus melalui aplikasi.
- **Riwayat lebih terorganisasi:** Informasi peminjaman dapat ditampilkan kembali melalui halaman riwayat.
- **Pemisahan tanggung jawab kode:** Frontend, backend, dan database memiliki peran masing-masing sehingga aplikasi lebih mudah dikembangkan.
- **Pengalaman pengguna lebih baik:** Riverpod membantu mengelola state aplikasi, termasuk proses pemuatan data dan pengiriman formulir.

## ✨ Fitur Inti (MVP)

### 1. Formulir Peminjaman — Create

Pengguna dapat mengisi informasi peminjaman berupa:

- Nama alat yang dipinjam.
- Jumlah alat.
- Tanggal pengembalian yang direncanakan.

Data dikirim melalui REST API dan disimpan ke dalam database MySQL.

### 2. Riwayat Peminjaman — Read

Aplikasi mengambil data riwayat peminjaman dari backend dan menampilkannya pada halaman riwayat.

Data yang ditampilkan meliputi informasi alat, jumlah, dan tanggal pengembalian.

### 3. Pembaruan Data — Update

Data peminjaman yang sudah tersimpan dapat diperbarui melalui aplikasi. Perubahan dikirim ke backend untuk disimpan ke database.

### 4. Penghapusan Data — Delete

Pengguna dapat menghapus data peminjaman. Backend memproses permintaan penghapusan dan memperbarui data yang tersimpan di database.

### 5. State Management dengan Riverpod

Riverpod digunakan untuk mengelola state dan memisahkan logika pengambilan data dari tampilan aplikasi.

Pengelolaan state mendukung proses pemuatan data dan penanganan hasil operasi peminjaman.

### 6. REST API dan Database

Backend menyediakan endpoint untuk operasi CRUD peminjaman. Prisma digunakan sebagai ORM untuk berinteraksi dengan database MySQL.

### 7. Validasi Data

Data peminjaman divalidasi sebelum disimpan. Contohnya, jumlah alat harus berupa bilangan bulat positif dan tanggal pengembalian harus mengikuti format `YYYY-MM-DD`.

---

## 🚧 Fitur yang Tidak Dikerjakan

Untuk menjaga ruang lingkup proyek tetap realistis, beberapa fitur berikut tidak termasuk dalam implementasi MVP saat ini atau masih memerlukan pengembangan tambahan:

- **Autentikasi dan manajemen role:** Login, registrasi, serta pemisahan hak akses mahasiswa dan Aslab.
- **Persetujuan peminjaman:** Mekanisme persetujuan atau penolakan permohonan oleh Aslab.
- **Manajemen stok inventaris lengkap:** Pembaruan stok otomatis berdasarkan peminjaman dan pengembalian.
- **Notifikasi otomatis:** Pengingat tanggal pengembalian atau notifikasi keterlambatan.
- **Pemindaian QR Code / barcode:** Identifikasi alat menggunakan kamera.
- **Denda dan pembayaran digital:** Perhitungan denda serta integrasi payment gateway.
- **Notifikasi push:** Integrasi layanan seperti Firebase Cloud Messaging.
- **Integrasi multi-laboratorium:** Pengelolaan inventaris dari beberapa laboratorium atau kampus.

Fitur-fitur tersebut dapat dipertimbangkan untuk pengembangan lanjutan apabila kebutuhan dan waktu proyek memungkinkan.

---

## ✅ Kriteria Keberhasilan

Keberhasilan MVP LabLend dievaluasi melalui skenario berikut:

- [x] **Create:** Pengguna dapat mengirim data peminjaman melalui aplikasi dan menyimpannya ke database.
- [x] **Read:** Aplikasi dapat mengambil dan menampilkan data peminjaman dari backend.
- [x] **Update:** Data peminjaman yang tersimpan dapat diperbarui melalui aplikasi.
- [x] **Delete:** Data peminjaman dapat dihapus melalui aplikasi.
- [x] **Integrasi API:** Frontend Flutter dapat berkomunikasi dengan backend melalui REST API.
- [x] **Integrasi Database:** Backend menggunakan Prisma untuk mengakses database MySQL.
- [x] **Validasi Input:** Backend memvalidasi data peminjaman, termasuk jumlah dan format tanggal.
- [x] **Pengujian Aplikasi:** `flutter analyze` dan `flutter test` berhasil dijalankan pada kondisi pengujian yang telah dilakukan.

> Status di atas didasarkan pada implementasi dan hasil pengujian yang telah dilaporkan selama pengembangan. Pengujian ulang tetap disarankan setelah perubahan kode.

---

## 🏗️ Arsitektur

LabLend menggunakan arsitektur tiga lapisan yang memisahkan antarmuka pengguna, pemrosesan backend, dan penyimpanan data.

```text
┌───────────────────────────────────┐
│          FLUTTER APP              │
│                                   │
│  Formulir Peminjaman               │
│  Riwayat Peminjaman                │
│  Riverpod State Management         │
└─────────────────┬─────────────────┘
                  │
                  │ HTTP / REST API
                  │ JSON
                  ▼
┌───────────────────────────────────┐
│          BACKEND API              │
│                                   │
│  Node.js + Express + TypeScript    │
│  Validasi Data                    │
│  CRUD Peminjaman                  │
│  Prisma ORM                       │
└─────────────────┬─────────────────┘
                  │
                  │ Prisma Client
                  ▼
┌───────────────────────────────────┐
│           DATABASE                │
│                                   │
│             MySQL                 │
│                                   │
│      Tabel peminjaman              │
└───────────────────────────────────┘
```

### Alur Data

1. Pengguna melakukan operasi melalui aplikasi Flutter.
2. Aplikasi mengirim permintaan HTTP ke endpoint backend.
3. Backend menerima dan memvalidasi data yang dikirim.
4. Prisma menjalankan operasi yang diperlukan pada database MySQL.
5. Backend mengembalikan respons kepada aplikasi.
6. Aplikasi memperbarui state dan menampilkan hasil kepada pengguna.

---

## 📁 Struktur Repository

Struktur utama repository LabLend adalah sebagai berikut:

```text
LabLend/
├── lib/
│   ├── main.dart
│   └── features/
│       └── peminjaman/
│           ├── models/
│           │   └── peminjaman_model.dart
│           ├── providers/
│           │   ├── peminjaman_notifier.dart
│           │   └── riwayat_peminjaman_notifier.dart
│           ├── repositories/
│           │   └── peminjaman_repository.dart
│           ├── services/
│           │   └── api_service.dart
│           └── ...
├── test/
├── backend/
│   ├── src/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── routes/
│   │   ├── app.ts
│   │   ├── database.ts
│   │   └── server.ts
│   ├── prisma/
│   │   └── schema.prisma
│   ├── .env.example
│   └── package.json
├── pubspec.yaml
├── README.md
└── .gitignore
```

*Catatan: Struktur di atas merupakan gambaran direktori utama. Sesuaikan nama atau lokasi file jika struktur repository aktual berbeda.*

---

## 🛠️ Tech Stack

**Frontend:**
- [Flutter](https://flutter.dev/) — framework aplikasi.
- [Dart](https://dart.dev/) — bahasa pemrograman frontend.
- [Riverpod](https://riverpod.dev/) — state management.
- HTTP — komunikasi REST API.

**Backend:**
- [Node.js](https://nodejs.org/) — runtime JavaScript.
- [Express](https://expressjs.com/) — framework REST API.
- [TypeScript](https://www.typescriptlang.org/) — pengembangan backend dengan tipe data.

**Database dan ORM:**
- [MySQL](https://www.mysql.com/) — penyimpanan data relasional.
- [Prisma](https://www.prisma.io/) — ORM untuk mengakses database.

**Development Tools:**
- [Visual Studio Code](https://code.visualstudio.com/) — editor kode.
- [Git](https://git-scm.com/) — version control.
- [GitHub](https://github.com/) — repository proyek.
- [Postman](https://www.postman.com/) atau browser — pengujian endpoint API.

---

## 🚀 Memulai

### Prasyarat

Pastikan perangkat telah memiliki:

- Flutter SDK dan Dart.
- Node.js dan npm.
- MySQL Server.
- Git.
- Editor kode seperti Visual Studio Code.

### 1. Clone Repository

```bash
git clone https://github.com/JamesEdsn/LabLend.git
cd LabLend
```

### 2. Menyiapkan Backend

Masuk ke direktori backend:

```bash
cd backend
npm install
```

Buat file `.env` berdasarkan konfigurasi proyek. Jika repository menyediakan `.env.example`, salin file tersebut:

```bash
copy .env.example .env
```

Perintah `copy` digunakan di Windows Command Prompt. Jika file contoh belum tersedia, buat `.env` berdasarkan konfigurasi yang diperlukan backend.

Isi variabel lingkungan yang dibutuhkan, termasuk koneksi database dan port server. Contoh format:

```env
DATABASE_URL="mysql://USER:PASSWORD@localhost:3306/lablend_db"
PORT=3000
```

Ganti `USER` dan `PASSWORD` dengan kredensial MySQL milikmu. Jangan commit file `.env` atau membagikan password database ke repository publik.

Pastikan database `lablend_db` telah dibuat pada MySQL. Selanjutnya, jalankan perintah Prisma sesuai konfigurasi proyek:

```bash
npx prisma generate
npx prisma db push
```

> Jika proyek menggunakan migrasi Prisma yang sudah tersedia, gunakan prosedur migrasi yang sesuai dengan repository, bukan menjalankan `db push` secara sembarangan pada database yang berisi data penting.

Jalankan backend menggunakan script yang tersedia di `backend/package.json`. Pada proyek yang menyediakan script `dev`, perintahnya biasanya:

```bash
npm run dev
```

Pastikan backend berjalan pada port `3000` atau port yang telah dikonfigurasi.

### 3. Menjalankan Aplikasi Flutter

Buka terminal baru, kemudian kembali ke root repository:

```bash
cd ..
flutter pub get
flutter run -d chrome
```

Perintah tersebut menjalankan aplikasi pada Google Chrome. Untuk menggunakan emulator atau perangkat lain, pilih target yang tersedia pada instalasi Flutter milikmu.

### 4. Konfigurasi URL API

Untuk pengembangan lokal melalui Flutter Web, URL API yang digunakan adalah:

```text
http://localhost:3000/api
```

Pastikan backend berjalan sebelum menguji fitur peminjaman.

Jika menggunakan Android Emulator, alamat `localhost` mengarah ke emulator itu sendiri, bukan komputer host. Gunakan alamat host yang sesuai, misalnya `http://10.0.2.2:3000/api` untuk konfigurasi Android Emulator standar, dan sesuaikan konfigurasi CORS backend jika diperlukan.

---

## 📘 Cara Pakai

1. Jalankan MySQL dan pastikan database LabLend tersedia.
2. Jalankan backend REST API.
3. Jalankan aplikasi Flutter.
4. Buka halaman formulir peminjaman.
5. Pilih alat, masukkan jumlah, dan tentukan tanggal pengembalian.
6. Kirim formulir untuk menyimpan data peminjaman.
7. Buka halaman riwayat untuk melihat data yang tersimpan.
8. Gunakan fitur edit untuk memperbarui informasi peminjaman.
9. Gunakan fitur hapus untuk menghapus data yang dipilih.
10. Periksa hasilnya pada aplikasi dan pastikan perubahan tersimpan pada database.

---

## 🧪 Pengujian

Jalankan perintah berikut dari root repository untuk memeriksa kualitas kode dan menjalankan pengujian Flutter:

```bash
flutter analyze
flutter test
```

Pengujian integrasi CRUD juga dapat dilakukan dengan menjalankan backend dan mencoba operasi berikut:

| Operasi | HTTP Method | Endpoint |
|---|---|---|
| Mengambil semua data | GET | `/api/peminjaman` |
| Mengambil satu data | GET | `/api/peminjaman/:id` |
| Membuat data | POST | `/api/peminjaman` |
| Memperbarui data | PUT | `/api/peminjaman/:id` |
| Menghapus data | DELETE | `/api/peminjaman/:id` |

Untuk pengujian manual, pastikan setiap operasi memberikan respons yang sesuai dan perubahan data benar-benar tercermin pada database.

---

## 📄 Lisensi

Lisensi proyek mengikuti ketentuan yang ditetapkan pada repository. Jika proyek akan dipublikasikan sebagai proyek open-source, tambahkan file `LICENSE` dan tentukan lisensi yang sesuai.

---

## 📬 Kontak

**Author:** James Edison Wihardja  
**GitHub:** [@JamesEdsn](https://github.com/JamesEdsn)  
**Repository:** [LabLend](https://github.com/JamesEdsn/LabLend)

---

<p align="center">📦 Dibuat untuk mendukung pengelolaan peminjaman inventaris laboratorium kampus secara lebih terorganisasi.</p>
