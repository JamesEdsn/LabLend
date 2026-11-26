import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:lablend/core/services/secure_storage_service.dart';
import 'package:lablend/features/auth/repositories/auth_repository.dart';
import 'package:lablend/features/auth/services/auth_api_service.dart';

// Fake API agar test tidak membutuhkan koneksi ke backend.
class FakeAuthApiService extends AuthApiService {
  FakeAuthApiService()
    : super(client: MockClient((_) async => http.Response('{}', 200)));

  Map<String, dynamic> registerResponse = {
    'id': 1,
    'nama': 'James',
    'email': 'james@test.com',
    'role': 'mahasiswa',
  };

  Map<String, dynamic> loginResponse = {
    'token': 'jwt-test-token',
    'user': {
      'id': 1,
      'nama': 'James',
      'email': 'james@test.com',
      'role': 'mahasiswa',
    },
  };

  String? registerNama;
  String? registerEmail;
  String? registerPassword;

  String? loginEmail;
  String? loginPassword;

  Object? registerError;
  Object? loginError;

  @override
  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    registerNama = nama;
    registerEmail = email;
    registerPassword = password;

    if (registerError != null) {
      throw registerError!;
    }

    return registerResponse;
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    loginEmail = email;
    loginPassword = password;

    if (loginError != null) {
      throw loginError!;
    }

    return loginResponse;
  }

  @override
  void dispose() {
    // Tidak perlu menutup client selama test.
  }
}

// Fake secure storage agar test tidak membutuhkan perangkat asli.
class FakeSecureStorage extends SecureStorageService {
  String? token;
  bool deleteCalled = false;

  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<String?> getToken() async {
    return token;
  }

  @override
  Future<void> deleteToken() async {
    token = null;
    deleteCalled = true;
  }
}

void main() {
  late FakeAuthApiService fakeApi;
  late FakeSecureStorage fakeStorage;
  late AuthRepository repository;

  setUp(() {
    fakeApi = FakeAuthApiService();
    fakeStorage = FakeSecureStorage();

    repository = AuthRepository(
      apiService: fakeApi,
      secureStorage: fakeStorage,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  test('Register mengirim data dan mengembalikan user', () async {
    final user = await repository.register(
      nama: 'James',
      email: 'james@test.com',
      password: 'password123',
    );

    expect(fakeApi.registerNama, 'James');
    expect(fakeApi.registerEmail, 'james@test.com');
    expect(fakeApi.registerPassword, 'password123');

    expect(user.id, '1');
    expect(user.nama, 'James');
    expect(user.email, 'james@test.com');
    expect(user.role, 'mahasiswa');
  });

  test('Register meneruskan error dari API', () async {
    final error = Exception('Email sudah digunakan');
    fakeApi.registerError = error;

    await expectLater(
      repository.register(
        nama: 'James',
        email: 'james@test.com',
        password: 'password123',
      ),
      throwsA(same(error)),
    );
  });

  test('Login mengirim data dan menyimpan JWT token', () async {
    final user = await repository.login(
      email: 'james@test.com',
      password: 'password123',
    );

    expect(fakeApi.loginEmail, 'james@test.com');
    expect(fakeApi.loginPassword, 'password123');

    expect(fakeStorage.token, 'jwt-test-token');

    expect(user.id, '1');
    expect(user.nama, 'James');
    expect(user.email, 'james@test.com');
  });

  test('Login gagal jika token tidak tersedia dalam respons', () async {
    fakeApi.loginResponse = {
      'user': {
        'id': 1,
        'nama': 'James',
        'email': 'james@test.com',
        'role': 'mahasiswa',
      },
    };

    await expectLater(
      repository.login(email: 'james@test.com', password: 'password123'),
      throwsA(isA<TypeError>()),
    );

    expect(fakeStorage.token, isNull);
  });

  test('Login gagal jika data user tidak tersedia', () async {
    fakeApi.loginResponse = {'token': 'jwt-test-token'};

    await expectLater(
      repository.login(email: 'james@test.com', password: 'password123'),
      throwsA(isA<TypeError>()),
    );

    expect(fakeStorage.token, isNull);
  });

  test('Logout menghapus token yang tersimpan', () async {
    fakeStorage.token = 'jwt-test-token';

    await repository.logout();

    expect(fakeStorage.deleteCalled, isTrue);
    expect(fakeStorage.token, isNull);
  });

  test('getToken mengembalikan token yang tersimpan', () async {
    fakeStorage.token = 'jwt-test-token';

    final token = await repository.getToken();

    expect(token, 'jwt-test-token');
  });
}
