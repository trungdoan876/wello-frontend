import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';

/// Bottom sheet for logging favorite food with amount selection
class FavoriteFoodDetailSheet extends StatefulWidget {
  final int foodId;
  final String foodName;
  final int baseCalories; // Calories per 100g
  final double baseProtein; // Protein per 100g
  final double baseCarbs; // Carbs per 100g
  final double baseFat; // Fat per 100g
  final String mealType;

  const FavoriteFoodDetailSheet({
    super.key,
    required this.foodId,
    required this.foodName,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    required this.mealType,
  });

  @override
  State<FavoriteFoodDetailSheet> createState() =>
      _FavoriteFoodDetailSheetState();
}

class _FavoriteFoodDetailSheetState extends State<FavoriteFoodDetailSheet> {
  double _amountGrams = 100; // Default 100g
  bool _isLogging = false;
  String? _errorMessage;

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

      // Calculate nutrition for this amount
      final calories = (widget.baseCalories * (_amountGrams / 100)).toInt();
      final protein = widget.baseProtein * (_amountGrams / 100);
      final carbs = widget.baseCarbs * (_amountGrams / 100);
      final fat = widget.baseFat * (_amountGrams / 100);

      // Check if this log will exceed the calorie target
      final summary = nutritionProvider.dailySummary;
      final profile = nutritionProvider.userProfile;

      if (summary != null && profile != null) {
        final currentConsumed = summary.caloriesConsumed;
        final target = profile.dailyCalorieTarget;

        if (currentConsumed + calories > target) {
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

      print('═══════════════════════════════════════════════════════');
      print('📤 THÊM MÓN ĂN TỪ YÊU THÍCH');
      print('═══════════════════════════════════════════════════════');
      print('👤 User ID: $userId');
      print('🍽️  Food Name: ${widget.foodName}');
      print('🆔 Food ID: ${widget.foodId}');
      print('⚖️  Amount: ${_amountGrams.toInt()} grams');
      print('🕐 Meal Type: ${widget.mealType}');
      print('───────────────────────────────────────────────────────');
      print('📊 NUTRITION DATA (CALCULATED):');
      print('🔥 Calories: $calories kcal');
      print('💪 Protein: ${protein.toStringAsFixed(1)} g');
      print('🍞 Carbs: ${carbs.toStringAsFixed(1)} g');
      print('🥑 Fat: ${fat.toStringAsFixed(1)} g');
      print('───────────────────────────────────────────────────────');
      print('✅ OVERRIDE DATA (SENT TO BACKEND):');
      print('   caloriesOverride: $calories');
      print('   foodNameOverride: ${widget.foodName}');
      print('═══════════════════════════════════════════════════════');

      await nutritionProvider.logFood(
        token: credentials.token,
        userId: userId,
        foodId: widget.foodId,
        amountGrams: _amountGrams.toInt(),
        mealType: widget.mealType,
        caloriesOverride: calories,
        foodNameOverride: widget.foodName, // Use name from favorites
      );

      print('✅ API call completed successfully');
      print('═══════════════════════════════════════════════════════');

      if (!mounted) return;

      // Store reference to parent context before popping
      final parentContext = context;

      // Check for goal achievements after logging
      final achievements = nutritionProvider.checkGoals();

      Navigator.pop(context, true); // Return true to indicate success

      if (achievements.isNotEmpty) {
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
    final calories = (widget.baseCalories * (_amountGrams / 100)).toInt();
    final protein = widget.baseProtein * (_amountGrams / 100);
    final carbs = widget.baseCarbs * (_amountGrams / 100);
    final fat = widget.baseFat * (_amountGrams / 100);

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

          // Nutrition Details (from favorites data)
          Container(
            padding: EdgeInsets.all(context.sp(4)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(context.sp(3)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientItem(
                  'Calories',
                  calories.toString(),
                  'kcal',
                  const Color(0xFFFF6B6B),
                ),
                _buildNutrientItem(
                  'Protein',
                  protein.toStringAsFixed(1),
                  'g',
                  const Color(0xFF4ECDC4),
                ),
                _buildNutrientItem(
                  'Carbs',
                  carbs.toStringAsFixed(1),
                  'g',
                  const Color(0xFFFFD93D),
                ),
                _buildNutrientItem(
                  'Fat',
                  fat.toStringAsFixed(1),
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
}
