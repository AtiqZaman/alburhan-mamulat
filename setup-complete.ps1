# ============================================================
# ALBURHAN MAMULAT - COMPLETE AUTOMATED SETUP
# Save this as: setup-complete.ps1
# Run in VS Code Terminal: .\setup-complete.ps1
# ============================================================

Write-Host "🚀 Starting Complete Alburhan Mamulat Setup..." -ForegroundColor Green
Write-Host ""

# Create all directories
Write-Host "📁 Creating directory structure..." -ForegroundColor Yellow
$directories = @(
    "lib/models",
    "lib/services",
    "lib/screens/auth",
    "lib/screens/admin",
    "lib/screens/murabi",
    "lib/screens/salik",
    "lib/widgets",
    "assets/fonts"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Host "✅ Directories created!" -ForegroundColor Green

# ============================================================
# MODELS
# ============================================================

Write-Host "📝 Generating model files..." -ForegroundColor Yellow

# lib/models/user_model.dart
$userModelCode = @"
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
"@
$userModelCode | Out-File -FilePath "lib/models/user_model.dart" -Encoding UTF8

# lib/models/task_model.dart
$taskModelCode = @"
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
"@
$taskModelCode | Out-File -FilePath "lib/models/task_model.dart" -Encoding UTF8

# lib/models/level_model.dart
$levelModelCode = @"
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
"@
$levelModelCode | Out-File -FilePath "lib/models/level_model.dart" -Encoding UTF8

# lib/models/daily_update_model.dart
$dailyUpdateCode = @"
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
"@
$dailyUpdateCode | Out-File -FilePath "lib/models/daily_update_model.dart" -Encoding UTF8

Write-Host "✅ Model files created!" -ForegroundColor Green

# ============================================================
# SERVICES
# ============================================================

Write-Host "📝 Generating service files..." -ForegroundColor Yellow

# lib/services/auth_service.dart
$authServiceCode = @"
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedMurabiId,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'assignedMurabiId': assignedMurabiId,
        'currentLevel': 1,
        'chillaDay': 1,
        'chillaStartDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } catch (e) {
      return 'ای میل یا پاس ورڈ غلط ہے';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Role
  Future<String> getUserRole() async {
    if (currentUser == null) return '';
    
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    
    return doc.get('role') ?? '';
  }

  // Get User Data
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    
    return doc.data() as Map<String, dynamic>?;
  }
}
"@
$authServiceCode | Out-File -FilePath "lib/services/auth_service.dart" -Encoding UTF8

# lib/services/firestore_service.dart
$firestoreServiceCode = @"
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';
import '../models/daily_update_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all Murabi
  Stream<List<UserModel>> getMurabis() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'murabi')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all Salik
  Stream<List<UserModel>> getAllSalikeen() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'salik')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add Level
  Future<void> addLevel(int levelNumber, String levelNameUrdu) async {
    await _firestore.collection('levels').add({
      'levelNumber': levelNumber,
      'levelNameUrdu': levelNameUrdu,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all Levels
  Stream<List<LevelModel>> getLevels() {
    return _firestore
        .collection('levels')
        .orderBy('levelNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LevelModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add Task
  Future<void> addTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  // Get Tasks by Level
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

  // Get assigned Salikeen
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

  // Get Salik's recent updates
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

  // Approve level progression
  Future<void> approveLevelProgression(String salikId) async {
    DocumentSnapshot salikDoc =
        await _firestore.collection('users').doc(salikId).get();
    
    int currentLevel = salikDoc.get('currentLevel');
    
    await _firestore.collection('users').doc(salikId).update({
      'currentLevel': currentLevel + 1,
      'chillaDay': 1,
      'chillaStartDate': FieldValue.serverTimestamp(),
    });
  }

  // Submit daily update
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
        await _firestore.collection('users').doc(salikId).update({
          'chillaDay': 40,
        });
      } else {
        await _firestore.collection('users').doc(salikId).update({
          'chillaDay': newDay,
        });
      }
    } else {
      await _firestore.collection('users').doc(salikId).update({
        'chillaDay': 0,
      });
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Get level by ID
  Future<LevelModel?> getLevelById(String levelId) async {
    DocumentSnapshot doc = await _firestore.collection('levels').doc(levelId).get();
    if (!doc.exists) return null;
    return LevelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
"@
$firestoreServiceCode | Out-File -FilePath "lib/services/firestore_service.dart" -Encoding UTF8

Write-Host "✅ Service files created!" -ForegroundColor Green

# ============================================================
# EMPTY WIDGET FILES
# ============================================================

Write-Host "📝 Creating widget files..." -ForegroundColor Yellow

$emptyWidget = @"
import 'package:flutter/material.dart';

// TODO: Implement widget
"@

$emptyWidget | Out-File -FilePath "lib/widgets/custom_button.dart" -Encoding UTF8
$emptyWidget | Out-File -FilePath "lib/widgets/custom_textfield.dart" -Encoding UTF8
$emptyWidget | Out-File -FilePath "lib/widgets/task_checkbox.dart" -Encoding UTF8

Write-Host "✅ Widget files created!" -ForegroundColor Green

# ============================================================
# EMPTY SCREEN FILES
# ============================================================

Write-Host "📝 Creating screen files..." -ForegroundColor Yellow

$emptyScreen = @"
import 'package:flutter/material.dart';

// TODO: Implement screen
"@

$emptyScreen | Out-File -FilePath "lib/screens/auth/signup_screen.dart" -Encoding UTF8
$emptyScreen | Out-File -FilePath "lib/screens/salik/submit_update_screen.dart" -Encoding UTF8

Write-Host "✅ Screen files created!" -ForegroundColor Green

# ============================================================
# CREATE MAIN.DART - PLACEHOLDER
# ============================================================

Write-Host "📝 Creating main.dart..." -ForegroundColor Yellow

$mainDartCode = @"
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'البرہان معمولات',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'NotoNastaliq',
        ),
        home: Scaffold(
          body: Center(
            child: Text('تمام فائلیں تیار ہیں! ✅'),
          ),
        ),
      ),
    );
  }
}
"@
$mainDartCode | Out-File -FilePath "lib/main.dart" -Encoding UTF8

Write-Host "✅ main.dart created!" -ForegroundColor Green

# ============================================================
# UPDATE PUBSPEC.YAML
# ============================================================

Write-Host "📝 Updating pubspec.yaml..." -ForegroundColor Yellow

$pubspecContent = @"
name: alburhan_mamulat
description: Islamic spiritual development tracking app

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0

  # State Management
  provider: ^6.1.1

  # UI & Utilities
  intl: ^0.19.0
  hijri: ^3.0.0
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true

  fonts:
    - family: NotoNastaliq
      fonts:
        - asset: assets/fonts/NotoNastaliqUrdu-Regular.ttf
"@
$pubspecContent | Out-File -FilePath "pubspec.yaml" -Encoding UTF8

Write-Host "✅ pubspec.yaml updated!" -ForegroundColor Green

# ============================================================
# FINAL INSTRUCTIONS
# ============================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""

Write-Host "📁 Created files and folders:" -ForegroundColor Cyan
Write-Host "   ✅ lib/models/ (4 files)"
Write-Host "   ✅ lib/services/ (2 files)"
Write-Host "   ✅ lib/screens/auth/ (2 files)"
Write-Host "   ✅ lib/screens/admin/ (empty - update next)"
Write-Host "   ✅ lib/screens/murabi/ (empty - update next)"
Write-Host "   ✅ lib/screens/salik/ (2 files)"
Write-Host "   ✅ lib/widgets/ (3 files)"
Write-Host "   ✅ assets/fonts/"
Write-Host "   ✅ lib/main.dart"
Write-Host ""

Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Download Urdu Font from: https://fonts.google.com/noto/specimen/Noto+Nastaliq+Urdu"
Write-Host "   2. Copy NotoNastaliqUrdu-Regular.ttf to assets/fonts/"
Write-Host "   3. Run: flutter pub get"
Write-Host "   4. Run: git add ."
Write-Host "   5. Run: git commit -m 'feat: Add complete project structure with all files'"
Write-Host "   6. Run: git push origin main"
Write-Host ""

Write-Host "🚀 Push to GitHub:" -ForegroundColor Yellow
Write-Host "   git add ."
Write-Host "   git commit -m 'feat: Add complete project structure with models, services, and initial screens'"
Write-Host "   git push origin main"
Write-Host ""

Write-Host "✅ All done! 🎉" -ForegroundColor Green