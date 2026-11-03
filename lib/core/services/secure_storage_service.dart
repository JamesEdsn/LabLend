import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // Menyimpan JWT setelah login berhasil.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Mengambil JWT ketika aplikasi dibuka kembali.
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  // Menghapus JWT ketika pengguna logout.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Memeriksa apakah pengguna memiliki token.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
