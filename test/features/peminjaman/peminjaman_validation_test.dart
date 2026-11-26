import 'package:flutter_test/flutter_test.dart';
import 'package:lablend/features/peminjaman/validation/peminjaman_validation.dart';

void main() {
  group('validatePilihanAlat', () {
    test('rejects null input', () {
      expect(validatePilihanAlat(null), 'Silakan pilih alat');
    });

    test('rejects empty input', () {
      expect(validatePilihanAlat(''), 'Silakan pilih alat');
    });

    test('rejects whitespace input', () {
      expect(validatePilihanAlat('   '), 'Silakan pilih alat');
    });

    test('accepts a valid equipment name', () {
      expect(validatePilihanAlat('Laptop'), isNull);
    });
  });

  group('validateJumlah', () {
    test('rejects null input', () {
      expect(validateJumlah(null), 'Jumlah tidak boleh kosong');
    });

    test('rejects empty input', () {
      expect(validateJumlah(''), 'Jumlah tidak boleh kosong');
    });

    test('rejects whitespace input', () {
      expect(validateJumlah('   '), 'Jumlah tidak boleh kosong');
    });

    test('rejects non-numeric input', () {
      expect(validateJumlah('abc'), 'Jumlah harus lebih dari 0');
    });

    test('rejects decimal input', () {
      expect(validateJumlah('2.5'), 'Jumlah harus lebih dari 0');
    });

    test('rejects zero quantity', () {
      expect(validateJumlah('0'), 'Jumlah harus lebih dari 0');
    });

    test('rejects negative quantity', () {
      expect(validateJumlah('-3'), 'Jumlah harus lebih dari 0');
    });

    test('accepts a positive integer', () {
      expect(validateJumlah('2'), isNull);
    });

    test('accepts a positive integer with surrounding spaces', () {
      expect(validateJumlah(' 5 '), isNull);
    });
  });

  group('validateTanggalKembali', () {
    test('rejects null input', () {
      expect(
        validateTanggalKembali(null),
        'Tanggal kembali tidak boleh kosong',
      );
    });

    test('rejects empty input', () {
      expect(validateTanggalKembali(''), 'Tanggal kembali tidak boleh kosong');
    });

    test('rejects invalid date format', () {
      expect(
        validateTanggalKembali('15-11-2026'),
        startsWith('Gunakan format YYYY-MM-DD'),
      );
    });

    test('rejects impossible calendar date', () {
      expect(
        validateTanggalKembali('2026-02-30'),
        startsWith('Gunakan format YYYY-MM-DD'),
      );
    });

    test('accepts a valid date', () {
      expect(validateTanggalKembali('2026-12-15'), isNull);
    });

    test('accepts a valid date with surrounding spaces', () {
      expect(validateTanggalKembali(' 2026-12-15 '), isNull);
    });
  });

  group('validateNamaAlat', () {
    test('rejects null input', () {
      expect(validateNamaAlat(null), 'Nama alat wajib diisi');
    });

    test('rejects empty input', () {
      expect(validateNamaAlat(''), 'Nama alat wajib diisi');
    });

    test('rejects whitespace input', () {
      expect(validateNamaAlat('   '), 'Nama alat wajib diisi');
    });

    test('accepts a valid equipment name', () {
      expect(validateNamaAlat('ESP32 Development Board'), isNull);
    });
  });
}
