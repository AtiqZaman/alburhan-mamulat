import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/level_service.dart';

class LevelProgressionScreen extends StatefulWidget {
  @override
  _LevelProgressionScreenState createState() => _LevelProgressionScreenState();
}

class _LevelProgressionScreenState extends State<LevelProgressionScreen> {
  late AuthService authService;
  late LevelService levelService;
  bool _isLoading = true;
  int _daysRemaining = 0;
  bool _isEligible = false;
  bool _promotionRequested = false;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    levelService = LevelService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = authService.currentUser?.uid ?? '';
      
      final daysRemaining = await levelService.getDaysRemaining(userId);
      final isEligible = await levelService.isEligibleForPromotion(userId);
      
      if (mounted) {
        setState(() {
          _daysRemaining = daysRemaining;
          _isEligible = isEligible;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestPromotion() async {
    try {
      final userId = authService.currentUser?.uid ?? '';
      final userData = await levelService.getLevelData(userId);
      final salikName = userData?['name'] ?? 'صارف';
      
      final success = await levelService.requestPromotion(userId, salikName);
      
      if (success && mounted) {
        setState(() => _promotionRequested = true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لیول منظوری کی درخواست بھیج دی گئی',
              style: TextStyle(fontFamily: 'NotoNastaliq'),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خرابی: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

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
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      Text(
                        'لیول کی ترقی',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  if (_isEligible) ...[
                    // Eligible - Show Promotion Ready
                    _buildGlassmorphicCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.6),
                              ),
                            ),
                            child: Text(
                              '✓ منظوری کے لیے تیار',
                              style: TextStyle(
                                color: Colors.green.shade300,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'مبارک ہو! آپ نے 40 دن مکمل کر لیے',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'NotoNastaliq',
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'آپ اگلے لیول پر جانے کے لیے تیار ہیں۔ اپنے مربی سے منظوری حاصل کریں۔',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontFamily: 'NotoNastaliq',
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _promotionRequested
                                  ? null
                                  : _requestPromotion,
                              icon: Icon(Icons.arrow_upward),
                              label: Text(
                                _promotionRequested
                                    ? 'درخواست بھیجی جا چکی'
                                    : 'منظوری کی درخواست',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoNastaliq',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _promotionRequested
                                    ? Colors.grey
                                    : Color(0xFF10B981),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Not Eligible - Show Progress
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
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '$_daysRemaining',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'دن باقی',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontFamily: 'NotoNastaliq',
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 2,
                                  height: 60,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${40 - _daysRemaining}',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'دن مکمل',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontFamily: 'NotoNastaliq',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: ((40 - _daysRemaining) / 40)
                                  .clamp(0.0, 1.0),
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF10B981),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '${(((40 - _daysRemaining) / 40) * 100).toStringAsFixed(0)}% مکمل',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontFamily: 'NotoNastaliq',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Info Card
                  _buildGlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'لیول کی ترقی کیسے کام کرتی ہے؟',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoPoint(
                          '1',
                          '40 دن مکمل کریں',
                          'روزانہ معمولات ادا کریں اور 40 دن مکمل کریں',
                        ),
                        SizedBox(height: 12),
                        _buildInfoPoint(
                          '2',
                          'درخواست بھیجیں',
                          'جب 40 دن مکمل ہوں تو منظوری کی درخواست کریں',
                        ),
                        SizedBox(height: 12),
                        _buildInfoPoint(
                          '3',
                          'منظوری حاصل کریں',
                          'اپنے مربی سے منظوری حاصل کریں',
                        ),
                        SizedBox(height: 12),
                        _buildInfoPoint(
                          '4',
                          'اگلے لیول پر جائیں',
                          'نئے معمولات اور نئی چ challenges کے ساتھ شروع کریں',
                        ),
                      ],
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

  Widget _buildInfoPoint(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(height: 4),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8B5CF6).withOpacity(0.3),
                border: Border.all(
                  color: Color(0xFF8B5CF6).withOpacity(0.6),
                ),
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoNastaliq',
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontFamily: 'NotoNastaliq',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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
}
