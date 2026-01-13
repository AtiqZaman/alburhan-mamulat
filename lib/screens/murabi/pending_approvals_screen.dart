import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/level_service.dart';

class PendingApprovalsScreen extends StatefulWidget {
  @override
  _PendingApprovalsScreenState createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  late AuthService authService;
  late LevelService levelService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    levelService = LevelService();
  }

  Future<void> _approvePromotion(String requestId, String salikId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'لیول منظور کریں؟',
          style: TextStyle(fontFamily: 'NotoNastaliq'),
        ),
        content: Text(
          'کیا آپ یہ طالب کو اگلے لیول پر بڑھانا چاہتے ہیں؟',
          style: TextStyle(fontFamily: 'NotoNastaliq'),
        ),
        backgroundColor: Color(0xFF1A3A5C),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'NotoNastaliq',
        ),
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'NotoNastaliq',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'منسوخ کریں',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'NotoNastaliq',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await levelService.approvePromotion(
                requestId,
                salikId,
                authService.currentUser!.uid,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'لیول منظور ہو گیا!',
                      style: TextStyle(fontFamily: 'NotoNastaliq'),
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              'منظور کریں',
              style: TextStyle(
                color: Colors.green,
                fontFamily: 'NotoNastaliq',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectPromotion(String requestId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'لیول مسترد کریں؟',
          style: TextStyle(fontFamily: 'NotoNastaliq'),
        ),
        content: Text(
          'کیا آپ یہ لیول منظوری مسترد کرنا چاہتے ہیں؟',
          style: TextStyle(fontFamily: 'NotoNastaliq'),
        ),
        backgroundColor: Color(0xFF1A3A5C),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'NotoNastaliq',
        ),
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'NotoNastaliq',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'منسوخ کریں',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'NotoNastaliq',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await levelService.rejectPromotion(requestId);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'لیول مسترد ہو گیا',
                      style: TextStyle(fontFamily: 'NotoNastaliq'),
                    ),
                    backgroundColor: Colors.orange.shade600,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              'مسترد کریں',
              style: TextStyle(
                color: Colors.orange,
                fontFamily: 'NotoNastaliq',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final murabiId = authService.currentUser?.uid ?? '';

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Text(
                      'زیر التوا منظوری',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: levelService.getPendingPromotions(murabiId),
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

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'کوئی زیر التوا منظوری نہیں',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                            Text(
                              'تمام طالبین منظور ہو چکے ہیں',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final promotions = snapshot.data!;

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: promotions.length,
                      itemBuilder: (context, index) {
                        final promotion = promotions[index];
                        final requestId = promotion['requestId'];
                        final salikId = promotion['salikId'];
                        final salikName = promotion['salikName'] ?? 'نام نہیں';
                        final fromLevel = promotion['currentLevel'] ?? 1;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(0xFFFFC107).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Title
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFC107)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Color(0xFFFFC107)
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                          child: Text(
                                            'زیر التوا',
                                            style: TextStyle(
                                              color: Color(0xFFFFC107),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoNastaliq',
                                            ),
                                          ),
                                        ),
                                        Text(
                                          salikName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'NotoNastaliq',
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 12),

                                    // Level Info
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF10B981)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'لیول $fromLevel سے لیول ${fromLevel + 1} تک',
                                                style: TextStyle(
                                                  color:
                                                      Color(0xFF10B981),
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'NotoNastaliq',
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '40 دن مکمل کر چکے ہیں',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.6),
                                                  fontSize: 12,
                                                  fontFamily: 'NotoNastaliq',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 12),
                                          Icon(
                                            Icons.trending_up,
                                            color: Color(0xFF10B981),
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 16),

                                    // Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Reject Button
                                        GestureDetector(
                                          onTap: () =>
                                              _rejectPromotion(requestId),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.red
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            child: Text(
                                              'مسترد',
                                              style: TextStyle(
                                                color: Colors.red.shade300,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'NotoNastaliq',
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 12),

                                        // Approve Button
                                        GestureDetector(
                                          onTap: () => _approvePromotion(
                                            requestId,
                                            salikId,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF10B981)
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Color(0xFF10B981)
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                            child: Text(
                                              'منظور کریں',
                                              style: TextStyle(
                                                color: Color(0xFF10B981),
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'NotoNastaliq',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
      ),
    );
  }
}
