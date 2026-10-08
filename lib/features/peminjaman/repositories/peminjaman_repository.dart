class PeminjamanRepository {
  final bool simulateEmpty;
  final bool simulateError;
  final Duration fetchDelay;
  final Duration submitDelay;

  const PeminjamanRepository({
    this.simulateEmpty = false,
    this.simulateError = false,
    this.fetchDelay = const Duration(seconds: 2),
    this.submitDelay = const Duration(seconds: 2),
  });

  Future<List<String>> fetchAlat() async {
    await Future.delayed(fetchDelay);

    if (simulateError) {
      throw Exception('Gagal mengambil data alat');
    }

    if (simulateEmpty) {
      return [];
    }

    return ['Laptop', 'Tripod', 'Kamera', 'Mikroskop', 'Flashdisk'];
  }

  Future<void> submitPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    await Future.delayed(submitDelay);
  }
}
