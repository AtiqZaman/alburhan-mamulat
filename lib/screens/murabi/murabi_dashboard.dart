import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class MurabiDashboard extends StatefulWidget {
  @override
  _MurabiDashboardState createState() => _MurabiDashboardState();
}

class _MurabiDashboardState extends State<MurabiDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedTabIndex = 0;

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
    final currentUserId = authService.currentUser?.uid ?? '';

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مربی ڈیش بورڈ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                        Text(
                          'اپنے سالکین کو منیج کریں',
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
                          colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF8B5CF6).withOpacity(0.4),
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
              ),

              // Stats Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('users')
                      .where('role', isEqualTo: 'salik')
                      .where('assignedMurabiId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    int salikCount = snapshot.data?.docs.length ?? 0;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'کل سالکین',
                            salikCount.toString(),
                            Color(0xFF10B981),
                            Icons.people,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'آج کی رپورٹس',
                            '0',
                            Color(0xFF3B82F6),
                            Icons.assignment,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              // Tab buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTabButton(0, 'میرے سالکین', Icons.people),
                    SizedBox(width: 12),
                    _buildTabButton(1, 'رپورٹس', Icons.assignment),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Tab content
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildSalikeenListTab(firestore, currentUserId)
                    : _buildReportsTab(firestore, currentUserId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedTabIndex = index);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFF8B5CF6).withOpacity(0.3)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Color(0xFF8B5CF6).withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Color(0xFF8B5CF6)
                          : Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Color(0xFF8B5CF6)
                            : Colors.white.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalikeenListTab(
      FirebaseFirestore firestore, String murabiId) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('users')
          .where('role', isEqualTo: 'salik')
          .where('assignedMurabiId', isEqualTo: murabiId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline,
                    size: 64, color: Colors.white.withOpacity(0.3)),
                SizedBox(height: 16),
                Text(
                  'ابھی کوئی طالب منسلک نہیں',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    fontFamily: 'NotoNastaliq',
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var salik =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            salik['id'] = snapshot.data!.docs[index].id;
            return _buildSalikCard(context, salik);
          },
        );
      },
    );
  }

  Widget _buildSalikCard(BuildContext context, Map<String, dynamic> salik) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salik['name'] ?? 'نام نہیں',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoNastaliq',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'لیول: ${salik['level'] ?? 1} | دن: ${salik['currentDay'] ?? 1}/40',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontFamily: 'NotoNastaliq',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                      ),
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      'رپورٹس دیکھیں',
                      Icons.visibility,
                      Color(0xFF3B82F6),
                      () {
                        _showSalikUpdates(
                            context, salik['id'], salik['name']);
                      },
                    ),
                    _buildActionButton(
                      'لیول منظور کریں',
                      Icons.check_circle,
                      Color(0xFF10B981),
                      () {
                        _approveLevelProgression(context, salik['id']);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NotoNastaliq',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsTab(
      FirebaseFirestore firestore, String murabiId) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('users')
          .where('role', isEqualTo: 'salik')
          .where('assignedMurabiId', isEqualTo: murabiId)
          .snapshots(),
      builder: (context, salikSnapshot) {
        if (salikSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          );
        }

        if (!salikSnapshot.hasData || salikSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'کوئی طالب نہیں',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontFamily: 'NotoNastaliq'),
            ),
          );
        }

        List<String> salikIds = salikSnapshot.data!.docs
            .map((doc) => doc.id)
            .cast<String>()
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('dailyUpdates')
              .where('salikId', whereIn: salikIds)
              .orderBy('createdAt', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, updatesSnapshot) {
            if (updatesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              );
            }

            if (!updatesSnapshot.hasData ||
                updatesSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 64, color: Colors.white.withOpacity(0.3)),
                    SizedBox(height: 16),
                    Text(
                      'ابھی کوئی رپورٹ نہیں',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: updatesSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var update = updatesSnapshot.data!.docs[index].data()
                    as Map<String, dynamic>;
                return _buildUpdateCard(update);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUpdateCard(Map<String, dynamic> update) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          update['salikName'] ?? 'نام نہیں',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'لیول ${update['level']}, دن ${update['currentDay']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM dd').format(
                        (update['createdAt'] as Timestamp).toDate(),
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مکمل شدہ کام: ${(update['tasksCompleted'] as Map?)?.values.where((v) => v == true).length ?? 0}',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                      if ((update['notes'] ?? '').isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          update['notes'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSalikUpdates(
      BuildContext context, String salikId, String salikName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A3A5C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$salikName - حالیہ رپورٹیں',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'NotoNastaliq',
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('dailyUpdates')
                    .where('salikId', isEqualTo: salikId)
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'کوئی رپورٹ نہیں',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var update = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM dd, HH:mm').format(
                                  (update['createdAt'] as Timestamp)
                                      .toDate(),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'مکمل: ${(update['tasksCompleted'] as Map?)?.values.where((v) => v == true).length ?? 0} کام',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 12,
                                  fontFamily: 'NotoNastaliq',
                                ),
                              ),
                              if ((update['notes'] ?? '').isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  update['notes'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontFamily: 'NotoNastaliq',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _approveLevelProgression(BuildContext context, String salikId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'لیول منظور کریں',
          style: TextStyle(fontFamily: 'NotoNastaliq'),
        ),
        content: Text(
          'کیا یہ طالب اگلے لیول پر جا سکتا ہے؟',
          style: TextStyle(fontFamily: 'NotoNastaliq'),
        ),
        backgroundColor: Color(0xFF1A3A5C),
        titleTextStyle:
            TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'NotoNastaliq'),
        contentTextStyle: TextStyle(color: Colors.white, fontFamily: 'NotoNastaliq'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('منسوخ کریں', style: TextStyle(fontFamily: 'NotoNastaliq')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('لیول منظور ہو گیا!',
                      style: TextStyle(fontFamily: 'NotoNastaliq')),
                ),
              );
            },
            child: Text('منظور کریں', style: TextStyle(fontFamily: 'NotoNastaliq')),
          ),
        ],
      ),
    );
  }
}
