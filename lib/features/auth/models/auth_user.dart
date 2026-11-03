class AuthUser {
  final String id;
  final String nama;
  final String email;
  final String role;

  const AuthUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      nama: json['nama'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'email': email, 'role': role};
  }
}
