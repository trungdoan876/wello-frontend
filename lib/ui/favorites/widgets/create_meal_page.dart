import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/data/models/requests/favorite_combo_item.dart';
import 'package:wello_frontend/domain/providers/favorites_provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/meal_selection/selection_screen.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/favorites/widgets/gram_input_bottom_sheet.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';

class CreateMealPage extends StatefulWidget {
  const CreateMealPage({Key? key}) : super(key: key);

  @override
  State<CreateMealPage> createState() => _CreateMealPageState();
}

class _CreateMealPageState extends State<CreateMealPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<_MealIngredient> _ingredients = [];

  void _addIngredientFromSelection(dynamic payload) async {
    if (payload is Map && payload['id'] != null) {
      // Show bottom sheet to input grams
      final baseCalories = (payload['calories'] as int?) ?? 0;
      final baseProtein = (payload['protein'] as num?)?.toDouble() ?? 0.0;
      final baseCarbs = (payload['carbs'] as num?)?.toDouble() ?? 0.0;
      final baseFat = (payload['fat'] as num?)?.toDouble() ?? 0.0;
      
      final grams = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GramInputBottomSheet(
          foodName: payload['name'] as String? ?? 'Món ăn',
          baseCalories: baseCalories,
          baseProtein: baseProtein,
          baseCarbs: baseCarbs,
          baseFat: baseFat,
        ),
      );

      if (grams != null) {
        // Calculate nutrition based on grams
        final ratio = grams / 100.0;
        setState(() {
          _ingredients.add(
            _MealIngredient(
              id: payload['id'] as int,
              name: payload['name'] as String? ?? 'Thực phẩm',
              portionText: '${grams}g',
              calories: (baseCalories * ratio).toInt(),
              protein: baseProtein * ratio,
              carbs: baseCarbs * ratio,
              fat: baseFat * ratio,
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color headerOrange = Color(0xFFEBCF23);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: headerOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tạo mới món ăn',
          style: GoogleFonts.baloo2(
            fontSize: context.sp(7),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.05),
            vertical: context.h(0.015),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.h(0.02)),
              Text(
                'Nhập thông tin về món ăn',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF132439),
                ),
              ),
              SizedBox(height: context.h(0.015)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.04),
                  vertical: context.h(0.008),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.sp(4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameController,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(4.5),
                    color: const Color(0xFF132439),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tên món mới',
                    hintStyle: GoogleFonts.beVietnamPro(
                      fontSize: context.sp(4.5),
                      color: const Color(0xFFB9C1CC),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: context.h(0.03)),
              Text(
                'Thành phần thực phẩm trong món ăn',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF132439),
                ),
              ),
              SizedBox(height: context.h(0.015)),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectionScreen(
                          mealType: 'chon_thuc_pham',
                          mealTitle: 'Chọn thực phẩm',
                        ),
                      ),
                    );
                    if (!mounted) return;
                    if (result != null) {
                      _addIngredientFromSelection(result);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: context.h(0.015),
                      horizontal: context.w(0.08),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE7F4F2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+  Thêm thực phẩm',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(5.5),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF61C8F5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.h(0.02)),
              // Selected ingredients list
              ..._ingredients.map(
                (ing) => _IngredientCard(
                  ingredient: ing,
                  onRemove: () {
                    setState(() {
                      _ingredients.removeWhere((i) => i.id == ing.id);
                    });
                  },
                ),
              ),

              SizedBox(height: context.h(0.02)),
              // Nutrition summary section
              if (_ingredients.isNotEmpty) ...[
                Text(
                  'Thành phần dinh dưỡng',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.5),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF132439),
                  ),
                ),
                SizedBox(height: context.h(0.015)),
                _NutritionSummary(ingredients: _ingredients),
              ],
              SizedBox(height: context.h(0.02)),
              Center(
                child: SizedBox(
                  width: context.w(0.8),
                  child: AnimatedStartButton(
                    text: 'Tạo món ăn mới',
                    onPressed: () {
                      final nameTrimmed = _nameController.text.trim();
                      if (nameTrimmed.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: context.w(0.03)),
                                Expanded(
                                  child: Text(
                                    'Vui lòng nhập tên của món ăn',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFFFF6B6B),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: context.w(0.05),
                              vertical: context.h(0.02),
                            ),
                            elevation: 8,
                          ),
                        );
                        return;
                      }
                      final totalCalories = _ingredients.fold<int>(
                        0,
                        (s, i) => s + (i.calories),
                      );
                      final totalProtein = _ingredients.fold<double>(
                        0.0,
                        (s, i) => s + i.protein,
                      );
                      final totalCarbs = _ingredients.fold<double>(
                        0.0,
                        (s, i) => s + i.carbs,
                      );
                      final totalFat = _ingredients.fold<double>(
                        0.0,
                        (s, i) => s + i.fat,
                      );
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return _AddMealBottomSheet(
                            mealName: nameTrimmed,
                            baseCalories: totalCalories,
                            totalProtein: totalProtein,
                            totalCarbs: totalCarbs,
                            totalFat: totalFat,
                            ingredients: _ingredients,
                            onConfirm: (mealTime, servings) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã thêm "$nameTrimmed" vào nhật ký (${servings} khẩu, ${mealTime.label})',
                                    style: GoogleFonts.beVietnamPro(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: context.h(0.04)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealIngredient {
  final int id;
  final String name;
  final String portionText;
  final int calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  _MealIngredient({
    required this.id,
    required this.name,
    required this.portionText,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _NutritionSummary extends StatelessWidget {
  final List<_MealIngredient> ingredients;
  const _NutritionSummary({Key? key, required this.ingredients})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double totalProtein = ingredients.fold<double>(
      0.0,
      (s, i) => s + (i.protein),
    );
    final double totalCarbs = ingredients.fold<double>(
      0.0,
      (s, i) => s + (i.carbs),
    );
    final double totalFat = ingredients.fold<double>(
      0.0,
      (s, i) => s + (i.fat),
    );
    final int totalCalories = ingredients.fold<int>(
      0,
      (s, i) => s + (i.calories),
    );

    // Energy by macro
    final energyProtein = totalProtein * 4;
    final energyCarbs = totalCarbs * 4;
    final energyFat = totalFat * 9;
    final energySum = energyProtein + energyCarbs + energyFat;

    double _safeShare(double v) {
      if (v.isNaN || v.isInfinite) return 0.0;
      return v.clamp(0.0, 1.0).toDouble();
    }

    final double pShare = _safeShare(
      energySum > 0 ? energyProtein / energySum : 0.0,
    );
    final double cShare = _safeShare(
      energySum > 0 ? energyCarbs / energySum : 0.0,
    );
    final double fShare = _safeShare(
      energySum > 0 ? energyFat / energySum : 0.0,
    );

    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.sp(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Donut chart
          SizedBox(
            width: context.w(0.35),
            height: context.w(0.35),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                return CustomPaint(
                  painter: _DonutPainter(
                    segments: [
                      _Segment(
                        share: cShare,
                        color: const Color(0xFF80DEEA),
                      ), // Carbs soft teal
                      _Segment(
                        share: pShare,
                        color: const Color(0xFFFFCC80),
                      ), // Protein soft peach
                      _Segment(
                        share: fShare,
                        color: const Color(0xFFCE93D8),
                      ), // Fat soft lavender
                    ],
                    centerText: '$totalCalories',
                    animation: t,
                    strokeWidth: 22,
                    gapRadians: 0.06,
                    backgroundColor: const Color(0xFFF2F5F9),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: context.w(0.04)),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendItem(
                  context,
                  color: const Color(0xFF80DEEA),
                  label: 'Carbs · ${(cShare * 100).round()}%',
                  valueText: '${totalCarbs.toStringAsFixed(1)}g',
                ),
                SizedBox(height: context.h(0.008)),
                _legendItem(
                  context,
                  color: const Color(0xFFFFCC80),
                  label: 'Chất đạm · ${(pShare * 100).round()}%',
                  valueText: '${totalProtein.toStringAsFixed(1)}g',
                ),
                SizedBox(height: context.h(0.008)),
                _legendItem(
                  context,
                  color: const Color(0xFFCE93D8),
                  label: 'Chất béo · ${(fShare * 100).round()}%',
                  valueText: '${totalFat.toStringAsFixed(1)}g',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required String valueText,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
        SizedBox(width: context.w(0.02)),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4.5),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF132439),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.02),
            vertical: context.h(0.004),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            valueText,
            style: GoogleFonts.beVietnamPro(
              fontSize: context.sp(4.0),
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Segment {
  final double share; // 0..1
  final Color color;
  _Segment({required this.share, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  final String centerText;
  final double animation; // 0..1
  final double strokeWidth;
  final double gapRadians;
  final Color backgroundColor;
  _DonutPainter({
    required this.segments,
    required this.centerText,
    required this.animation,
    this.strokeWidth = 20,
    this.gapRadians = 0.0,
    this.backgroundColor = const Color(0xFFEFF3F7),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Arc geometry
    double startAngle = -math.pi / 2;
    final arcRect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    // Helper: color tint
    Color _tint(Color c, double amount) {
      final h = HSLColor.fromColor(c);
      final t = h.withLightness((h.lightness + amount).clamp(0.0, 1.0));
      return t.toColor();
    }

    // Draw segments
    for (final s in segments) {
      if (s.share <= 0) continue;
      final totalSweep = (s.share.clamp(0.0, 1.0)) * 2 * math.pi * animation;
      final effectiveGap = math.min(gapRadians, totalSweep * 0.25);
      final sweep = math.max(0.0, totalSweep - effectiveGap);
      final start = startAngle + effectiveGap / 2;

      final gradient = SweepGradient(
        colors: [_tint(s.color, 0.18), s.color, _tint(s.color, -0.10)],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(arcRect);

      final segPaint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

      canvas.drawArc(arcRect, start, sweep, false, segPaint);
      startAngle += totalSweep;
    }

    // Center text and sublabel
    final gradientTextPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD1A1), Color(0xFFFFA66C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: TextStyle(
          foreground: gradientTextPaint,
          fontSize: size.width * 0.22,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset =
        center - Offset(textPainter.width / 2, textPainter.height / 2 + 6);
    textPainter.paint(canvas, textOffset);

    // Sub label 'Kcal'
    final subPainter = TextPainter(
      text: const TextSpan(
        text: 'kcal',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subPainter.layout();
    final subOffset =
        center + Offset(-subPainter.width / 2, textPainter.height / 2 - 2);
    subPainter.paint(canvas, subOffset);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.segments != segments ||
        old.centerText != centerText ||
        old.animation != animation ||
        old.strokeWidth != strokeWidth ||
        old.gapRadians != gapRadians ||
        old.backgroundColor != backgroundColor;
  }
}

enum _MealTime { breakfast, lunch, dinner, snack }

extension _MealTimeX on _MealTime {
  String get label {
    switch (this) {
      case _MealTime.breakfast:
        return 'Bữa sáng';
      case _MealTime.lunch:
        return 'Bữa trưa';
      case _MealTime.dinner:
        return 'Bữa tối';
      case _MealTime.snack:
        return 'Bữa phụ';
    }
  }
}

class _AddMealBottomSheet extends StatefulWidget {
  final String mealName;
  final int baseCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<_MealIngredient> ingredients;
  final void Function(_MealTime mealTime, int servings) onConfirm;
  const _AddMealBottomSheet({
    Key? key,
    required this.mealName,
    required this.baseCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.ingredients,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<_AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends State<_AddMealBottomSheet> {
  _MealTime _selectedTime = _MealTime.dinner;
  int _servings = 1;

  Future<void> _addToFavorites() async {
    try {
      final favoritesProvider = Provider.of<FavoritesProvider>(
        context,
        listen: false,
      );

      // Convert _MealIngredient to FavoriteComboItem
      final items = widget.ingredients.map((ingredient) {
        // Extract grams from portionText (e.g., "100 g" -> 100)
        final gramsMatch = RegExp(r'(\d+)\s*g').firstMatch(ingredient.portionText);
        final amountGrams = gramsMatch != null 
            ? int.parse(gramsMatch.group(1)!) 
            : 100;

        return FavoriteComboItem(
          foodId: ingredient.id,
          amountGrams: amountGrams,
        );
      }).toList();

      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Người dùng chưa đăng nhập');
      final userId = credentials.userId;

      final success = await favoritesProvider.addCombo(
        userId: userId,
        favoriteName: widget.mealName,
        mealType: _selectedTime.toString().split('.').last.toUpperCase(),
        items: items,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đã thêm "${widget.mealName}" vào yêu thích',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2ECC71),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${favoritesProvider.errorMessage}',
              style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi kết nối: $e',
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeOrange = const Color(0xFFEBCF23);
    final totalCalories = (_servings * widget.baseCalories).clamp(0, 999999);

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isLoading = favoritesProvider.isLoading;

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thêm bữa ăn',
                              style: GoogleFonts.baloo2(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: themeOrange,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.mealName,
                              style: GoogleFonts.baloo2(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF132439),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: themeOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: themeOrange, size: 24),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeOrange.withOpacity(0.08),
                          themeOrange.withOpacity(0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: themeOrange.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeOrange.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_fire_department_rounded,
                            color: themeOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Năng lượng',
                                style: GoogleFonts.baloo2(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$totalCalories kcal',
                                style: GoogleFonts.baloo2(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: themeOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Chọn bữa ăn',
                    style: GoogleFonts.baloo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF132439),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _MealTime.values.map((t) {
                      final selected = t == _selectedTime;
                      return Material(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTime = t),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? themeOrange : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? themeOrange
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: themeOrange.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              t.label,
                              style: GoogleFonts.baloo2(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF5E6A78),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: themeOrange.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _addToFavorites,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoading
                              ? Colors.grey
                              : themeOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Thêm vào yêu thích',
                                style: GoogleFonts.baloo2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final _MealIngredient ingredient;
  final VoidCallback onRemove;
  const _IngredientCard({
    Key? key,
    required this.ingredient,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(0.015)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.04),
          vertical: context.h(0.018),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sp(4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5.5),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF132439),
                    ),
                  ),
                  SizedBox(height: context.h(0.006)),
                  Text(
                    '${ingredient.portionText} - ${ingredient.calories} calo',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.5),
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(Icons.close, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
