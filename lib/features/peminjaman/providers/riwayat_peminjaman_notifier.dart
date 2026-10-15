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

  Future<void> refreshRiwayat() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(peminjamanRepositoryProvider);
      return repository.fetchPeminjaman();
    });
  }

  Future<void> hapusPeminjaman(String id) async {
    final repository = ref.read(peminjamanRepositoryProvider);

    await repository.deletePeminjaman(id);

    final records = await repository.fetchPeminjaman();
    state = AsyncData(records);
  }

  Future<void> updatePeminjaman(Peminjaman updatedRecord) async {
    final repository = ref.read(peminjamanRepositoryProvider);

    await repository.updatePeminjaman(updatedRecord);

    final records = await repository.fetchPeminjaman();
    state = AsyncData(records);
  }
}
