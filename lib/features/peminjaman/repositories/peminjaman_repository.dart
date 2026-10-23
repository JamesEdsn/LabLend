import '../models/peminjaman_model.dart';
import '../services/api_service.dart';

class PeminjamanRepository {
  final bool simulateEmpty;
  final bool simulateError;
  final Duration fetchDelay;
  final Duration submitDelay;

  final ApiService _api;

  PeminjamanRepository({
    this.simulateEmpty = false,
    this.simulateError = false,
    this.fetchDelay = const Duration(seconds: 2),
    this.submitDelay = const Duration(seconds: 2),
    ApiService? api,
  }) : _api = api ?? ApiService();

  // Tetap menyediakan daftar alat untuk dropdown.
  Future<List<String>> fetchAlat() async {
    await Future.delayed(fetchDelay);

    if (simulateError) {
      throw Exception('Gagal mengambil data alat');
    }

    if (simulateEmpty) {
      return [];
    }

    return ['Laptop', 'Proyektor', 'Kamera', 'Mikroskop'];
  }

  // READ: mengambil riwayat dari API.
  Future<List<Peminjaman>> fetchPeminjaman() {
    return _api.fetchPeminjaman();
  }

  // CREATE: menyimpan peminjaman melalui API.
  Future<Peminjaman> createPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) {
    return _api.createPeminjaman(
      alat: alat,
      jumlah: jumlah,
      tanggalKembali: tanggalKembali,
    );
  }

  // UPDATE: memperbarui peminjaman melalui API.
  Future<void> updatePeminjaman(Peminjaman updatedRecord) {
    return _api.updatePeminjaman(updatedRecord);
  }

  // DELETE: menghapus peminjaman melalui API.
  Future<void> deletePeminjaman(String id) {
    return _api.deletePeminjaman(id);
  }

  Future<void> submitPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    await Future.delayed(submitDelay);

    await createPeminjaman(
      alat: alat,
      jumlah: jumlah,
      tanggalKembali: tanggalKembali,
    );
  }
}
