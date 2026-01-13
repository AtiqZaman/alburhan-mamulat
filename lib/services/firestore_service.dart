import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new user (Murabi, Salik, or Admin)
  Future<void> addUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String role, // 'admin', 'murabi', 'salik'
    String? assignedMurabi,
    String? bio,
    int? level,
    int? currentDay,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'assignedMurabi': assignedMurabi ?? '',
        'bio': bio ?? '',
        'level': level ?? 1,
        'currentDay': currentDay ?? 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  // Get user by UID
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get all users with specific role
  Stream<List<Map<String, dynamic>>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
        );
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Add task for a level
  Future<void> addTask({
    required String levelId,
    required String taskName,
    required String description,
    required String category,
    bool isCountable = false,
    int maxCount = 1,
    int order = 0,
  }) async {
    try {
      await _firestore.collection('tasks').add({
        'levelId': levelId,
        'taskName': taskName,
        'description': description,
        'category': category,
        'isCountable': isCountable,
        'maxCount': maxCount,
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  // Get tasks by level
  Stream<List<Map<String, dynamic>>> getTasksByLevel(String levelId) {
    return _firestore
        .collection('tasks')
        .where('levelId', isEqualTo: levelId)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // Add level
  Future<void> addLevel({
    required String levelName,
    required int levelNumber,
    required int daysRequired,
    String description = '',
  }) async {
    try {
      await _firestore.collection('levels').add({
        'levelName': levelName,
        'levelNumber': levelNumber,
        'daysRequired': daysRequired,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding level: $e');
      rethrow;
    }
  }

  // Get all levels
  Stream<List<Map<String, dynamic>>> getAllLevels() {
    return _firestore
        .collection('levels')
        .orderBy('levelNumber')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // Submit daily update
  Future<void> submitDailyUpdate({
    required String salikId,
    required String salikName,
    required int currentLevel,
    required int currentDay,
    required Map<String, dynamic> tasksCompleted,
    String notes = '',
  }) async {
    try {
      await _firestore.collection('dailyUpdates').add({
        'salikId': salikId,
        'salikName': salikName,
        'currentLevel': currentLevel,
        'currentDay': currentDay,
        'tasksCompleted': tasksCompleted,
        'notes': notes,
        'date': FieldValue.serverTimestamp(),
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting daily update: $e');
      rethrow;
    }
  }

  // Get daily updates for a salik
  Stream<List<Map<String, dynamic>>> getDailyUpdates(
    String salikId, {
    int limit = 30,
  }) {
    return _firestore
        .collection('dailyUpdates')
        .where('salikId', isEqualTo: salikId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // Get assigned salikeen for a murabi
  Stream<List<Map<String, dynamic>>> getAssignedSalikeen(String murabiId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'salik')
        .where('assignedMurabi', isEqualTo: murabiId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // Approve level progression
  Future<void> approveLevelProgression(String salikId, int newLevel) async {
    try {
      await _firestore.collection('users').doc(salikId).update({
        'level': newLevel,
        'currentDay': 1,
        'levelStartDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error approving level progression: $e');
      rethrow;
    }
  }

  // Get user progress stats
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) return {};

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Get count of daily updates
      QuerySnapshot updates = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: uid)
          .get();

      return {
        'name': userData['name'],
        'level': userData['level'],
        'currentDay': userData['currentDay'],
        'totalUpdatesSubmitted': updates.docs.length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Submit individual task
  Future<void> submitIndividualTask({
    required String salikId,
    required String taskId,
    required String taskName,
    required bool completed,
    required int count,
    required String date, // YYYY-MM-DD format
  }) async {
    try {
      final docRef = _firestore
          .collection('taskSubmissions')
          .doc(salikId)
          .collection('submissions')
          .doc('${date}_${taskId}');

      await docRef.set({
        'salikId': salikId,
        'taskId': taskId,
        'taskName': taskName,
        'completed': completed,
        'count': count,
        'date': date,
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting task: $e');
      rethrow;
    }
  }

  // Get today's task submissions for a salik
  Future<Map<String, dynamic>> getTodaySubmissions(String salikId, String date) async {
    try {
      QuerySnapshot snapshots = await _firestore
          .collection('taskSubmissions')
          .doc(salikId)
          .collection('submissions')
          .where('date', isEqualTo: date)
          .get();

      Map<String, dynamic> submissions = {};
      for (var doc in snapshots.docs) {
        submissions[doc['taskId']] = doc.data();
      }
      return submissions;
    } catch (e) {
      print('Error getting today submissions: $e');
      return {};
    }
  }

  // Get Murabi details for Salik
  Future<Map<String, dynamic>?> getMurabiDetails(String murabiId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(murabiId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting Murabi details: $e');
      return null;
    }
  }

  // Get level details
  Future<Map<String, dynamic>?> getLevelDetails(int levelNumber) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('levels')
          .where('levelNumber', isEqualTo: levelNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {...snapshot.docs.first.data() as Map<String, dynamic>, 'id': snapshot.docs.first.id};
      }
      return null;
    } catch (e) {
      print('Error getting level details: $e');
      return null;
    }
  }

  // Get recent daily updates for Murabi's assigned Salikeens
  Stream<List<Map<String, dynamic>>> getRecentUpdatesForMurabi(
    String murabiId, {int limit = 50}) {
    return _firestore
        .collection('dailyUpdates')
        .where('murabiId', isEqualTo: murabiId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
              .toList(),
        );
  }

  // Check if daily update already exists for today
  Future<bool> hasDailyUpdateForToday(String salikId) async {
    try {
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .where('date', isEqualTo: todayString)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking daily update: $e');
      return false;
    }
  }

  // Get update history for analytics
  Stream<List<Map<String, dynamic>>> getUpdateHistory(
    String salikId, {
    int daysBack = 30,
  }) {
    final startDate = DateTime.now().subtract(Duration(days: daysBack));

    return _firestore
        .collection('dailyUpdates')
        .where('salikId', isEqualTo: salikId)
        .where('date', isGreaterThan: startDate)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
              .toList(),
        );
  }

  // Get completion percentage for a Salik in a period
  Future<double> getCompletionPercentage(
    String salikId, {
    int daysBack = 7,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: daysBack));

      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .where('date', isGreaterThan: startDate)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      // Count completed tasks
      int completedCount = 0;
      int totalCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final tasksCompleted = data['tasksCompleted'] as Map<String, dynamic>?;
        if (tasksCompleted != null) {
          totalCount += tasksCompleted.length;
          completedCount +=
              tasksCompleted.values.where((v) => v == true).length;
        }
      }

      if (totalCount == 0) return 0.0;
      return (completedCount / totalCount) * 100;
    } catch (e) {
      print('Error calculating completion percentage: $e');
      return 0.0;
    }
  }

  // Get current streak
  Future<int> getCurrentStreak(String salikId) async {
    try {
      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp?;
        if (timestamp == null) continue;

        final updateDate = timestamp.toDate();
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final updateDateStart =
            DateTime(updateDate.year, updateDate.month, updateDate.day);

        if (lastDate == null) {
          // First iteration
          if (updateDateStart == todayStart ||
              updateDateStart ==
                  todayStart.subtract(Duration(days: 1))) {
            streak = 1;
            lastDate = updateDateStart;
          } else {
            break;
          }
        } else {
          // Check if previous day
          if (updateDateStart ==
              lastDate.subtract(Duration(days: 1))) {
            streak++;
            lastDate = updateDateStart;
          } else {
            break;
          }
        }
      }

      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }

  // Get performance comparison for Murabi's Salikeens
  Future<List<Map<String, dynamic>>> getSalikPerformanceComparison(
    String murabiId, {
    int daysBack = 7,
  }) async {
    try {
      // Get all Salikeens assigned to this Murabi
      final salikSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'salik')
          .where('assignedMurabi', isEqualTo: murabiId)
          .get();

      List<Map<String, dynamic>> performance = [];

      for (var salikDoc in salikSnapshot.docs) {
        final salikData = salikDoc.data() as Map<String, dynamic>;
        final salikId = salikDoc.id;

        // Calculate completion percentage
        final percentage =
            await getCompletionPercentage(salikId, daysBack: daysBack);
        final streak = await getCurrentStreak(salikId);

        performance.add({
          'salikId': salikId,
          'salikName': salikData['name'],
          'level': salikData['level'] ?? 1,
          'currentDay': salikData['currentDay'] ?? 1,
          'completionPercentage': percentage,
          'streak': streak,
        });
      }

      // Sort by completion percentage
      performance.sort((a, b) =>
          (b['completionPercentage'] as num)
              .compareTo(a['completionPercentage'] as num));

      return performance;
    } catch (e) {
      print('Error getting performance comparison: $e');
      return [];
    }
  }
}
