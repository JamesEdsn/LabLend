import 'package:flutter_test/flutter_test.dart';
import 'package:lablend/features/peminjaman/models/peminjaman_model.dart';

void main() {
  final validJson = <String, dynamic>{
    'id': 'test-1',
    'alat': 'Laptop',
    'jumlah': 2,
    'tanggalKembali': '2026-11-15',
  };

  group('isValidTanggalKembali', () {
    test('accepts a real date in YYYY-MM-DD format', () {
      expect(isValidTanggalKembali('2026-11-15'), isTrue);
    });

    test('rejects a date written in a different format', () {
      expect(isValidTanggalKembali('15-11-2026'), isFalse);
      expect(isValidTanggalKembali('15 November 2026'), isFalse);
    });

    test('rejects impossible calendar dates', () {
      expect(isValidTanggalKembali('2026-02-30'), isFalse);
      expect(isValidTanggalKembali('2026-13-01'), isFalse);
    });
  });

  group('Peminjaman.fromJson', () {
    test('parses a valid borrowing record', () {
      final record = Peminjaman.fromJson(validJson);

      expect(record.id, 'test-1');
      expect(record.alat, 'Laptop');
      expect(record.jumlah, 2);
      expect(record.tanggalKembali, '2026-11-15');
    });

    test('rejects a missing or empty ID', () {
      expect(
        () => Peminjaman.fromJson({...validJson, 'id': ''}),
        throwsFormatException,
      );
    });

    test('rejects an empty equipment name', () {
      expect(
        () => Peminjaman.fromJson({...validJson, 'alat': '  '}),
        throwsFormatException,
      );
    });

    test('rejects non-positive quantity', () {
      expect(
        () => Peminjaman.fromJson({...validJson, 'jumlah': 0}),
        throwsFormatException,
      );
      expect(
        () => Peminjaman.fromJson({...validJson, 'jumlah': -1}),
        throwsFormatException,
      );
    });

    test('rejects invalid return dates', () {
      expect(
        () => Peminjaman.fromJson({...validJson, 'tanggalKembali': '2026-02-30'}),
        throwsFormatException,
      );
    });
  });
}
