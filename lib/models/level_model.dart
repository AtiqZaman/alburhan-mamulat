// ============================================================
// FILE: lib/models/level_model.dart
// COPY THIS CODE INTO: lib/models/level_model.dart
// ============================================================

class LevelModel {
  final String id;
  final int levelNumber;
  final String levelNameUrdu;
  final bool isActive;
  final DateTime createdAt;

  LevelModel({
    required this.id,
    required this.levelNumber,
    required this.levelNameUrdu,
    this.isActive = true,
    required this.createdAt,
  });

  factory LevelModel.fromMap(Map<String, dynamic> map, String id) {
    return LevelModel(
      id: id,
      levelNumber: map['levelNumber'] ?? 1,
      levelNameUrdu: map['levelNameUrdu'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelNumber': levelNumber,
      'levelNameUrdu': levelNameUrdu,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
