enum UserRole { trainer, member }

class User {
  const User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.assignedTrainerId,
  });

  final String id;
  final UserRole role;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? assignedTrainerId;

  Map<String, Object?> toJson() => {
        'id': id,
        'role': role.name,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'assignedTrainerId': assignedTrainerId,
      };

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as String,
      role: UserRole.values.byName(json['role'] as String),
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      assignedTrainerId: json['assignedTrainerId'] as String?,
    );
  }
}
