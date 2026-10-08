import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/peminjaman_repository.dart';

enum PeminjamanStatus { loading, loaded, empty, error }

class PeminjamanState {
  final PeminjamanStatus status;
  final List<String> alat;
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
    List<String>? alat,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return PeminjamanState(
      status: status ?? this.status,
      alat: alat ?? this.alat,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final peminjamanRepositoryProvider = Provider<PeminjamanRepository>((ref) {
  return const PeminjamanRepository(); // kalo mau stok sedang kosong & test error
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

    // Start loading the equipment data.
    Future.microtask(fetchAlat);

    return const PeminjamanState(status: PeminjamanStatus.loading);
  }

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
      state = const PeminjamanState(
        status: PeminjamanStatus.error,
        errorMessage: 'Gagal mengambil data alat.',
      );
    }
  }

  Future<bool> submitPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    // Prevent double submit.
    if (state.isSubmitting) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      await repository.submitPeminjaman(
        alat: alat,
        jumlah: jumlah,
        tanggalKembali: tanggalKembali,
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
