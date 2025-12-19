import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/data_source/exercise_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/exercise_repository_impl.dart';
import 'package:wello_frontend/domain/entities/exercise.dart';
import 'package:intl/intl.dart';

/// Widget to display daily workout history
class WorkoutHistoryWidget extends StatefulWidget {
  const WorkoutHistoryWidget({super.key});

  @override
  State<WorkoutHistoryWidget> createState() => _WorkoutHistoryWidgetState();
}

class _WorkoutHistoryWidgetState extends State<WorkoutHistoryWidget> {
  DailyWorkoutLog? _workoutLog;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      final repository = ExerciseRepositoryImpl(
        remoteDataSource: ExerciseRemoteDataSource(),
      );

      final log = await repository.getDailyWorkoutLog(
        credentials.token,
        credentials.userIdString,
        _selectedDate,
      );

      setState(() {
        _workoutLog = log;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date selector (simplified - just show today)
        Container(
          padding: EdgeInsets.all(context.w(0.04)),
          margin: EdgeInsets.symmetric(
            horizontal: context.w(0.04),
            vertical: context.h(0.02),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEA),
            borderRadius: BorderRadius.circular(context.sp(3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: Color(0xFFEBCF23), size: context.sp(5)),
              SizedBox(width: context.w(0.02)),
              Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),

        // Total calories summary
        if (_workoutLog != null &&!_isLoading)
          Container(
            padding: EdgeInsets.all(context.sp(5)),
            margin: EdgeInsets.symmetric(horizontal: context.w(0.04)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(context.sp(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200.withOpacity(0.5),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, color: Colors.white, size: context.sp(10)),
                SizedBox(width: context.w(0.02)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng calo đốt',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${_workoutLog!.totalCaloriesBurned} calo',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(9),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        SizedBox(height: context.h(0.02)),

        // Workout list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
                  ),
                )
              : _errorMessage != null
                  ? _buildErrorState()
                  : _workoutLog == null || _workoutLog!.workouts.isEmpty
                      ? _buildEmptyState()
                      : _buildWorkoutList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: context.sp(20),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: context.h(0.02)),
          Text(
            'Chưa có bài tập nào',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(6),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: context.h(0.01)),
          Text(
            'Hãy thêm bài tập đầu tiên của bạn!',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4.5),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: context.sp(15), color: Colors.red.shade300),
          SizedBox(height: context.h(0.02)),
          Text(
            'Không thể tải lịch sử',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.5),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: context.h(0.01)),
          ElevatedButton.icon(
            onPressed: _loadWorkoutHistory,
            icon: Icon(Icons.refresh),
            label: Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEBCF23),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
      itemCount: _workoutLog!.workouts.length,
      itemBuilder: (context, index) {
        final workout = _workoutLog!.workouts[index];
        return Container(
          margin: EdgeInsets.only(bottom: context.h(0.015)),
          padding: EdgeInsets.all(context.sp(4)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.sp(3)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(context.sp(3)),
                decoration: BoxDecoration(
                  color: Color(0xFFEBCF23).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_run,
                  color: Color(0xFFEBCF23),
                  size: context.sp(8),
                ),
              ),
              SizedBox(width: context.w(0.04)),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.exerciseName,
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: context.h(0.005)),
                    Text(
                      '${workout.durationMinutes} phút',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${workout.caloriesBurned}',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(7),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  Text(
                    'calo',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
