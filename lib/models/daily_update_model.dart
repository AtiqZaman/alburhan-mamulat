// ============================================================
// FILE: lib/models/daily_update_model.dart
// COPY THIS CODE INTO: lib/models/daily_update_model.dart
// ============================================================

class DailyUpdateModel {
  final String id;
  final String salikId;
  final DateTime date;
  final int chillaDay;
  final String levelId;
  final Map<String, TaskStatus> taskStatuses;
  final DateTime submittedAt;

  DailyUpdateModel({
    required this.id,
    required this.salikId,
    required this.date,
    required this.chillaDay,
    required this.levelId,
    required this.taskStatuses,
    required this.submittedAt,
  });

  factory DailyUpdateModel.fromMap(Map<String, dynamic> map, String id) {
    Map<String, TaskStatus> statuses = {};
    if (map['taskStatuses'] != null) {
      (map['taskStatuses'] as Map<String, dynamic>).forEach((key, value) {
        statuses[key] = TaskStatus(
          completed: value['completed'] ?? false,
          count: value['count'] ?? 0,
        );
      });
    }

    return DailyUpdateModel(
      id: id,
      salikId: map['salikId'] ?? '',
      date: (map['date'] as dynamic).toDate(),
      chillaDay: map['chillaDay'] ?? 0,
      levelId: map['levelId'] ?? '',
      taskStatuses: statuses,
      submittedAt: (map['submittedAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> statusMap = {};
    taskStatuses.forEach((key, value) {
      statusMap[key] = {
        'completed': value.completed,
        'count': value.count,
      };
    });

    return {
      'salikId': salikId,
      'date': date,
      'chillaDay': chillaDay,
      'levelId': levelId,
      'taskStatuses': statusMap,
      'submittedAt': submittedAt,
    };
  }
}

class TaskStatus {
  final bool completed;
  final int count;

  TaskStatus({required this.completed, this.count = 0});
}

