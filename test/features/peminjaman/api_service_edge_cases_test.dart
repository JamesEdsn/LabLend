import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lablend/features/peminjaman/models/peminjaman_model.dart';
import 'package:lablend/features/peminjaman/services/api_service.dart';

void main() {
  final validRecord = <String, dynamic>{
    'id': 'edge-1',
    'alat': 'ESP32 Development Board',
    'jumlah': 2,
    'tanggalKembali': '2026-12-15',
  };

  ApiService createService(
    http.Client client, {
    Future<String?> Function()? tokenProvider,
  }) {
    return ApiService(
      client: client,
      tokenProvider: tokenProvider ?? () async => 'test-token',
    );
  }

  group('GET API edge cases', () {
    test('rejects response when success is false', () async {
      final service = createService(
        MockClient(
          (_) async =>
              http.Response(jsonEncode({'success': false, 'data': []}), 200),
        ),
      );

      await expectLater(
        service.fetchPeminjaman(),
        throwsA(isA<FormatException>()),
      );

      service.dispose();
    });

    test('rejects response when data is not a list', () async {
      final service = createService(
        MockClient(
          (_) async =>
              http.Response(jsonEncode({'success': true, 'data': {}}), 200),
        ),
      );

      await expectLater(
        service.fetchPeminjaman(),
        throwsA(isA<FormatException>()),
      );

      service.dispose();
    });

    test('rejects a record that is not a JSON object', () async {
      final service = createService(
        MockClient(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': ['invalid-record'],
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
  });

  group('POST API edge cases', () {
    test('accepts HTTP 200 as a successful creation response', () async {
      final service = createService(
        MockClient(
          (_) async => http.Response(
            jsonEncode({'success': true, 'data': validRecord}),
            200,
          ),
        ),
      );

      final result = await service.createPeminjaman(
        alat: 'ESP32 Development Board',
        jumlah: 2,
        tanggalKembali: '2026-12-15',
      );

      expect(result.id, 'edge-1');
      expect(result.alat, 'ESP32 Development Board');

      service.dispose();
    });

    test('rejects response when success is false', () async {
      final service = createService(
        MockClient(
          (_) async => http.Response(
            jsonEncode({'success': false, 'message': 'Request rejected'}),
            201,
          ),
        ),
      );

      await expectLater(
        service.createPeminjaman(
          alat: 'Laptop',
          jumlah: 1,
          tanggalKembali: '2026-12-15',
        ),
        throwsA(isA<FormatException>()),
      );

      service.dispose();
    });

    test('rejects response when data is not a JSON object', () async {
      final service = createService(
        MockClient(
          (_) async =>
              http.Response(jsonEncode({'success': true, 'data': []}), 201),
        ),
      );

      await expectLater(
        service.createPeminjaman(
          alat: 'Laptop',
          jumlah: 1,
          tanggalKembali: '2026-12-15',
        ),
        throwsA(isA<FormatException>()),
      );

      service.dispose();
    });

    test('rejects malformed JSON in successful response', () async {
      final service = createService(
        MockClient((_) async => http.Response('{invalid-json', 201)),
      );

      await expectLater(
        service.createPeminjaman(
          alat: 'Laptop',
          jumlah: 1,
          tanggalKembali: '2026-12-15',
        ),
        throwsA(isA<FormatException>()),
      );

      service.dispose();
    });
  });

  group('Authentication edge cases', () {
    test('GET fails when authentication token is missing', () async {
      final service = createService(
        MockClient((_) async {
          fail('Request should not be sent without a token');
        }),
        tokenProvider: () async => null,
      );

      await expectLater(service.fetchPeminjaman(), throwsA(isA<Exception>()));

      service.dispose();
    });

    test('POST fails when authentication token is empty', () async {
      final service = createService(
        MockClient((_) async {
          fail('Request should not be sent without a token');
        }),
        tokenProvider: () async => '',
      );

      await expectLater(
        service.createPeminjaman(
          alat: 'Laptop',
          jumlah: 1,
          tanggalKembali: '2026-12-15',
        ),
        throwsA(isA<Exception>()),
      );

      service.dispose();
    });

    test('PUT fails when authentication token is missing', () async {
      final service = createService(
        MockClient((_) async {
          fail('Request should not be sent without a token');
        }),
        tokenProvider: () async => null,
      );

      await expectLater(
        service.updatePeminjaman(Peminjaman.fromJson(validRecord)),
        throwsA(isA<Exception>()),
      );

      service.dispose();
    });

    test('DELETE fails when authentication token is missing', () async {
      final service = createService(
        MockClient((_) async {
          fail('Request should not be sent without a token');
        }),
        tokenProvider: () async => null,
      );

      await expectLater(
        service.deletePeminjaman('edge-1'),
        throwsA(isA<Exception>()),
      );

      service.dispose();
    });
  });
}
