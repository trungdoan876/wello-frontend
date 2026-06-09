import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/data_source/exercise_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/exercise_repository_impl.dart';
import 'live_running_screen.dart';

class RouteDetailScreen extends StatefulWidget {
  final LatLng? initialCenter;

  const RouteDetailScreen({super.key, this.initialCenter});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final MapController _mapController = MapController();

  static const Color _pageBg = Color(0xFFF4F7FF);
  static const Color _accent = Color(0xFF4D7CFE);
  static const Color _accentSoft = Color(0xFFEAF1FF);
  static const Color _cardBorder = Color(0xFFE2EAFB);

  LatLng? _center;
  int _targetKm = 3;
  int _targetMinutes = 30;
  int _targetCalories = 300;
  int _targetSteps = 5000;
  bool _isRunning = false;
  String _selectedGoal = 'distance';
  String _selectedActivity = 'running';

  // Workout data
  int _totalCaloriesBurned = 0;
  double _totalKmRun = 0;
  int _totalMinutesRun = 0;
  bool _isLoadingWorkout = true;
  static const double _stepsPerKm = 5000;

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter;
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) return;

      final repository = ExerciseRepositoryImpl(
        remoteDataSource: ExerciseRemoteDataSource(),
      );

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final log = await repository.getDailyWorkoutLog(
        credentials.token,
        credentials.userIdString,
        today,
      );

      setState(() {
        _totalCaloriesBurned = log.totalCaloriesBurned;

        // Tính tổng thời gian tập luyện (phút)
        _totalMinutesRun = log.workouts.fold<int>(
          0,
          (sum, workout) => sum + workout.durationMinutes,
        );

        // Ước tính khoảng cách dựa trên tốc độ chạy bộ trung bình (12 km/h)
        // = 0.2 km/phút, hoặc ~6 km/giờ cho đi bộ
        final isRunning = _selectedActivity == 'running';
        final speedKmPerHour = isRunning
            ? 12.0
            : 6.0; // Chạy 12km/h, đi bộ 6km/h
        _totalKmRun = (_totalMinutesRun / 60.0) * speedKmPerHour;

        _isLoadingWorkout = false;
      });
    } catch (e) {
      print('❌ Lỗi khi load workout data: $e');
      setState(() => _isLoadingWorkout = false);
    }
  }

  Future<void> _ensureCenterReady() async {
    if (_center != null) return;
    await Future.delayed(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _ensureCenterReady(),
          builder: (context, snapshot) {
            if (_center == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(context.w(0.08)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: context.h(0.02)),
                      Text(
                        'Đang lấy vị trí hiện tại...',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(5),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.w(0.05),
                    context.h(0.01),
                    context.w(0.05),
                    context.h(0.015),
                  ),
                  child: Row(
                    children: [
                      _circleIcon(
                        context,
                        Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        'Bản đồ',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(5.2),
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      _circleIcon(context, Icons.more_horiz),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMapPanel(context),
                        SizedBox(height: context.h(0.02)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(0.05),
                          ),
                          child: _buildTargetPanel(context),
                        ),
                        SizedBox(height: context.h(0.02)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapPanel(BuildContext context) {
    final center = _center!;

    return Container(
      height: context.h(0.58),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.w(0.06)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.w(0.06)),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onMapReady: () => _mapController.move(center, 16),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.wello.frontend',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 56,
                      height: 56,
                      point: center,
                      child: _mapMarker(context, Colors.white, Icons.person),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: context.w(0.05),
              top: context.h(0.04),
              child: _statusPill(
                context,
                'Sẵn sàng',
                Icons.fitness_center,
                _accent,
              ),
            ),
            Positioned(
              right: context.w(0.05),
              top: context.h(0.04),
              child: _mapLabel(context, 'Bản đồ trực tiếp', Icons.map),
            ),
            Positioned(
              left: context.w(0.05),
              right: context.w(0.05),
              bottom: context.h(0.03),
              child: _buildLiveStatsCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetPanel(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.04),
        vertical: context.h(0.03),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.04)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'MỤC TIÊU CỦA BẠN',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              fontWeight: FontWeight.w900,
              color: _accent,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: context.h(0.02)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _decreaseGoalValue,
                child: _circleControl(context, Icons.remove),
              ),
              SizedBox(width: context.w(0.06)),
              Text(
                _goalValueText,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(8),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1D2A4D),
                ),
              ),
              SizedBox(width: context.w(0.06)),
              GestureDetector(
                onTap: _increaseGoalValue,
                child: _circleControl(context, Icons.add),
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),
          InkWell(
            onTap: () => _showGoalSheet(context),
            borderRadius: BorderRadius.circular(context.w(0.03)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(0.005)),
              child: Row(
                children: [
                  Icon(
                    _goalIcon(_selectedGoal),
                    size: context.sp(5),
                    color: Colors.black87,
                  ),
                  SizedBox(width: context.w(0.03)),
                  Expanded(
                    child: Text(
                      _goalLabel(_selectedGoal),
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.2),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),
          SizedBox(height: context.h(0.02)),
          Divider(height: 1, color: Colors.grey[200]),
          SizedBox(height: context.h(0.02)),
          InkWell(
            onTap: () => _showActivitySheet(context),
            borderRadius: BorderRadius.circular(context.w(0.03)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(0.005)),
              child: Row(
                children: [
                  Icon(
                    _activityIcon(_selectedActivity),
                    size: context.sp(5),
                    color: Colors.black87,
                  ),
                  SizedBox(width: context.w(0.03)),
                  Expanded(
                    child: Text(
                      _activityLabel(_selectedActivity),
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),
          SizedBox(height: context.h(0.03)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRunning
                  ? null
                  : () async {
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LiveRunningScreen(
                            activityLabel: _activityLabel(_selectedActivity),
                            activityType: _selectedActivity,
                            goalValueText: _goalValueText,
                            selectedGoal: _selectedGoal,
                            targetKm: _targetKm,
                            targetMinutes: _targetMinutes,
                            targetCalories: _targetCalories,
                            targetSteps: _targetSteps,
                            center: _center,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? Colors.grey : _accent,
                padding: EdgeInsets.symmetric(vertical: context.h(0.025)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                ),
              ),
              child: Text(
                _isRunning ? 'Đang chạy' : 'Bắt đầu',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(0.02)),
          _buildLiveStatsCard(context),
        ],
      ),
    );
  }

  void _showGoalSheet(BuildContext context) {
    const goals = [
      {
        'key': 'distance',
        'label': 'Khoảng cách',
        'icon': Icons.pin_drop_outlined,
      },
      {'key': 'time', 'label': 'Thời gian', 'icon': Icons.timer_outlined},
      {
        'key': 'calories',
        'label': 'Calo',
        'icon': Icons.local_fire_department_outlined,
      },
      {'key': 'steps', 'label': 'Bước', 'icon': Icons.directions_walk_outlined},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: context.w(0.05),
              right: context.w(0.05),
              bottom: context.h(0.02),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(0.05),
                vertical: context.h(0.03),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.w(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: goals.map((goal) {
                  final key = goal['key'] as String;
                  final isSelected = _selectedGoal == key;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedGoal = key;
                      });
                      Navigator.pop(sheetContext);
                    },
                    borderRadius: BorderRadius.circular(context.w(0.03)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(0.018)),
                      child: Row(
                        children: [
                          Icon(
                            goal['icon'] as IconData,
                            color: _goalColor(key),
                            size: context.sp(5),
                          ),
                          SizedBox(width: context.w(0.04)),
                          Expanded(
                            child: Text(
                              goal['label'] as String,
                              style: GoogleFonts.baloo2(
                                fontSize: context.sp(4.8),
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            width: context.w(0.075),
                            height: context.w(0.075),
                            decoration: BoxDecoration(
                              color: isSelected ? _accent : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? _accent
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActivitySheet(BuildContext context) {
    const activities = [
      {'key': 'running', 'label': 'Chạy bộ', 'icon': Icons.directions_run},
      {'key': 'walking', 'label': 'Đi bộ', 'icon': Icons.directions_walk},
      {'key': 'cycling', 'label': 'Đạp xe', 'icon': Icons.directions_bike},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: context.w(0.05),
              right: context.w(0.05),
              bottom: context.h(0.02),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(0.05),
                vertical: context.h(0.03),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.w(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: activities.map((activity) {
                  final key = activity['key'] as String;
                  final isSelected = _selectedActivity == key;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedActivity = key;
                      });
                      Navigator.pop(sheetContext);
                    },
                    borderRadius: BorderRadius.circular(context.w(0.03)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(0.018)),
                      child: Row(
                        children: [
                          Container(
                            width: context.w(0.1),
                            height: context.w(0.1),
                            decoration: const BoxDecoration(
                              color: _accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity['icon'] as IconData,
                              color: Colors.white,
                              size: context.sp(4.8),
                            ),
                          ),
                          SizedBox(width: context.w(0.04)),
                          Expanded(
                            child: Text(
                              activity['label'] as String,
                              style: GoogleFonts.baloo2(
                                fontSize: context.sp(4.8),
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            width: context.w(0.075),
                            height: context.w(0.075),
                            decoration: BoxDecoration(
                              color: isSelected ? _accent : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? _accent
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  String get _goalValueText {
    switch (_selectedGoal) {
      case 'time':
        return '$_targetMinutes phút';
      case 'calories':
        return '$_targetCalories kcal';
      case 'steps':
        return '$_targetSteps bước';
      case 'distance':
      default:
        return '$_targetKm km';
    }
  }

  double get _defaultMinutesPerKm {
    switch (_selectedActivity) {
      case 'walking':
        return 12.0;
      case 'cycling':
        return 3.0;
      case 'running':
      default:
        return 5.5;
    }
  }

  double get _defaultCaloriesPerMinute {
    switch (_selectedActivity) {
      case 'walking':
        return 4.5;
      case 'cycling':
        return 7.0;
      case 'running':
      default:
        return 10.0;
    }
  }

  double get _effectiveMinutesPerKm {
    if (_totalKmRun > 0 && _totalMinutesRun > 0) {
      return _totalMinutesRun / _totalKmRun;
    }
    return _defaultMinutesPerKm;
  }

  double get _effectiveCaloriesPerMinute {
    if (_totalCaloriesBurned > 0 && _totalMinutesRun > 0) {
      return _totalCaloriesBurned / _totalMinutesRun;
    }
    return _defaultCaloriesPerMinute;
  }

  double get _targetMinutesEquivalent {
    switch (_selectedGoal) {
      case 'distance':
        return _targetKm * _effectiveMinutesPerKm;
      case 'time':
        return _targetMinutes.toDouble();
      case 'steps':
        final kmFromSteps = _targetSteps / _stepsPerKm;
        return kmFromSteps * _effectiveMinutesPerKm;
      case 'calories':
      default:
        return 0;
    }
  }

  /// Tính toán calo dựa trên mục tiêu được chọn
  int get _calculatedCalories {
    if (_selectedGoal == 'calories') return _targetCalories;
    return (_targetMinutesEquivalent * _effectiveCaloriesPerMinute).round();
  }

  /// Tính toán tốc độ (phút/km) dựa trên mục tiêu
  String get _calculatedSpeed {
    double kmTarget = 0;
    double minuteTarget = 0;
    final pace = _effectiveMinutesPerKm;

    switch (_selectedGoal) {
      case 'distance':
        kmTarget = _targetKm.toDouble();
        minuteTarget = _targetKm * pace;
        break;

      case 'time':
        minuteTarget = _targetMinutes.toDouble();
        kmTarget = _targetMinutes / pace;
        break;

      case 'calories':
        minuteTarget = _targetCalories / _effectiveCaloriesPerMinute;
        kmTarget = minuteTarget / pace;
        break;
      case 'steps':
        kmTarget = _targetSteps / _stepsPerKm;
        minuteTarget = kmTarget * pace;
        break;
      default:
        return '5:25/km';
    }

    if (kmTarget <= 0) return '5:25/km';

    // Tính tốc độ phút/km
    final speedMinutesPerKm = minuteTarget / kmTarget;
    final minutes = speedMinutesPerKm.floor();
    final seconds = ((speedMinutesPerKm - minutes) * 60).toInt();

    return '$minutes:${seconds.toString().padLeft(2, '0')}/km';
  }

  void _increaseGoalValue() {
    setState(() {
      switch (_selectedGoal) {
        case 'time':
          _targetMinutes += 5;
          break;
        case 'calories':
          _targetCalories += 50;
          break;
        case 'steps':
          _targetSteps += 500;
          break;
        case 'distance':
        default:
          _targetKm += 1;
          break;
      }
    });
  }

  void _decreaseGoalValue() {
    setState(() {
      switch (_selectedGoal) {
        case 'time':
          if (_targetMinutes > 5) _targetMinutes -= 5;
          break;
        case 'calories':
          if (_targetCalories > 50) _targetCalories -= 50;
          break;
        case 'steps':
          if (_targetSteps > 500) _targetSteps -= 500;
          break;
        case 'distance':
        default:
          if (_targetKm > 1) _targetKm -= 1;
          break;
      }
    });
  }

  String _goalLabel(String goal) {
    switch (goal) {
      case 'time':
        return 'Thời gian';
      case 'calories':
        return 'Calo';
      case 'steps':
        return 'Bước';
      case 'distance':
      default:
        return 'Khoảng cách';
    }
  }

  IconData _goalIcon(String goal) {
    switch (goal) {
      case 'time':
        return Icons.timer_outlined;
      case 'calories':
        return Icons.local_fire_department_outlined;
      case 'steps':
        return Icons.directions_walk_outlined;
      case 'distance':
      default:
        return Icons.pin_drop_outlined;
    }
  }

  Color _goalColor(String goal) {
    switch (goal) {
      case 'distance':
        return const Color(0xFFD7A05C);
      case 'time':
        return const Color(0xFF18C56E);
      case 'calories':
        return const Color(0xFFFFB31A);
      case 'steps':
        return const Color(0xFFF4C21B);
      default:
        return Colors.black87;
    }
  }

  String _activityLabel(String activity) {
    switch (activity) {
      case 'walking':
        return 'Đi bộ';
      case 'poles':
        return 'Đi bộ kèm gậy';
      case 'cycling':
        return 'Đạp xe';
      case 'mountain':
        return 'Đạp xe leo núi';
      case 'workout':
        return 'Chương trình luyện tập';
      case 'custom':
        return 'Tùy chỉnh tập luyện';
      case 'running':
      default:
        return 'Chạy bộ';
    }
  }

  IconData _activityIcon(String activity) {
    switch (activity) {
      case 'walking':
        return Icons.directions_walk;
      case 'poles':
        return Icons.hiking;
      case 'cycling':
        return Icons.directions_bike;
      case 'mountain':
        return Icons.terrain;
      case 'workout':
        return Icons.assignment_turned_in;
      case 'custom':
        return Icons.tune;
      case 'running':
      default:
        return Icons.directions_run;
    }
  }

  Widget _circleControl(BuildContext context, IconData icon) {
    return Container(
      width: context.w(0.14),
      height: context.w(0.14),
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: context.sp(6)),
    );
  }

  Widget _buildLiveStatsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(context.w(0.05)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _liveMetric(
              context,
              'Mục tiêu',
              _goalValueText,
              Icons.flag_outlined,
            ),
          ),
          Container(width: 1, height: 42, color: Colors.grey[200]),
          Expanded(
            child: _liveMetric(
              context,
              'Tốc độ',
              _calculatedSpeed,
              Icons.speed,
            ),
          ),
          Container(width: 1, height: 42, color: Colors.grey[200]),
          Expanded(
            child: _liveMetric(
              context,
              'Calo',
              '${_calculatedCalories} kcal',
              Icons.local_fire_department,
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: context.sp(4.8), color: _accent),
        SizedBox(height: context.h(0.005)),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4.6),
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3),
            fontWeight: FontWeight.w600,
            color: _accent,
          ),
        ),
      ],
    );
  }

  Widget _statusPill(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.03),
        vertical: context.h(0.008),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(context.w(0.05)),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.sp(3.8), color: color),
          SizedBox(width: context.w(0.01)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.2),
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapLabel(BuildContext context, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.03),
        vertical: context.h(0.008),
      ),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.22),
        borderRadius: BorderRadius.circular(context.w(0.03)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: context.sp(3.8)),
          SizedBox(width: context.w(0.01)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.2),
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapMarker(BuildContext context, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color == Colors.white ? const Color(0xFF1D2834) : Colors.white,
        size: context.sp(4.5),
      ),
    );
  }

  Widget _circleIcon(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(0.11),
        height: context.w(0.11),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: context.sp(4.5)),
      ),
    );
  }
}
