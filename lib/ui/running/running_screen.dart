import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/running_provider.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/domain/entities/running_session.dart';
import 'route_detail_screen.dart';
import 'services/location_service.dart';
import 'widgets/running_history_card.dart';
import 'widgets/running_stats_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/steps_chart_card.dart';
import 'widgets/running_schedule_card.dart';
import 'widgets/start_running_card.dart';
import 'models/running_record.dart';

class RunningScreen extends StatefulWidget {
  final ValueChanged<bool>? onQuickActionsChanged;

  const RunningScreen({Key? key, this.onQuickActionsChanged}) : super(key: key);

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  bool _isRunning = false;
  bool _isLoadingStats = true;
  String _displayName = 'Người dùng';
  int _totalCalories = 0;
  double _totalDistance = 0;
  int _totalDurationSeconds = 0;
  double _averageSpeedKmh = 0;
  List<RunningRecord> _recentRecords = const [];
  RunningRecord? _latestRecord;
  List<RunningDailySummary> _weeklyDailySummaries = const [];

  @override
  void initState() {
    super.initState();
    _loadRunningStats();
  }

  void _startRunning() {
    _openLiveMap();
  }

  Future<void> _loadRunningStats() async {
    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null || !mounted) return;

      final userId = int.tryParse(credentials.userIdString);
      if (userId == null) return;

      final profileProvider = context.read<ProfileProvider>();
      final runningProvider = context.read<RunningProvider>();

      await Future.wait([
        profileProvider.loadProfile(userId),
        runningProvider.loadDashboard(credentials.token, userId),
      ]);

      final profile = profileProvider.profileData;
      final weeklySummary = runningProvider.weeklySummary;

      if (!mounted) return;

      setState(() {
        _displayName = profile?.fullname.trim().isNotEmpty == true
            ? profile!.fullname
            : 'Người dùng';
        _totalCalories = weeklySummary?.totalCaloriesBurned ?? 0;
        _totalDistance = weeklySummary?.totalDistanceKm ?? 0;
        _totalDurationSeconds = weeklySummary?.totalDurationSeconds ?? 0;
        _averageSpeedKmh = runningProvider.weeklyAverageSpeedKmh;
        _recentRecords = runningProvider.historyRecords;
        _latestRecord = runningProvider.latestRecord;
        _weeklyDailySummaries = weeklySummary?.dailySummaries ?? const [];
        _isLoadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _openLiveMap() async {
    try {
      final currentLocation = await LocationService.getCurrentLatLng();
      if (!mounted) {
        return;
      }

      setState(() {
        _isRunning = true;
      });

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RouteDetailScreen(initialCenter: currentLocation),
        ),
      );

      await _loadRunningStats();

      // Quay lại: reset để nút Bắt đầu hiện lại
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy vị trí hiện tại: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: _isLoadingStats
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(0.05),
                    vertical: context.h(0.02),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildGreetingHeader(context),
                      SizedBox(height: context.h(0.025)),
                      QuickStatsRow(
                        calories: _totalCalories,
                        distance: _totalDistance,
                      ),
                      SizedBox(height: context.h(0.025)),
                      RunningHistoryCard(records: _recentRecords),
                      SizedBox(height: context.h(0.025)),
                      StepsChartCard(dailySummaries: _weeklyDailySummaries),
                      SizedBox(height: context.h(0.025)),
                      RunningStatsCard(
                        distance: _totalDistance,
                        calories: _totalCalories,
                        duration: Duration(seconds: _totalDurationSeconds),
                        pace: _averageSpeedKmh,
                      ),
                      SizedBox(height: context.h(0.025)),
                      if (_latestRecord != null) ...[
                        _buildLatestRunSection(context),
                        SizedBox(height: context.h(0.025)),
                        RunningScheduleCard(record: _latestRecord!),
                        SizedBox(height: context.h(0.025)),
                      ],
                      if (!_isRunning)
                        StartRunningCard(
                          isRunning: _isRunning,
                          onStartPressed: _startRunning,
                        ),
                      SizedBox(height: context.h(0.02)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.04)),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: context.w(0.14),
            height: context.w(0.14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffEBCF23).withOpacity(0.2),
              border: Border.all(color: const Color(0xffEBCF23), width: 2),
            ),
            child: Icon(
              Icons.person,
              color: const Color(0xffEBCF23),
              size: context.sp(6),
            ),
          ),
          SizedBox(width: context.w(0.03)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Xin chào, $_displayName!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(7),
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Hôm nay cùng tập luyện nào!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.8),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestRunSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        'Buổi chạy gần nhất',
        style: GoogleFonts.baloo2(
          fontSize: context.sp(6),
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    );
  }
}
