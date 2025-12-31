import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/domain/providers/favorites_provider.dart';

/// Bottom sheet for logging favorite food with amount selection
class FavoriteFoodDetailSheet extends StatefulWidget {
  final int foodId;
  final String foodName;
  final int totalCalories; // Total calories of the combo
  final double totalProtein; // Total protein of the combo
  final double totalCarbs; // Total carbs of the combo
  final double totalFat; // Total fat of the combo
  final String mealType;

  const FavoriteFoodDetailSheet({
    super.key,
    required this.foodId,
    required this.foodName,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealType,
  });

  @override
  State<FavoriteFoodDetailSheet> createState() =>
      _FavoriteFoodDetailSheetState();
}

class _FavoriteFoodDetailSheetState extends State<FavoriteFoodDetailSheet> {
  bool _isLogging = false;
  String? _errorMessage;
  late String _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
  }

  Future<void> _logFood() async {
    print('👉 STARTING _logFood()');
    setState(() {
      _isLogging = true;
      _errorMessage = null;
    });

    try {
      print('🔐 Getting credentials...');
      final credentials = await AuthHelper.getCredentials();
      print('🔐 Credentials found: ${credentials != null}');
      if (credentials == null) throw Exception('Not authenticated');

      final userId = int.tryParse(credentials.userIdString) ?? 0;
      if (userId == 0) throw Exception('Invalid user ID');

      final nutritionProvider = context.read<NutritionProvider>();

      // Use total nutrition values directly (no calculation needed)
      final calories = widget.totalCalories;
      final protein = widget.totalProtein;
      final carbs = widget.totalCarbs;
      final fat = widget.totalFat;

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
      print('🕐 Meal Type: $_selectedMealType');
      print('───────────────────────────────────────────────────────');
      print('📊 NUTRITION DATA (CALCULATED):');
      print('🔥 Calories: $calories kcal');
      print('💪 Protein: ${protein.toStringAsFixed(1)} g');
      print('🍞 Carbs: ${carbs.toStringAsFixed(1)} g');
      print('🥑 Fat: ${fat.toStringAsFixed(1)} g');
      print('───────────────────────────────────────────────────────');
      print('✅ API Call: favoritesProvider.logFavorite');
      print('   favoriteId: ${widget.foodId} (from favorite model)');
      print('   mealType: $_selectedMealType');
      // print('   date: ${nutritionProvider.selectedDate}'); // Ensure selectedDate is available

      // Use FavoritesProvider to log the combo directly
      final favoritesProvider = context.read<FavoritesProvider>();
      
      final success = await favoritesProvider.logFavorite(
        userId: userId,
        favoriteId: widget.foodId, // This is the favoriteId
        date: nutritionProvider.selectedDate,
        mealType: _selectedMealType,
      );

      if (!success) {
        throw Exception(favoritesProvider.errorMessage ?? 'Failed to log favorite');
      }

      print('✅ Favorite logged successfully. Refreshing nutrition data...');

      // Refresh nutrition data
      await nutritionProvider.loadDailySummary(
        credentials.token,
        userId.toString(),
        nutritionProvider.selectedDate,
      );
      
      await nutritionProvider.loadFoodHistory(
        credentials.token,
        userId.toString(),
        nutritionProvider.selectedDate,
      );
      
      print('✅ Data refreshed');
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
      print('❌ ERROR in _logFood: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLogging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use total nutrition values directly (no calculation needed)
    final calories = widget.totalCalories;
    final protein = widget.totalProtein;
    final carbs = widget.totalCarbs;
    final fat = widget.totalFat;

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

          // Nutrition Details (total values from combo)
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
          SizedBox(height: context.h(0.03)),

          // Meal Type Selection
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Chọn bữa ăn:',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(height: context.h(0.01)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMealTypeChip('Sáng', 'BREAKFAST'),
                SizedBox(width: context.w(0.02)),
                _buildMealTypeChip('Trưa', 'LUNCH'),
                SizedBox(width: context.w(0.02)),
                _buildMealTypeChip('Tối', 'DINNER'),
                SizedBox(width: context.w(0.02)),
                _buildMealTypeChip('Phụ', 'SNACK'),
              ],
            ),
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

  Widget _buildMealTypeChip(String label, String value) {
    final isSelected = _selectedMealType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMealType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.04),
          vertical: context.h(0.01),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBCF23) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(context.sp(5)),
          border: Border.all(
            color: isSelected ? const Color(0xFFEBCF23) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
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
