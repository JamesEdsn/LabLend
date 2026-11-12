import '../validation/peminjaman_validation.dart';

class Peminjaman {
  final String id;
  final String alat;
  final int jumlah;
  final String tanggalKembali;

  const Peminjaman({
    required this.id,
    required this.alat,
    required this.jumlah,
    required this.tanggalKembali,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alat': alat,
      'jumlah': jumlah,
      'tanggalKembali': tanggalKembali,
    };
  }

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final alat = json['alat'];
    final jumlah = json['jumlah'];
    final tanggalKembali = json['tanggalKembali'];

    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('ID peminjaman tidak valid');
    }

    if (alat is! String || alat.trim().isEmpty) {
      throw const FormatException('Nama alat tidak valid');
    }

    if (jumlah is! int || jumlah <= 0) {
      throw const FormatException('Jumlah peminjaman tidak valid');
    }

    if (tanggalKembali is! String || !isValidTanggalKembali(tanggalKembali)) {
      throw const FormatException('Tanggal kembali tidak valid');
    }

    return Peminjaman(
      id: id,
      alat: alat,
      jumlah: jumlah,
      tanggalKembali: tanggalKembali,
    );
  }

  Peminjaman copyWith({
    String? id,
    String? alat,
    int? jumlah,
    String? tanggalKembali,
  }) {
    return Peminjaman(
      id: id ?? this.id,
      alat: alat ?? this.alat,
      jumlah: jumlah ?? this.jumlah,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
    );
  }
}
