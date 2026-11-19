import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_logger.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = AuthRepository();

  ref.onDispose(repository.dispose);

  return repository;
});

// Authentication state provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    return const AuthState(status: AuthStatus.loading);
  }

  // MEMULIHKAN SESSION SAAT APLIKASI DIBUKA
  Future<void> restoreSession() async {
    AppLogger.info('Session restoration started');

    try {
      final token = await _repository.getToken();

      if (token != null && token.isNotEmpty) {
        AppLogger.info('Session restored successfully');

        state = const AuthState(status: AuthStatus.authenticated);
      } else {
        AppLogger.warning('No saved session found');

        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Session restoration failed',
        error: error,
        stackTrace: stackTrace,
      );

      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  // LOGIN
  Future<bool> login({required String email, required String password}) async {
    AppLogger.info('Login process started');

    state = const AuthState(status: AuthStatus.loading);

    try {
      final user = await _repository.login(email: email, password: password);

      AppLogger.info('Login successful');

      state = AuthState(status: AuthStatus.authenticated, user: user);

      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Login failed', error: error, stackTrace: stackTrace);

      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );

      return false;
    }
  }

  // REGISTER
  Future<bool> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    AppLogger.info('Registration process started');

    state = const AuthState(status: AuthStatus.loading);

    try {
      await _repository.register(nama: nama, email: email, password: password);

      AppLogger.info('Registration successful');

      // Register belum menghasilkan token.
      // Pengguna harus login setelah registrasi.
      state = const AuthState(status: AuthStatus.unauthenticated);

      return true;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Registration failed',
        error: error,
        stackTrace: stackTrace,
      );

      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );

      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    AppLogger.info('Logout process started');

    try {
      await _repository.logout();

      AppLogger.info('Logout successful');

      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (error, stackTrace) {
      AppLogger.error('Logout failed', error: error, stackTrace: stackTrace);

      rethrow;
    }
  }

  String _getErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
