import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alat_model.dart';
import '../repositories/peminjaman_repository.dart';

enum PeminjamanStatus { loading, loaded, empty, error }

class PeminjamanState {
  final PeminjamanStatus status;
  final List<Alat> alat;
  final String? errorMessage;
  final bool isSubmitting;

  const PeminjamanState({
    this.status = PeminjamanStatus.loading,
    this.alat = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  PeminjamanState copyWith({
    PeminjamanStatus? status,
    List<Alat>? alat,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return PeminjamanState(
      status: status ?? this.status,
      alat: alat ?? this.alat,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final peminjamanRepositoryProvider = Provider<PeminjamanRepository>((ref) {
  final repository = PeminjamanRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final peminjamanProvider =
    NotifierProvider<PeminjamanNotifier, PeminjamanState>(
      PeminjamanNotifier.new,
    );

class PeminjamanNotifier extends Notifier<PeminjamanState> {
  late final PeminjamanRepository repository;

  @override
  PeminjamanState build() {
    repository = ref.read(peminjamanRepositoryProvider);

    Future.microtask(fetchAlat);

    return const PeminjamanState(status: PeminjamanStatus.loading);
  }

  // Mengambil inventaris dari API.
  Future<void> fetchAlat() async {
    state = const PeminjamanState(status: PeminjamanStatus.loading);

    try {
      final data = await repository.fetchAlat();

      if (data.isEmpty) {
        state = const PeminjamanState(status: PeminjamanStatus.empty);
      } else {
        state = PeminjamanState(status: PeminjamanStatus.loaded, alat: data);
      }
    } catch (e) {
      state = PeminjamanState(
        status: PeminjamanStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // Mengajukan peminjaman dan meneruskan pesan error backend.
  Future<bool> submitPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    if (state.isSubmitting) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await repository.submitPeminjaman(
        alat: alat,
        jumlah: jumlah,
        tanggalKembali: tanggalKembali,
      );

      state = state.copyWith(clearError: true);

      // Refresh stok setelah peminjaman berhasil.
      await fetchAlat();

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );

      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
