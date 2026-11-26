import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:lablend/features/auth/services/auth_api_service.dart';

void main() {
  late AuthApiService service;

  tearDown(() {
    service.dispose();
  });

  test('register berhasil dan mengirim data yang benar', () async {
    service = AuthApiService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url,
          Uri.parse('${AuthApiService.baseUrl}/auth/register'),
        );
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body);

        expect(body['nama'], 'Test User');
        expect(body['email'], 'test@example.com');
        expect(body['password'], 'password123');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'user-1',
              'nama': 'Test User',
              'email': 'test@example.com',
              'role': 'user',
            },
          }),
          201,
        );
      }),
    );

    final result = await service.register(
      nama: 'Test User',
      email: 'test@example.com',
      password: 'password123',
    );

    expect(result['id'], 'user-1');
    expect(result['email'], 'test@example.com');
  });

  test('login berhasil dan mengirim email serta password', () async {
    service = AuthApiService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.parse('${AuthApiService.baseUrl}/auth/login'));

        final body = jsonDecode(request.body);

        expect(body['email'], 'test@example.com');
        expect(body['password'], 'password123');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'token': 'test-token',
              'user': {
                'id': 'user-1',
                'nama': 'Test User',
                'email': 'test@example.com',
                'role': 'user',
              },
            },
          }),
          200,
        );
      }),
    );

    final result = await service.login(
      email: 'test@example.com',
      password: 'password123',
    );

    expect(result['token'], 'test-token');
    expect(result['user']['id'], 'user-1');
  });

  test('register gagal dengan pesan error dari server', () async {
    service = AuthApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'success': false, 'message': 'Email sudah digunakan.'}),
          409,
        ),
      ),
    );

    await expectLater(
      service.register(
        nama: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      ),
      throwsA(
        predicate(
          (error) => error.toString().contains('Email sudah digunakan.'),
        ),
      ),
    );
  });

  test('login gagal dengan pesan error dari server', () async {
    service = AuthApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email atau password salah.',
          }),
          401,
        ),
      ),
    );

    await expectLater(
      service.login(email: 'wrong@example.com', password: 'wrong-password'),
      throwsA(
        predicate(
          (error) => error.toString().contains('Email atau password salah.'),
        ),
      ),
    );
  });

  test('menolak response dengan format JSON tidak valid', () async {
    service = AuthApiService(
      client: MockClient((_) async => http.Response('Invalid JSON', 200)),
    );

    await expectLater(
      service.login(email: 'test@example.com', password: 'password123'),
      throwsA(
        predicate(
          (error) =>
              error.toString().contains('Response dari server tidak valid.'),
        ),
      ),
    );
  });

  test('menolak response jika data bukan object JSON', () async {
    service = AuthApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': true,
            'data': ['invalid', 'data'],
          }),
          200,
        ),
      ),
    );

    await expectLater(
      service.login(email: 'test@example.com', password: 'password123'),
      throwsA(
        predicate(
          (error) =>
              error.toString().contains('Format data dari server tidak valid.'),
        ),
      ),
    );
  });

  test('menolak response jika success bukan true', () async {
    service = AuthApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'success': false, 'message': 'Permintaan ditolak.'}),
          200,
        ),
      ),
    );

    await expectLater(
      service.register(
        nama: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      ),
      throwsA(
        predicate((error) => error.toString().contains('Permintaan ditolak.')),
      ),
    );
  });

  test(
    'menggunakan pesan default jika server tidak memberikan message',
    () async {
      service = AuthApiService(
        client: MockClient(
          (_) async => http.Response(jsonEncode({'success': false}), 500),
        ),
      );

      await expectLater(
        service.login(email: 'test@example.com', password: 'password123'),
        throwsA(
          predicate(
            (error) =>
                error.toString().contains('Terjadi kesalahan pada server.'),
          ),
        ),
      );
    },
  );
}
