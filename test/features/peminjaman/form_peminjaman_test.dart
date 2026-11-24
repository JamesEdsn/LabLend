import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:lablend/features/peminjaman/models/alat_model.dart';
import 'package:lablend/features/peminjaman/screens/lab_lend_home.dart' as app;
import 'package:lablend/features/peminjaman/providers/peminjaman_notifier.dart';
import 'package:lablend/features/peminjaman/repositories/peminjaman_repository.dart';
import 'package:lablend/features/peminjaman/screens/form_peminjaman_screen.dart';
import 'package:lablend/features/peminjaman/services/api_service.dart';

const _validRecord = <String, dynamic>{
  'id': 'test-1',
  'alat': 'Laptop',
  'jumlah': 1,
  'tanggalKembali': '2026-11-15',
};

const _validAlat = <String, dynamic>{
  'id': 'alat-001',
  'nama': 'Laptop',
  'kategori': 'Elektronik',
  'stokTotal': 10,
  'stokTersedia': 10,
};

final _alatList = <Map<String, dynamic>>[_validAlat];

http.Response _successResponse(dynamic data, {int statusCode = 200}) {
  return http.Response(
    jsonEncode({'success': true, 'data': data}),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

Widget createTestApp(PeminjamanRepository repository) {
  return ProviderScope(
    overrides: [peminjamanRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: FormPeminjamanScreen()),
  );
}

/// Membuat repository dengan API palsu untuk kebutuhan widget test.
PeminjamanRepository createRepository({
  bool simulateEmpty = false,
  bool simulateError = false,
  Duration fetchDelay = Duration.zero,
  Duration submitDelay = Duration.zero,
  http.Client? client,
}) {
  return PeminjamanRepository(
    simulateEmpty: simulateEmpty,
    simulateError: simulateError,
    fetchDelay: fetchDelay,
    submitDelay: submitDelay,
    api: ApiService(
      client:
          client ??
          MockClient((request) async {
            if (request.method == 'GET' && request.url.path.endsWith('/alat')) {
              return _successResponse(simulateEmpty ? [] : _alatList);
            }

            if (request.method == 'GET' &&
                request.url.path.endsWith('/peminjaman')) {
              return _successResponse([_validRecord]);
            }

            if (request.method == 'POST' &&
                request.url.path.endsWith('/peminjaman')) {
              return _successResponse(_validRecord, statusCode: 201);
            }

            return http.Response(
              jsonEncode({
                'success': false,
                'message': 'Endpoint tidak ditemukan',
              }),
              404,
            );
          }),
      tokenProvider: () async => 'test-jwt-token',
    ),
  );
}

/// Scroll ke widget terlebih dahulu, kemudian lakukan tap.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Scroll ke TextField terlebih dahulu, kemudian isi teks.
Future<void> enterTextVisible(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Repository yang sengaja gagal pada percobaan pertama.
/// Percobaan kedua akan berhasil mengembalikan data alat.
class _RetryOnceRepository extends PeminjamanRepository {
  _RetryOnceRepository() : super(fetchDelay: Duration.zero);

  int attempts = 0;

  @override
  Future<List<Alat>> fetchAlat() async {
    attempts++;

    // Percobaan pertama: simulasikan kegagalan.
    if (attempts == 1) {
      throw Exception('Simulated temporary failure');
    }

    // Percobaan kedua: kembalikan data alat.
    return const [
      Alat(
        id: 'alat-1',
        nama: 'Laptop',
        kategori: 'Elektronik',
        stokTotal: 10,
        stokTersedia: 10,
      ),
    ];
  }
}

void main() {
  group('Form Peminjaman Widget Tests', () {
    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        createTestApp(createRepository(fetchDelay: const Duration(seconds: 1))),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Form Peminjaman Alat'), findsOneWidget);
    });

    testWidgets('shows loaded data', (tester) async {
      await tester.pumpWidget(createTestApp(createRepository()));

      await tester.pumpAndSettle();

      expect(find.text('Form Peminjaman Alat'), findsOneWidget);

      expect(find.text('Submit Peminjaman'), findsOneWidget);

      expect(find.byType(DropdownButtonFormField<Alat>), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(
        createTestApp(createRepository(simulateEmpty: true)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Stok Alat Sedang Kosong'), findsOneWidget);
    });

    testWidgets('shows error and retry recovers after a temporary failure', (
      tester,
    ) async {
      final repository = _RetryOnceRepository();

      await tester.pumpWidget(createTestApp(repository));

      await tester.pumpAndSettle();

      expect(repository.attempts, 1);
      // Pesan error dapat berbeda sesuai implementasi notifier.
      // Yang diuji di sini adalah state gagal dan kemampuan untuk retry.
      expect(find.text('Form Peminjaman Alat'), findsNothing);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tapVisible(tester, find.text('Coba Lagi'));

      expect(repository.attempts, 2);
      expect(find.text('Form Peminjaman Alat'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty form fields', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(createRepository()));

      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('Submit Peminjaman'));

      expect(find.text('Pilih alat terlebih dahulu'), findsOneWidget);

      expect(find.text('Jumlah tidak boleh kosong'), findsOneWidget);

      expect(find.text('Tanggal kembali tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('rejects a date that does not match YYYY-MM-DD', (
      tester,
    ) async {
      var apiCalls = 0;

      final repository = createRepository(
        client: MockClient((request) async {
          if (request.method == 'GET' && request.url.path.endsWith('/alat')) {
            return _successResponse(_alatList);
          }

          if (request.method == 'POST') {
            apiCalls++;
          }

          return _successResponse([_validRecord]);
        }),
      );

      await tester.pumpWidget(createTestApp(repository));

      await tester.pumpAndSettle();

      await tapVisible(tester, find.byType(DropdownButtonFormField<Alat>));

      await tester.tap(find.textContaining('Laptop').last);
      await tester.pumpAndSettle();

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Jumlah'),
        '1',
      );

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
        '20 Oktober 2026',
      );

      await tapVisible(tester, find.text('Submit Peminjaman'));

      expect(
        find.text('Gunakan format YYYY-MM-DD (contoh: 2026-11-15)'),
        findsOneWidget,
      );

      expect(apiCalls, 0);
    });

    testWidgets('submit shows loading state and reports success', (
      tester,
    ) async {
      var postCalls = 0;

      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path.endsWith('/alat')) {
          return _successResponse(_alatList);
        }

        if (request.method == 'POST') {
          postCalls++;

          await Future<void>.delayed(const Duration(seconds: 1));

          return _successResponse(_validRecord, statusCode: 201);
        }

        return _successResponse([_validRecord]);
      });

      await tester.pumpWidget(createTestApp(createRepository(client: client)));

      await tester.pumpAndSettle();

      await tapVisible(tester, find.byType(DropdownButtonFormField<Alat>));

      await tester.tap(find.textContaining('Laptop').last);
      await tester.pumpAndSettle();

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Jumlah'),
        '1',
      );

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
        '2026-11-15',
      );

      final submitFinder = find.text('Submit Peminjaman');

      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();

      await tester.tap(submitFinder);

      // Tangkap kondisi loading sebelum request selesai.
      await tester.pump(const Duration(milliseconds: 10));

      expect(postCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(buttons.any((button) => button.onPressed == null), isTrue);

      // Selesaikan simulasi request API.
      await tester.pump(const Duration(seconds: 1));

      await tester.pumpAndSettle();

      expect(find.text('Peminjaman berhasil diajukan!'), findsOneWidget);
    });

    testWidgets('newly created record appears in history after refresh', (
      tester,
    ) async {
      final records = <Map<String, dynamic>>[];

      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path.endsWith('/alat')) {
          return _successResponse(_alatList);
        }

        if (request.method == 'GET' &&
            request.url.path.endsWith('/peminjaman')) {
          return _successResponse(records);
        }

        if (request.method == 'POST' &&
            request.url.path.endsWith('/peminjaman')) {
          records.add(_validRecord);

          return _successResponse(_validRecord, statusCode: 201);
        }

        return http.Response('Not found', 404);
      });

      final repository = createRepository(client: client);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peminjamanRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: app.LabLendHome()),
        ),
      );

      await tester.pumpAndSettle();

      // Submit satu peminjaman melalui form.
      await tapVisible(tester, find.byType(DropdownButtonFormField<Alat>));

      await tester.tap(find.textContaining('Laptop').last);
      await tester.pumpAndSettle();

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Jumlah'),
        '1',
      );

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
        '2026-11-15',
      );

      await tapVisible(tester, find.text('Submit Peminjaman'));

      expect(records, hasLength(1));

      // Beralih ke halaman riwayat.
      await tapVisible(tester, find.text('Riwayat'));

      expect(find.text('Laptop'), findsOneWidget);

      expect(find.textContaining('Jumlah: 1'), findsOneWidget);
    });

    testWidgets('submit shows a failure message when API returns an error', (
      tester,
    ) async {
      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path.endsWith('/alat')) {
          return _successResponse(_alatList);
        }

        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Gagal menyimpan peminjaman',
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      await tester.pumpWidget(createTestApp(createRepository(client: client)));

      await tester.pumpAndSettle();

      await tapVisible(tester, find.byType(DropdownButtonFormField<Alat>));

      await tester.tap(find.textContaining('Laptop').last);
      await tester.pumpAndSettle();

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Jumlah'),
        '1',
      );

      await enterTextVisible(
        tester,
        find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
        '2026-11-15',
      );

      await tapVisible(tester, find.text('Submit Peminjaman'));

      expect(
        find.textContaining('Gagal menyimpan peminjaman'),
        findsNWidgets(2),
      );

      final submitButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Submit Peminjaman'),
          matching: find.byType(ElevatedButton),
        ),
      );

      expect(submitButton.onPressed, isNotNull);
    });
  });
}
