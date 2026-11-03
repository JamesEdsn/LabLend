import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/peminjaman_model.dart';

class ApiService {
  // Untuk Flutter Web yang berjalan di komputer yang sama dengan backend.
  static const String baseUrl = 'http://localhost:3000/api';

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Peminjaman>> fetchPeminjaman() async {
    final response = await client.get(Uri.parse('$baseUrl/peminjaman'));

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

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Format data peminjaman tidak valid');
      }

      return Peminjaman.fromJson(item);
    }).toList();
  }

  Future<Peminjaman> createPeminjaman({
    required String alat,
    required int jumlah,
    required String tanggalKembali,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/peminjaman'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alat': alat,
        'jumlah': jumlah,
        'tanggalKembali': tanggalKembali,
      }),
    );

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

    return Peminjaman.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<void> updatePeminjaman(Peminjaman record) async {
    final response = await client.put(
      Uri.parse('$baseUrl/peminjaman/${Uri.encodeComponent(record.id)}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alat': record.alat,
        'jumlah': record.jumlah,
        'tanggalKembali': record.tanggalKembali,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memperbarui peminjaman: HTTP ${response.statusCode}',
      );
    }
  }

  Future<void> deletePeminjaman(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/peminjaman/${Uri.encodeComponent(id)}'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal menghapus peminjaman: HTTP ${response.statusCode}',
      );
    }
  }

  void dispose() {
    client.close();
  }
}
