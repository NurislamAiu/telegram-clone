// lib/models/user_model.dart

class UserModel {
  final String userId;
  final String username;
  final String passwordHash;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'],
      username: map['username'],
      passwordHash: map['passwordHash'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}