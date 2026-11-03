import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lablend/features/peminjaman/models/peminjaman_model.dart';
import 'package:lablend/features/peminjaman/services/api_service.dart';

void main() {
  final validRecord = <String, dynamic>{
    'id': 'test-1',
    'alat': 'Laptop',
    'jumlah': 2,
    'tanggalKembali': '2026-11-15',
  };

  ApiService createTestService(http.Client client) {
    return ApiService(
      client: client,
      tokenProvider: () async => 'test-jwt-token',
    );
  }

  test('GET parses a successful response', () async {
    final service = createTestService(
      MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/peminjaman');
        expect(request.headers['authorization'], 'Bearer test-jwt-token');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [validRecord],
          }),
          200,
        );
      }),
    );

    final records = await service.fetchPeminjaman();

    expect(records, hasLength(1));
    expect(records.single.alat, 'Laptop');
    expect(records.single.jumlah, 2);
    service.dispose();
  });

  test('GET returns an empty list when there is no data', () async {
    final service = createTestService(
      MockClient(
        (_) async =>
            http.Response(jsonEncode({'success': true, 'data': []}), 200),
      ),
    );

    expect(await service.fetchPeminjaman(), isEmpty);
    service.dispose();
  });

  test('GET throws when the server returns an HTTP failure', () async {
    final service = createTestService(
      MockClient((_) async => http.Response('Server error', 503)),
    );

    await expectLater(service.fetchPeminjaman(), throwsA(isA<Exception>()));
    service.dispose();
  });

  test('GET throws FormatException when JSON is malformed', () async {
    final service = createTestService(
      MockClient((_) async => http.Response('{bad json', 200)),
    );

    await expectLater(
      service.fetchPeminjaman(),
      throwsA(isA<FormatException>()),
    );
    service.dispose();
  });

  test('GET rejects invalid records in a valid JSON response', () async {
    final service = createTestService(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {'alat': 'Laptop'},
            ],
          }),
          200,
        ),
      ),
    );

    await expectLater(
      service.fetchPeminjaman(),
      throwsA(isA<FormatException>()),
    );
    service.dispose();
  });

  test('POST sends the form payload and parses the created record', () async {
    final service = createTestService(
      MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['content-type'], contains('application/json'));
        expect(request.headers['authorization'], 'Bearer test-jwt-token');
        expect(jsonDecode(request.body), {
          'alat': 'Laptop',
          'jumlah': 2,
          'tanggalKembali': '2026-11-15',
        });

        return http.Response(
          jsonEncode({'success': true, 'data': validRecord}),
          201,
        );
      }),
    );

    final record = await service.createPeminjaman(
      alat: 'Laptop',
      jumlah: 2,
      tanggalKembali: '2026-11-15',
    );

    expect(record.id, 'test-1');
    expect(record.tanggalKembali, '2026-11-15');
    service.dispose();
  });

  test('POST throws when the server rejects the request', () async {
    final service = createTestService(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'success': false, 'message': 'Data tidak valid'}),
          400,
        ),
      ),
    );

    await expectLater(
      service.createPeminjaman(
        alat: 'Laptop',
        jumlah: 0,
        tanggalKembali: '2026-11-15',
      ),
      throwsA(isA<Exception>()),
    );
    service.dispose();
  });

  test('PUT sends updated record and accepts a successful response', () async {
    final service = createTestService(
      MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/api/peminjaman/test-1');
        expect(request.headers['authorization'], 'Bearer test-jwt-token');
        expect(jsonDecode(request.body), {
          'alat': 'Laptop',
          'jumlah': 3,
          'tanggalKembali': '2026-11-15',
        });

        return http.Response(jsonEncode({'success': true}), 200);
      }),
    );

    await expectLater(
      service.updatePeminjaman(
        Peminjaman.fromJson({...validRecord, 'jumlah': 3}),
      ),
      completes,
    );
    service.dispose();
  });

  test(
    'DELETE sends the record ID and accepts a successful response',
    () async {
      final service = createTestService(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(request.url.path, '/api/peminjaman/test-1');
          expect(request.headers['authorization'], 'Bearer test-jwt-token');

          return http.Response(jsonEncode({'success': true}), 200);
        }),
      );

      await expectLater(service.deletePeminjaman('test-1'), completes);
      service.dispose();
    },
  );

  test('PUT throws when the server returns an HTTP failure', () async {
    final service = createTestService(
      MockClient((_) async => http.Response('Not found', 404)),
    );

    await expectLater(
      service.updatePeminjaman(Peminjaman.fromJson(validRecord)),
      throwsA(isA<Exception>()),
    );
    service.dispose();
  });

  test('DELETE throws when the server returns an HTTP failure', () async {
    final service = createTestService(
      MockClient((_) async => http.Response('Not found', 404)),
    );

    await expectLater(
      service.deletePeminjaman('missing-id'),
      throwsA(isA<Exception>()),
    );
    service.dispose();
  });
}
