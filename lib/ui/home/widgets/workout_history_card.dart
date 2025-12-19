import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/core/utils/workout_event_notifier.dart';
import 'package:wello_frontend/data/data_source/exercise_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/exercise_repository_impl.dart';
import 'package:wello_frontend/domain/entities/exercise.dart';
import 'package:intl/intl.dart';

/// Compact workout history widget for Home Screen
class WorkoutHistoryCard extends StatefulWidget {
  const WorkoutHistoryCard({super.key});

  @override
  State<WorkoutHistoryCard> createState() => _WorkoutHistoryCardState();
}

class _WorkoutHistoryCardState extends State<WorkoutHistoryCard> with WidgetsBindingObserver {
  DailyWorkoutLog? _workoutLog;
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWorkoutHistory();
    
    // Listen for workout added events
    WorkoutEventNotifier.workoutAdded.addListener(_onWorkoutAdded);
  }

  @override
  void dispose() {
    WorkoutEventNotifier.workoutAdded.removeListener(_onWorkoutAdded);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onWorkoutAdded() {
    // Reload when a new workout is added
    _loadWorkoutHistory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload when app resumes (e.g., coming back from background)
    if (state == AppLifecycleState.resumed) {
      _loadWorkoutHistory();
    }
  }

  // Public method to manually refresh
  void refresh() {
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) return;

      final repository = ExerciseRepositoryImpl(
        remoteDataSource: ExerciseRemoteDataSource(),
      );

      final log = await repository.getDailyWorkoutLog(
        credentials.token,
        credentials.userIdString,
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      setState(() {
        _workoutLog = log;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

 @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(context.sp(5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sp(5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
          ),
        ),
      );
    }

    if (_workoutLog == null || _workoutLog!.workouts.isEmpty) {
      return SizedBox.shrink(); // Hide if no workouts
    }

    return Container(
      padding: EdgeInsets.all(context.sp(5)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.sp(5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Color(0xFFEBCF23),
                    size: context.sp(6),
                  ),
                  SizedBox(width: context.w(0.02)),
                  Text(
                    'Lịch sử tập luyện',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.03),
                  vertical: context.h(0.005),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  ),
                  borderRadius: BorderRadius.circular(context.sp(2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: context.sp(4),
                    ),
                    SizedBox(width: context.w(0.01)),
                    Text(
                      '${_workoutLog!.totalCaloriesBurned}',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),

          // Workout list (show 3 or all based on _isExpanded)
          // Group workouts by exercise name and sum calories/duration
          ...(() {
            // Group workouts by exerciseName
            final Map<String, WorkoutHistoryItem> groupedWorkouts = {};
            
            for (var workout in _workoutLog!.workouts) {
              if (groupedWorkouts.containsKey(workout.exerciseName)) {
                // Sum calories and duration
                final existing = groupedWorkouts[workout.exerciseName]!;
                groupedWorkouts[workout.exerciseName] = WorkoutHistoryItem(
                  id: existing.id,
                  exerciseName: existing.exerciseName,
                  durationMinutes: existing.durationMinutes + workout.durationMinutes,
                  caloriesBurned: existing.caloriesBurned + workout.caloriesBurned,
                );
              } else {
                groupedWorkouts[workout.exerciseName] = workout;
              }
            }
            
            final workoutList = groupedWorkouts.values.toList();
            final displayList = _isExpanded ? workoutList : workoutList.take(3);
            
            return displayList.map((workout) {
            return Container(
              margin: EdgeInsets.only(bottom: context.h(0.01)),
              padding: EdgeInsets.all(context.sp(3)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(context.sp(2.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_run,
                    color: Color(0xFFEBCF23),
                    size: context.sp(6),
                  ),
                  SizedBox(width: context.w(0.03)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.exerciseName,
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(4.5),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${workout.durationMinutes} phút',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(3.5),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${workout.caloriesBurned}',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5.5),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  SizedBox(width: context.w(0.01)),
                  Text(
                    'calo',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(3.5),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
          })(),

          // Show more/less button
          if (() {
            final Map<String, WorkoutHistoryItem> groupedWorkouts = {};
            for (var workout in _workoutLog!.workouts) {
              if (!groupedWorkouts.containsKey(workout.exerciseName)) {
                groupedWorkouts[workout.exerciseName] = workout;
              }
            }
            return groupedWorkouts.length > 3;
          }())
            Padding(
              padding: EdgeInsets.only(top: context.h(0.01)),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(0.04),
                    vertical: context.h(0.01),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEBCF23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.sp(2)),
                    border: Border.all(
                      color: Color(0xFFEBCF23).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded 
                            ? 'Thu gọn' 
                            : () {
                                final Map<String, WorkoutHistoryItem> groupedWorkouts = {};
                                for (var workout in _workoutLog!.workouts) {
                                  if (!groupedWorkouts.containsKey(workout.exerciseName)) {
                                    groupedWorkouts[workout.exerciseName] = workout;
                                  }
                                }
                                final remaining = groupedWorkouts.length - 3;
                                return 'Xem thêm $remaining bài tập';
                              }(),
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(4),
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEBCF23),
                        ),
                      ),
                      SizedBox(width: context.w(0.01)),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Color(0xFFEBCF23),
                        size: context.sp(5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
