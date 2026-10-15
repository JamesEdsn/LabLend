import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/peminjaman_model.dart';

class LocalStorageService {
  static const String _storageKey = 'peminjaman_records';

  Future<List<Peminjaman>> getPeminjaman() async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = preferences.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;

    return decoded.map((item) {
      return Peminjaman.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  Future<void> savePeminjaman(List<Peminjaman> records) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );

    await preferences.setString(_storageKey, jsonString);
  }

  Future<void> clearPeminjaman() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
