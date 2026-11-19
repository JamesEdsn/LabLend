import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/app_logger.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/peminjaman_model.dart';

class ApiService {
  // Untuk Flutter Web yang berjalan di komputer yang sama dengan backend.
  static const String baseUrl = 'http://localhost:3000/api';

  final http.Client client;
  final Future<String?> Function()? tokenProvider;
  final SecureStorageService secureStorage;

  ApiService({
    http.Client? client,
    SecureStorageService? secureStorage,
    this.tokenProvider,
  }) : client = client ?? http.Client(),
       secureStorage = secureStorage ?? SecureStorageService();

  // Mengambil JWT dan memasukkannya ke header Authorization.
  Future<Map<String, String>> _authHeaders({bool jsonContent = false}) async {
    try {
      final token = tokenProvider != null
          ? await tokenProvider!()
          : await secureStorage.getToken();

      if (token == null || token.isEmpty) {
        AppLogger.warning('Authentication token not found');

        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      AppLogger.info('Authentication token retrieved successfully');

      return {
        'Authorization': 'Bearer $token',
        if (jsonContent) 'Content-Type': 'application/json',
      };
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to retrieve authentication token',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Peminjaman>> fetchPeminjaman() async {
    final uri = Uri.parse('$baseUrl/peminjaman');

    try {
      AppLogger.info('GET /peminjaman - Request started');

      final response = await client.get(uri, headers: await _authHeaders());

      AppLogger.info('GET /peminjaman - HTTP ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil riwayat peminjaman: HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true ||
          decoded['data'] is! List) {
        throw const FormatException('Format respons API tidak valid');
      }

      final data = decoded['data'] as List<dynamic>;

      final records = data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Format data peminjaman tidak valid');
        }

        return Peminjaman.fromJson(item);
      }).toList();

      AppLogger.info(
        'GET /peminjaman - Successfully loaded ${records.length} records',
      );

      return records;
    } catch (error, stackTrace) {
      AppLogger.error(
        'GET /peminjaman - Request failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Peminjaman> createPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    final uri = Uri.parse('$baseUrl/peminjaman');

    try {
      AppLogger.info('POST /peminjaman - Request started');

      final response = await client.post(
        uri,
        headers: await _authHeaders(jsonContent: true),
        body: jsonEncode({
          'alat': alat,
          'jumlah': jumlah,
          'tanggalKembali': tanggalKembali,
        }),
      );

      AppLogger.info('POST /peminjaman - HTTP ${response.statusCode}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Gagal menyimpan peminjaman: HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true ||
          decoded['data'] is! Map<String, dynamic>) {
        throw const FormatException('Format respons API tidak valid');
      }

      final record = Peminjaman.fromJson(
        decoded['data'] as Map<String, dynamic>,
      );

      AppLogger.info('POST /peminjaman - Peminjaman created successfully');

      return record;
    } catch (error, stackTrace) {
      AppLogger.error(
        'POST /peminjaman - Request failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updatePeminjaman(Peminjaman record) async {
    final uri = Uri.parse(
      '$baseUrl/peminjaman/${Uri.encodeComponent(record.id)}',
    );

    try {
      AppLogger.info('PUT /peminjaman - Request started');

      final response = await client.put(
        uri,
        headers: await _authHeaders(jsonContent: true),
        body: jsonEncode({
          'alat': record.alat,
          'jumlah': record.jumlah,
          'tanggalKembali': record.tanggalKembali,
        }),
      );

      AppLogger.info('PUT /peminjaman - HTTP ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui peminjaman: HTTP ${response.statusCode}',
        );
      }

      AppLogger.info('PUT /peminjaman - Peminjaman updated successfully');
    } catch (error, stackTrace) {
      AppLogger.error(
        'PUT /peminjaman - Request failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deletePeminjaman(String id) async {
    final uri = Uri.parse('$baseUrl/peminjaman/${Uri.encodeComponent(id)}');

    try {
      AppLogger.info('DELETE /peminjaman - Request started');

      final response = await client.delete(uri, headers: await _authHeaders());

      AppLogger.info('DELETE /peminjaman - HTTP ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal menghapus peminjaman: HTTP ${response.statusCode}',
        );
      }

      AppLogger.info('DELETE /peminjaman - Peminjaman deleted successfully');
    } catch (error, stackTrace) {
      AppLogger.error(
        'DELETE /peminjaman - Request failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void dispose() {
    AppLogger.info('ApiService disposed');
    client.close();
  }
}
