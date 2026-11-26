import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lablend/features/peminjaman/models/alat_model.dart';
import 'package:lablend/features/peminjaman/providers/peminjaman_notifier.dart';
import 'package:lablend/features/peminjaman/repositories/peminjaman_repository.dart';

class FakePeminjamanRepository extends PeminjamanRepository {
  FakePeminjamanRepository() : super();

  List<Alat> alatToReturn = const [
    Alat(
      id: '1',
      nama: 'ESP32',
      kategori: 'Mikrokontroler',
      stokTotal: 20,
      stokTersedia: 18,
    ),
  ];

  Object? fetchError;
  Object? submitError;

  Completer<void>? submitCompleter;

  int fetchCalls = 0;
  int submitCalls = 0;

  String? submittedAlat;
  int? submittedJumlah;
  String? submittedTanggalKembali;

  @override
  Future<List<Alat>> fetchAlat() async {
    fetchCalls++;

    if (fetchError != null) {
      throw fetchError!;
    }

    return alatToReturn;
  }

  @override
  Future<void> submitPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    submitCalls++;

    submittedAlat = alat;
    submittedJumlah = jumlah;
    submittedTanggalKembali = tanggalKembali;

    if (submitCompleter != null) {
      await submitCompleter!.future;
    }

    if (submitError != null) {
      throw submitError!;
    }
  }

  @override
  void dispose() {
    // Fake repository tidak membutuhkan cleanup HTTP client.
  }
}

void main() {
  late FakePeminjamanRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakePeminjamanRepository();

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        peminjamanRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // Menunggu fetchAlat otomatis yang dijalankan saat provider dibuat.
  Future<void> waitForInitialFetch() async {
    container.read(peminjamanProvider);
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'berhasil memuat daftar alat saat provider pertama dijalankan',
    () async {
      await waitForInitialFetch();

      final state = container.read(peminjamanProvider);

      expect(state.status, PeminjamanStatus.loaded);
      expect(state.alat.length, 1);
      expect(state.alat.first.nama, 'ESP32');
      expect(state.alat.first.stokTersedia, 18);
      expect(fakeRepository.fetchCalls, 1);
    },
  );

  test('menampilkan status empty jika daftar alat kosong', () async {
    fakeRepository.alatToReturn = [];

    await waitForInitialFetch();

    final state = container.read(peminjamanProvider);

    expect(state.status, PeminjamanStatus.empty);
    expect(state.alat, isEmpty);
    expect(state.errorMessage, isNull);
  });

  test('menampilkan error jika pengambilan daftar alat gagal', () async {
    fakeRepository.fetchError = Exception('Gagal mengambil data alat');

    await waitForInitialFetch();

    final state = container.read(peminjamanProvider);

    expect(state.status, PeminjamanStatus.error);
    expect(state.errorMessage, 'Gagal mengambil data alat');
  });

  test('fetchAlat dapat memperbarui daftar alat', () async {
    await waitForInitialFetch();

    fakeRepository.alatToReturn = const [
      Alat(
        id: '2',
        nama: 'Arduino Uno',
        kategori: 'Mikrokontroler',
        stokTotal: 15,
        stokTersedia: 12,
      ),
    ];

    await container.read(peminjamanProvider.notifier).fetchAlat();

    final state = container.read(peminjamanProvider);

    expect(fakeRepository.fetchCalls, 2);
    expect(state.status, PeminjamanStatus.loaded);
    expect(state.alat.first.nama, 'Arduino Uno');
    expect(state.alat.first.stokTersedia, 12);
  });

  test('berhasil mengajukan peminjaman dan memuat ulang daftar alat', () async {
    await waitForInitialFetch();

    final result = await container
        .read(peminjamanProvider.notifier)
        .submitPeminjaman(
          alat: 'ESP32',
          jumlah: 2,
          tanggalKembali: '2026-12-15',
        );

    final state = container.read(peminjamanProvider);

    expect(result, isTrue);
    expect(fakeRepository.submitCalls, 1);
    expect(fakeRepository.submittedAlat, 'ESP32');
    expect(fakeRepository.submittedJumlah, 2);
    expect(fakeRepository.submittedTanggalKembali, '2026-12-15');

    // Satu fetch awal + satu fetch setelah submit berhasil.
    expect(fakeRepository.fetchCalls, 2);

    expect(state.isSubmitting, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.status, PeminjamanStatus.loaded);
  });

  test('mengembalikan false jika pengajuan peminjaman gagal', () async {
    await waitForInitialFetch();

    fakeRepository.submitError = Exception('Stok tidak mencukupi');

    final result = await container
        .read(peminjamanProvider.notifier)
        .submitPeminjaman(
          alat: 'ESP32',
          jumlah: 100,
          tanggalKembali: '2026-12-15',
        );

    final state = container.read(peminjamanProvider);

    expect(result, isFalse);
    expect(fakeRepository.submitCalls, 1);
    expect(state.errorMessage, 'Stok tidak mencukupi');
    expect(state.isSubmitting, isFalse);
  });

  test('menolak pengajuan kedua saat pengajuan pertama berlangsung', () async {
    await waitForInitialFetch();

    fakeRepository.submitCompleter = Completer<void>();

    final notifier = container.read(peminjamanProvider.notifier);

    final firstRequest = notifier.submitPeminjaman(
      alat: 'ESP32',
      jumlah: 1,
      tanggalKembali: '2026-12-15',
    );

    expect(container.read(peminjamanProvider).isSubmitting, isTrue);

    final secondResult = await notifier.submitPeminjaman(
      alat: 'ESP32',
      jumlah: 1,
      tanggalKembali: '2026-12-15',
    );

    expect(secondResult, isFalse);
    expect(fakeRepository.submitCalls, 1);

    fakeRepository.submitCompleter!.complete();

    final firstResult = await firstRequest;

    expect(firstResult, isTrue);
    expect(fakeRepository.submitCalls, 1);
    expect(container.read(peminjamanProvider).isSubmitting, isFalse);
  });

  test('menghapus pesan error setelah pengajuan baru dimulai', () async {
    await waitForInitialFetch();

    fakeRepository.submitError = Exception('Pengajuan gagal');

    await container
        .read(peminjamanProvider.notifier)
        .submitPeminjaman(
          alat: 'ESP32',
          jumlah: 100,
          tanggalKembali: '2026-12-15',
        );

    expect(container.read(peminjamanProvider).errorMessage, 'Pengajuan gagal');

    fakeRepository.submitError = null;

    await container
        .read(peminjamanProvider.notifier)
        .submitPeminjaman(
          alat: 'ESP32',
          jumlah: 1,
          tanggalKembali: '2026-12-15',
        );

    final state = container.read(peminjamanProvider);

    expect(state.errorMessage, isNull);
    expect(state.isSubmitting, isFalse);
  });
}
