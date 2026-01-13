import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LevelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get days remaining for current level (40 days)
  Future<int> getDaysRemaining(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 40;

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentDay = userData['currentDay'] ?? 1;

      return (40 - (currentDay - 1)).clamp(0, 40);
    } catch (e) {
      print('Error getting days remaining: $e');
      return 40;
    }
  }

  /// Check if Salik is eligible for level progression (completed 40 days)
  Future<bool> isEligibleForPromotion(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentDay = userData['currentDay'] ?? 1;

      // Eligible if day >= 40
      return currentDay >= 40;
    } catch (e) {
      print('Error checking eligibility: $e');
      return false;
    }
  }

  /// Get level data for a user
  Future<Map<String, dynamic>?> getLevelData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting level data: $e');
      return null;
    }
  }

  /// Request promotion to next level
  Future<bool> requestPromotion(String userId, String salikName) async {
    try {
      final userData = await getLevelData(userId);
      if (userData == null) return false;

      final currentLevel = userData['level'] ?? 1;
      final murabiId = userData['assignedMurabi'] ?? '';

      // Create promotion request
      await _firestore.collection('promotionRequests').add({
        'salikId': userId,
        'salikName': salikName,
        'murabiId': murabiId,
        'currentLevel': currentLevel,
        'requestedLevel': currentLevel + 1,
        'status': 'pending', // pending, approved, rejected
        'requestedAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
      });

      print('Promotion request created for $salikName');
      return true;
    } catch (e) {
      print('Error requesting promotion: $e');
      rethrow;
    }
  }

  /// Get pending promotion requests for a Murabi
  Stream<List<Map<String, dynamic>>> getPendingPromotionRequests(
    String murabiId,
  ) {
    return _firestore
        .collection('promotionRequests')
        .where('murabiId', isEqualTo: murabiId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  /// Approve level progression
  Future<bool> approvePromotion(String promotionRequestId, String salikId) async {
    try {
      // Get the promotion request details
      final requestDoc = await _firestore
          .collection('promotionRequests')
          .doc(promotionRequestId)
          .get();

      if (!requestDoc.exists) return false;

      final requestData = requestDoc.data() as Map<String, dynamic>;
      final newLevel = requestData['requestedLevel'] ?? 2;

      // Update promotion request status
      await _firestore
          .collection('promotionRequests')
          .doc(promotionRequestId)
          .update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Update user's level and reset day counter
      await _firestore.collection('users').doc(salikId).update({
        'level': newLevel,
        'currentDay': 1,
        'levelStartDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Promotion approved for salik: $salikId to level $newLevel');
      return true;
    } catch (e) {
      print('Error approving promotion: $e');
      rethrow;
    }
  }

  /// Reject level progression
  Future<bool> rejectPromotion(String promotionRequestId) async {
    try {
      await _firestore
          .collection('promotionRequests')
          .doc(promotionRequestId)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      print('Promotion rejected for request: $promotionRequestId');
      return true;
    } catch (e) {
      print('Error rejecting promotion: $e');
      rethrow;
    }
  }

  /// Increment day counter (called when daily update is submitted)
  Future<void> incrementDay(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      int currentDay = userData['currentDay'] ?? 1;

      // Increment day if less than 40
      if (currentDay < 40) {
        await _firestore.collection('users').doc(userId).update({
          'currentDay': currentDay + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error incrementing day: $e');
    }
  }

  /// Get all levels
  Future<List<Map<String, dynamic>>> getAllLevels() async {
    try {
      final snapshot = await _firestore
          .collection('levels')
          .orderBy('levelNumber')
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting levels: $e');
      return [];
    }
  }

  /// Get specific level details
  Future<Map<String, dynamic>?> getLevelDetails(int levelNumber) async {
    try {
      final snapshot = await _firestore
          .collection('levels')
          .where('levelNumber', isEqualTo: levelNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id};
      }
      return null;
    } catch (e) {
      print('Error getting level details: $e');
      return null;
    }
  }

  /// Get tasks for a level
  Future<List<Map<String, dynamic>>> getLevelTasks(String levelId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('levelId', isEqualTo: levelId)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting level tasks: $e');
      return [];
    }
  }

  /// Check if today's update already submitted
  Future<bool> isTodayUpdateSubmitted(String salikId) async {
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

  /// Get user's update history
  Future<List<Map<String, dynamic>>> getUserUpdateHistory(
    String salikId, {
    int limit = 30,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting update history: $e');
      return [];
    }
  }

  /// Calculate and update streaks
  Future<void> updateStreak(String salikId) async {
    try {
      final history = await getUserUpdateHistory(salikId, limit: 100);
      if (history.isEmpty) return;

      int streak = 0;
      DateTime lastDate = DateTime.now();

      for (final update in history) {
        // Skip if update timestamp doesn't exist
        if (update['date'] == null) continue;

        final updateTimestamp = update['date'] as Timestamp;
        final updateDate = updateTimestamp.toDate();

        // Check if dates are consecutive (within 1 day)
        final daysDiff =
            lastDate.difference(updateDate).inDays;

        if (daysDiff <= 1) {
          streak++;
          lastDate = updateDate;
        } else {
          break; // Streak broken
        }
      }

      // Update user's streak
      await _firestore.collection('users').doc(salikId).update({
        'currentStreak': streak,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  /// Get user's current streak
  Future<int> getCurrentStreak(String salikId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(salikId).get();
      if (!userDoc.exists) return 0;

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['currentStreak'] ?? 0;
    } catch (e) {
      print('Error getting streak: $e');
      return 0;
    }
  }
}
