import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lablend/core/services/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService', () {
    test('saveToken menyimpan token dengan key auth_token', () async {
      when(() => mockStorage.write(key: 'auth_token', value: 'jwt-test-token'))
          .thenAnswer((_) async {});

      await service.saveToken('jwt-test-token');

      verify(
        () => mockStorage.write(key: 'auth_token', value: 'jwt-test-token'),
      ).called(1);
    });

    test('getToken mengambil token dari storage', () async {
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'jwt-test-token');

      final token = await service.getToken();

      expect(token, 'jwt-test-token');

      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('getToken mengembalikan null jika token tidak tersedia', () async {
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => null);

      final token = await service.getToken();

      expect(token, isNull);
    });

    test('deleteToken menghapus token dari storage', () async {
      when(() => mockStorage.delete(key: 'auth_token'))
          .thenAnswer((_) async {});

      await service.deleteToken();

      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
    });

    test('hasToken mengembalikan true jika token tersedia', () async {
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'jwt-test-token');

      final result = await service.hasToken();

      expect(result, isTrue);
    });

    test('hasToken mengembalikan false jika token null', () async {
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => null);

      final result = await service.hasToken();

      expect(result, isFalse);
    });

    test('hasToken mengembalikan false jika token kosong', () async {
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => '');

      final result = await service.hasToken();

      expect(result, isFalse);
    });
  });
}
