# 📦 LabLend

**LabLend** adalah aplikasi Flutter untuk pencatatan peminjaman inventaris laboratorium kampus. Aplikasi menggunakan Riverpod untuk state management, REST API berbasis Express + TypeScript, Prisma ORM, dan MySQL.

> **Status pengembangan:** source saat ini sudah memiliki form peminjaman, riwayat, CRUD record peminjaman melalui API, validasi dasar, serta test otomatis yang ditambahkan. Audit dan regression test pada mesin pengembangan masih harus dijalankan sebelum menyatakan semua test lulus. Beberapa fitur pada lingkup awal—termasuk login/role, katalog inventaris dinamis, approval, status pengembalian, pengelolaan stok otomatis, dan isolasi data per pengguna—belum tersedia. Lihat [`checklist_mvp.md`](checklist_mvp.md).

## 📖 Daftar Isi

- [Tujuan](#-tujuan)
- [Fitur yang Tersedia](#-fitur-yang-tersedia)
- [Batasan dan Fitur Lanjutan](#-batasan-dan-fitur-lanjutan)
- [Arsitektur](#-arsitektur)
- [Tech Stack](#-tech-stack)
- [Menjalankan Aplikasi](#-menjalankan-aplikasi)
- [Pengujian](#-pengujian)
- [Dokumentasi Pengumpulan](#-dokumentasi-pengumpulan)
- [Kontak](#-kontak)

## 🧩 Tujuan

Pencatatan manual untuk peminjaman peralatan laboratorium rentan terhadap kesalahan dan membuat riwayat lebih sulit dicari. LabLend dibuat sebagai langkah digitalisasi agar data peminjaman dapat dibuat, dilihat, diperbarui, dan dihapus melalui aplikasi.

## ✅ Fitur yang Tersedia

- **Form peminjaman:** memilih alat, mengisi jumlah, dan tanggal kembali.
- **Validasi input:** nama alat wajib dipilih, jumlah harus berupa bilangan bulat positif, dan tanggal harus valid dengan format `YYYY-MM-DD`.
- **Loading, empty, dan error state:** UI memiliki state untuk pemuatan pilihan alat, data kosong, kegagalan, dan tombol coba lagi.
- **Submit-lock:** tombol submit dinonaktifkan saat permintaan sedang berlangsung untuk mencegah submit ganda.
- **Riwayat peminjaman:** membaca daftar record dari backend.
- **CRUD record:** membuat, membaca, memperbarui, dan menghapus record peminjaman melalui API.
- **Validasi backend:** backend memeriksa payload sebelum menjalankan operasi database.

## 🚧 Batasan dan Fitur Lanjutan

Fitur berikut pernah dicantumkan pada rancangan ruang lingkup awal, tetapi belum tersedia pada implementasi yang diaudit:

- Login/registrasi dan autentikasi pengguna.
- Role Mahasiswa dan Asisten Laboratorium/Admin dengan pembatasan akses.
- Katalog inventaris dari database beserta CRUD alat.
- Persetujuan/penolakan pinjaman dan status menunggu, dipinjam, atau dikembalikan.
- Pengurangan stok saat approval dan penambahan stok saat pengembalian.
- Isolasi riwayat berdasarkan pengguna yang sedang login.

## 🏗️ Arsitektur

```text
Flutter UI + Riverpod
        │
        ▼
PeminjamanRepository → ApiService (HTTP/JSON)
        │
        ▼
Express + TypeScript REST API
        │
        ▼
Prisma ORM + MariaDB Adapter
        │
        ▼
MySQL
```

Daftar alat pada formulir masih statis; record peminjaman disimpan dan diambil dari backend melalui API. Rincian tersedia di [`ARCHITECTURE.md`](ARCHITECTURE.md).

## 🛠️ Tech Stack

- [Flutter](https://flutter.dev/) dan Dart
- [Riverpod](https://riverpod.dev/) untuk state management
- [`http`](https://pub.dev/packages/http) untuk REST API
- [Node.js](https://nodejs.org/), [Express](https://expressjs.com/), dan [TypeScript](https://www.typescriptlang.org/)
- [Prisma](https://www.prisma.io/)
- [MySQL](https://www.mysql.com/)

## 🚀 Menjalankan Aplikasi

Ikuti panduan langkah demi langkah pada [`HowToRun.md`](HowToRun.md). Panduan tersebut menjelaskan persiapan MySQL, konfigurasi `backend/.env`, menjalankan API, dan menjalankan Flutter Web di Chrome. Jangan commit file `.env` atau password database ke Git.

## 🧪 Pengujian

Dari root repository, jalankan:

```bash
flutter analyze
flutter test
```

Dari folder `backend`, jalankan:

```bash
npm test
npm run build
```

Status pengujian harus diperbarui berdasarkan hasil aktual. Jangan menandai test sebagai `PASSED` sebelum perintah tersebut benar-benar berjalan dan lulus.

## 📄 Dokumentasi Pengumpulan

- [`HowToRun.md`](HowToRun.md) — petunjuk menjalankan aplikasi.
- [`checklist_mvp.md`](checklist_mvp.md) — fitur, status implementasi dan pengujian.
- [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) — urutan demo yang dapat direkam setelah regression test.
- [`AUDIT_REPORT.md`](AUDIT_REPORT.md) — ringkasan progres audit dan fitur yang masih menjadi gap.
- `demo.mp4` — belum disertakan; perlu direkam dari aplikasi yang berjalan pada mesin pengembangan.

## 📬 Kontak

**Author:** James Edison Wihardja  
**GitHub:** [@JamesEdsn](https://github.com/JamesEdsn)  
**Repository:** [LabLend](https://github.com/JamesEdsn/LabLend)
