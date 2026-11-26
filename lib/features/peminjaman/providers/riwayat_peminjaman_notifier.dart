import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/peminjaman_model.dart';
import 'peminjaman_notifier.dart';

final riwayatPeminjamanProvider =
    AsyncNotifierProvider<RiwayatPeminjamanNotifier, List<Peminjaman>>(
      RiwayatPeminjamanNotifier.new,
    );

class RiwayatPeminjamanNotifier extends AsyncNotifier<List<Peminjaman>> {
  @override
  Future<List<Peminjaman>> build() async {
    final repository = ref.read(peminjamanRepositoryProvider);
    return repository.fetchPeminjaman();
  }

  // Mengambil ulang data riwayat.
  Future<void> refreshRiwayat() async {
    if (!ref.mounted) return;

    final repository = ref.read(peminjamanRepositoryProvider);

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() => repository.fetchPeminjaman());

    if (!ref.mounted) return;

    state = result;
  }

  // DELETE: hapus peminjaman, refresh riwayat dan stok inventaris.
  Future<void> hapusPeminjaman(String id) async {
    if (!ref.mounted) return;

    final repository = ref.read(peminjamanRepositoryProvider);

    await repository.deletePeminjaman(id);

    if (!ref.mounted) return;

    final records = await repository.fetchPeminjaman();

    if (!ref.mounted) return;

    state = AsyncData(records);

    // Ambil stok terbaru dari backend.
    await ref.read(peminjamanProvider.notifier).fetchAlat();
  }

  // UPDATE: perbarui peminjaman, refresh riwayat dan stok inventaris.
  Future<void> updatePeminjaman(Peminjaman updatedRecord) async {
    if (!ref.mounted) return;

    final repository = ref.read(peminjamanRepositoryProvider);

    await repository.updatePeminjaman(updatedRecord);

    if (!ref.mounted) return;

    final records = await repository.fetchPeminjaman();

    if (!ref.mounted) return;

    state = AsyncData(records);

    // Ambil stok terbaru dari backend.
    await ref.read(peminjamanProvider.notifier).fetchAlat();
  }
}
