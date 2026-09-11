# LabLend - Aplikasi Manajemen Peminjaman Inventaris Laboratorium

# 📌 Deskripsi Masalah
Dalam pelaksanaan kegiatan praktikum maupun pengerjaan tugas akhir, mahasiswa sering kali diwajibkan untuk meminjam perangkat keras laboratorium (seperti mikrokontroler ESP32, sensor ultrasonik HC-SR04, router MikroTik, atau kabel jaringan). Namun, sistem peminjaman yang berjalan saat ini masih mengandalkan pencatatan manual di buku besar laboratorium. Hal ini menimbulkan beberapa masalah utama:

- Informasi Stok Tidak Real-Time: Mahasiswa sering membuang waktu datang ke laboratorium hanya untuk mendapati bahwa alat yang dibutuhkan sedang habis atau dipinjam orang lain.
- Risiko Kehilangan Aset: Pencatatan manual rentan terhadap human error (lupa mencatat, tulisan tidak terbaca), sehingga sulit melacak siapa peminjam terakhir jika sebuah alat hilang atau rusak.
- Birokrasi yang Memakan Waktu: Asisten Laboratorium (Aslab) kesulitan memantau alat mana saja yang sudah melewati tenggat waktu pengembalian karena harus mengecek ratusan baris di buku catatan secara manual.

# 👤 Profil Target Pengguna
Aplikasi ini dirancang untuk dua jenis peran (role) pengguna utama di lingkungan kampus:

- Mahasiswa (Pengguna Utama / Peminjam): Mahasiswa program studi informatika atau teknik yang membutuhkan akses sementara ke perangkat keras lab untuk menunjang tugas kuliah atau eksperimen proyek.
- Asisten Laboratorium / Teknisi (Pengelola / Admin): Pihak yang bertanggung jawab menjaga aset laboratorium, memvalidasi permohonan pinjaman, dan memastikan barang kembali dalam keadaan utuh.

# ✅ Manfaat Aplikasi
- Transparansi Ketersediaan Alat: Mahasiswa dapat mengecek sisa stok inventaris secara langsung melalui smartphone sebelum datang ke kampus.
- Akuntabilitas Peminjaman: Setiap barang yang keluar masuk lab terikat dengan ID/NIM mahasiswa peminjam, sehingga mencegah terjadinya kehilangan barang tanpa jejak.
- Efisiensi Waktu Aslab: Aslab tidak perlu lagi merekap data di kertas; seluruh daftar mahasiswa yang belum mengembalikan alat dapat dilihat melalui satu dashboard digital yang rapi.
- Digitalisasi Riwayat: Kampus memiliki rekam jejak digital terkait alat apa saja yang paling sering dipinjam untuk keperluan evaluasi pengadaan barang di semester berikutnya.

# 🧩 Daftar Fitur Inti (Realistis untuk 12 Pertemuan)
Fitur-fitur ini difokuskan pada penguasaan operasi CRUD (Create, Read, Update, Delete) dan manajemen state yang esensial:

- Autentikasi Pengguna & Role Management: Login/Register sederhana menggunakan NIM dan password, dengan pemisahan tampilan beranda antara Mahasiswa dan Aslab.
- Katalog Inventaris (Read): Menampilkan daftar perangkat keras lab yang tersedia beserta foto, nama, deskripsi singkat, dan jumlah sisa stok saat ini.
- Formulir Pengajuan Pinjaman (Create): Mahasiswa dapat memilih alat dari katalog, memasukkan jumlah yang ingin dipinjam, dan mengisi estimasi tanggal pengembalian.
- Validasi Peminjaman & Pengembalian oleh Aslab (Update):
    1. Aslab memiliki tombol Approve (mengubah status menjadi "Sedang Dipinjam" dan mengurangi stok).
    2. Aslab memiliki tombol Returned (mengubah status menjadi "Sudah Dikembalikan" dan menambah stok kembali).
- Riwayat & Status Peminjaman (Read): Halaman khusus bagi mahasiswa untuk melihat status pengajuan mereka (Menunggu Persetujuan -> Sedang Dipinjam -> Selesai).

# 🚫 Fitur yang Tidak Dikerjakan (Out of Scope)
Untuk menjaga agar proyek tetap realistis dan selesai tepat waktu, beberapa fitur lanjutan berikut ditiadakan pada rilis awal ini:

- Sistem Scan Barcode atau QR Code: Peminjaman tidak menggunakan integrasi kamera untuk memindai label pada fisik alat.
- Denda Keterlambatan Otomatis & Payment Gateway: Tidak ada integrasi pembayaran uang denda secara online jika mahasiswa terlambat mengembalikan barang.
- Notifikasi Push Kompleks: Tidak menggunakan layanan pihak ketiga seperti Firebase Cloud Messaging untuk notifikasi; pembaruan status cukup dilihat dengan membuka (me-refresh) aplikasi.
- Integrasi Multi-Fakultas / Multi-Kampus: Aplikasi hanya diatur untuk satu basis data laboratorium spesifik, tidak digabungkan dengan lab dari jurusan lain.

# 🎯 Kriteria Aplikasi Dinyatakan Berhasil
Aplikasi LabLend dinyatakan layak dan berhasil apabila memenuhi skenario pengujian end-to-end berikut:

- Integritas Data Stok: Ketika Aslab menekan tombol Approve pada peminjaman, angka stok barang di halaman katalog otomatis berkurang. Begitu pula saat barang dikembalikan, stok otomatis bertambah dengan akurat.
- Keberhasilan Operasi CRUD: Aslab dapat menambah (Create), melihat (Read), mengedit (Update), dan menghapus (Delete) daftar barang baru ke dalam katalog tanpa memicu error atau crash pada aplikasi.
- Isolasi Data Peminjam: Mahasiswa (User A) hanya bisa melihat riwayat peminjamannya sendiri, dan tidak bisa melihat barang apa yang sedang dipinjam oleh Mahasiswa lain (User B).
- Perubahan Status Real-Time (Aplikasi): Mahasiswa dapat melihat perubahan status secara tepat pada riwayat pinjamannya dari "Menunggu Persetujuan" menjadi "Sedang Dipinjam" setelah Aslab melakukan validasi dari akunnya.
