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
}
