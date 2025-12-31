import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/core/utils/workout_event_notifier.dart';
import 'package:wello_frontend/data/data_source/exercise_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/exercise_repository_impl.dart';
import 'package:wello_frontend/domain/entities/exercise.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for selecting exercise duration and logging workout
class ExerciseDetailSheet extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseDetailSheet({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  double _durationMinutes = 30; // Default 30 minutes
  int _estimatedCalories = 0;
  bool _isCalculating = false;
  bool _isLogging = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculateCalories();
  }

  Future<void> _calculateCalories() async {
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      print('Dang tinh calo cho bai tap ${widget.exerciseId}, thoi gian: ${_durationMinutes.toInt()}');

      final repository = ExerciseRepositoryImpl(
        remoteDataSource: ExerciseRemoteDataSource(),
      );

      final preview = await repository.calculateCalories(
        credentials.token,
        credentials.userIdString,
        widget.exerciseId,
        _durationMinutes.toInt(),
      );

      print('Da tinh xong calo: ${preview.estimatedCalories}');

      setState(() {
        _estimatedCalories = preview.estimatedCalories;
        _isCalculating = false;
      });
    } catch (e) {
      print('Loi khi tinh calo: $e');
      setState(() {
        _errorMessage = e.toString();
        _isCalculating = false;
      });
    }
  }

  Future<void> _logWorkout() async {
    setState(() {
      _isLogging = true;
      _errorMessage = null;
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      final repository = ExerciseRepositoryImpl(
        remoteDataSource: ExerciseRemoteDataSource(),
      );

      final userId = int.tryParse(credentials.userIdString) ?? 0;
      if (userId == 0) throw Exception('Invalid user ID');

      final workoutLog = WorkoutLog(
        userId: userId,
        exerciseId: widget.exerciseId,
        durationMinutes: _durationMinutes.toInt(),
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      await repository.logWorkout(credentials.token, workoutLog);

      if (!mounted) return;
      
      // Reload nutrition data to update calories burned on HomeScreen
      print('Dang tai lai du lieu dinh duong sau khi luu bai tap...');
      final nutritionProvider = context.read<NutritionProvider>();
      await nutritionProvider.loadDailySummary(
        credentials.token,
        credentials.userIdString,
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      print('Da tai lai du lieu dinh duong thanh cong');
      
      // Notify workout history to reload
      WorkoutEventNotifier.notifyWorkoutAdded();
      
      Navigator.pop(context, true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã lưu bài tập ${widget.exerciseName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLogging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.05)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.sp(6)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: context.w(0.15),
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: context.h(0.02)),

          // Title
          Text(
            widget.exerciseName,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(7),
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEBCF23),
            ),
          ),
          SizedBox(height: context.h(0.01)),

          // Calorie display
          Container(
            padding: EdgeInsets.all(context.sp(5)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEA),
              borderRadius: BorderRadius.circular(context.sp(4)),
            ),
            child: Column(
              children: [
                Text(
                  'Calories đốt cháy dự kiến',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.5),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: context.h(0.005)),
                _isCalculating
                    ? SizedBox(
                        width: context.sp(8),
                        height: context.sp(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
                        ),
                      )
                    : Text(
                        '$_estimatedCalories',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF6B6B),
                        ),
                      ),
                Text(
                  'calo',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(0.03)),

          // Duration slider
          Text(
            'Thời gian tập',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.5),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: context.h(0.01)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_durationMinutes.toInt()}',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEBCF23),
                ),
              ),
              SizedBox(width: context.w(0.02)),
              Text(
                'phút',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Slider(
            value: _durationMinutes,
            min: 5,
            max: 120,
            divisions: 23, // 5-minute increments
            activeColor: const Color(0xFFEBCF23),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              setState(() => _durationMinutes = value);
            },
            onChangeEnd: (value) {
              _calculateCalories(); // Recalculate when user stops sliding
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 phút',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '120 phút',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),

          // Info note
          Container(
            padding: EdgeInsets.all(context.sp(4)),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(context.sp(2.5)),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: context.sp(5),
                ),
                SizedBox(width: context.w(0.02)),
                Expanded(
                  child: Text(
                    'Lượng calo bạn đốt qua tập luyện sẽ không ảnh hưởng vào lượng calo mà bạn đã ăn',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4),
                      color: Colors.blue.shade800,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(0.02)),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.only(bottom: context.h(0.02)),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLogging ? null : _logWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBCF23),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: context.h(0.02)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.sp(3)),
                ),
                elevation: 2,
              ),
              child: _isLogging
                  ? SizedBox(
                      width: context.sp(6),
                      height: context.sp(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Lưu bài tập',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: context.h(0.02)),
        ],
      ),
    );
  }
}
