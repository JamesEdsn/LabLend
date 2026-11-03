import '../models/auth_user.dart';
import '../services/auth_api_service.dart';
import '../../../../core/services/secure_storage_service.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthRepository({
    AuthApiService? apiService,
    SecureStorageService? secureStorage,
  }) : _apiService = apiService ?? AuthApiService(),
       _secureStorage = secureStorage ?? SecureStorageService();

  Future<AuthUser> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    final data = await _apiService.register(
      nama: nama,
      email: email,
      password: password,
    );

    return AuthUser.fromJson(data);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final data = await _apiService.login(email: email, password: password);

    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await _secureStorage.saveToken(token);

    return AuthUser.fromJson(userData);
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  Future<String?> getToken() async {
    return _secureStorage.getToken();
  }

  void dispose() {
    _apiService.dispose();
  }
}
