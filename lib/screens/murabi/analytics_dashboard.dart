import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';

class MurabiAnalyticsScreen extends StatefulWidget {
  @override
  _MurabiAnalyticsScreenState createState() => _MurabiAnalyticsScreenState();
}

class _MurabiAnalyticsScreenState extends State<MurabiAnalyticsScreen> {
  late AuthService authService;
  late AnalyticsService analyticsService;
  bool _isLoading = true;
  List<Map<String, dynamic>> _salikStats = [];

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    analyticsService = AnalyticsService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final murabiId = authService.currentUser?.uid ?? '';
      final stats = await analyticsService.getMurabiSalikeenStats(murabiId);

      if (mounted) {
        setState(() {
          _salikStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading analytics: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                        'سالکین کی کارکردگی',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NotoNastaliq',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  if (_salikStats.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'کوئی سالک نہیں',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                              fontFamily: 'NotoNastaliq',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Summary Stats
                        _buildGlassmorphicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'خلاصہ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'NotoNastaliq',
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryItem(
                                    _salikStats.length.toString(),
                                    'کل سالکین',
                                    Color(0xFF3B82F6),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  _buildSummaryItem(
                                    '${(_salikStats.fold(0, (prev, curr) => prev + (curr['completionRate'] as int)) / _salikStats.length).toStringAsFixed(0)}%',
                                    'اوسط کارکردگی',
                                    Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Salik Rankings
                        Text(
                          'درجہ بندی',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),

                        SizedBox(height: 12),

                        ..._salikStats.asMap().entries.map((entry) {
                          final index = entry.key;
                          final salik = entry.value;
                          final salikName =
                              salik['salikName'] as String? ?? 'نام نہیں';
                          final completionRate =
                              salik['completionRate'] as int? ?? 0;
                          final daysActive = salik['daysActive'] as int? ?? 0;
                          final level = salik['currentLevel'] as int? ?? 1;

                          Color getMedalColor() {
                            if (index == 0) return Color(0xFFFFD700);
                            if (index == 1) return Color(0xFFC0C0C0);
                            if (index == 2) return Color(0xFFCD7F32);
                            return Colors.white.withOpacity(0.4);
                          }

                          String getMedalEmoji() {
                            if (index == 0) return '🥇';
                            if (index == 1) return '🥈';
                            if (index == 2) return '🥉';
                            return '${index + 1}';
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: _buildGlassmorphicCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
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
                                          color: Color(0xFF8B5CF6)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Color(0xFF8B5CF6)
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          'لیول $level',
                                          style: TextStyle(
                                            color: Color(0xFF8B5CF6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoNastaliq',
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                salikName,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: 'NotoNastaliq',
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                getMedalEmoji(),
                                                style:
                                                    TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
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
                                          color: Color(0xFF10B981)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$daysActive دن فعال',
                                          style: TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 12,
                                            fontFamily: 'NotoNastaliq',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$completionRate%',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: _getColorForRate(
                                              completionRate),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: completionRate / 100,
                                      minHeight: 6,
                                      backgroundColor: Colors.white
                                          .withOpacity(0.1),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        _getColorForRate(completionRate),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontFamily: 'NotoNastaliq',
          ),
        ),
      ],
    );
  }

  Color _getColorForRate(int rate) {
    if (rate >= 90) return Color(0xFF10B981);
    if (rate >= 75) return Color(0xFFFCD34D);
    if (rate >= 50) return Color(0xFFF97316);
    return Color(0xFEF2F2);
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
