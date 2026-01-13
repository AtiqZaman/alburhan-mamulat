import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class SubmitUpdateScreen extends StatefulWidget {
  @override
  _SubmitUpdateScreenState createState() => _SubmitUpdateScreenState();
}

class _SubmitUpdateScreenState extends State<SubmitUpdateScreen> {
  late AuthService authService;
  late FirestoreService firestoreService;
  
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> tasks = [];
  Map<String, dynamic> taskSubmissions = {}; // taskId -> {completed, count}
  TextEditingController notesController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
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

      // Get current user
      final user = await firestoreService.getUser(authService.currentUser!.uid);
      if (user == null) return;

      setState(() => userData = user);

      // Get level details first
      final currentLevel = user['level'] ?? 1;
      final level = await firestoreService.getLevelDetails(currentLevel);
      
      // Get tasks for current level using level ID
      if (level != null && level['id'] != null) {
        final levelId = level['id'];
        final tasks_stream = firestoreService.getTasksByLevel(levelId);
        
        tasks_stream.listen((taskList) {
          if (mounted) {
            setState(() => tasks = taskList);
          }
        });
      } else {
        print('Level not found');
        if (mounted) {
          setState(() => tasks = []);
        }
      }
      // Get today's existing submissions
      final submissions = await firestoreService.getTodaySubmissions(
        authService.currentUser!.uid,
        _todayDate,
      );
      
      // Initialize taskSubmissions from existing data
      for (var task in tasks) {
        final taskId = task['id'] ?? '';
        if (submissions.containsKey(taskId)) {
          taskSubmissions[taskId] = submissions[taskId];
        } else {
          taskSubmissions[taskId] = {
            'completed': false,
            'count': 0,
          };
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitAllTasks() async {
    try {
      setState(() => _isSubmitting = true);

      // Create a map of completed tasks
      Map<String, bool> completedTasks = {};
      for (var taskId in taskSubmissions.keys) {
        completedTasks[taskId] = taskSubmissions[taskId]['completed'] ?? false;
      }

      // Submit daily update
      await firestoreService.submitDailyUpdate(
        salikId: authService.currentUser!.uid,
        salikName: userData!['name'] ?? 'نام نہیں',
        currentLevel: userData!['level'] ?? 1,
        currentDay: userData!['currentDay'] ?? 1,
        tasksCompleted: completedTasks,
        notes: notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('معمول کامیابی سے جمع ہو گیا!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );

        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      print('Error submitting update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خرابی: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
    int completedCount = taskSubmissions.values
        .where((task) => task['completed'] == true)
        .length;

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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'واپس',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'NotoNastaliq',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'آج کا معمول جمع کریں',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Progress Card
                  _buildGlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$completedCount / ${tasks.length}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              'مکمل کام',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: tasks.isEmpty ? 0 : (completedCount / tasks.length),
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Tasks List
                  Text(
                    'معمول کی تفصیل',
                    style: TextStyle(
                      fontSize: 16,
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
                    ...tasks.map((task) => _buildTaskCheckItem(task)).toList(),

                  SizedBox(height: 24),

                  // Notes Section
                  Text(
                    'اضافی نوٹس (اختیاری)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'NotoNastaliq',
                    ),
                  ),

                  SizedBox(height: 12),

                  _buildGlassmorphicCard(
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: TextField(
                        controller: notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'کچھ لکھیں...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'NotoNastaliq',
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAllTasks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'معمول جمع کریں',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCheckItem(Map<String, dynamic> task) {
    final taskId = task['id'] ?? task['taskId'] ?? '';
    final taskName = task['taskName'] ?? 'نام نہیں';
    final description = task['description'] ?? '';
    final isCountable = task['isCountable'] ?? false;
    final maxCount = task['maxCount'] ?? 1;

    final submission = taskSubmissions[taskId] ?? {};
    final isCompleted = submission['completed'] ?? false;
    final count = submission['count'] ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: _buildGlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Task Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isCountable)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        taskSubmissions[taskId] = {
                          'completed': !isCompleted,
                          'count': 0,
                        };
                      });
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                    if (description.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Countable Task UI
            if (isCountable) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Plus Button
                  GestureDetector(
                    onTap: () {
                      if (count < maxCount) {
                        setState(() {
                          taskSubmissions[taskId] = {
                            'completed': true,
                            'count': count + 1,
                          };
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
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
                        size: 20,
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Count Display
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '$count / $maxCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Minus Button
                  GestureDetector(
                    onTap: () {
                      if (count > 0) {
                        setState(() {
                          taskSubmissions[taskId] = {
                            'completed': count - 1 > 0,
                            'count': count - 1,
                          };
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
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
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          padding: EdgeInsets.all(16),
          child: child,
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

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}
