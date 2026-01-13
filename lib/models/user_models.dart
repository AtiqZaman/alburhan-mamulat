import 'package:cloud_firestore/cloud_firestore.dart';

class SalikUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final int level;
  final int currentDay;
  final int currentStreak;
  final String assignedMurabi;
  final DateTime createdAt;

  SalikUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.level,
    required this.currentDay,
    required this.currentStreak,
    required this.assignedMurabi,
    required this.createdAt,
  });

  factory SalikUser.fromJson(Map<String, dynamic> json) {
    return SalikUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      level: json['level'] ?? 1,
      currentDay: json['currentDay'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      assignedMurabi: json['assignedMurabi'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'level': level,
        'currentDay': currentDay,
        'currentStreak': currentStreak,
        'assignedMurabi': assignedMurabi,
        'createdAt': createdAt,
      };
}

class MurabiUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final int totalSalikeens;
  final int pendingApprovals;
  final DateTime createdAt;

  MurabiUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalSalikeens,
    required this.pendingApprovals,
    required this.createdAt,
  });

  factory MurabiUser.fromJson(Map<String, dynamic> json) {
    return MurabiUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      totalSalikeens: json['totalSalikeens'] ?? 0,
      pendingApprovals: json['pendingApprovals'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class Level {
  final String id;
  final int levelNumber;
  final String levelName;
  final int daysRequired;
  final String description;
  final DateTime createdAt;

  Level({
    required this.id,
    required this.levelNumber,
    required this.levelName,
    required this.daysRequired,
    required this.description,
    required this.createdAt,
  });

  factory Level.fromJson(String id, Map<String, dynamic> json) {
    return Level(
      id: id,
      levelNumber: json['levelNumber'] ?? 1,
      levelName: json['levelName'] ?? '',
      daysRequired: json['daysRequired'] ?? 40,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'levelName': levelName,
        'daysRequired': daysRequired,
        'description': description,
        'createdAt': createdAt,
      };
}

class Task {
  final String id;
  final String levelId;
  final String taskName;
  final String description;
  final String category;
  final bool isCountable;
  final int maxCount;
  final int order;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.levelId,
    required this.taskName,
    required this.description,
    required this.category,
    required this.isCountable,
    required this.maxCount,
    required this.order,
    required this.createdAt,
  });

  factory Task.fromJson(String id, Map<String, dynamic> json) {
    return Task(
      id: id,
      levelId: json['levelId'] ?? '',
      taskName: json['taskName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isCountable: json['isCountable'] ?? false,
      maxCount: json['maxCount'] ?? 1,
      order: json['order'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'levelId': levelId,
        'taskName': taskName,
        'description': description,
        'category': category,
        'isCountable': isCountable,
        'maxCount': maxCount,
        'order': order,
        'createdAt': createdAt,
      };
}

class DailyUpdate {
  final String id;
  final String salikId;
  final String salikName;
  final String murabiId;
  final int currentLevel;
  final int currentDay;
  final Map<String, dynamic> tasksCompleted;
  final String notes;
  final DateTime date;
  final DateTime submittedAt;

  DailyUpdate({
    required this.id,
    required this.salikId,
    required this.salikName,
    required this.murabiId,
    required this.currentLevel,
    required this.currentDay,
    required this.tasksCompleted,
    required this.notes,
    required this.date,
    required this.submittedAt,
  });

  factory DailyUpdate.fromJson(String id, Map<String, dynamic> json) {
    return DailyUpdate(
      id: id,
      salikId: json['salikId'] ?? '',
      salikName: json['salikName'] ?? '',
      murabiId: json['murabiId'] ?? '',
      currentLevel: json['currentLevel'] ?? 1,
      currentDay: json['currentDay'] ?? 1,
      tasksCompleted: json['tasksCompleted'] ?? {},
      notes: json['notes'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      submittedAt: json['submittedAt'] is Timestamp
          ? (json['submittedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'salikId': salikId,
        'salikName': salikName,
        'murabiId': murabiId,
        'currentLevel': currentLevel,
        'currentDay': currentDay,
        'tasksCompleted': tasksCompleted,
        'notes': notes,
        'date': date,
        'submittedAt': submittedAt,
      };
}

class PromotionRequest {
  final String id;
  final String salikId;
  final String salikName;
  final String murabiId;
  final int currentLevel;
  final int requestedLevel;
  final String status; // pending, approved, rejected
  final DateTime requestedAt;
  final DateTime? approvedAt;

  PromotionRequest({
    required this.id,
    required this.salikId,
    required this.salikName,
    required this.murabiId,
    required this.currentLevel,
    required this.requestedLevel,
    required this.status,
    required this.requestedAt,
    required this.approvedAt,
  });

  factory PromotionRequest.fromJson(String id, Map<String, dynamic> json) {
    return PromotionRequest(
      id: id,
      salikId: json['salikId'] ?? '',
      salikName: json['salikName'] ?? '',
      murabiId: json['murabiId'] ?? '',
      currentLevel: json['currentLevel'] ?? 1,
      requestedLevel: json['requestedLevel'] ?? 2,
      status: json['status'] ?? 'pending',
      requestedAt: json['requestedAt'] is Timestamp
          ? (json['requestedAt'] as Timestamp).toDate()
          : DateTime.now(),
      approvedAt: json['approvedAt'] is Timestamp
          ? (json['approvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'salikId': salikId,
        'salikName': salikName,
        'murabiId': murabiId,
        'currentLevel': currentLevel,
        'requestedLevel': requestedLevel,
        'status': status,
        'requestedAt': requestedAt,
        'approvedAt': approvedAt,
      };

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class SalikPerformance {
  final String salikId;
  final String salikName;
  final int level;
  final int currentDay;
  final double completionPercentage;
  final int streak;

  SalikPerformance({
    required this.salikId,
    required this.salikName,
    required this.level,
    required this.currentDay,
    required this.completionPercentage,
    required this.streak,
  });

  factory SalikPerformance.fromJson(Map<String, dynamic> json) {
    return SalikPerformance(
      salikId: json['salikId'] ?? '',
      salikName: json['salikName'] ?? '',
      level: json['level'] ?? 1,
      currentDay: json['currentDay'] ?? 1,
      completionPercentage: (json['completionPercentage'] ?? 0.0).toDouble(),
      streak: json['streak'] ?? 0,
    );
  }

  String getMedalEmoji() {
    // Will be determined by rank in list
    return '◯';
  }
}
