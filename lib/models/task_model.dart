// ============================================================
// FILE: lib/models/task_model.dart
// COPY THIS CODE INTO: lib/models/task_model.dart
// ============================================================

class TaskModel {
  final String id;
  final String taskNameUrdu;
  final String category; // prayer, dhikr-morning, dhikr-evening
  final bool isCountable;
  final int maxCount;
  final String levelId;
  final int order;

  TaskModel({
    required this.id,
    required this.taskNameUrdu,
    required this.category,
    this.isCountable = false,
    this.maxCount = 0,
    required this.levelId,
    required this.order,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      taskNameUrdu: map['taskNameUrdu'] ?? '',
      category: map['category'] ?? '',
      isCountable: map['isCountable'] ?? false,
      maxCount: map['maxCount'] ?? 0,
      levelId: map['levelId'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskNameUrdu': taskNameUrdu,
      'category': category,
      'isCountable': isCountable,
      'maxCount': maxCount,
      'levelId': levelId,
      'order': order,
    };
  }
}