import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'submit_update_screen.dart';

class SalikDashboard extends StatefulWidget {
  @override
  _SalikDashboardState createState() => _SalikDashboardState();
}

class _SalikDashboardState extends State<SalikDashboard> {
  late AuthService authService;
  late FirestoreService firestoreService;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? murabiData;
  Map<String, dynamic>? levelData;
  List<Map<String, dynamic>> tasks = [];
  Map<String, dynamic> todaySubmissions = {};
  bool _isLoading = true;
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    firestoreService = Provider.of<FirestoreService>(context, listen: false);
    _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // Get current user data
      final user = await firestoreService.getUser(authService.currentUser!.uid);
      
      if (user == null) {
        print('User not found');
        return;
      }

      setState(() => userData = user);

      // Get Murabi details
      if (user['assignedMurabiId'] != null && user['assignedMurabiId'].toString().isNotEmpty) {
        final murabi = await firestoreService.getMurabiDetails(user['assignedMurabiId']);
        if (mounted) {
          setState(() => murabiData = murabi);
        }
      }

      // Get Level details
      final currentLevel = user['level'] ?? 1;
      final level = await firestoreService.getLevelDetails(currentLevel);
      if (mounted) {
        setState(() => levelData = level);
      }

      // Get tasks for current level
      final levelId = currentLevel.toString();
      final tasksSnapshot = firestoreService.getTasksByLevel(levelId);
      tasksSnapshot.listen((taskList) {
        if (mounted) {
          setState(() => tasks = taskList);
        }
      });

      // Get today's submissions
      final submissions = await firestoreService.getTodaySubmissions(
        authService.currentUser!.uid,
        _todayDate,
      );
      
      if (mounted) {
        setState(() => todaySubmissions = submissions);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitTask({
    required String taskId,
    required String taskName,
    required bool completed,
    required int count,
  }) async {
    try {
      await firestoreService.submitIndividualTask(
        salikId: authService.currentUser!.uid,
        taskId: taskId,
        taskName: taskName,
        completed: completed,
        count: count,
        date: _todayDate,
      );

      if (mounted) {
        setState(() {
          todaySubmissions[taskId] = {
            'taskId': taskId,
            'taskName': taskName,
            'completed': completed,
            'count': count,
            'date': _todayDate,
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تجمع کیا گیا'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error submitting task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خرابی'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || userData == null) {
      return _buildLoadingScreen();
    }

    final currentDay = userData!['currentDay'] ?? 1;
    final currentLevel = userData!['level'] ?? 1;
    final murabiName = murabiData?['name'] ?? 'غیر مختص';
    final levelName = levelData?['levelName'] ?? 'سطح $currentLevel';
    final levelDays = levelData?['daysRequired'] ?? 40;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A5C),
              Color(0xFF2D5A8C),
              Color(0xFF3D6B9E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Header with Logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await authService.signOut();
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'لاگ آؤٹ',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoNastaliq',
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'سالک ڈیش بورڈ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // User Info Card
                  _buildGlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          userData!['name'] ?? 'صارف',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow('مرشد', murabiName),
                        SizedBox(height: 12),
                        _buildInfoRow('سطح', levelName),
                        SizedBox(height: 12),
                        _buildInfoRow('ای میل', userData!['email'] ?? ''),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Level Progress Card
                  _buildGlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'روز مرہ کی ترقی',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                        SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (currentDay / levelDays).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$levelDays دن',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                            Text(
                              'دن $currentDay / $levelDays',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Tasks Section
                  Text(
                    'آج کے کام',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'NotoNastaliq',
                    ),
                  ),

                  SizedBox(height: 12),

                  if (tasks.isEmpty)
                    _buildGlassmorphicCard(
                      child: Text(
                        'کوئی کام دستیاب نہیں',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                    )
                  else
                    ...tasks.map((task) => _buildTaskCard(task)).toList(),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A5C),
              Color(0xFF2D5A8C),
              Color(0xFF3D6B9E),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'براہ کرم انتظار کریں...',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'NotoNastaliq',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'NotoNastaliq',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontFamily: 'NotoNastaliq',
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final taskId = task['id'] ?? task['taskId'] ?? '';
    final taskName = task['taskName'] ?? 'نام دستیاب نہیں';
    final description = task['description'] ?? '';
    final isCountable = task['isCountable'] ?? false;
    final maxCount = task['maxCount'] ?? 1;

    final submission = todaySubmissions[taskId];
    final isCompleted = submission?['completed'] ?? false;
    final count = submission?['count'] ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: _buildGlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.6),
                      ),
                    ),
                    child: Text(
                      '✓ جمع',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                  ),
                Text(
                  taskName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'NotoNastaliq',
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: 'NotoNastaliq',
                    fontSize: 13,
                  ),
                ),
              ),
            SizedBox(height: 16),
            if (isCountable)
              _buildCountableTaskUI(
                taskId: taskId,
                taskName: taskName,
                maxCount: maxCount,
                currentCount: count,
              )
            else
              _buildCheckableTaskUI(
                taskId: taskId,
                taskName: taskName,
                isCompleted: isCompleted,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckableTaskUI({
    required String taskId,
    required String taskName,
    required bool isCompleted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            _submitTask(
              taskId: taskId,
              taskName: taskName,
              completed: !isCompleted,
              count: 0,
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: isCompleted
                    ? Colors.green.withOpacity(0.6)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.check_box_outline_blank,
              color: isCompleted ? Colors.green.shade300 : Colors.white,
              size: 28,
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
          isCompleted ? 'مکمل' : 'مکمل کریں',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'NotoNastaliq',
          ),
        ),
      ],
    );
  }

  Widget _buildCountableTaskUI({
    required String taskId,
    required String taskName,
    required int maxCount,
    required int currentCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'تعداد: $currentCount / $maxCount',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'NotoNastaliq',
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                _submitTask(
                  taskId: taskId,
                  taskName: taskName,
                  completed: currentCount > 0,
                  count: currentCount,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF10B981).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF10B981).withOpacity(0.6),
                  ),
                ),
                child: Text(
                  'جمع کریں',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoNastaliq',
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (currentCount < maxCount) {
                  _submitTask(
                    taskId: taskId,
                    taskName: taskName,
                    completed: true,
                    count: currentCount + 1,
                  );
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8B5CF6).withOpacity(0.3),
                  border: Border.all(
                    color: Color(0xFF8B5CF6).withOpacity(0.6),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (currentCount > 0) {
                  _submitTask(
                    taskId: taskId,
                    taskName: taskName,
                    completed: currentCount - 1 > 0,
                    count: currentCount - 1,
                  );
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  color: Colors.red.shade300,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          padding: EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
