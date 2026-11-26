import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lablend/features/auth/models/auth_user.dart';
import 'package:lablend/features/auth/providers/auth_notifier.dart';
import 'package:lablend/features/auth/providers/auth_state.dart';
import 'package:lablend/features/auth/repositories/auth_repository.dart';

class FakeAuthRepository extends AuthRepository {
  String? storedToken;

  Exception? tokenException;
  Exception? loginException;
  Exception? registerException;
  Exception? logoutException;

  int loginCalls = 0;
  int registerCalls = 0;
  int logoutCalls = 0;

  AuthUser loginUser = const AuthUser(
    id: 'user-1',
    nama: 'Test User',
    email: 'test@example.com',
    role: 'user',
  );

  @override
  Future<String?> getToken() async {
    if (tokenException != null) {
      throw tokenException!;
    }

    return storedToken;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;

    if (loginException != null) {
      throw loginException!;
    }

    return loginUser;
  }

  @override
  Future<AuthUser> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    registerCalls++;

    if (registerException != null) {
      throw registerException!;
    }

    return loginUser;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;

    if (logoutException != null) {
      throw logoutException!;
    }

    storedToken = null;
  }
}

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
    repository.dispose();
  });

  test('restoreSession berhasil jika token tersedia', () async {
    repository.storedToken = 'valid-token';

    await container.read(authProvider.notifier).restoreSession();

    final state = container.read(authProvider);

    expect(state.status, AuthStatus.authenticated);
    expect(state.errorMessage, isNull);
  });

  test(
    'restoreSession menjadi unauthenticated jika token tidak tersedia',
    () async {
      repository.storedToken = null;

      await container.read(authProvider.notifier).restoreSession();

      final state = container.read(authProvider);

      expect(state.status, AuthStatus.unauthenticated);
    },
  );

  test(
    'restoreSession menampilkan error jika pengambilan token gagal',
    () async {
      repository.tokenException = Exception('Storage unavailable');

      await container.read(authProvider.notifier).restoreSession();

      final state = container.read(authProvider);

      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Storage unavailable');
    },
  );

  test('login berhasil dan menyimpan data user pada state', () async {
    final result = await container
        .read(authProvider.notifier)
        .login(email: 'test@example.com', password: 'password123');

    final state = container.read(authProvider);

    expect(result, isTrue);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user?.id, 'user-1');
    expect(state.user?.email, 'test@example.com');
    expect(repository.loginCalls, 1);
  });

  test('login gagal dan menampilkan pesan error', () async {
    repository.loginException = Exception('Email atau password salah.');

    final result = await container
        .read(authProvider.notifier)
        .login(email: 'wrong@example.com', password: 'wrong-password');

    final state = container.read(authProvider);

    expect(result, isFalse);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Email atau password salah.');
    expect(state.user, isNull);
  });

  test('register berhasil dan status kembali unauthenticated', () async {
    final result = await container
        .read(authProvider.notifier)
        .register(
          nama: 'Test User',
          email: 'test@example.com',
          password: 'password123',
        );

    final state = container.read(authProvider);

    expect(result, isTrue);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.user, isNull);
    expect(repository.registerCalls, 1);
  });

  test('register gagal dan menampilkan pesan error', () async {
    repository.registerException = Exception('Email sudah digunakan.');

    final result = await container
        .read(authProvider.notifier)
        .register(
          nama: 'Test User',
          email: 'test@example.com',
          password: 'password123',
        );

    final state = container.read(authProvider);

    expect(result, isFalse);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Email sudah digunakan.');
  });

  test('logout berhasil dan menghapus session', () async {
    repository.storedToken = 'valid-token';

    await container.read(authProvider.notifier).logout();

    final state = container.read(authProvider);

    expect(state.status, AuthStatus.unauthenticated);
    expect(repository.storedToken, isNull);
    expect(repository.logoutCalls, 1);
  });

  test('logout meneruskan error jika penghapusan session gagal', () async {
    repository.logoutException = Exception('Gagal menghapus token.');

    await expectLater(
      container.read(authProvider.notifier).logout(),
      throwsA(isA<Exception>()),
    );

    expect(repository.logoutCalls, 1);
  });
}
