import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';

class SalikAnalyticsDashboard extends StatefulWidget {
  @override
  _SalikAnalyticsDashboardState createState() => _SalikAnalyticsDashboardState();
}

class _SalikAnalyticsDashboardState extends State<SalikAnalyticsDashboard> {
  late AuthService authService;
  late AnalyticsService analyticsService;
  bool _isLoading = true;
  
  Map<String, dynamic> _weeklyStats = {};
  Map<String, dynamic> _monthlyStats = {};
  Map<String, dynamic> _overallStats = {};
  List<Map<String, dynamic>> _taskBreakdown = [];
  int _currentStreak = 0;
  List<String> _badges = [];
  List<Map<String, dynamic>> _dailyData = [];

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    analyticsService = AnalyticsService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = authService.currentUser?.uid ?? '';

      final weeklyStats = await analyticsService.getWeeklyStats(userId);
      final monthlyStats = await analyticsService.getMonthlyStats(userId);
      final overallStats = await analyticsService.getOverallStats(userId);
      final taskBreakdown = await analyticsService.getTaskBreakdown(userId);
      final streak = await analyticsService.getCurrentStreak(userId);
      final badges = await analyticsService.getBadges(userId);
      final dailyData = await analyticsService.getDailyCompletionRate(userId, 7);

      if (mounted) {
        setState(() {
          _weeklyStats = weeklyStats;
          _monthlyStats = monthlyStats;
          _overallStats = overallStats;
          _taskBreakdown = taskBreakdown;
          _currentStreak = streak;
          _badges = badges;
          _dailyData = dailyData;
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

    final weeklyRate = _weeklyStats['completionRate'] as int? ?? 0;
    final monthlyRate = _monthlyStats['completionRate'] as int? ?? 0;
    final overallRate = _overallStats['overallRate'] as int? ?? 0;

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
                        'تجزیات',
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

                  // Badges Section
                  if (_badges.isNotEmpty) ...[
                    Text(
                      'اعزامات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: _badges
                          .map((badge) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFC107).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFFFFC107).withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontSize: 12,
                                    fontFamily: 'NotoNastaliq',
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Streak Card
                  _buildGlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'موجودہ سلسلہ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'NotoNastaliq',
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'دن',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontFamily: 'NotoNastaliq',
                              ),
                            ),
                            Text(
                              '🔥 $_currentStreak',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Stats Cards
                  Text(
                    'کارکردگی',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'NotoNastaliq',
                    ),
                  ),

                  SizedBox(height: 12),

                  // Weekly Stats
                  _buildStatCard(
                    'ہفتہ وار',
                    '$weeklyRate%',
                    Color(0xFF3B82F6),
                    _weeklyStats['daysActive'] as int? ?? 0,
                    'دن فعال',
                  ),

                  SizedBox(height: 12),

                  // Monthly Stats
                  _buildStatCard(
                    'ماہانہ',
                    '$monthlyRate%',
                    Color(0xFF10B981),
                    _monthlyStats['daysActive'] as int? ?? 0,
                    'دن فعال',
                  ),

                  SizedBox(height: 12),

                  // Overall Stats
                  _buildStatCard(
                    'مجموعی',
                    '$overallRate%',
                    Color(0xFF8B5CF6),
                    _overallStats['totalSubmissions'] as int? ?? 0,
                    'جمع کیے ہوئے',
                  ),

                  SizedBox(height: 24),

                  // Weekly Chart
                  if (_dailyData.isNotEmpty) ...[
                    Text(
                      'گزشتہ 7 دن',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildGlassmorphicCard(
                      child: SizedBox(
                        height: 200,
                        child: _buildLineChart(),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Top Tasks
                  if (_taskBreakdown.isNotEmpty) ...[
                    Text(
                      'بہترین کام',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                    SizedBox(height: 12),
                    ..._taskBreakdown.take(5).map((task) {
                      final taskName = task['taskName'] as String? ?? 'نام نہیں';
                      final count = task['completedCount'] as int? ?? 0;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _buildGlassmorphicCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$count بار',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoNastaliq',
                                  ),
                                ),
                              ),
                              Text(
                                taskName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'NotoNastaliq',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String percentage,
    Color color,
    int value,
    String subtitle,
  ) {
    return _buildGlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoNastaliq',
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontFamily: 'NotoNastaliq',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: int.parse(percentage.replaceAll('%', '')) / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['شنی', 'اتوار', 'سوموار', 'منگل', 'بدھ', 'جمعرات', 'جمعہ'];
                return Text(
                  days[value.toInt() % 7],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _dailyData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value['rate'].toDouble());
            }).toList(),
            isCurved: true,
            color: Color(0xFF10B981),
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
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
}
