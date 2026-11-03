# LabLend — Audit Report (MVP Progress)

## Ringkasan

Audit source menemukan satu alur CRUD peminjaman yang sudah terhubung dari Flutter ke REST API dan MySQL melalui Prisma. Ada state loading/empty/error untuk daftar alat statis dan state loading/error/empty untuk halaman riwayat. Namun, belum ada bukti pengujian ulang dari audit environment, dan beberapa fitur yang pernah ditulis dalam ruang lingkup awal belum ada di source.

## Perbaikan pada paket progres ini

- Validasi tanggal pada model dan form Flutter diseragamkan ke format `YYYY-MM-DD`, termasuk pemeriksaan tanggal kalender yang valid.
- Form edit juga memakai validasi tanggal yang sama.
- HTTP API unit tests menggunakan `MockClient`, bukan bergantung pada server lokal yang sedang berjalan.
- Ditambahkan test untuk operasi API sukses/gagal serta validasi model.
- Ditambahkan test backend untuk validasi payload dan skenario HTTP dengan repository in-memory.
- Error JSON yang malformed ditangani sebagai HTTP 400.
- Riwayat peminjaman di-refresh setelah create berhasil supaya data baru tidak tertahan dalam state lama pada `IndexedStack`.
- HTTP client ditutup saat provider repository dihancurkan.
- Delay simulasi default di repository diubah menjadi nol; test dapat menetapkan delay sendiri saat menguji loading.
- Script `start` backend diarahkan ke `dist/src/server.js`, sesuai struktur output TypeScript yang diatur dalam `tsconfig.json`.
- `README.md` dan `ARCHITECTURE.md` diperbarui agar menggambarkan arsitektur aktual.
- Dibuat `HowToRun.md`, `checklist_mvp.md`, `AUDIT_REPORT.md`, `DEMO_SCRIPT.md`, dan `backend/.env.example`.
- `.gitignore` ditambah untuk mencegah file konfigurasi lokal Android/Flutter masuk ke Git.
- Screenshot lama belum diperbarui setelah perubahan label/validasi tanggal; ambil ulang bukti visual setelah menjalankan aplikasi pada mesin pengembang.

## Jumlah test yang tersedia

Ada 44 test case yang didefinisikan di source:

- 13 Flutter widget tests.
- 11 Flutter API-service tests.
- 8 Flutter model/date-validation tests.
- 5 backend model-validation tests.
- 7 backend HTTP API tests.

**Status eksekusi: BELUM DIKONFIRMASI.** Flutter SDK tidak tersedia di environment audit dan instalasi dependency npm tidak berhasil selesai di environment ini. Karena itu, test tidak ditandai `PASSED`. Jalankan perintah yang ada di `HowToRun.md` pada komputer Windows yang mempunyai Flutter dan akses dependency, lalu catat hasil aktual di `checklist_mvp.md`.

TypeScript source dan test telah diperiksa untuk syntax/transpilation errors menggunakan TypeScript transpiler yang tersedia secara global. Lima assertion validasi pada backend model juga dieksekusi manual dari hasil transpilation dan lulus. Namun, `npm ci` pada environment audit mengalami timeout; pemeriksaan syntax/manual ini bukan pengganti `npm test` atau `npm run build`.

## Gap terhadap rancangan MVP awal

Source saat ini belum memiliki:

1. Autentikasi/login/register dan role mahasiswa/Aslab.
2. Katalog inventaris dari database dan CRUD alat.
3. Status pinjaman, approval/penolakan, serta pengembalian oleh Aslab.
4. Pembaruan stok otomatis yang konsisten dengan approval/pengembalian.
5. Isolasi data berdasarkan pengguna yang login.

Apabila item di atas masih diwajibkan sebagai bagian dari ruang lingkup yang telah disepakati, LabLend **belum dapat dinyatakan sebagai MVP lengkap**. Implementasikan fitur yang diwajibkan, tambahkan test-nya, dan jalankan regresi sebelum merekam video demo final.

## Berkas pengumpulan

- [x] `HowToRun.md` — panduan awal telah dibuat, perlu diverifikasi dengan mengikuti langkahnya di mesin bersih.
- [x] `checklist_mvp.md` — status implementasi dan status tes, belum ditandai lulus secara prematur.
- [x] `DEMO_SCRIPT.md` — urutan manual untuk merekam demonstrasi.
- [ ] `demo.mp4` — belum dibuat karena perlu direkam saat aplikasi berjalan pada mesin pengembang.
- [ ] Kode versi final — belum final hingga scope MVP dan seluruh test yang relevan telah lulus.
