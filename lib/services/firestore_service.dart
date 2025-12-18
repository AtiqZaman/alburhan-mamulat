// ============================================================
// FILE: lib/services/firestore_service.dart
// COPY THIS CODE INTO: lib/services/firestore_service.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';
import '../models/daily_update_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getMurabis() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'murabi')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<UserModel>> getAllSalikeen() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'salik')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addLevel(int levelNumber, String levelNameUrdu) async {
    await _firestore.collection('levels').add({
      'levelNumber': levelNumber,
      'levelNameUrdu': levelNameUrdu,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<LevelModel>> getLevels() {
    return _firestore
        .collection('levels')
        .orderBy('levelNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LevelModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  Stream<List<TaskModel>> getTasksByLevel(String levelId) {
    return _firestore
        .collection('tasks')
        .where('levelId', isEqualTo: levelId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<UserModel>> getAssignedSalikeen(String murabiId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'salik')
        .where('assignedMurabiId', isEqualTo: murabiId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<DailyUpdateModel>> getSalikUpdates(String salikId, int limit) {
    return _firestore
        .collection('dailyUpdates')
        .where('salikId', isEqualTo: salikId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyUpdateModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> approveLevelProgression(String salikId) async {
    DocumentSnapshot salikDoc = await _firestore.collection('users').doc(salikId).get();
    int currentLevel = salikDoc.get('currentLevel');
    
    await _firestore.collection('users').doc(salikId).update({
      'currentLevel': currentLevel + 1,
      'chillaDay': 1,
      'chillaStartDate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitDailyUpdate(
    String salikId,
    String levelId,
    int chillaDay,
    Map<String, TaskStatus> taskStatuses,
  ) async {
    bool allCompleted = taskStatuses.values.every((status) => status.completed);

    await _firestore.collection('dailyUpdates').add({
      'salikId': salikId,
      'date': DateTime.now(),
      'chillaDay': chillaDay,
      'levelId': levelId,
      'taskStatuses': taskStatuses.map(
        (key, value) => MapEntry(key, {
          'completed': value.completed,
          'count': value.count,
        }),
      ),
      'submittedAt': FieldValue.serverTimestamp(),
    });

    if (allCompleted) {
      int newDay = chillaDay + 1;
      if (newDay > 40) {
        await _firestore.collection('users').doc(salikId).update({'chillaDay': 40});
      } else {
        await _firestore.collection('users').doc(salikId).update({'chillaDay': newDay});
      }
    } else {
      await _firestore.collection('users').doc(salikId).update({'chillaDay': 0});
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<LevelModel?> getLevelById(String levelId) async {
    DocumentSnapshot doc = await _firestore.collection('levels').doc(levelId).get();
    if (!doc.exists) return null;
    return LevelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}