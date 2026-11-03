# 📦 LabLend

### Laboratory Inventory & Borrowing Management Application

**LabLend** adalah aplikasi berbasis Flutter untuk membantu digitalisasi proses peminjaman dan pengelolaan riwayat inventaris laboratorium kampus. Aplikasi menggunakan Riverpod untuk state management, REST API berbasis Node.js, Express, dan TypeScript, serta MySQL sebagai basis data dengan Prisma ORM.

> **Status Pengembangan:** LabLend telah memiliki fitur form peminjaman, riwayat, CRUD data peminjaman melalui REST API, validasi, serta pengujian otomatis. Backend juga telah dilengkapi registrasi, login, autentikasi JWT, dan pembatasan akses data peminjaman berdasarkan pengguna. Integrasi autentikasi ke antarmuka Flutter dan beberapa fitur pengelolaan inventaris masih menjadi bagian pengembangan berikutnya.

---

## 📖 Daftar Isi

- [Deskripsi Masalah](#-deskripsi-masalah)
- [Profil Target Pengguna](#-profil-target-pengguna)
- [Manfaat Aplikasi](#-manfaat-aplikasi)
- [Fitur yang Tersedia](#-fitur-yang-tersedia)
- [Batasan dan Pengembangan Lanjutan](#-batasan-dan-pengembangan-lanjutan)
- [Arsitektur](#️-arsitektur)
- [Struktur Repository](#-struktur-repository)
- [Tech Stack](#️-tech-stack)
- [Menjalankan Aplikasi](#-menjalankan-aplikasi)
- [Pengujian](#-pengujian)
- [Dokumentasi Proyek](#-dokumentasi-proyek)
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

LabLend dikembangkan sebagai solusi digital untuk membantu proses pencatatan, pengambilan, pembaruan, dan penghapusan data peminjaman melalui aplikasi.

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

> Catatan: Kedua kelompok tersebut merupakan target pengguna aplikasi. Pembagian role dan pembatasan hak akses masih memerlukan pengembangan lebih lanjut.

## 💡 Manfaat Aplikasi

- **Digitalisasi pencatatan:** Data peminjaman disimpan dalam basis data.
- **Pengelolaan data lebih praktis:** Data dapat dibuat, dilihat, diperbarui, dan dihapus melalui aplikasi.
- **Riwayat lebih terorganisasi:** Informasi peminjaman dapat ditampilkan kembali melalui halaman riwayat.
- **Pemisahan tanggung jawab kode:** Frontend, backend, dan database memiliki peran masing-masing.
- **Pengalaman pengguna lebih baik:** Riverpod membantu mengelola state aplikasi, termasuk proses loading dan penanganan error.
- **Keamanan data backend:** JWT digunakan untuk autentikasi dan akses data peminjaman dibatasi berdasarkan identitas pengguna.

## ✨ Fitur yang Tersedia

### 1. Formulir Peminjaman — Create

Pengguna dapat mengisi informasi peminjaman berupa:

- Nama alat yang dipinjam.
- Jumlah alat.
- Tanggal pengembalian yang direncanakan.

Data dikirim melalui REST API untuk diproses dan disimpan ke database MySQL.

### 2. Riwayat Peminjaman — Read

Aplikasi mengambil data riwayat peminjaman dari backend dan menampilkannya pada halaman riwayat.

Data yang ditampilkan meliputi informasi alat, jumlah, dan tanggal pengembalian.

### 3. Pembaruan Data — Update

Data peminjaman yang sudah tersimpan dapat diperbarui melalui aplikasi. Perubahan dikirim ke backend untuk disimpan ke database.

### 4. Penghapusan Data — Delete

Pengguna dapat menghapus data peminjaman. Backend memproses permintaan penghapusan dan memperbarui data yang tersimpan di database.

### 5. State Management dengan Riverpod

Riverpod digunakan untuk mengelola state dan memisahkan logika pengambilan data dari tampilan aplikasi.

State yang ditangani mencakup loading, success, empty, error, validasi form, dan proses submit.

### 6. REST API dan Database

Backend menyediakan endpoint untuk operasi CRUD peminjaman. Prisma digunakan sebagai ORM untuk berinteraksi dengan database MySQL.

### 7. Validasi Data

Data peminjaman divalidasi sebelum disimpan. Contohnya, jumlah alat harus berupa bilangan bulat positif dan tanggal pengembalian harus mengikuti format `YYYY-MM-DD`.

### 8. Registrasi dan Login Backend

Backend menyediakan fitur:

- Registrasi pengguna.
- Login pengguna.
- Password hashing menggunakan bcrypt.
- Pembuatan dan verifikasi JSON Web Token (JWT).
- Informasi pengguna dan role pada respons autentikasi.

### 9. Proteksi Endpoint dan Data Pengguna

Endpoint peminjaman dilindungi oleh middleware autentikasi. Operasi pengambilan, pembuatan, pembaruan, dan penghapusan data dibatasi berdasarkan `userId` dari token pengguna yang telah diverifikasi.

> Catatan: Fitur autentikasi dan pembatasan data telah diimplementasikan dan diuji pada backend. Integrasi alur login, penyimpanan sesi/token, dan pengalaman autentikasi pada aplikasi Flutter masih perlu diselesaikan.

## 🚧 Batasan dan Pengembangan Lanjutan

Beberapa fitur berikut masih memerlukan pengembangan tambahan:

- Integrasi halaman login dan registrasi pada aplikasi Flutter.
- Penyimpanan token dan pengelolaan sesi pengguna pada frontend.
- Implementasi role Mahasiswa dan Asisten Laboratorium/Admin beserta pembatasan hak akses.
- Katalog inventaris dinamis dari database beserta CRUD alat.
- Persetujuan atau penolakan peminjaman oleh pengelola laboratorium.
- Status peminjaman seperti menunggu, dipinjam, dan dikembalikan.
- Pengurangan stok saat peminjaman disetujui dan penambahan stok saat pengembalian.
- Notifikasi pengingat tanggal pengembalian.
- Pemindaian QR Code atau barcode.
- Integrasi multi-laboratorium.

Fitur-fitur tersebut dapat dipertimbangkan untuk pengembangan lanjutan sesuai kebutuhan dan ruang lingkup proyek.

## 🏗️ Arsitektur

LabLend menggunakan arsitektur tiga lapisan yang memisahkan antarmuka pengguna, pemrosesan backend, dan penyimpanan data.

```text
┌───────────────────────────────────┐
│           FLUTTER APP             │
│                                   │
│  Formulir Peminjaman              │
│  Riwayat Peminjaman               │
│  Riverpod State Management        │
│  API Service                      │
└─────────────────┬─────────────────┘
                  │
                  │ HTTP / REST API
                  │ JSON
                  ▼
┌───────────────────────────────────┐
│           BACKEND API             │
│                                   │
│  Node.js + Express + TypeScript   │
│  Authentication Middleware        │
│  JWT Authentication               │
│  Validasi Data                    │
│  CRUD Peminjaman                  │
│  Repository Layer                 │
└─────────────────┬─────────────────┘
                  │
                  │ Prisma Client
                  ▼
┌───────────────────────────────────┐
│             DATABASE              │
│                                   │
│              MySQL                │
│                                   │
│        User / Peminjaman          │
└───────────────────────────────────┘
```

### Alur Data

1. Pengguna melakukan operasi melalui aplikasi Flutter.
2. Aplikasi mengirim permintaan HTTP ke endpoint backend.
3. Backend menerima dan memvalidasi permintaan.
4. Untuk endpoint yang dilindungi, middleware memverifikasi JWT.
5. Repository menjalankan operasi database melalui Prisma.
6. Backend mengembalikan respons kepada aplikasi.

Rincian arsitektur dan pembagian tanggung jawab komponen tersedia di [ARCHITECTURE.md](ARCHITECTURE.md).

## 📁 Struktur Repository

```text
LabLend/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   └── features/
│       └── peminjaman/
│           ├── models/
│           ├── providers/
│           ├── repositories/
│           ├── screens/
│           └── services/
├── test/
│   └── features/
│       └── peminjaman/
├── backend/
│   ├── prisma/
│   │   ├── migrations/
│   │   └── schema.prisma
│   ├── src/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── routes/
│   │   ├── app.ts
│   │   ├── database.ts
│   │   └── server.ts
│   ├── tests/
│   ├── .env.example
│   └── package.json
├── screenshots/
├── ARCHITECTURE.md
├── AUDIT_REPORT.md
├── DEMO_SCRIPT.md
├── HowToRun.md
├── checklist_mvp.md
├── pubspec.yaml
├── README.md
└── .gitignore
```

*Catatan: Struktur di atas merupakan gambaran direktori utama repository.*

## 🛠️ Tech Stack

**Frontend**

- [Flutter](https://flutter.dev/) — framework aplikasi.
- [Dart](https://dart.dev/) — bahasa pemrograman frontend.
- [Riverpod](https://riverpod.dev/) — state management.
- [HTTP](https://pub.dev/packages/http) — komunikasi REST API.

**Backend**

- [Node.js](https://nodejs.org/) — runtime JavaScript.
- [Express](https://expressjs.com/) — framework REST API.
- [TypeScript](https://www.typescriptlang.org/) — pengembangan backend dengan tipe data.
- [bcryptjs](https://www.npmjs.com/package/bcryptjs) — hashing password.
- [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) — autentikasi berbasis JWT.

**Database dan ORM**

- [MySQL](https://www.mysql.com/) — penyimpanan data relasional.
- [Prisma](https://www.prisma.io/) — ORM untuk mengakses database.

**Development Tools**

- [Visual Studio Code](https://code.visualstudio.com/) — editor kode.
- [Git](https://git-scm.com/) — version control.
- [GitHub](https://github.com/) — repository proyek.
- [Postman](https://www.postman.com/) atau browser — pengujian endpoint API.

## 🚀 Menjalankan Aplikasi

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

Buat file `.env` berdasarkan `.env.example` dan isi konfigurasi koneksi database serta secret JWT sesuai kebutuhan proyek.

Pastikan database MySQL sudah tersedia.

Untuk langkah konfigurasi Prisma, menjalankan migration, generate client, dan menjalankan server, ikuti panduan yang tersedia di [HowToRun.md](HowToRun.md).

> Jangan commit file `.env` atau membagikan password database dan JWT secret ke repository publik.

### 3. Menjalankan Aplikasi Flutter

Buka terminal baru dan kembali ke root repository:

```bash
cd ..
flutter pub get
flutter run -d chrome
```

Perintah tersebut menjalankan aplikasi pada Google Chrome. Untuk menggunakan emulator atau perangkat lain, pilih target yang tersedia pada instalasi Flutter.

### 4. Konfigurasi URL API

Untuk pengembangan lokal melalui Flutter Web, URL API yang digunakan adalah:

```text
http://localhost:3000/api
```

Pastikan backend berjalan sebelum menguji fitur peminjaman.

Jika menggunakan Android Emulator standar, gunakan alamat host yang sesuai, misalnya `http://10.0.2.2:3000/api`.

## 🧪 Pengujian

### Flutter

Jalankan dari root repository:

```bash
flutter analyze
flutter test
```

### Backend

Jalankan dari direktori `backend`:

```bash
npm test
npm run build
```

Pengujian backend mencakup validasi model, operasi API, respons error, autentikasi, dan pembatasan data pengguna sesuai skenario test yang tersedia.

> Hasil pengujian harus diperbarui berdasarkan hasil aktual. Jangan menyatakan semua test lulus sebelum perintah tersebut benar-benar dijalankan dan berhasil.

## 📄 Dokumentasi Proyek

- [HowToRun.md](HowToRun.md) — panduan menjalankan aplikasi dan backend.
- [ARCHITECTURE.md](ARCHITECTURE.md) — dokumentasi arsitektur sistem.
- [checklist_mvp.md](checklist_mvp.md) — daftar fitur dan status implementasi.
- [AUDIT_REPORT.md](AUDIT_REPORT.md) — ringkasan progres audit dan fitur yang masih menjadi gap.
- [DEMO_SCRIPT.md](DEMO_SCRIPT.md) — urutan demonstrasi aplikasi.
- [screenshots/](screenshots/) — bukti tampilan dan state aplikasi.

## 📄 Lisensi

Lisensi proyek mengikuti ketentuan yang ditetapkan pada repository. Jika proyek akan dipublikasikan sebagai proyek open-source, tambahkan file `LICENSE` dan tentukan lisensi yang sesuai.

## 📬 Kontak

**Author:** James Edison Wihardja  
**GitHub:** [@JamesEdsn](https://github.com/JamesEdsn)  
**Repository:** [LabLend](https://github.com/JamesEdsn/LabLend)

---

<p align="center">📦 Dibuat untuk mendukung pengelolaan peminjaman inventaris laboratorium kampus secara lebih terorganisasi.</p>