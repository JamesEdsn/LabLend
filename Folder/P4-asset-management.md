# P4 — Dokumentasi Fitur: Form Peminjaman LabLend

Fitur yang dikembangkan pada tahap ini merupakan bagian awal dari aplikasi LabLend untuk memenuhi requirement P4, yaitu penerapan state management menggunakan Riverpod, form dengan validasi input, serta enam kondisi UI yang wajib ditunjukkan.

Fitur ini berfokus pada proses pengajuan peminjaman alat laboratorium. Pengguna dapat memilih alat, memasukkan jumlah alat, menentukan tanggal pengembalian, dan mengirim pengajuan. Data yang digunakan masih berupa data simulasi dan belum terhubung dengan backend atau database.

## 1. Ringkasan Implementasi

* **Nama project:** LabLend
* **Fitur:** Form Peminjaman Inventaris Laboratorium
* **Framework:** Flutter
* **Bahasa pemrograman:** Dart
* **State management:** Riverpod (`flutter_riverpod`)
* **Pola arsitektur:** Feature-based structure dan Repository Pattern
* **Lokasi kode:** `lib/features/peminjaman/`
* **Lokasi widget test:** `test/features/peminjaman/form_peminjaman_test.dart`
* **Bukti screenshot:** `screenshots/`

### Struktur Implementasi

```text
lib/
├── main.dart
└── features/
    └── peminjaman/
        ├── providers/
        │   └── peminjaman_notifier.dart
        ├── repositories/
        │   └── peminjaman_repository.dart
        └── screens/
            └── form_peminjaman_screen.dart

test/
└── features/
    └── peminjaman/
        └── form_peminjaman_test.dart

screenshots/
├── 01-loading.png
├── 02-loaded.png
├── 03-empty.png
├── 04-error-retry.png
├── 05-validation.png
├── 06-submit-loading.png
└── 07-widget-tests.png
```

### Pembagian Tanggung Jawab

* **`form_peminjaman_screen.dart`** — menampilkan antarmuka peminjaman, menerima input pengguna, menjalankan validasi form, dan menampilkan hasil proses.
* **`peminjaman_notifier.dart`** — mengatur state aplikasi, mengambil data alat, menangani error, serta mengelola proses submit.
* **`peminjaman_repository.dart`** — menyediakan data alat dan mensimulasikan proses pengajuan peminjaman.
* **`form_peminjaman_test.dart`** — menguji kondisi UI dan perilaku utama pada fitur peminjaman.

### Alur State Management

```text
Pengguna
   |
   v
FormPeminjamanScreen
   |
   | Input dan validasi form
   v
PeminjamanNotifier
   |
   | Mengatur perubahan state
   v
PeminjamanRepository
   |
   | Simulasi pengambilan dan
   | pengiriman data
   v
Data Simulasi
```

## 2. Prompt AI yang Digunakan

Pengembangan fitur ini dilakukan secara bertahap dengan bantuan AI sebagai pendamping penulisan dan perbaikan kode. Kode tetap perlu diperiksa dan diuji secara langsung agar sesuai dengan requirement tugas.

Prompt berikut merangkum tahapan pengembangan. Untuk laporan final, sesuaikan dengan prompt asli yang benar-benar digunakan dan tambahkan screenshot percakapan atau output terminal jika tersedia.

### Prompt 1 — Implementasi Awal Fitur Peminjaman

Membangun project Flutter LabLend dengan fitur form peminjaman alat laboratorium. Implementasi menggunakan Riverpod sebagai state management, repository untuk penyediaan data, dan pemisahan kode berdasarkan fitur.

Fitur awal meliputi pemilihan alat, input jumlah, tanggal pengembalian, serta simulasi pengambilan data dan pengajuan peminjaman.

**Fokus implementasi:**

* Menyiapkan struktur folder fitur peminjaman.
* Membuat repository untuk data simulasi.
* Membuat notifier untuk mengatur state.
* Membuat UI form peminjaman.

**Bukti:** Tambahkan screenshot prompt AI yang digunakan dan hasil implementasi awal.

### Prompt 2 — Implementasi State Management

Menerapkan state management menggunakan Riverpod agar UI dapat menampilkan kondisi aplikasi secara tepat ketika data sedang dimuat, berhasil diperoleh, kosong, atau gagal diperoleh.

**Fokus implementasi:**

* Initial loading.
* Data berhasil dimuat.
* Empty state.
* Error state dengan tombol retry.
* Loading saat submit.
* Pencegahan submit berulang selama proses pengajuan berlangsung.

**Bukti:** Tambahkan screenshot kode notifier dan tampilan state aplikasi.

### Prompt 3 — Implementasi Validasi Form

Memastikan form peminjaman melakukan validasi sebelum proses submit dijalankan.

Aturan validasi yang diterapkan:

* Alat harus dipilih.
* Jumlah tidak boleh kosong.
* Jumlah harus berupa bilangan bulat yang lebih besar dari nol.
* Tanggal pengembalian tidak boleh kosong.

Jika validasi gagal, pesan kesalahan ditampilkan dan proses submit tidak dijalankan.

**Bukti:** Tambahkan screenshot form yang menunjukkan pesan kesalahan validasi.

### Prompt 4 — Implementasi dan Perbaikan Widget Test

Membuat widget test untuk memeriksa kondisi utama fitur peminjaman menggunakan repository provider override agar kondisi seperti data kosong, error, dan loading dapat diuji secara terkontrol.

**Fokus implementasi:**

* Menguji initial loading.
* Menguji tampilan data alat.
* Menguji empty state.
* Menguji error dan tombol retry.
* Menguji validasi form.
* Menguji loading pada tombol submit.

**Bukti:** Tambahkan screenshot perintah `flutter test` beserta output terminal aktual.

## 3. Hasil Widget Test

Widget test dibuat pada file:

```text
test/features/peminjaman/form_peminjaman_test.dart
```

Enam skenario yang direncanakan untuk diuji adalah sebagai berikut.

| No. | Skenario             | Hasil yang Diharapkan                                          |
| --- | -------------------- | -------------------------------------------------------------- |
| 1   | Initial loading      | Indikator loading ditampilkan ketika data sedang dimuat.       |
| 2   | Data berhasil dimuat | Daftar alat dan form peminjaman ditampilkan.                   |
| 3   | Empty state          | Pesan bahwa stok alat sedang kosong ditampilkan.               |
| 4   | Error dan retry      | Pesan error serta tombol Coba Lagi ditampilkan.                |
| 5   | Validasi form        | Pesan kesalahan muncul ketika input tidak valid.               |
| 6   | Loading saat submit  | Tombol submit dinonaktifkan dan indikator loading ditampilkan. |

### Perintah Pengujian

Jalankan pengujian melalui terminal VS Code:

```bash
flutter test test/features/peminjaman/form_peminjaman_test.dart
```

Untuk menjalankan seluruh test pada project:

```bash
flutter test
```

**Hasil pengujian:** Isi bagian ini berdasarkan output terminal yang benar-benar diperoleh setelah menjalankan perintah tersebut. Jangan menyatakan seluruh test berhasil sebelum hasilnya diverifikasi.

**Bukti pengujian:** Lampirkan screenshot terminal yang menunjukkan jumlah test berhasil atau pesan error yang ditemukan.

## 4. Bukti Enam Kondisi UI

Screenshot berikut digunakan untuk menunjukkan bahwa fitur peminjaman dapat menangani berbagai kondisi aplikasi.

| No. | Kondisi              | Screenshot                                            | Penjelasan                                                                                              |
| --- | -------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| 1   | Initial loading      | [Lihat Screenshot](screenshots/01-loading.png)        | Indikator loading ditampilkan ketika aplikasi mengambil data alat.                                      |
| 2   | Data berhasil dimuat | [Lihat Screenshot](screenshots/02-loaded.png)         | Daftar alat dan form peminjaman ditampilkan setelah data tersedia.                                      |
| 3   | Empty state          | [Lihat Screenshot](screenshots/03-empty.png)          | Pesan stok alat kosong ditampilkan ketika repository mengembalikan daftar kosong.                       |
| 4   | Error + retry        | [Lihat Screenshot](screenshots/04-error-retry.png)    | Pesan error dan tombol Coba Lagi ditampilkan ketika pengambilan data gagal.                             |
| 5   | Validasi input       | [Lihat Screenshot](screenshots/05-validation.png)     | Pesan kesalahan muncul ketika input form tidak memenuhi aturan validasi.                                |
| 6   | Loading saat submit  | [Lihat Screenshot](screenshots/06-submit-loading.png) | Tombol submit menampilkan indikator loading dan tidak dapat ditekan ulang selama pengajuan berlangsung. |

## 5. Bagian yang Saya Review/Perbaiki Sendiri

Bagian ini menjelaskan pemahaman dan pemeriksaan manual terhadap kode yang dikembangkan dengan bantuan AI. Catatan berikut perlu disesuaikan dengan hal yang benar-benar sudah diperiksa selama pengerjaan.

* **State management:** Memeriksa hubungan antara `FormPeminjamanScreen`, `PeminjamanNotifier`, dan `PeminjamanRepository`, serta memahami bagaimana perubahan state memengaruhi tampilan UI.
* **Validasi form:** Memeriksa bahwa alat harus dipilih, jumlah harus berupa bilangan bulat positif, dan tanggal pengembalian wajib diisi sebelum submit dijalankan.
* **Error dan retry:** Memeriksa bahwa kegagalan pengambilan data menampilkan pesan error dan tombol Coba Lagi dapat memulai proses pengambilan data kembali.
* **Pencegahan submit berulang:** Memeriksa bahwa tombol submit dinonaktifkan selama proses pengajuan dan notifier menolak submit tambahan ketika proses sebelumnya masih berjalan.
* **Repository:** Memeriksa bahwa data alat berasal dari repository, bukan ditulis langsung pada widget UI, sehingga sumber data dapat diganti ketika backend mulai dikembangkan.
* **Widget test:** Meninjau skenario pengujian untuk memastikan test memeriksa perilaku UI, bukan hanya keberadaan widget secara visual.

Jika ditemukan bug selama pengujian, tambahkan satu atau dua contoh konkret berupa masalah awal, penyebab, perbaikan, dan hasil setelah perbaikan.

## 6. Catatan Tambahan dan Pengembangan Selanjutnya

Implementasi ini merupakan tahap awal pengembangan LabLend, bukan versi final aplikasi. Fitur yang telah dibuat berfokus pada penerapan state management, validasi form, dan pengujian kondisi UI.

### Batasan Implementasi Saat Ini

* Data inventaris masih menggunakan data simulasi.
* Proses pengajuan peminjaman belum disimpan ke database.
* Belum ada autentikasi dan pengaturan hak akses pengguna.
* Belum ada integrasi backend/API.
* Belum ada alur persetujuan peminjaman oleh Asisten Laboratorium.
* Belum ada proses pengembalian dan riwayat peminjaman yang terhubung dengan data nyata.

### Rencana Pengembangan Berikutnya

1. Menambahkan katalog inventaris.
2. Mengembangkan autentikasi dan role pengguna.
3. Menghubungkan fitur dengan backend dan database.
4. Menambahkan validasi dan persetujuan peminjaman oleh Aslab.
5. Mengembangkan proses pengembalian dan riwayat peminjaman.
6. Menyempurnakan UI/UX dan memperluas pengujian aplikasi.

> **Kesimpulan:** Tahap ini menghasilkan fondasi fitur peminjaman LabLend dengan Riverpod, pemisahan tanggung jawab antara UI, notifier, dan repository, validasi input, serta penanganan berbagai kondisi UI. Pengembangan akan dilanjutkan secara bertahap hingga fitur-fitur utama aplikasi selesai diimplementasikan.
