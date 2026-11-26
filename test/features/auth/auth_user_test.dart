import 'package:flutter_test/flutter_test.dart';
import 'package:lablend/features/auth/models/auth_user.dart';

void main() {
  group('AuthUser.fromJson', () {
    test('parses a valid user JSON', () {
      final user = AuthUser.fromJson({
        'id': 'user-1',
        'nama': 'James',
        'email': 'james@example.com',
        'role': 'mahasiswa',
      });

      expect(user.id, 'user-1');
      expect(user.nama, 'James');
      expect(user.email, 'james@example.com');
      expect(user.role, 'mahasiswa');
    });

    test('converts numeric ID into string', () {
      final user = AuthUser.fromJson({
        'id': 123,
        'nama': 'James',
        'email': 'james@example.com',
        'role': 'mahasiswa',
      });

      expect(user.id, '123');
    });

    test('converts null ID into string null', () {
      final user = AuthUser.fromJson({
        'id': null,
        'nama': 'James',
        'email': 'james@example.com',
        'role': 'mahasiswa',
      });

      expect(user.id, 'null');
    });

    test('preserves administrator role', () {
      final user = AuthUser.fromJson({
        'id': 'admin-1',
        'nama': 'Admin',
        'email': 'admin@example.com',
        'role': 'admin',
      });

      expect(user.role, 'admin');
    });
  });

  group('AuthUser.toJson', () {
    test('converts user properties into JSON', () {
      const user = AuthUser(
        id: 'user-1',
        nama: 'James',
        email: 'james@example.com',
        role: 'mahasiswa',
      );

      expect(user.toJson(), {
        'id': 'user-1',
        'nama': 'James',
        'email': 'james@example.com',
        'role': 'mahasiswa',
      });
    });

    test('keeps all four expected JSON keys', () {
      const user = AuthUser(
        id: 'user-2',
        nama: 'Test User',
        email: 'test@example.com',
        role: 'admin',
      );

      final json = user.toJson();

      expect(json.keys.toSet(), {'id', 'nama', 'email', 'role'});
      expect(json.length, 4);
    });
  });
}
