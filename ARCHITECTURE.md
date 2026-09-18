# Architecture — LabLend

## Stack

* **Frontend:** React Native (Expo) + TypeScript + NativeWind
* **Backend:** Node.js (Express) + TypeScript
* **Database:** MySQL
* **ORM:** Prisma
* **Infrastructure:** Docker Compose (untuk database lokal)
* **Architecture Pattern:** Monorepo (npm workspaces)

## Folder Structure

lablend-app/
├── apps/
│   ├── mobile/          -> UI pages (screens), components, API services (Frontend)
│   └── api/             -> Express routes, controllers, Prisma schema (Backend)
├── packages/
│   └── shared/          -> Data models (AlatLab, Peminjaman), enums, DTOs
├── docker-compose.yml   -> MySQL database config
└── README.md

## Data Flow
User actions di Mobile App -> HTTP Request ke Express API -> Prisma eksekusi query ke MySQL -> API mengembalikan respons JSON -> Mobile App memperbarui state UI.

## Key Decisions
**Monorepo (npm workspaces):** Dipakai agar frontend dan backend bisa berbagi tipe data (DTO dan interface) dari folder shared, sehingga tidak ada duplikasi kode.
**React Native (Expo):** Dipilih agar bisa membangun aplikasi mobile (Android/iOS) dengan cepat tanpa perlu konfigurasi native (Android Studio/Xcode) yang berat.
**Prisma ORM:** Digunakan karena fitur type-safety dengan TypeScript sangat kuat, mengurangi risiko bug pada database.
**NativeWind:** Dipakai agar styling UI di React Native bisa menggunakan utility classes ala Tailwind CSS, mempercepat proses desain.
**Skala Realistis:** Autentikasi dibuat sederhana (tanpa OAuth), dan akses hardware seperti kamera (scan barcode) diabaikan pada versi MVP ini agar proyek pasti selesai dalam 12 kali pertemuan perkuliahan.
