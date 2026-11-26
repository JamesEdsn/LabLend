import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lablend/features/peminjaman/models/peminjaman_model.dart';
import 'package:lablend/features/peminjaman/repositories/peminjaman_repository.dart';
import 'package:lablend/features/peminjaman/services/api_service.dart';

void main() {
  const record = {
    'id': 'repo-1',
    'alat': 'ESP32 Development Board',
    'jumlah': 2,
    'tanggalKembali': '2026-12-15',
  };

  PeminjamanRepository createRepository(
    Future<http.Response> Function(http.Request request) handler,
  ) {
    final client = MockClient(handler);

    final api = ApiService(
      client: client,
      tokenProvider: () async => 'repository-test-token',
    );

    return PeminjamanRepository(api: api);
  }

  group('PeminjamanRepository READ', () {
    test('returns records from API service', () async {
      final repository = createRepository((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, endsWith('/peminjaman'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [record],
          }),
          200,
        );
      });

      final result = await repository.fetchPeminjaman();

      expect(result, hasLength(1));
      expect(result.first.id, 'repo-1');
      expect(result.first.alat, 'ESP32 Development Board');

      repository.dispose();
    });
  });

  group('PeminjamanRepository CREATE', () {
    test('forwards creation data to API service', () async {
      final repository = createRepository((request) async {
        expect(request.method, 'POST');

        final body = jsonDecode(request.body) as Map<String, dynamic>;

        expect(body['alat'], 'ESP32 Development Board');
        expect(body['jumlah'], 2);
        expect(body['tanggalKembali'], '2026-12-15');

        return http.Response(
          jsonEncode({'success': true, 'data': record}),
          201,
        );
      });

      final result = await repository.createPeminjaman(
        alat: 'ESP32 Development Board',
        jumlah: 2,
        tanggalKembali: '2026-12-15',
      );

      expect(result.id, 'repo-1');
      expect(result.jumlah, 2);

      repository.dispose();
    });

    test('propagates API creation errors', () async {
      final repository = createRepository((request) async {
        return http.Response(
          jsonEncode({'success': false, 'message': 'Stok tidak mencukupi'}),
          409,
        );
      });

      await expectLater(
        repository.createPeminjaman(
          alat: 'Laptop',
          jumlah: 99,
          tanggalKembali: '2026-12-15',
        ),
        throwsA(isA<Exception>()),
      );

      repository.dispose();
    });
  });

  group('PeminjamanRepository UPDATE', () {
    test('forwards updated record to API service', () async {
      final repository = createRepository((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, endsWith('/peminjaman/repo-1'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;

        expect(body['alat'], 'ESP32 Development Board');
        expect(body['jumlah'], 3);

        return http.Response(jsonEncode({'success': true}), 200);
      });

      final updatedRecord = Peminjaman(
        id: 'repo-1',
        alat: 'ESP32 Development Board',
        jumlah: 3,
        tanggalKembali: '2026-12-20',
      );

      await expectLater(repository.updatePeminjaman(updatedRecord), completes);

      repository.dispose();
    });
  });

  group('PeminjamanRepository DELETE', () {
    test('forwards record ID to API service', () async {
      final repository = createRepository((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, endsWith('/peminjaman/repo-1'));

        return http.Response(jsonEncode({'success': true}), 200);
      });

      await expectLater(repository.deletePeminjaman('repo-1'), completes);

      repository.dispose();
    });
  });
}
