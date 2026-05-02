import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/data/data_source/food_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/food_repository_impl.dart';
import 'package:wello_frontend/ui/home/home_screen.dart';
import 'package:wello_frontend/domain/entities/food.dart';
import 'package:wello_frontend/domain/entities/goal_status.dart';

/// Bottom sheet for selecting food amount and logging intake
class FoodDetailSheet extends StatefulWidget {
  final int foodId;
  final String foodName;
  final int
  baseCalories; // Calories per 100g (assumed based on standard food DB)
  final String mealType;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;

  const FoodDetailSheet({
    super.key,
    required this.foodId,
    required this.foodName,
    required this.mealType,
    this.baseCalories = 0,
    this.baseProtein = 0,
    this.baseCarbs = 0,
    this.baseFat = 0,
  });

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  double _amountGrams = 100; // Default 100g
  bool _isLogging = false;
  bool _isPreviewing = false;
  Food? _previewData;
  String? _errorMessage;
  late final bool _hasBaseData;

  @override
  void initState() {
    super.initState();
    _hasBaseData =
        (widget.baseCalories > 0) ||
        (widget.baseProtein > 0) ||
        (widget.baseCarbs > 0) ||
        (widget.baseFat > 0);

    // Chỉ gọi preview API nếu không có dữ liệu base truyền vào
    if (!_hasBaseData) {
      _previewNutrients();
    }
  }

  Future<void> _previewNutrients() async {
    setState(() {
      _isPreviewing = true;
      _errorMessage = null;
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      final repository = FoodRepositoryImpl(
        remoteDataSource: FoodRemoteDataSource(),
      );

      final preview = await repository.previewFood(
        credentials.token,
        widget.foodId,
        _amountGrams.toInt(),
      );

      setState(() {
        _previewData = preview;
        _isPreviewing = false;
      });
    } catch (e) {
      setState(() {
        _isPreviewing = false;
      });
      // Don't show error for preview, just keep old data or show 0
    }
  }

  Future<void> _logFood() async {
    setState(() {
      _isLogging = true;
      _errorMessage = null;
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      final userId = int.tryParse(credentials.userIdString) ?? 0;
      if (userId == 0) throw Exception('Invalid user ID');

      final nutritionProvider = context.read<NutritionProvider>();

      // Check if this log will exceed the calorie target
      final summary = nutritionProvider.dailySummary;
      final profile = nutritionProvider.userProfile;

      // Get calories from preview or calculate from base data
      int? newCalories;
      if (_previewData != null) {
        newCalories = _previewData!.calories;
      } else if (_hasBaseData) {
        // Tính từ base data
        newCalories = (widget.baseCalories * (_amountGrams / 100)).toInt();
      }

      if (summary != null &&
          profile != null &&
          newCalories != null &&
          newCalories > 0) {
        final currentConsumed = summary.caloriesConsumed;
        final target = profile.dailyCalorieTarget;

        if (currentConsumed + newCalories > target) {
          // Show confirmation dialog
          bool proceed = false;
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.confirm,
            title: 'Cảnh báo mục tiêu',
            text:
                'Món ăn này sẽ khiến bạn vượt mục tiêu Calorie trong ngày. Bạn có chắc chắn muốn thêm không?',
            confirmBtnText: 'Vẫn thêm',
            cancelBtnText: 'Hủy',
            confirmBtnColor: const Color(0xFFEBCF23),
            onConfirmBtnTap: () {
              proceed = true;
              Navigator.pop(context);
            },
          );

          if (!proceed) {
            setState(() => _isLogging = false);
            return;
          }
        }
      }

      final result = await nutritionProvider.logFood(
        token: credentials.token,
        userId: userId,
        foodId: widget.foodId,
        amountGrams: _amountGrams.toInt(),
        mealType: widget.mealType,
      );

      // ⭐ HIỂN THỊ CHÚC MỪNG CHUỖI MỚI (STREAK)
      if (result.engagement != null && result.engagement!.isStreak) {
        HomeScreen.homeKey.currentState?.showStreakCelebration(result.engagement!.message);
      }

      if (!mounted) return;

      // Store reference to parent context before popping
      final parentContext = context;

      // Check for goal achievements after logging
      final achievements = nutritionProvider.checkGoals();

      Navigator.pop(context, true); // Return true to indicate success

      if (achievements.isNotEmpty) {
        // Show celebration only for goals that were reached but not exceeded
        // (Since exceeding was already handled by the pre-log confirmation)
        final celebrates = achievements.where((a) => !a.exceeded).toList();

        if (celebrates.isNotEmpty) {
          final achievement = celebrates.first;
          QuickAlert.show(
            context: parentContext,
            type: QuickAlertType.success,
            title: 'Tuyệt vời!',
            text: achievement.message,
            confirmBtnText: 'Đồng ý',
            confirmBtnColor: const Color(0xFFEBCF23),
          );
        }
      }
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
            widget.foodName,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(7),
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEBCF23),
            ),
          ),
          SizedBox(height: context.h(0.02)),

          // Grams display
          Container(
            padding: EdgeInsets.all(context.sp(5)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEA),
              borderRadius: BorderRadius.circular(context.sp(4)),
            ),
            child: Column(
              children: [
                Text(
                  'Khối lượng tiêu thụ',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.5),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: context.h(0.01)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${_amountGrams.toInt()}',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEBCF23),
                      ),
                    ),
                    SizedBox(width: context.w(0.01)),
                    Text(
                      'g',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(0.02)),

          // Nutrition Details Preview (fallback to base macros if preview missing)
          Container(
            padding: EdgeInsets.all(context.sp(4)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(context.sp(3)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _isPreviewing && _previewData == null
                ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutrientItem(
                        'Calories',
                        _previewData != null
                            ? '${_previewData!.calories}'
                            : _formatNumber(
                                widget.baseCalories * (_amountGrams / 100),
                              ),
                        'kcal',
                        const Color(0xFFFF6B6B),
                      ),
                      _buildNutrientItem(
                        'Protein',
                        _previewData != null
                            ? _previewData!.protein.toStringAsFixed(1)
                            : _formatNumber(
                                widget.baseProtein * (_amountGrams / 100),
                                decimals: 1,
                              ),
                        'g',
                        const Color(0xFF4ECDC4),
                      ),
                      _buildNutrientItem(
                        'Carbs',
                        _previewData != null
                            ? _previewData!.carbs.toStringAsFixed(1)
                            : _formatNumber(
                                widget.baseCarbs * (_amountGrams / 100),
                                decimals: 1,
                              ),
                        'g',
                        const Color(0xFFFFD93D),
                      ),
                      _buildNutrientItem(
                        'Fat',
                        _previewData != null
                            ? _previewData!.fat.toStringAsFixed(1)
                            : _formatNumber(
                                widget.baseFat * (_amountGrams / 100),
                                decimals: 1,
                              ),
                        'g',
                        const Color(0xFFFF8066),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: context.h(0.01)),
          SizedBox(height: context.h(0.03)),

          // Slider
          Slider(
            value: _amountGrams,
            min: 10,
            max: 1000,
            divisions: 99, // 10g increments
            activeColor: const Color(0xFFEBCF23),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              setState(() => _amountGrams = value);
            },
            onChangeEnd: (value) {
              if (!_hasBaseData) {
                _previewNutrients();
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10g',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '1000g',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.04)),

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
              onPressed: _isLogging ? null : _logFood,
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
                      'Thêm món ăn',
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

  Widget _buildNutrientItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3.5),
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4.5),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3),
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _formatNumber(double value, {int decimals = 1}) {
    return value.toStringAsFixed(decimals);
  }
}
