import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:lablend/features/peminjaman/providers/peminjaman_notifier.dart';
import 'package:lablend/features/peminjaman/repositories/peminjaman_repository.dart';
import 'package:lablend/features/peminjaman/screens/form_peminjaman_screen.dart';
import 'package:lablend/features/peminjaman/services/api_service.dart';
import 'package:lablend/main.dart' as app;

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

    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(repository.attempts, 2);
    expect(find.text('Form Peminjaman Alat'), findsOneWidget);
  });

  testWidgets('shows validation errors for empty form fields', (tester) async {
    await tester.pumpWidget(createTestApp(createRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Peminjaman'));
    await tester.pump();

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

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah'), '1');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
      '20 Oktober 2026',
    );
    await tester.tap(find.text('Submit Peminjaman'));
    await tester.pumpAndSettle();

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

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah'), '1');

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
      '2026-11-15',
    );

    await tester.tap(find.text('Submit Peminjaman'));

    // Proses submit menggunakan Future.delayed(Duration.zero).
    // Majukan waktu sedikit agar proses tersebut dapat berjalan.
    await tester.pump(const Duration(milliseconds: 10));

    expect(postCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final submitButton = find.byType(ElevatedButton);

    expect(submitButton, findsWidgets);

    final lockedButtons = tester.widgetList<ElevatedButton>(submitButton);

    expect(lockedButtons.any((button) => button.onPressed == null), isTrue);

    // Selesaikan simulasi request API satu detik kemudian.
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

    // Submit one borrowing through the real form widget.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah'), '1');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
      '2026-11-15',
    );
    await tester.tap(find.text('Submit Peminjaman'));
    await tester.pumpAndSettle();

    expect(records, hasLength(1));

    // Switch to history; it should not keep the stale empty response.
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.textContaining('Jumlah: 1'), findsOneWidget);
  });

  testWidgets('submit shows a failure message when API returns an error', (
    tester,
  ) async {
    final client = MockClient((_) async => http.Response('Server error', 500));
    await tester.pumpWidget(createTestApp(createRepository(client: client)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah'), '1');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tanggal Kembali (YYYY-MM-DD)'),
      '2026-11-15',
    );
    await tester.tap(find.text('Submit Peminjaman'));
    await tester.pumpAndSettle();

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
