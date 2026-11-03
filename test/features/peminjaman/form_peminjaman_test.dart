import 'dart:convert';

import 'package:lablend/features/peminjaman/screens/lab_lend_home.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

Widget createTestApp(PeminjamanRepository repository) {
  return ProviderScope(
    overrides: [peminjamanRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: FormPeminjamanScreen()),
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
          MockClient((_) async {
            return http.Response(
              jsonEncode({'success': true, 'data': _validRecord}),
              201,
            );
          }),
      tokenProvider: () async => 'test-jwt-token',
    ),
  );
}

class _RetryOnceRepository extends PeminjamanRepository {
  _RetryOnceRepository() : super(fetchDelay: Duration.zero);

  int attempts = 0;

  @override
  Future<List<String>> fetchAlat() async {
    attempts++;

    if (attempts == 1) {
      throw Exception('Simulated first request failure');
    }

    return ['Laptop'];
  }
}

void main() {
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

    expect(find.text('Gagal mengambil data alat.'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    await tapVisible(tester, find.text('Coba Lagi'));

    expect(repository.attempts, 2);
    expect(find.text('Form Peminjaman Alat'), findsOneWidget);
  });

  testWidgets('shows validation errors for empty form fields', (tester) async {
    await tester.pumpWidget(createTestApp(createRepository()));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Submit Peminjaman'));

    expect(find.text('Silakan pilih alat'), findsOneWidget);
    expect(find.text('Jumlah tidak boleh kosong'), findsOneWidget);
    expect(find.text('Tanggal kembali tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('rejects a date that does not match YYYY-MM-DD', (tester) async {
    var apiCalls = 0;

    final repository = createRepository(
      client: MockClient((_) async {
        apiCalls++;

        return http.Response(
          jsonEncode({'success': true, 'data': _validRecord}),
          201,
        );
      }),
    );

    await tester.pumpWidget(createTestApp(repository));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byType(DropdownButtonFormField<String>));

    await tester.tap(find.text('Laptop').last);
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

  testWidgets('submit shows loading state and reports success', (tester) async {
    var postCalls = 0;

    final client = MockClient((request) async {
      if (request.method == 'POST') {
        postCalls++;
      }

      await Future<void>.delayed(const Duration(seconds: 1));

      return http.Response(
        jsonEncode({'success': true, 'data': _validRecord}),
        201,
      );
    });

    await tester.pumpWidget(createTestApp(createRepository(client: client)));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byType(DropdownButtonFormField<String>));

    await tester.tap(find.text('Laptop').last);
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

    // Jangan gunakan pumpAndSettle di sini!
    // Kita ingin menangkap kondisi loading sebelum API selesai.
    await tester.pump(const Duration(milliseconds: 10));

    expect(postCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Beri waktu agar proses submit mulai berjalan.
    await tester.pump(const Duration(milliseconds: 10));

    expect(postCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final submitButton = find.byType(ElevatedButton);

    expect(submitButton, findsWidgets);

    final lockedButtons = tester.widgetList<ElevatedButton>(submitButton);

    expect(lockedButtons.any((button) => button.onPressed == null), isTrue);

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
      if (request.method == 'GET' && request.url.path == '/api/peminjaman') {
        return http.Response(
          jsonEncode({'success': true, 'data': records}),
          200,
        );
      }

      if (request.method == 'POST' && request.url.path == '/api/peminjaman') {
        records.add(_validRecord);

        return http.Response(
          jsonEncode({'success': true, 'data': _validRecord}),
          201,
        );
      }

      return http.Response('Not found', 404);
    });

    final repository = createRepository(client: client);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [peminjamanRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: app.LabLendHome()),
      ),
    );

    await tester.pumpAndSettle();

    // Submit satu peminjaman melalui form.
    await tapVisible(tester, find.byType(DropdownButtonFormField<String>));

    await tester.tap(find.text('Laptop').last);
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
    final client = MockClient((_) async => http.Response('Server error', 500));

    await tester.pumpWidget(createTestApp(createRepository(client: client)));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byType(DropdownButtonFormField<String>));

    await tester.tap(find.text('Laptop').last);
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

    expect(find.text('Peminjaman gagal diajukan.'), findsOneWidget);

    final submitButton = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Submit Peminjaman'),
        matching: find.byType(ElevatedButton),
      ),
    );

    expect(submitButton.onPressed, isNotNull);
  });
}
