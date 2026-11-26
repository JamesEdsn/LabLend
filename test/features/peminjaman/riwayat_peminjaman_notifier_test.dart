import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:lablend/features/peminjaman/models/peminjaman_model.dart';
import 'package:lablend/features/peminjaman/providers/peminjaman_notifier.dart';
import 'package:lablend/features/peminjaman/providers/riwayat_peminjaman_notifier.dart';
import 'package:lablend/features/peminjaman/repositories/peminjaman_repository.dart';
import 'package:lablend/features/peminjaman/services/api_service.dart';

const testRecord = <String, dynamic>{
  'id': 'test-1',
  'alat': 'ESP32 Development Board',
  'jumlah': 2,
  'tanggalKembali': '2026-12-15',
};

const updatedRecord = Peminjaman(
  id: 'test-1',
  alat: 'ESP32 Development Board',
  jumlah: 3,
  tanggalKembali: '2026-12-20',
);

http.Response listResponse(List<Map<String, dynamic>> records) {
  return http.Response(jsonEncode({'success': true, 'data': records}), 200);
}

void main() {
  late MockClient client;
  late ProviderContainer container;

  void setup(Future<http.Response> Function(http.Request) handler) {
    client = MockClient(handler);

    final repository = PeminjamanRepository(
      api: ApiService(client: client, tokenProvider: () async => 'test-token'),
    );

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [peminjamanRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(() {
      container.dispose();
      client.close();
    });
  }

  test(
    'berhasil memuat riwayat saat provider pertama kali dijalankan',
    () async {
      setup((_) async => listResponse([testRecord]));

      final records = await container.read(riwayatPeminjamanProvider.future);

      expect(records.length, 1);
      expect(records.first.alat, 'ESP32 Development Board');
      expect(records.first.jumlah, 2);
    },
  );

  test('refreshRiwayat memperbarui data dari API', () async {
    var requestCount = 0;

    setup((_) async {
      requestCount++;

      if (requestCount == 1) {
        return listResponse([testRecord]);
      }

      return listResponse([
        {...testRecord, 'jumlah': 5},
      ]);
    });

    await container.read(riwayatPeminjamanProvider.future);

    await container.read(riwayatPeminjamanProvider.notifier).refreshRiwayat();

    final records = container.read(riwayatPeminjamanProvider).requireValue;

    expect(requestCount, 2);
    expect(records.first.jumlah, 5);
  });

  test('refreshRiwayat menampilkan error ketika API gagal', () async {
    var requestCount = 0;

    setup((_) async {
      requestCount++;

      if (requestCount == 1) {
        return listResponse([testRecord]);
      }

      return http.Response('Server Error', 503);
    });

    await container.read(riwayatPeminjamanProvider.future);

    await container.read(riwayatPeminjamanProvider.notifier).refreshRiwayat();

    expect(container.read(riwayatPeminjamanProvider).hasError, isTrue);
  });

  test('hapusPeminjaman menghapus data lalu mengambil ulang riwayat', () async {
    var deleteCalled = false;
    var getCount = 0;

    setup((request) async {
      if (request.method == 'DELETE') {
        deleteCalled = true;
        expect(request.url.path, endsWith('/peminjaman/test-1'));
        return http.Response('{}', 200);
      }

      if (request.method == 'GET') {
        getCount++;

        if (getCount == 1) {
          return listResponse([testRecord]);
        }

        return listResponse([]);
      }

      return http.Response('Not Found', 404);
    });

    await container.read(riwayatPeminjamanProvider.future);

    await container
        .read(riwayatPeminjamanProvider.notifier)
        .hapusPeminjaman('test-1');

    final records = container.read(riwayatPeminjamanProvider).requireValue;

    expect(deleteCalled, isTrue);
    expect(records, isEmpty);
  });

  test(
    'updatePeminjaman memperbarui data lalu mengambil ulang riwayat',
    () async {
      var updateCalled = false;
      var getCount = 0;

      setup((request) async {
        if (request.method == 'PUT') {
          updateCalled = true;

          final body = jsonDecode(request.body) as Map<String, dynamic>;

          expect(body['jumlah'], 3);
          return http.Response('{}', 200);
        }

        if (request.method == 'GET') {
          getCount++;

          if (getCount == 1) {
            return listResponse([testRecord]);
          }

          return listResponse([
            {...testRecord, 'jumlah': 3, 'tanggalKembali': '2026-12-20'},
          ]);
        }

        return http.Response('Not Found', 404);
      });

      await container.read(riwayatPeminjamanProvider.future);

      await container
          .read(riwayatPeminjamanProvider.notifier)
          .updatePeminjaman(updatedRecord);

      final records = container.read(riwayatPeminjamanProvider).requireValue;

      expect(updateCalled, isTrue);
      expect(records.first.jumlah, 3);
      expect(records.first.tanggalKembali, '2026-12-20');
    },
  );

  test('hapusPeminjaman tidak mengubah state jika API delete gagal', () async {
    setup((request) async {
      if (request.method == 'DELETE') {
        return http.Response('Server Error', 500);
      }

      return listResponse([testRecord]);
    });

    await container.read(riwayatPeminjamanProvider.future);

    await expectLater(
      container
          .read(riwayatPeminjamanProvider.notifier)
          .hapusPeminjaman('test-1'),
      throwsException,
    );

    final records = container.read(riwayatPeminjamanProvider).requireValue;

    expect(records.length, 1);
    expect(records.first.id, 'test-1');
  });

  test('updatePeminjaman tidak mengubah state jika API update gagal', () async {
    setup((request) async {
      if (request.method == 'PUT') {
        return http.Response('Server Error', 500);
      }

      return listResponse([testRecord]);
    });

    await container.read(riwayatPeminjamanProvider.future);

    try {
      await container
          .read(riwayatPeminjamanProvider.notifier)
          .updatePeminjaman(updatedRecord);
    } catch (_) {
      // Expected API error.
    }

    final records = container.read(riwayatPeminjamanProvider).requireValue;

    expect(records.length, 1);
    expect(records.first.jumlah, 2);
  });
}
