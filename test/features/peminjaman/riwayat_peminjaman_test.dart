import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lablend/features/peminjaman/providers/peminjaman_notifier.dart';
import 'package:lablend/features/peminjaman/repositories/peminjaman_repository.dart';
import 'package:lablend/features/peminjaman/screens/riwayat_peminjaman_screen.dart';
import 'package:lablend/features/peminjaman/services/api_service.dart';

const _validRecord = <String, dynamic>{
  'id': 'test-1',
  'alat': 'ESP32',
  'jumlah': 2,
  'tanggalKembali': '2026-11-15',
};

Widget _testApp(http.Client client) {
  final repository = PeminjamanRepository(
    api: ApiService(
      client: client,
      tokenProvider: () async => 'test-jwt-token',
    ),
  );

  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [peminjamanRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: RiwayatPeminjamanScreen()),
  );
}

http.Response _listResponse(List<Map<String, dynamic>> records) {
  return http.Response(jsonEncode({'success': true, 'data': records}), 200);
}

void main() {
  testWidgets('menampilkan loading saat riwayat sedang dimuat', (tester) async {
    final client = MockClient((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _listResponse([]);
    });

    await tester.pumpWidget(_testApp(client));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada riwayat peminjaman.'), findsOneWidget);
  });

  testWidgets('menampilkan empty state ketika API mengembalikan array kosong', (
    tester,
  ) async {
    final client = MockClient((_) async => _listResponse([]));

    await tester.pumpWidget(_testApp(client));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada riwayat peminjaman.'), findsOneWidget);
  });

  testWidgets('menampilkan data yang berhasil diambil dari API', (
    tester,
  ) async {
    final client = MockClient((_) async => _listResponse([_validRecord]));

    await tester.pumpWidget(_testApp(client));
    await tester.pumpAndSettle();

    expect(find.text('ESP32'), findsOneWidget);
    expect(find.textContaining('Jumlah: 2'), findsOneWidget);
  });

  testWidgets('error state dapat pulih setelah tombol Coba Lagi ditekan', (
    tester,
  ) async {
    var attempts = 0;
    final client = MockClient((_) async {
      attempts++;
      if (attempts == 1) {
        return http.Response('Service Unavailable', 503);
      }
      return _listResponse([_validRecord]);
    });

    await tester.pumpWidget(_testApp(client));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat riwayat peminjaman.'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('ESP32'), findsOneWidget);
  });
}
