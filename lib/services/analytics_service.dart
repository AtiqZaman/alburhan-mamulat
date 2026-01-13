import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Salik's daily completion rate for past N days
  Future<List<Map<String, dynamic>>> getDailyCompletionRate(
    String salikId,
    int days,
  ) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .where('submittedAt', isGreaterThanOrEqualTo: startDate)
          .orderBy('submittedAt', descending: false)
          .get();

      List<Map<String, dynamic>> data = [];

      for (var doc in snapshot.docs) {
        final tasksCompleted = doc['tasksCompleted'] as Map?;
        final totalTasks = tasksCompleted?.length ?? 0;
        final completed = tasksCompleted?.values.where((v) => v == true).length ?? 0;
        final rate = totalTasks > 0 ? (completed / totalTasks * 100).toStringAsFixed(0) : '0';

        data.add({
          'date': (doc['submittedAt'] as Timestamp).toDate(),
          'rate': int.parse(rate),
          'completed': completed,
          'total': totalTasks,
        });
      }

      return data;
    } catch (e) {
      print('Error getting daily completion rate: $e');
      return [];
    }
  }

  /// Get weekly statistics
  Future<Map<String, dynamic>> getWeeklyStats(String salikId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .where('submittedAt', isGreaterThanOrEqualTo: sevenDaysAgo)
          .get();

      int totalTasks = 0;
      int completedTasks = 0;
      int daysActive = 0;

      for (var doc in snapshot.docs) {
        final tasksCompleted = doc['tasksCompleted'] as Map?;
        if (tasksCompleted != null && tasksCompleted.isNotEmpty) {
          totalTasks += tasksCompleted.length;
          completedTasks +=
              tasksCompleted.values.where((v) => v == true).length;
          daysActive++;
        }
      }

      final completionRate =
          totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;

      return {
        'daysActive': daysActive,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'completionRate': completionRate,
        'averagePerDay': daysActive > 0 ? (completedTasks / daysActive).toInt() : 0,
      };
    } catch (e) {
      print('Error getting weekly stats: $e');
      return {};
    }
  }

  /// Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStats(String salikId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .where('submittedAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      int totalTasks = 0;
      int completedTasks = 0;
      int daysActive = 0;
      Map<int, int> dailyStreak = {}; // day -> streak count

      for (var doc in snapshot.docs) {
        final tasksCompleted = doc['tasksCompleted'] as Map?;
        if (tasksCompleted != null && tasksCompleted.isNotEmpty) {
          totalTasks += tasksCompleted.length;
          final completed =
              tasksCompleted.values.where((v) => v == true).length;
          completedTasks += completed;

          if (completed > 0) {
            daysActive++;
          }
        }
      }

      final completionRate =
          totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;

      return {
        'daysActive': daysActive,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'completionRate': completionRate,
        'averagePerDay': daysActive > 0 ? (completedTasks / daysActive).toInt() : 0,
      };
    } catch (e) {
      print('Error getting monthly stats: $e');
      return {};
    }
  }

  /// Get overall statistics
  Future<Map<String, dynamic>> getOverallStats(String salikId) async {
    try {
      final snapshot = await _firestore
          .collection('dailyUpdates')
          .where('salikId', isEqualTo: salikId)
          .get();

      int totalSubmissions = snapshot.docs.length;
      int totalTasks = 0;
      int completedTasks = 0;

      for (var doc in snapshot.docs) {
        final tasksCompleted = doc['tasksCompleted'] as Map?;
        if (tasksCompleted != null) {
          totalTasks += tasksCompleted.length;
          completedTasks +=
              tasksCompleted.values.where((v) => v == true).length;
        }
      }

      final overallRate =
          totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;

      return {
        'totalSubmissions': totalSubmissions,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'overallRate': overallRate,
      };
    } catch (e) {
      print('Error getting overall stats: $e');
      return {};
    }
  }

  /// Get task completion breakdown (by task type)
  Future<List<Map<String, dynamic>>> getTaskBreakdown(String salikId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

      final snapshot = await _firestore
          .collection('taskSubmissions')
          .doc(salikId)
          .collection('submissions')
          .where('date',
              isGreaterThanOrEqualTo: _formatDate(thirtyDaysAgo))
          .get();

      Map<String, int> taskStats = {}; // taskName -> completed count

      for (var doc in snapshot.docs) {
        final taskName = doc['taskName'] as String?;
        final completed = doc['completed'] as bool? ?? false;

        if (taskName != null && completed) {
          taskStats[taskName] = (taskStats[taskName] ?? 0) + 1;
        }
      }

      List<Map<String, dynamic>> breakdown = taskStats.entries
          .map((e) => {'taskName': e.key, 'completedCount': e.value})
          .toList();

      // Sort by completed count descending
      breakdown.sort((a, b) => b['completedCount'].compareTo(a['completedCount']));

      return breakdown;
    } catch (e) {
      print('Error getting task breakdown: $e');
      return [];
    }
  }

  /// Get streaks (consecutive days with submissions)
  Future<int> getCurrentStreak(String salikId) async {
    try {
      int streak = 0;
      DateTime checkDate = DateTime.now();

      for (int i = 0; i < 365; i++) {
        final dateStr = _formatDate(checkDate);

        final snapshot = await _firestore
            .collection('taskSubmissions')
            .doc(salikId)
            .collection('submissions')
            .where('date', isEqualTo: dateStr)
            .get();

        if (snapshot.docs.isEmpty) {
          break;
        }

        streak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      }

      return streak;
    } catch (e) {
      print('Error getting current streak: $e');
      return 0;
    }
  }

  /// Get Murabi's assigned Salikeens stats
  Future<List<Map<String, dynamic>>> getMurabiSalikeenStats(
    String murabiId,
  ) async {
    try {
      // Get all Salikeens assigned to Murabi
      final salikSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'salik')
          .where('assignedMurabiId', isEqualTo: murabiId)
          .get();

      List<Map<String, dynamic>> stats = [];

      for (var doc in salikSnapshot.docs) {
        final salikData = doc.data();
        final salikId = doc.id;
        final salikName = salikData['name'] as String?;
        final currentLevel = salikData['level'] ?? 1;

        // Get weekly stats for this Salik
        final weeklyStats = await getWeeklyStats(salikId);

        stats.add({
          'salikId': salikId,
          'salikName': salikName,
          'currentLevel': currentLevel,
          'completionRate': weeklyStats['completionRate'] ?? 0,
          'daysActive': weeklyStats['daysActive'] ?? 0,
        });
      }

      // Sort by completion rate descending
      stats.sort((a, b) => b['completionRate'].compareTo(a['completionRate']));

      return stats;
    } catch (e) {
      print('Error getting Murabi stats: $e');
      return [];
    }
  }

  /// Helper function to format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get comparative analysis (multiple Salikeens)
  Future<List<Map<String, dynamic>>> getComparativeAnalysis(
    List<String> salikIds,
  ) async {
    try {
      List<Map<String, dynamic>> comparison = [];

      for (var salikId in salikIds) {
        final overallStats = await getOverallStats(salikId);
        final userData = await _firestore.collection('users').doc(salikId).get();
        
        if (userData.exists) {
          final data = userData.data() as Map<String, dynamic>;
          comparison.add({
            'salikId': salikId,
            'salikName': data['name'],
            'level': data['level'],
            'overallRate': overallStats['overallRate'] ?? 0,
            'totalSubmissions': overallStats['totalSubmissions'] ?? 0,
          });
        }
      }

      // Sort by overall rate descending
      comparison.sort((a, b) => b['overallRate'].compareTo(a['overallRate']));

      return comparison;
    } catch (e) {
      print('Error getting comparative analysis: $e');
      return [];
    }
  }

  /// Get badges/achievements
  Future<List<String>> getBadges(String salikId) async {
    try {
      List<String> badges = [];

      // Get current streak
      final streak = await getCurrentStreak(salikId);
      if (streak >= 7) badges.add('🔥 ہفتہ وار سلسلہ (7 دن)');
      if (streak >= 30) badges.add('🏆 ماہانہ سلسلہ (30 دن)');

      // Get overall stats
      final overallStats = await getOverallStats(salikId);
      final rate = overallStats['overallRate'] as int? ?? 0;
      if (rate >= 90) badges.add('⭐ شاندار (90% سے اوپر)');
      if (rate >= 100) badges.add('💎 کامل (100%)');

      // Get level
      final userData = await _firestore.collection('users').doc(salikId).get();
      if (userData.exists) {
        final level = (userData.data() as Map)['level'] ?? 1;
        if (level >= 5) badges.add('🎯 ماہر (Level 5)');
      }

      return badges;
    } catch (e) {
      print('Error getting badges: $e');
      return [];
    }
  }
}
