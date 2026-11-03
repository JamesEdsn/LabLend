import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  final http.Client client;

  AuthApiService({http.Client? client}) : client = client ?? http.Client();

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  // RESPONSE HANDLER
  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> decoded;

    try {
      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        throw const FormatException();
      }

      decoded = body;
    } catch (_) {
      throw Exception('Response dari server tidak valid.');
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded['success'] == true) {
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Format data dari server tidak valid.');
    }

    throw Exception(decoded['message'] ?? 'Terjadi kesalahan pada server.');
  }

  void dispose() {
    client.close();
  }
}
