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
    return Peminjaman(
      id: json['id'] as String,
      alat: json['alat'] as String,
      jumlah: json['jumlah'] as int,
      tanggalKembali: json['tanggalKembali'] as String,
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
