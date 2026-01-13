import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class SalikDailyUpdateScreen extends StatefulWidget {
  @override
  _SalikDailyUpdateScreenState createState() => _SalikDailyUpdateScreenState();
}

class _SalikDailyUpdateScreenState extends State<SalikDailyUpdateScreen> {
  Map<String, bool> _completedTasks = {};
  Map<String, int> _taskCounts = {};
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _tasks = [];
  int _currentLevel = 1;
  int _currentDay = 1;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getUserData();
    
    setState(() {
      _currentLevel = userData?['currentLevel'] ?? 1;
      _currentDay = userData?['chillaDay'] ?? 1;
      _userName = userData?['name'] ?? 'User';
    });
  }

  Future<void> _loadTasks() async {
    try {
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('levels')
          .where('levelNumber', isEqualTo: _currentLevel)
          .get();
      
      if (tasksSnapshot.docs.isNotEmpty) {
        final levelId = tasksSnapshot.docs.first.id;
        final taskSnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('levelId', isEqualTo: levelId)
            .orderBy('order')
            .get();
        
        setState(() {
          _tasks = taskSnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    'name': doc['taskName'],
                    'isCountable': doc['isCountable'] ?? false,
                    'maxCount': doc['maxCount'] ?? 1,
                    'description': doc['description'] ?? '',
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  Future<void> _submitUpdate() async {
    if (_completedTasks.isEmpty) {
      _showSnackBar('Please complete at least one task');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = FirestoreService();
      final userId = authService.currentUser?.uid ?? '';

      await firestoreService.submitDailyUpdate(
        salikId: userId,
        salikName: _userName,
        currentLevel: _currentLevel,
        currentDay: _currentDay,
        tasksCompleted: _completedTasks,
        notes: _notesController.text,
      );

      _showSnackBar('Update submitted successfully!');
      
      setState(() {
        _completedTasks.clear();
        _taskCounts.clear();
        _notesController.clear();
      });
    } catch (e) {
      _showSnackBar('Error submitting update: $e');
    }

    setState(() => _isSubmitting = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int progressPercentage = (_currentDay / 40 * 100).toInt();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1A3A5C),
              Color(0xFF2D5A8C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Update',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Day $_currentDay of Level $_currentLevel',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _buildProgressCard(progressPercentage),
                ),

                SizedBox(height: 24),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Complete your tasks:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _tasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks for this level',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(
                            _tasks.length,
                            (index) => Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: _buildTaskCard(_tasks[index]),
                            ),
                          ),
                        ),
                ),

                SizedBox(height: 24),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Notes:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: TextField(
                              controller: _notesController,
                              style: TextStyle(color: Colors.white),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Add any notes about your day...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10B981).withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSubmitting ? null : _submitUpdate,
                          borderRadius: BorderRadius.circular(16),
                          child: _isSubmitting
                              ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Submit Daily Update',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.check_circle, color: Colors.white),
                                  ],
                                ),
                        ),
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
    );
  }

  Widget _buildProgressCard(int progressPercentage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981).withOpacity(0.2), Color(0xFF34D399).withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFF10B981).withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $_currentLevel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$_currentDay / 40 Days',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: _currentDay / 40,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                    Text(
                      '$progressPercentage%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    String taskId = task['id'];
    bool isCompleted = _completedTasks[taskId] ?? false;
    int taskCount = _taskCounts[taskId] ?? 0;
    bool isCountable = task['isCountable'] ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? Color(0xFF10B981).withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? Color(0xFF10B981).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isCountable) {
                        _completedTasks[taskId] = !isCompleted;
                        if (!isCompleted) {
                          _taskCounts[taskId] = task['maxCount'];
                        }
                      } else {
                        _completedTasks[taskId] = !isCompleted;
                      }
                    });
                  },
                  customBorder: CircleBorder(),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isCompleted
                            ? [Color(0xFF10B981), Color(0xFF34D399)]
                            : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                      ),
                      border: Border.all(
                        color: isCompleted
                            ? Color(0xFF10B981).withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle_outlined,
                      color: isCompleted ? Colors.white : Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      task['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (isCountable)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: taskCount > 0
                                          ? () {
                                              setState(() {
                                                _taskCounts[taskId] = taskCount - 1;
                                              });
                                            }
                                          : null,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Icon(
                                          Icons.remove,
                                          color: taskCount > 0
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.3),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$taskCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: taskCount < task['maxCount']
                                          ? () {
                                              setState(() {
                                                _taskCounts[taskId] = taskCount + 1;
                                              });
                                            }
                                          : null,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Icon(
                                          Icons.add,
                                          color: taskCount < task['maxCount']
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.3),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${task['maxCount']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
