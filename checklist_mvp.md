# LabLend — MVP Checklist dan Status Pengujian

> **Penting:** status `PASSED` hanya boleh dipakai setelah tes dijalankan dan hasilnya berhasil. Tes baru pada source ini belum dapat dieksekusi dari lingkungan audit karena Flutter SDK tidak tersedia dan instalasi dependency npm tidak selesai. Jalankan semua perintah pada bagian Pengujian di bawah dari komputer pengembang, lalu perbarui status berdasarkan hasil aktual.

## A. Fitur yang sudah tersedia pada kode

| ID | Fitur / skenario | Status implementasi | Status pengujian saat audit |
|---|---|---|---|
| MVP-01 | Memuat daftar alat untuk pilihan form | Diimplementasikan, daftar masih statis | BELUM DIJALANKAN |
| MVP-02 | Menampilkan loading saat memuat daftar alat | Diimplementasikan | BELUM DIJALANKAN |
| MVP-03 | Menampilkan empty state saat daftar alat kosong | Diimplementasikan | BELUM DIJALANKAN |
| MVP-04 | Menampilkan error dan menyediakan tombol retry | Diimplementasikan; test retry dibuat agar dapat pulih dari kegagalan sementara | BELUM DIJALANKAN |
| MVP-05 | Validasi alat wajib dipilih | Diimplementasikan | BELUM DIJALANKAN |
| MVP-06 | Validasi jumlah harus bilangan bulat positif | Diimplementasikan di UI dan backend | BELUM DIJALANKAN |
| MVP-07 | Validasi tanggal `YYYY-MM-DD` dan tanggal kalender valid | Diimplementasikan di model, form, dan backend | BELUM DIJALANKAN |
| MVP-08 | Submit-lock saat pengiriman berlangsung | Diimplementasikan melalui `isSubmitting` dan tombol nonaktif | BELUM DIJALANKAN |
| MVP-09 | Create: menyimpan record peminjaman melalui API | Diimplementasikan | PERLU REGRESSION TEST DENGAN MYSQL |
| MVP-10 | Read: memuat riwayat dari API | Diimplementasikan | PERLU REGRESSION TEST DENGAN MYSQL |
| MVP-11 | Update: mengubah record peminjaman | Diimplementasikan | PERLU REGRESSION TEST DENGAN MYSQL |
| MVP-12 | Delete: menghapus record peminjaman | Diimplementasikan | PERLU REGRESSION TEST DENGAN MYSQL |
| MVP-13 | Menampilkan empty state jika riwayat API kosong | Diimplementasikan | BELUM DIJALANKAN |
| MVP-14 | Menampilkan error dan tombol retry saat riwayat gagal dimuat | Diimplementasikan | BELUM DIJALANKAN |
| MVP-15 | API mengembalikan 400 untuk input invalid | Diimplementasikan | BELUM DIJALANKAN |
| MVP-16 | API mengembalikan 400 untuk JSON rusak | Error handler ditambahkan | BELUM DIJALANKAN |
| MVP-17 | API memberi respons error saat repository gagal | Error handler 500 tersedia | BELUM DIJALANKAN |
| MVP-18 | Data permanen tersimpan melalui Prisma/MySQL | Repository dan schema tersedia | PERLU REGRESSION TEST DENGAN MYSQL |

## B. Fitur yang belum tersedia menurut ruang lingkup yang pernah ditulis

Fitur berikut pernah tercantum di dokumen ruang lingkup awal. Fitur ini **belum diimplementasikan** pada source yang diaudit; jangan menyatakan MVP keseluruhan final sebelum fitur-fitur yang memang diwajibkan dosen selesai atau ruang lingkupnya secara resmi dipersempit.

| ID | Fitur inti dalam ruang lingkup awal | Status implementasi | Status pengujian |
|---|---|---|---|
| MVP-19 | Autentikasi login/register | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |
| MVP-20 | Role mahasiswa dan Aslab/admin serta pembatasan akses | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |
| MVP-21 | Inventaris/alat diambil dari database, bukan daftar hardcoded | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |
| MVP-22 | CRUD katalog inventaris | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |
| MVP-23 | Status peminjaman: menunggu, dipinjam, dikembalikan | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |
| MVP-24 | Approval/penolakan oleh Aslab | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |
| MVP-25 | Stok berkurang saat approval dan bertambah saat pengembalian | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |
| MVP-26 | Riwayat terisolasi berdasarkan pengguna yang login | BELUM DIIMPLEMENTASIKAN | BELUM DIUJI |

## C. Test otomatis yang disediakan

Saat ini ada **44 test case yang didefinisikan** (13 widget, 11 API service, 8 model/date, 5 backend model, 7 backend API). Jumlah ini adalah jumlah test yang tertulis di source, bukan bukti bahwa seluruhnya telah lulus.

### Flutter

- `test/features/peminjaman/form_peminjaman_test.dart` — loading, loaded, empty, error + retry, validasi form, tanggal invalid, submit-lock/loading/sukses, kegagalan API, dan sinkronisasi create ke riwayat.
- `test/features/peminjaman/riwayat_peminjaman_test.dart` — loading, empty, data sukses, error + retry pada halaman riwayat.
- `test/features/peminjaman/peminjaman_model_test.dart` — parsing model, ID/nama alat/jumlah invalid, dan validasi tanggal.
- `test/features/peminjaman/api_service_test.dart` — respons sukses, data kosong, HTTP failure, malformed JSON, record invalid, serta request POST/PUT/DELETE.

Perintah:

```bat
flutter analyze
flutter test
```

### Backend

- `backend/tests/peminjaman.model.test.ts` — validasi payload benar dan input invalid.
- `backend/tests/peminjaman.api.test.ts` — respons GET, empty data, lifecycle CRUD via HTTP dengan repository in-memory, input invalid, JSON rusak, ID tidak ditemukan, dan kegagalan repository.

Perintah dari folder `backend`:

```bat
npm test
npm run build
```

## D. Berkas pengumpulan

| Berkas | Status | Catatan |
|---|---|---|
| Kode versi final | DALAM PROSES | Fitur awal dan perbaikan validasi/API tersedia; fitur di Bagian B belum selesai |
| `HowToRun.md` | TERSEDIA | Sudah dibuat pada root repository; perlu diuji dari awal |
| `checklist_mvp.md` | TERSEDIA | Status pengujian perlu diperbarui setelah test benar-benar dijalankan |
| `AUDIT_REPORT.md` | TERSEDIA | Rangkuman temuan audit, perbaikan, dan gap scope |
| `demo.mp4` | BELUM TERSEDIA | Perlu direkam dari aplikasi berjalan setelah regression test selesai |
| Screenshot bukti | PERLU DIPERBARUI | Screenshot `05-validation.png` masih memperlihatkan label tanggal versi lama; ambil ulang setelah perubahan diverifikasi |

## E. Final sign-off

- [ ] `flutter analyze` selesai tanpa error.
- [ ] `flutter test` lulus seluruh test.
- [ ] `npm test` lulus seluruh test backend.
- [ ] `npm run build` berhasil.
- [ ] Create/Read/Update/Delete berhasil dari UI dengan backend dan MySQL aktif.
- [ ] Uji API mati lalu pulih, input invalid, data kosong, retry, dan submit-lock.
- [ ] Fitur inti pada Bagian B selesai jika masih termasuk ruang lingkup yang diwajibkan.
- [ ] Video demo `demo.mp4` direkam dan diputar ulang untuk memastikan kualitasnya.
- [ ] `HowToRun.md` dicoba mengikuti instruksi dari awal menggunakan database pengujian yang bersih.
