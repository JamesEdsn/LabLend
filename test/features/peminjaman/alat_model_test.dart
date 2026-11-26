import 'package:flutter_test/flutter_test.dart';
import 'package:lablend/features/peminjaman/models/alat_model.dart';

void main() {
  group('Alat Model', () {
    test('Constructor menyimpan semua properti dengan benar', () {
      const alat = Alat(
        id: '1',
        nama: 'ESP32',
        kategori: 'Mikrokontroler',
        stokTotal: 20,
        stokTersedia: 18,
      );

      expect(alat.id, '1');
      expect(alat.nama, 'ESP32');
      expect(alat.kategori, 'Mikrokontroler');
      expect(alat.stokTotal, 20);
      expect(alat.stokTersedia, 18);
    });

    test('fromJson membaca data alat dengan benar', () {
      final alat = Alat.fromJson({
        'id': '1',
        'nama': 'ESP32',
        'kategori': 'Mikrokontroler',
        'stokTotal': 20,
        'stokTersedia': 18,
      });

      expect(alat.id, '1');
      expect(alat.nama, 'ESP32');
      expect(alat.kategori, 'Mikrokontroler');
      expect(alat.stokTotal, 20);
      expect(alat.stokTersedia, 18);
    });

    test('Kategori menjadi string kosong jika field tidak tersedia', () {
      final alat = Alat.fromJson({
        'id': '2',
        'nama': 'Arduino Uno',
        'stokTotal': 15,
        'stokTersedia': 15,
      });

      expect(alat.kategori, '');
    });

    test('Kategori menjadi string kosong jika nilainya null', () {
      final alat = Alat.fromJson({
        'id': '3',
        'nama': 'Multimeter',
        'kategori': null,
        'stokTotal': 8,
        'stokTersedia': 8,
      });

      expect(alat.kategori, '');
    });

    test('Stok desimal dikonversi menjadi integer', () {
      final alat = Alat.fromJson({
        'id': '4',
        'nama': 'Sensor Kit',
        'kategori': 'Sensor',
        'stokTotal': 10.9,
        'stokTersedia': 7.8,
      });

      expect(alat.stokTotal, 10);
      expect(alat.stokTersedia, 7);
    });

    test('Stok integer tetap terbaca dengan benar', () {
      final alat = Alat.fromJson({
        'id': '5',
        'nama': 'Router',
        'kategori': 'Jaringan',
        'stokTotal': 4,
        'stokTersedia': 3,
      });

      expect(alat.stokTotal, 4);
      expect(alat.stokTersedia, 3);
    });

    test('fromJson menghasilkan TypeError jika ID tidak tersedia', () {
      expect(
        () => Alat.fromJson({
          'nama': 'ESP32',
          'kategori': 'Mikrokontroler',
          'stokTotal': 20,
          'stokTersedia': 18,
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('fromJson menghasilkan TypeError jika tipe stok tidak valid', () {
      expect(
        () => Alat.fromJson({
          'id': '6',
          'nama': 'ESP32',
          'kategori': 'Mikrokontroler',
          'stokTotal': '20',
          'stokTersedia': '18',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
