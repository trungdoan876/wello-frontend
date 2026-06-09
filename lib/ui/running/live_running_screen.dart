import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/data_source/running_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/running_repository_impl.dart';
import 'package:wello_frontend/domain/entities/running_session.dart';
import 'package:wello_frontend/domain/providers/running_provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class LiveRunningScreen extends StatefulWidget {
  final String activityLabel;
  final String activityType;
  final String goalValueText;
  final String selectedGoal;
  final int targetKm;
  final int targetMinutes;
  final int targetCalories;
  final int targetSteps;
  final LatLng? center;

  const LiveRunningScreen({
    super.key,
    required this.activityLabel,
    required this.activityType,
    required this.goalValueText,
    required this.selectedGoal,
    required this.targetKm,
    required this.targetMinutes,
    required this.targetCalories,
    required this.targetSteps,
    this.center,
  });

  @override
  State<LiveRunningScreen> createState() => _LiveRunningScreenState();
}

class _LiveRunningScreenState extends State<LiveRunningScreen>
    with TickerProviderStateMixin {
  static const Color _accent = Color(0xFF4D7CFE);
  static const Color _pageBg = Color(0xFFF4F7FF);
  static const Color _cardBorder = Color(0xFFE2EAFB);

  // Page dots
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Map
  final MapController _mapController = MapController();
  LatLng? _lastPosition;
  late RunningProvider _runningProvider;

  @override
  void initState() {
    super.initState();
    _runningProvider = context.read<RunningProvider>();
    if (!_runningProvider.isTracking) {
      _runningProvider.startTracking(
        activityLabel: widget.activityLabel,
        activityType: widget.activityType,
        goalValueText: widget.goalValueText,
        selectedGoal: widget.selectedGoal,
        targetKm: widget.targetKm,
        targetMinutes: widget.targetMinutes,
        targetCalories: widget.targetCalories,
        targetSteps: widget.targetSteps,
        center: widget.center,
      );
    }
    _lastPosition = _runningProvider.currentPosition;
    _runningProvider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    if (!mounted) return;
    if (_runningProvider.currentPosition != _lastPosition) {
      _lastPosition = _runningProvider.currentPosition;
      if (_lastPosition != null) {
        try {
          if (_runningProvider.routePoints.length >= 2) {
            final bounds = LatLngBounds.fromPoints(_runningProvider.routePoints);
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(32.0),
              ),
            );
          } else {
            _mapController.move(_lastPosition!, 17);
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _stopRunning() async {
    if (_runningProvider.isSaving) {
      print('🏃 [LiveRunningScreen] _stopRunning: already saving, ignoring.');
      return;
    }

    print('🏃 [LiveRunningScreen] _stopRunning: starting save via provider...');
    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials != null) {
        final userId = int.tryParse(credentials.userIdString) ?? 0;
        if (userId > 0) {
          final success = await _runningProvider.stopAndSaveTracking(credentials.token, userId);
          if (success && mounted) {
            print('🏃 [LiveRunningScreen] _stopRunning: save success! popping with true.');
            Navigator.of(context).pop(true);
          }
        } else {
          print('🏃 [LiveRunningScreen] _stopRunning: invalid userId: $userId');
        }
      } else {
        print('🏃 [LiveRunningScreen] _stopRunning: credentials are null!');
      }
    } catch (e) {
      print('🏃 [LiveRunningScreen] _stopRunning: error saving session: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể lưu buổi chạy: $e')));
      }
    }
  }

  @override
  void dispose() {
    _runningProvider.removeListener(_onProviderUpdate);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RunningProvider>();

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildMapSection(context, provider),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildStatsPage(context, provider),
                    _buildDetailPage(context, provider),
                  ],
                ),
              ),
              _buildDots(context),
              _buildBottomButton(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Map ────────────────────────────────────────────────────────────────────

  Widget _buildMapSection(BuildContext context, RunningProvider provider) {
    final center = provider.currentPosition ?? widget.center;
    return SizedBox(
      height: context.h(0.28),
      child: Stack(
        children: [
          center != null
              ? ClipRect(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: center, initialZoom: 17),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.wello.frontend',
                      ),
                      // Đường đi thực tế (Thiết kế hiệu ứng phát sáng cao cấp)
                      if (provider.routePoints.length > 1)
                        PolylineLayer(
                          polylines: [
                            // Lớp phát sáng mờ bên dưới
                            Polyline(
                              points: provider.routePoints,
                              color: _accent.withValues(alpha: 0.25),
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              strokeJoin: StrokeJoin.round,
                            ),
                            // Đường vẽ chính sắc nét bên trên
                            Polyline(
                              points: provider.routePoints,
                              color: _accent,
                              strokeWidth: 5,
                              strokeCap: StrokeCap.round,
                              strokeJoin: StrokeJoin.round,
                            ),
                          ],
                        ),
                      // Vị trí hiện tại
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 44,
                            height: 44,
                            point: center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
          // Nút back nổi lên trên bản đồ
          Positioned(
            left: context.w(0.04),
            top: context.h(0.02),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: context.w(0.1),
                height: context.w(0.1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: context.sp(4.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trang 1: Stats chính ───────────────────────────────────────────────────

  Widget _buildStatsPage(BuildContext context, RunningProvider provider) {
    return Column(
      children: [
        SizedBox(height: context.h(0.02)),
        _buildCircularProgress(context, provider),
        SizedBox(height: context.h(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(context, provider.steps > 0 ? '${provider.steps}' : '-', 'Bước', '🦶'),
              _statItem(context, provider.formattedTime, 'Thời gian', '⏱'),
              _statItem(context, provider.gpsReady ? '♥' : '--', 'bpm', '❤️'),
            ],
          ),
        ),
        SizedBox(height: context.h(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(context, provider.km.toStringAsFixed(2), 'km', '📍'),
              _statItem(context, '${provider.calories}', 'calo', '🔥'),
              _statItem(context, provider.formattedPace, 'phút/km', '🏃'),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Trang 2: Chi tiết ─────────────────────────────────────────────────────

  Widget _buildDetailPage(BuildContext context, RunningProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.05),
        vertical: context.h(0.02),
      ),
      child: Column(
        children: [
          SizedBox(height: context.h(0.01)),
          Text(
            'Thống kê chi tiết',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: context.h(0.015)),
          Row(
            children: [
              Expanded(
                child: _detailCard(context, '📍', provider.km.toStringAsFixed(2), 'km'),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: _detailCard(context, '⏱', provider.formattedTime, 'Thời gian'),
              ),
            ],
          ),
          SizedBox(height: context.h(0.012)),
          Row(
            children: [
              Expanded(child: _detailCard(context, '🔥', '${provider.calories}', 'Calo')),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: _detailCard(context, '🏃', provider.formattedPace, 'phút/km'),
              ),
            ],
          ),
          SizedBox(height: context.h(0.012)),
          Row(
            children: [
              Expanded(child: _detailCard(context, '🦶', '${provider.steps}', 'Bước')),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: _detailCard(
                  context,
                  '🗺️',
                  '${(provider.progress * 100).round()}%',
                  'Hoàn thành',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Circular progress ─────────────────────────────────────────────────────

  Widget _buildCircularProgress(BuildContext context, RunningProvider provider) {
    final pct = (provider.progress * 100).round();
    return SizedBox(
      width: context.w(0.52),
      height: context.w(0.52),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: context.w(0.52),
            height: context.w(0.52),
            child: CircularProgressIndicator(
              value: provider.progress,
              strokeWidth: 7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.activityLabel.toUpperCase(),
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(3),
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '$pct %',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(7.5),
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              Text(
                'của ${widget.goalValueText}',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(3.2),
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _statItem(
    BuildContext context,
    String value,
    String label,
    String emoji,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(5.2),
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: context.sp(3.2))),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(3.2),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailCard(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.h(0.018),
        horizontal: context.w(0.03),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.04)),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: context.sp(5.5))),
          SizedBox(height: context.h(0.004)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(0.008)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == i ? 14 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == i ? _accent : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, RunningProvider provider) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          _showStopConfirm(context, provider);
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          context.w(0.04),
          0,
          context.w(0.04),
          context.h(0.02),
        ),
        height: context.h(0.075),
        decoration: BoxDecoration(
          color: provider.isPaused ? Colors.orange : _accent,
          borderRadius: BorderRadius.circular(context.w(0.05)),
          boxShadow: [
            BoxShadow(
              color: (provider.isPaused ? Colors.orange : _accent).withValues(
                alpha: 0.35,
              ),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: context.w(0.04)),
            Icon(Icons.double_arrow, color: Colors.white, size: context.sp(6)),
            const Spacer(),
            GestureDetector(
              onTap: provider.togglePause,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.isPaused ? 'Tiếp tục | Dừng lại' : 'Tạm dừng | Dừng lại',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.5),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Vuốt sang phải để dừng',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(2.8),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.double_arrow, color: Colors.white, size: context.sp(6)),
            SizedBox(width: context.w(0.04)),
          ],
        ),
      ),
    );
  }

  void _showStopConfirm(BuildContext context, RunningProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          context.w(0.06),
          context.h(0.025),
          context.w(0.06),
          context.h(0.04),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: context.w(0.12),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.h(0.025)),

            // Icon
            Container(
              width: context.w(0.18),
              height: context.w(0.18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.stop_circle_outlined,
                color: Colors.redAccent,
                size: context.sp(10),
              ),
            ),
            SizedBox(height: context.h(0.018)),

            // Title
            Text(
              'Kết thúc buổi tập?',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(6),
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: context.h(0.006)),
            Text(
              'Bạn đã có một buổi tập tuyệt vời!',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(3.8),
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: context.h(0.025)),

            // Stats summary
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(0.04),
                vertical: context.h(0.02),
              ),
              decoration: BoxDecoration(
                color: _pageBg,
                borderRadius: BorderRadius.circular(context.w(0.04)),
                border: Border.all(color: _cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem(context, '⏱', provider.formattedTime, 'Thời gian'),
                  _vDivider(),
                  _summaryItem(context, '📍', provider.km.toStringAsFixed(2), 'km'),
                  _vDivider(),
                  _summaryItem(context, '🔥', '${provider.calories}', 'Calo'),
                  _vDivider(),
                  _summaryItem(context, '🦶', '${provider.steps}', 'Bước'),
                ],
              ),
            ),
            SizedBox(height: context.h(0.03)),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.h(0.02)),
                      side: BorderSide(color: _accent, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.w(0.035)),
                      ),
                    ),
                    child: Text(
                      'Tiếp tục',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        fontWeight: FontWeight.w800,
                        color: _accent,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.w(0.03)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _stopRunning();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: context.h(0.02)),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.w(0.035)),
                      ),
                    ),
                    child: Text(
                      provider.isSaving ? 'Đang lưu...' : 'Dừng lại',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: TextStyle(fontSize: context.sp(4.5))),
        SizedBox(height: context.h(0.004)),
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4.5),
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(2.8),
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(width: 1, height: 44, color: _cardBorder);
}
