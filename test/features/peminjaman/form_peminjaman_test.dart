import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lablend/features/peminjaman/providers/peminjaman_notifier.dart';
import 'package:lablend/features/peminjaman/repositories/peminjaman_repository.dart';
import 'package:lablend/features/peminjaman/screens/form_peminjaman_screen.dart';

void main() {
  Widget createTestApp(PeminjamanRepository repository) {
    return ProviderScope(
      overrides: [peminjamanRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: FormPeminjamanScreen()),
    );
  }

  testWidgets('shows loading state', (tester) async {
    await tester.pumpWidget(
      createTestApp(
        const PeminjamanRepository(fetchDelay: Duration(seconds: 1)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('shows loaded data', (tester) async {
    await tester.pumpWidget(
      createTestApp(const PeminjamanRepository(fetchDelay: Duration.zero)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Form Peminjaman Alat'), findsOneWidget);

    expect(find.text('Submit Peminjaman'), findsOneWidget);
  });

  testWidgets('shows empty state', (tester) async {
    await tester.pumpWidget(
      createTestApp(
        const PeminjamanRepository(
          simulateEmpty: true,
          fetchDelay: Duration.zero,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stok Alat Sedang Kosong'), findsOneWidget);
  });

  testWidgets('shows error and retry button', (tester) async {
    await tester.pumpWidget(
      createTestApp(
        const PeminjamanRepository(
          simulateError: true,
          fetchDelay: Duration.zero,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gagal mengambil data alat.'), findsOneWidget);

    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('shows validation errors', (tester) async {
    await tester.pumpWidget(
      createTestApp(const PeminjamanRepository(fetchDelay: Duration.zero)),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Peminjaman'));

    await tester.pump();

    expect(find.text('Silakan pilih alat'), findsOneWidget);

    expect(find.text('Jumlah tidak boleh kosong'), findsOneWidget);

    expect(find.text('Tanggal kembali tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('submit button shows loading state', (tester) async {
    await tester.pumpWidget(
      createTestApp(
        const PeminjamanRepository(
          fetchDelay: Duration.zero,
          submitDelay: Duration(seconds: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open dropdown.
    await tester.tap(find.byType(DropdownButtonFormField<String>));

    await tester.pumpAndSettle();

    // Select Laptop.
    await tester.tap(find.text('Laptop').last);

    await tester.pumpAndSettle();

    // Fill quantity.
    await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah'), '1');

    // Fill return date.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tanggal Kembali'),
      '20 Oktober 2026',
    );

    // Submit.
    await tester.tap(find.text('Submit Peminjaman'));

    await tester.pump();

    // Loading spinner should appear.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}
