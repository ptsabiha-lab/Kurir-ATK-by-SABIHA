class AppUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final int? institutionId;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.institutionId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      institutionId: json['institution_id'] as int?,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isKurir => role == 'kurir';
}
