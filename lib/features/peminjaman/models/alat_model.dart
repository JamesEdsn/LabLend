class Alat {
  final String id;
  final String nama;
  final String kategori;
  final int stokTotal;
  final int stokTersedia;

  const Alat({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.stokTotal,
    required this.stokTersedia,
  });

  factory Alat.fromJson(Map<String, dynamic> json) {
    return Alat(
      id: json['id'] as String,
      nama: json['nama'] as String,
      kategori: json['kategori'] as String? ?? '',
      stokTotal: (json['stokTotal'] as num).toInt(),
      stokTersedia: (json['stokTersedia'] as num).toInt(),
    );
  }
}
