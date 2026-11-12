/// Memvalidasi pilihan alat.
String? validatePilihanAlat(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Silakan pilih alat';
  }
  return null;
}

/// Memvalidasi jumlah alat yang dipinjam.
String? validateJumlah(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Jumlah tidak boleh kosong';
  }

  final jumlah = int.tryParse(value.trim());

  if (jumlah == null || jumlah <= 0) {
    return 'Jumlah harus lebih dari 0';
  }

  return null;
}

/// Memvalidasi format dan tanggal kalender YYYY-MM-DD.
bool isValidTanggalKembali(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    return false;
  }

  final parsedDate = DateTime.tryParse(value);

  if (parsedDate == null) {
    return false;
  }

  final normalized =
      '${parsedDate.year.toString().padLeft(4, '0')}-'
      '${parsedDate.month.toString().padLeft(2, '0')}-'
      '${parsedDate.day.toString().padLeft(2, '0')}';

  return normalized == value;
}

/// Memvalidasi input tanggal kembali dari form.
String? validateTanggalKembali(String? value) {
  final tanggal = value?.trim() ?? '';

  if (tanggal.isEmpty) {
    return 'Tanggal kembali tidak boleh kosong';
  }

  if (!isValidTanggalKembali(tanggal)) {
    return 'Gunakan format YYYY-MM-DD (contoh: 2026-11-15)';
  }

  return null;
}

/// Memvalidasi nama alat pada form edit.
String? validateNamaAlat(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nama alat wajib diisi';
  }

  return null;
}
