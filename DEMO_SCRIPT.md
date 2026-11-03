# Script Rekaman Demo LabLend

Rekam setelah semua fitur yang diwajibkan selesai dan regression test lulus. Jangan menyunting video seolah-olah skenario yang belum berjalan sudah berhasil.

## Urutan rekaman yang disarankan

1. **Pembukaan (5–10 detik):** tunjukkan nama LabLend dan jelaskan bahwa aplikasi mendigitalisasi peminjaman alat laboratorium.
2. **Tampilkan form:** tunjukkan daftar alat yang tersedia dan field jumlah serta tanggal kembali.
3. **Validasi (10–15 detik):** submit form kosong, lalu tunjukkan pesan validasi. Isi tanggal dengan format salah dan tunjukkan bahwa input ditolak.
4. **Create:** isi peminjaman valid dengan tanggal berformat `YYYY-MM-DD`, submit, dan tunjukkan pesan sukses.
5. **Read:** buka halaman Riwayat dan pastikan record baru tampil.
6. **Update:** edit jumlah atau alat, simpan, lalu tunjukkan perubahan di riwayat.
7. **Delete:** hapus record dengan konfirmasi dan pastikan record hilang.
8. **Empty/error/retry:** bila sesuai dan aman untuk demo, tunjukkan riwayat kosong serta penanganan kegagalan API dan tombol Coba Lagi.
9. **Penutup:** tunjukkan terminal `flutter test`, `npm test`, dan `npm run build` hanya setelah perintah tersebut benar-benar berhasil.

## Rekam menjadi `demo.mp4`

- Gunakan Windows Snipping Tool (Screen Recording), OBS Studio, atau aplikasi perekam layar lain.
- Rekam layar aplikasi dan terminal hanya saat diperlukan; tutup file `.env`, password, dan informasi pribadi.
- Simpan hasil akhir dengan nama persis `demo.mp4` pada root folder pengumpulan.
- Putar ulang file sebelum dikumpulkan dan pastikan suara/tampilan terbaca.
