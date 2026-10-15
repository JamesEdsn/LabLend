import '../models/peminjaman_model.dart';
import '../services/local_storage_service.dart';

class PeminjamanRepository {
  final bool simulateEmpty;
  final bool simulateError;
  final Duration fetchDelay;
  final Duration submitDelay;

  final LocalStorageService _storage;

  PeminjamanRepository({
    this.simulateEmpty = false,
    this.simulateError = false,
    this.fetchDelay = const Duration(seconds: 2),
    this.submitDelay = const Duration(seconds: 2),
    LocalStorageService? storage,
  }) : _storage = storage ?? LocalStorageService();

  // Existing functionality: load equipment for the dropdown.
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

  // READ: load saved borrowing records.
  Future<List<Peminjaman>> fetchPeminjaman() async {
    return _storage.getPeminjaman();
  }

  // CREATE: save a new borrowing record.
  Future<Peminjaman> createPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    final records = await _storage.getPeminjaman();

    final newRecord = Peminjaman(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      alat: alat,
      jumlah: jumlah,
      tanggalKembali: tanggalKembali,
    );

    records.add(newRecord);
    await _storage.savePeminjaman(records);

    return newRecord;
  }

  // UPDATE: replace an existing record.
  Future<void> updatePeminjaman(Peminjaman updatedRecord) async {
    final records = await _storage.getPeminjaman();

    final index = records.indexWhere((record) => record.id == updatedRecord.id);

    if (index == -1) {
      throw Exception('Data peminjaman tidak ditemukan');
    }

    records[index] = updatedRecord;
    await _storage.savePeminjaman(records);
  }

  // DELETE: remove a record by ID.
  Future<void> deletePeminjaman(String id) async {
    final records = await _storage.getPeminjaman();

    records.removeWhere((record) => record.id == id);

    await _storage.savePeminjaman(records);
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
