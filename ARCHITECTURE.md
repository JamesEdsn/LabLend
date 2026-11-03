# LabLend Architecture

LabLend adalah aplikasi peminjaman inventaris laboratorium berbasis Flutter. Dokumen ini menjelaskan implementasi yang tersedia pada source saat ini dan membedakannya dari fitur MVP yang masih perlu dikembangkan.

## Tech Stack

- **Frontend:** Flutter + Dart
- **State management:** Riverpod
- **HTTP client:** package `http`
- **Backend:** Node.js, Express, TypeScript
- **ORM:** Prisma
- **Database:** MySQL
- **Automated tests:** Flutter widget/unit tests; Node.js test runner untuk API/backend

## Struktur Utama

```text
LabLend/
├── lib/
│   ├── main.dart
│   └── features/peminjaman/
│       ├── models/peminjaman_model.dart
│       ├── providers/
│       │   ├── peminjaman_notifier.dart
│       │   └── riwayat_peminjaman_notifier.dart
│       ├── repositories/peminjaman_repository.dart
│       ├── screens/
│       ├── services/api_service.dart
│       └── ...
├── test/features/peminjaman/
├── backend/
│   ├── src/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── routes/
│   │   ├── app.ts
│   │   ├── database.ts
│   │   └── server.ts
│   ├── prisma/schema.prisma
│   └── tests/
├── HowToRun.md
├── checklist_mvp.md
└── README.md
```

## Architecture Flow

```text
Flutter Screen
    │ user action / state rendering
    ▼
Riverpod Notifier
    │ calls repository methods
    ▼
PeminjamanRepository
    │ calls ApiService
    ▼
ApiService (HTTP + JSON)
    │ REST requests
    ▼
Express + TypeScript API
    │ validates request and runs CRUD
    ▼
Prisma Client + MariaDB adapter
    │ SQL operations
    ▼
MySQL (peminjaman table)
```

## State Management

`PeminjamanNotifier` mengelola state form dan pilihan alat: `loading`, `loaded`, `empty`, `error`, serta `isSubmitting`. `RiwayatPeminjamanNotifier` menggunakan `AsyncNotifier` untuk memuat data riwayat serta menangani refresh, update, dan delete.

Pada implementasi saat ini, daftar pilihan alat di form masih statis dari `PeminjamanRepository.fetchAlat()`. Data riwayat peminjaman sudah dibaca dari REST API. Setelah create berhasil, provider riwayat di-invalidate agar daftar membaca ulang data.

## REST API

Base URL default saat Flutter Web dan backend berada di komputer yang sama: `http://localhost:3000/api`.

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/peminjaman` | Mengambil semua record |
| GET | `/peminjaman/:id` | Mengambil satu record |
| POST | `/peminjaman` | Membuat record baru |
| PUT | `/peminjaman/:id` | Memperbarui record |
| DELETE | `/peminjaman/:id` | Menghapus record |

Backend memvalidasi nama alat, jumlah positif berbentuk integer, dan tanggal valid berformat `YYYY-MM-DD`. Respons JSON yang rusak dikembalikan sebagai HTTP 400. Error internal ditangani sebagai HTTP 500.

## Testing

Tes Flutter ada di `test/features/peminjaman/` dan memakai HTTP mock agar tidak membutuhkan server API sungguhan. Tes backend ada di `backend/tests/` dan menjalankan HTTP server lokal dengan repository in-memory sehingga tes API tidak memerlukan koneksi MySQL.

Jalankan dari root Flutter:

```bash
flutter analyze
flutter test
```

Jalankan dari folder `backend`:

```bash
npm test
npm run build
```

## Batasan MVP Saat Ini

CRUD record peminjaman telah tersedia. Namun, daftar alat masih statis dan source belum memiliki autentikasi, role pengguna, katalog inventaris berbasis database, workflow approval/pengembalian, perubahan stok, atau pemisahan riwayat berdasarkan pengguna. Apakah hal-hal tersebut wajib diselesaikan harus merujuk pada ruang lingkup final yang disetujui dosen. Status audit rinci dicatat di `checklist_mvp.md`.
