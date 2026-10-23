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

    if (tanggalKembali is! String ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(tanggalKembali)) {
      throw const FormatException('Tanggal kembali tidak valid');
    }

    final parsedDate = DateTime.tryParse(tanggalKembali);

    if (parsedDate == null ||
        '${parsedDate.year.toString().padLeft(4, '0')}-'
                '${parsedDate.month.toString().padLeft(2, '0')}-'
                '${parsedDate.day.toString().padLeft(2, '0')}' !=
            tanggalKembali) {
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
