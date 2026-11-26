import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lablend/features/peminjaman/models/peminjaman_model.dart';
import 'package:lablend/features/peminjaman/services/local_storage_service.dart';

void main() {
  late LocalStorageService service;

  const testRecord = Peminjaman(
    id: 'test-1',
    alat: 'ESP32 Development Board',
    jumlah: 2,
    tanggalKembali: '2026-12-15',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = LocalStorageService();
  });

  group('LocalStorageService', () {
    test(
      'getPeminjaman mengembalikan list kosong jika belum ada data',
      () async {
        final records = await service.getPeminjaman();

        expect(records, isEmpty);
      },
    );

    test(
      'getPeminjaman mengembalikan list kosong jika data berupa string kosong',
      () async {
        SharedPreferences.setMockInitialValues({'peminjaman_records': ''});

        final records = await service.getPeminjaman();

        expect(records, isEmpty);
      },
    );

    test('savePeminjaman menyimpan data ke SharedPreferences', () async {
      await service.savePeminjaman([testRecord]);

      final preferences = await SharedPreferences.getInstance();
      final savedData = preferences.getString('peminjaman_records');

      expect(savedData, isNotNull);
      expect(savedData, contains('ESP32 Development Board'));
    });

    test('getPeminjaman membaca data yang sudah disimpan', () async {
      await service.savePeminjaman([testRecord]);

      final records = await service.getPeminjaman();

      expect(records.length, 1);
      expect(records.first.id, 'test-1');
      expect(records.first.alat, 'ESP32 Development Board');
      expect(records.first.jumlah, 2);
      expect(records.first.tanggalKembali, '2026-12-15');
    });

    test('savePeminjaman dapat menyimpan beberapa record', () async {
      const secondRecord = Peminjaman(
        id: 'test-2',
        alat: 'Arduino Uno',
        jumlah: 1,
        tanggalKembali: '2026-12-20',
      );

      await service.savePeminjaman([testRecord, secondRecord]);

      final records = await service.getPeminjaman();

      expect(records.length, 2);
      expect(records[0].id, 'test-1');
      expect(records[1].id, 'test-2');
    });

    test('clearPeminjaman menghapus seluruh data tersimpan', () async {
      await service.savePeminjaman([testRecord]);

      await service.clearPeminjaman();

      final records = await service.getPeminjaman();

      expect(records, isEmpty);

      final preferences = await SharedPreferences.getInstance();

      expect(preferences.getString('peminjaman_records'), isNull);
    });

    test(
      'getPeminjaman menghasilkan FormatException jika JSON tidak valid',
      () async {
        SharedPreferences.setMockInitialValues({
          'peminjaman_records': 'invalid-json',
        });

        expect(() => service.getPeminjaman(), throwsFormatException);
      },
    );
  });
}
