// ============================================================
// FILE: lib/models/user_model.dart
// COPY THIS CODE INTO: lib/models/user_model.dart
// ============================================================

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // admin, murabi, salik
  final String? assignedMurabiId;
  final int currentLevel;
  final int chillaDay;
  final DateTime chillaStartDate;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.assignedMurabiId,
    this.currentLevel = 1,
    this.chillaDay = 1,
    required this.chillaStartDate,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'salik',
      assignedMurabiId: map['assignedMurabiId'],
      currentLevel: map['currentLevel'] ?? 1,
      chillaDay: map['chillaDay'] ?? 1,
      chillaStartDate: (map['chillaStartDate'] as dynamic).toDate(),
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'assignedMurabiId': assignedMurabiId,
      'currentLevel': currentLevel,
      'chillaDay': chillaDay,
      'chillaStartDate': chillaStartDate,
      'createdAt': createdAt,
    };
  }
}