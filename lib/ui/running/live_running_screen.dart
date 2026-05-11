import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/data_source/running_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/running_repository_impl.dart';
import 'package:wello_frontend/domain/entities/running_session.dart';
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
  static const double _minAcceptedMovementMeters = 10.0;
  static const double _minAcceptedSpeedMs = 0.8;

  // Timer
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isPaused = false;

  // GPS
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _currentPosition;
  final List<LatLng> _routePoints = [];
  bool _gpsReady = false;

  // Stats (GPS-based)
  double _km = 0;
  int _steps = 0;
  int _calories = 0;
  double _paceMinPerKm = 0;
  double _progress = 0;
  bool _isSaving = false;

  // Page dots
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Map
  final MapController _mapController = MapController();

  // Calories per km by activity
  double get _caloriesPerKm {
    switch (widget.activityLabel.toLowerCase()) {
      case 'đi bộ':
        return 60.0;
      case 'đạp xe':
        return 40.0;
      default:
        return 80.0; // Chạy bộ
    }
  }

  // Steps per km by activity
  double get _stepsPerKm {
    switch (widget.activityLabel.toLowerCase()) {
      case 'đi bộ':
        return 1350.0;
      case 'đạp xe':
        return 0.0;
      default:
        return 1250.0; // Chạy bộ
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.center;
    if (widget.center != null) _routePoints.add(widget.center!);
    _startTimer();
    _startGPS();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      setState(() {
        _secondsElapsed++;
        _updateProgress();
      });
    });
  }

  Future<void> _startGPS() async {
    // Kiểm tra và xin quyền
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có quyền truy cập GPS')),
        );
      }
      return;
    }

    setState(() => _gpsReady = true);

    // Lắng nghe stream GPS
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Cập nhật mỗi khi di chuyển >= 5 mét
      ),
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    if (_isPaused || !mounted) return;

    final newPoint = LatLng(position.latitude, position.longitude);
    final speedMs = position.speed >= 0 ? position.speed : 0.0;

    setState(() {
      final distanceMeters = _currentPosition == null
          ? 0.0
          : Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              newPoint.latitude,
              newPoint.longitude,
            );

      final hasRealMovement =
          distanceMeters >= _minAcceptedMovementMeters &&
          speedMs >= _minAcceptedSpeedMs;

      if (hasRealMovement) {
        final addedKm = distanceMeters / 1000.0;
        _km += addedKm;
        _steps += (addedKm * _stepsPerKm).round();
        _calories = (_km * _caloriesPerKm).round();

        // Tính pace (phút/km)
        if (_km > 0 && _secondsElapsed > 0) {
          _paceMinPerKm = (_secondsElapsed / 60.0) / _km;
        }

        _routePoints.add(newPoint);
        _currentPosition = newPoint;
        _updateProgress();
      }

      // Di chuyển camera map theo người dùng
      try {
        _mapController.move(newPoint, 17);
      } catch (_) {}
    });
  }

  void _updateProgress() {
    switch (widget.selectedGoal) {
      case 'distance':
        _progress = (_km / widget.targetKm).clamp(0.0, 1.0);
        break;
      case 'time':
        _progress = (_secondsElapsed / 60.0 / widget.targetMinutes).clamp(
          0.0,
          1.0,
        );
        break;
      case 'calories':
        _progress = (_calories / widget.targetCalories).clamp(0.0, 1.0);
        break;
      case 'steps':
        _progress = (_steps / widget.targetSteps).clamp(0.0, 1.0);
        break;
      default:
        _progress = (_km / widget.targetKm).clamp(0.0, 1.0);
    }
  }

  String get _formattedTime {
    final h = _secondsElapsed ~/ 3600;
    final m = (_secondsElapsed % 3600) ~/ 60;
    final s = _secondsElapsed % 60;
    return '${h > 0 ? '${h.toString().padLeft(2, '0')}:' : ''}${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _formattedPace {
    if (_paceMinPerKm <= 0) return '--:--';
    final m = _paceMinPerKm.floor();
    final s = ((_paceMinPerKm - m) * 60).round();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  Future<void> _stopRunning() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials != null) {
        final userId = int.tryParse(credentials.userIdString) ?? 0;
        if (userId > 0) {
          final session = RunningSession(
            userId: userId,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            activityType: widget.activityType,
            durationSeconds: _secondsElapsed,
            distanceKm: _km,
            caloriesBurned: _calories,
            steps: _steps,
            avgPaceSecPerKm: _km > 0 ? (_secondsElapsed / _km).round() : 0,
            goalType: widget.selectedGoal,
            goalValue: switch (widget.selectedGoal) {
              'distance' => widget.targetKm.toDouble(),
              'time' => widget.targetMinutes.toDouble(),
              'calories' => widget.targetCalories.toDouble(),
              'steps' => widget.targetSteps.toDouble(),
              _ => widget.targetKm.toDouble(),
            },
            completionPercent: (_progress * 100).clamp(0, 100).round(),
          );

          final repository = RunningRepositoryImpl(
            remoteDataSource: RunningRemoteDataSource(),
          );
          await repository.saveSession(credentials.token, session);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể lưu buổi chạy: $e')));
      }
    } finally {
      _timer?.cancel();
      _positionSubscription?.cancel();
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<bool> _onWillPop() async {
    await _stopRunning();
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildMapSection(context),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildStatsPage(context),
                    _buildDetailPage(context),
                  ],
                ),
              ),
              _buildDots(context),
              _buildBottomButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Map ────────────────────────────────────────────────────────────────────

  Widget _buildMapSection(BuildContext context) {
    final center = _currentPosition ?? widget.center;
    return SizedBox(
      height: context.h(0.28),
      child: center != null
          ? ClipRect(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: center, initialZoom: 17),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.wello.frontend',
                  ),
                  // Đường đi thực tế
                  if (_routePoints.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: _accent,
                          strokeWidth: 4,
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
    );
  }

  // ─── Trang 1: Stats chính ───────────────────────────────────────────────────

  Widget _buildStatsPage(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.h(0.02)),
        _buildCircularProgress(context),
        SizedBox(height: context.h(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(context, _steps > 0 ? '$_steps' : '-', 'Bước', '🦶'),
              _statItem(context, _formattedTime, 'Thời gian', '⏱'),
              _statItem(context, _gpsReady ? '♥' : '--', 'bpm', '❤️'),
            ],
          ),
        ),
        SizedBox(height: context.h(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(context, _km.toStringAsFixed(2), 'km', '📍'),
              _statItem(context, '$_calories', 'calo', '🔥'),
              _statItem(context, _formattedPace, 'phút/km', '🏃'),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Trang 2: Chi tiết ─────────────────────────────────────────────────────

  Widget _buildDetailPage(BuildContext context) {
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
                child: _detailCard(context, '📍', _km.toStringAsFixed(2), 'km'),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: _detailCard(context, '⏱', _formattedTime, 'Thời gian'),
              ),
            ],
          ),
          SizedBox(height: context.h(0.012)),
          Row(
            children: [
              Expanded(child: _detailCard(context, '🔥', '$_calories', 'Calo')),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: _detailCard(context, '🏃', _formattedPace, 'phút/km'),
              ),
            ],
          ),
          SizedBox(height: context.h(0.012)),
          Row(
            children: [
              Expanded(child: _detailCard(context, '🦶', '$_steps', 'Bước')),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: _detailCard(
                  context,
                  '🗺️',
                  '${(_progress * 100).round()}%',
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

  Widget _buildCircularProgress(BuildContext context) {
    final pct = (_progress * 100).round();
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
              value: _progress,
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

  Widget _buildBottomButton(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          _showStopConfirm(context);
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
          color: _isPaused ? Colors.orange : _accent,
          borderRadius: BorderRadius.circular(context.w(0.05)),
          boxShadow: [
            BoxShadow(
              color: (_isPaused ? Colors.orange : _accent).withValues(
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
              onTap: _togglePause,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isPaused ? 'Tiếp tục | Dừng lại' : 'Tạm dừng | Dừng lại',
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

  void _showStopConfirm(BuildContext context) {
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
                  _summaryItem(context, '⏱', _formattedTime, 'Thời gian'),
                  _vDivider(),
                  _summaryItem(context, '📍', _km.toStringAsFixed(2), 'km'),
                  _vDivider(),
                  _summaryItem(context, '🔥', '$_calories', 'Calo'),
                  _vDivider(),
                  _summaryItem(context, '🦶', '$_steps', 'Bước'),
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
                      _isSaving ? 'Đang lưu...' : 'Dừng lại',
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
