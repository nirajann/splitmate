class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }
}
