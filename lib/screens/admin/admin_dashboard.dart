import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'add_murabi_screen.dart';
import 'add_salik_screen.dart';
import 'assign_murabi_screen.dart';
import 'manage_levels_screen.dart' as levels;
import 'manage_tasks_screen.dart' as tasks;

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السلام علیکم',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                        Text(
                          'ایڈمن',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await authService.signOut();
                          },
                          customBorder: CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Statistics Cards
                StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    int murabiCount = 0;
                    int salikCount = 0;

                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (data['role'] == 'murabi') {
                          murabiCount++;
                        } else if (data['role'] == 'salik') {
                          salikCount++;
                        }
                      }
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'کل مربی',
                            murabiCount.toString(),
                            Color(0xFF8B5CF6),
                            Icons.group,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'کل سالکین',
                            salikCount.toString(),
                            Color(0xFF10B981),
                            Icons.school,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 32),

                // Title
                Text(
                  'نظام کو منیج کریں',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'NotoNastaliq',
                  ),
                ),

                SizedBox(height: 16),

                // Admin Functions Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildAdminCard(
                      'مربی شامل کریں',
                      Icons.person_add,
                      Color(0xFF8B5CF6),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMurabiScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    _buildAdminCard(
                      'سالک شامل کریں',
                      Icons.person_add,
                      Color(0xFF10B981),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddSalikScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    _buildAdminCard(
                      'سالک کو مربی assign کریں',
                      Icons.link,
                      Color(0xFF3B82F6),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignMurabiScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    _buildAdminCard(
                      'لیولز منیج کریں',
                      Icons.layers,
                      Color(0xFF3B82F6),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => levels.ManageLevelsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminCard(
                      'کام منیج کریں',
                      Icons.assignment,
                      Color(0xFFF59E0B),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => tasks.ManageTasksScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Recent Activity Title
                Text(
                  'ہالیہ سرگرمی',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'NotoNastaliq',
                  ),
                ),

                SizedBox(height: 16),

                // Recent Users
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('users')
                      .orderBy('createdAt', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'کوئی صارف نہیں',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildActivityCard(data);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'NotoNastaliq',
                    ),
                  ),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 40),
                  SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NotoNastaliq',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> user) {
    String roleText = '';
    Color roleColor = Colors.grey;

    if (user['role'] == 'murabi') {
      roleText = 'مربی';
      roleColor = Color(0xFF8B5CF6);
    } else if (user['role'] == 'salik') {
      roleText = 'سالک';
      roleColor = Color(0xFF10B981);
    } else if (user['role'] == 'admin') {
      roleText = 'ایڈمن';
      roleColor = Color(0xFF6366F1);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'نام نہیں',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user['email'] ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: roleColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    roleText,
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NotoNastaliq',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
