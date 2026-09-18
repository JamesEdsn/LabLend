Architecture.md - LabLend
Bangun aplikasi mobile full-stack sederhana bernama LabLend.

Tujuan:
Membantu Mahasiswa dan Asisten Laboratorium (Aslab) mengelola inventaris perangkat keras laboratorium. Aplikasi memungkinkan mahasiswa melihat stok dan mengajukan peminjaman, sementara Aslab dapat memvalidasi permohonan dan melacak status pengembalian alat secara real-time.

Gunakan stack ini:

Frontend (Mobile): React Native (Expo) + TypeScript + NativeWind (Tailwind CSS)

Backend: Node.js + TypeScript + Express

Database: MySQL

ORM: Prisma

API style: REST API

Infrastruktur: Docker Compose untuk MySQL

Konfigurasi: Gunakan .env.example untuk URL database dan rahasia JWT/Sesi.

Aturan Kode:

Jangan menambahkan komentar kecuali benar-benar diperlukan.

Gunakan PascalCase untuk semua class, tipe, interface, enum, komponen React Native, model database, API DTO, dan properti JSON.

Variabel lokal dapat menggunakan camelCase.

Jaga panjang baris kode di bawah 150 karakter jika memungkinkan.

Gunakan struktur folder yang bersih dan sederhana.

Gunakan autentikasi sederhana (NIM/Username dan Password) untuk membedakan peran (Role) Mahasiswa dan Aslab.

Entitas Utama:

Pengguna

Id

Nim (Nomor Induk Mahasiswa / ID Aslab)

Name

Role (MAHASISWA | ASLAB)

PasswordHash

CreatedAt

AlatLab

Id

Name

Description

ImageUrl

TotalStock

CurrentStock

CreatedAt

Peminjaman

Id

PenggunaId

AlatLabId

Quantity

Status (MENUNGGU | DIPINJAM | DIKEMBALIKAN | DITOLAK)

ExpectedReturnDate

ActualReturnDate

CreatedAt

Aturan Database:

Satu Peminjaman terikat pada satu Pengguna dan satu AlatLab.

Nilai CurrentStock pada AlatLab tidak boleh di bawah 0.

Ketika status Peminjaman diubah menjadi DIPINJAM (disetujui oleh Aslab), kurangi CurrentStock sebanyak Quantity.

Ketika status Peminjaman diubah menjadi DIKEMBALIKAN, tambahkan kembali CurrentStock sebanyak Quantity.

Gunakan migrasi Prisma dan buat data seed awal: 1 akun Aslab, 2 akun Mahasiswa, dan 5 AlatLab (misal: ESP32, HC-SR04, MikroTik).

Fitur Backend:

Autentikasi Sederhana

Endpoint login yang mengembalikan Id Pengguna dan Role.

CRUD AlatLab (Hanya Aslab)

Create, list, detail, update, delete alat laboratorium.

Mahasiswa hanya memiliki akses Read (list dan detail).

Manajemen Peminjaman

Mahasiswa: Dapat membuat permohonan peminjaman baru (status default: MENUNGGU).

Aslab: Dapat mengubah status peminjaman (MENUNGGU -> DIPINJAM atau DITOLAK).

Aslab: Dapat mengubah status peminjaman (DIPINJAM -> DIKEMBALIKAN).

Validasi stok: Tolak pengajuan jika Quantity melebihi CurrentStock.

Dashboard API

Mengembalikan ringkasan untuk Aslab:

TotalAlatLab

TotalMenungguPersetujuan

TotalSedangDipinjam

TotalDikembalikan

Halaman Frontend (Mobile Screens):

Login Screen

Form input NIM dan Password.

Navigasi dinamis berdasarkan Role setelah login berhasil.

Beranda / Katalog Alat (Mahasiswa)

Daftar alat laboratorium dalam bentuk grid/card.

Tampilkan nama, foto, dan sisa stok (CurrentStock).

Klik alat untuk masuk ke detail dan tombol "Ajukan Pinjaman".

Form Pengajuan Pinjaman (Mahasiswa)

Input jumlah yang ingin dipinjam (Quantity).

Input estimasi tanggal pengembalian (ExpectedReturnDate).

Tombol "Kirim Pengajuan".

Riwayat Peminjaman (Mahasiswa)

Daftar permohonan yang pernah dibuat oleh pengguna tersebut.

Tampilkan status pengajuan dengan badge warna.

Dashboard Aslab (Aslab)

Ringkasan data (Total Alat, Total Pengajuan Menunggu).

Daftar pengajuan dengan status MENUNGGU.

Tombol Approve (Setujui) dan Reject (Tolak).

Daftar Peminjaman Aktif (Aslab)

Daftar mahasiswa yang barangnya berstatus DIPINJAM.

Tombol Mark as Returned (Tandai Dikembalikan).

Kelola AlatLab (Aslab)

Daftar lengkap inventaris dengan operasi tambah, edit, dan hapus alat.

Kebutuhan UI:

Gunakan bahasa Indonesia untuk semua label, tombol, pesan, dan validasi.

Gunakan desain antarmuka mobile yang bersih (menggunakan prinsip rasio 60-30-10).

Gunakan elemen standar: Card, List, Modal/Dialog konfirmasi sebelum aksi penting (seperti menyetujui peminjaman), dan Empty States (jika data kosong).

Gunakan warna Badge Status:

DIPINJAM: Biru

DIKEMBALIKAN: Hijau

MENUNGGU: Kuning/Oranye

DITOLAK: Merah

Rute API yang Dibutuhkan:

POST /api/auth/login

GET /api/alat-lab

POST /api/alat-lab (Aslab)

GET /api/alat-lab/:Id

PUT /api/alat-lab/:Id (Aslab)

DELETE /api/alat-lab/:Id (Aslab)

GET /api/peminjaman (Aslab melihat semua, Mahasiswa melihat miliknya)

POST /api/peminjaman (Mahasiswa)

PUT /api/peminjaman/:Id/status (Aslab - untuk mengubah status)

GET /api/dashboard/aslab (Aslab)

Hasil yang Diharapkan (Deliverables):

Kode sumber lengkap untuk frontend (mobile) dan backend.

Skema Prisma, file migrasi, dan data seed.

File Docker Compose untuk MySQL.

.env.example.

File README berisi instruksi instalasi, migrasi database, seed, cara menjalankan aplikasi React Native (Expo) dan Node.js, serta penggunaan Docker.

Pastikan aplikasi dapat di-build dan operasi CRUD serta siklus peminjaman berjalan dengan lancar.

Struktur Proyek:

Gunakan arsitektur TypeScript monorepo dengan npm workspaces.

Struktur:

Plaintext
lablend-app/
apps/
  mobile/
  api/
packages/
  shared/
Kebutuhan Paket Shared:

Buat packages/shared sebagai @lablend/shared.

Simpan semua model domain bersama, enum, tipe respons API, dan konstanta bersama di sini.

Baik apps/mobile maupun apps/api harus mengimpor tipe shared dari paket ini.

Jangan menduplikasi definisi model domain antara frontend dan backend.

Contoh File Shared:

Plaintext
packages/shared/src/
  models/
    Pengguna.ts
    AlatLab.ts
    Peminjaman.ts
  enums/
    Role.ts
    PeminjamanStatus.ts
  dto/
    AuthResponse.ts
    DashboardResponse.ts
  index.ts
Aturan Model:

Tentukan tipe atau interface TypeScript bersama hanya sekali di packages/shared.

Contoh: Pengguna, AlatLab, Peminjaman, dan PeminjamanStatus harus diimpor oleh frontend dan backend dari @lablend/shared.

Model Prisma tetap berada di backend karena bersifat spesifik untuk database.

Backend memetakan entitas Prisma ke model API bersama (Shared DTO) sebelum mengembalikan respons.

Frontend tidak boleh mengimpor tipe Prisma secara langsung.

Konfigurasikan TypeScript paths, dependensi workspace, dan skrip agar seluruh paket dapat dikompilasi dengan sukses.
