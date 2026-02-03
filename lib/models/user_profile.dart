class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'sales',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
