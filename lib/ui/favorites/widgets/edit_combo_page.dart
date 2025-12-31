import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wello_frontend/data/models/requests/favorite_combo_item.dart';
import 'package:wello_frontend/data/models/responses/favorite_combo_response.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/favorites_provider.dart';
import 'package:wello_frontend/ui/meal_selection/selection_screen.dart';
import 'package:wello_frontend/ui/favorites/widgets/gram_input_bottom_sheet.dart';

/// Full-featured edit combo page
class EditComboPage extends StatefulWidget {
  final int favoriteId;
  final int userId;

  const EditComboPage({
    super.key,
    required this.favoriteId,
    required this.userId,
  });

  @override
  State<EditComboPage> createState() => _EditComboPageState();
}

class _EditComboPageState extends State<EditComboPage> {
  late TextEditingController _nameController;
  String _selectedMealType = 'LUNCH';
  List<FavoriteComboItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'];
  final Map<String, String> _mealTypeLabels = {
    'BREAKFAST': 'Sáng',
    'LUNCH': 'Trưa',
    'DINNER': 'Tối',
    'SNACK': 'Phụ',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadComboData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadComboData() async {
    try {
      final provider = context.read<FavoritesProvider>();
      final combo = await provider.getFavoriteById(
        favoriteId: widget.favoriteId,
        userId: widget.userId,
      );

      if (combo != null) {
        setState(() {
          _nameController.text = combo.favoriteName;
          _selectedMealType = combo.mealType;
          _items = List.from(combo.items);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể tải dữ liệu combo';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addItemFromSelection(dynamic payload) async {
    if (payload is Map && payload['id'] != null) {
      // Show beautiful bottom sheet with slider and nutrition info
      final baseCalories = (payload['calories'] as int?) ?? 0;
      final baseProtein = (payload['protein'] as num?)?.toDouble() ?? 0.0;
      final baseCarbs = (payload['carbs'] as num?)?.toDouble() ?? 0.0;
      final baseFat = (payload['fat'] as num?)?.toDouble() ?? 0.0;
      
      final result = await showModalBottomSheet<int>(
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

      if (result != null) {
        setState(() {
          _items.add(
            FavoriteComboItem(
              foodId: payload['id'] as int,
              foodName: payload['name'] as String?,
              amountGrams: result,
              calories: payload['calories'] as int?,
              protein: (payload['protein'] as num?)?.toDouble(),
              carbs: (payload['carbs'] as num?)?.toDouble(),
              fat: (payload['fat'] as num?)?.toDouble(),
            ),
          );
        });
      }
    }
  }

  Widget _buildNutritionItem(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: GoogleFonts.baloo2(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  void _editItem(int index) async {
    final item = _items[index];
    
    // Calculate base nutrition per 100g from current item
    final currentRatio = item.amountGrams / 100.0;
    final baseCalories = currentRatio > 0 ? ((item.calories ?? 0) / currentRatio).toInt() : 0;
    final baseProtein = currentRatio > 0 ? (item.protein ?? 0.0) / currentRatio : 0.0;
    final baseCarbs = currentRatio > 0 ? (item.carbs ?? 0.0) / currentRatio : 0.0;
    final baseFat = currentRatio > 0 ? (item.fat ?? 0.0) / currentRatio : 0.0;
    
    final newGrams = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GramInputBottomSheet(
        foodName: item.foodName ?? 'Món ăn',
        baseCalories: baseCalories,
        baseProtein: baseProtein,
        baseCarbs: baseCarbs,
        baseFat: baseFat,
      ),
    );

    if (newGrams != null) {
      // Update item with new grams and recalculated nutrition
      final ratio = newGrams / 100.0;
      setState(() {
        _items[index] = FavoriteComboItem(
          itemId: item.itemId,
          foodId: item.foodId,
          foodName: item.foodName,
          amountGrams: newGrams,
          calories: (baseCalories * ratio).toInt(),
          protein: baseProtein * ratio,
          carbs: baseCarbs * ratio,
          fat: baseFat * ratio,
        );
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: 'Vui lòng nhập tên combo',
        confirmBtnText: 'Đồng ý',
      );
      return;
    }

    if (_items.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: 'Vui lòng thêm ít nhất 1 món ăn',
        confirmBtnText: 'Đồng ý',
      );
      return;
    }

    try {
      final provider = context.read<FavoritesProvider>();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
          ),
        ),
      );

      final success = await provider.updateCombo(
        userId: widget.userId,
        favoriteId: widget.favoriteId,
        favoriteName: _nameController.text.trim(),
        mealType: _selectedMealType,
        items: _items,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (success) {
        Navigator.pop(context, true); // Return to previous screen
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công!',
          text: 'Đã cập nhật combo',
          confirmBtnText: 'Đồng ý',
          confirmBtnColor: const Color(0xFFEBCF23),
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi!',
          text: provider.errorMessage ?? 'Không thể cập nhật combo',
          confirmBtnText: 'Đồng ý',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi!',
        text: e.toString(),
        confirmBtnText: 'Đồng ý',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color headerOrange = Color(0xFFEBCF23);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: headerOrange,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Chỉnh sửa combo',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(7),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(headerOrange),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: headerOrange,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Chỉnh sửa combo',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(7),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: GoogleFonts.baloo2(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final totalCalories = _items.fold<int>(0, (sum, item) => sum + (item.calories ?? 0));
    final totalProtein = _items.fold<double>(0.0, (sum, item) => sum + (item.protein ?? 0.0));
    final totalCarbs = _items.fold<double>(0.0, (sum, item) => sum + (item.carbs ?? 0.0));
    final totalFat = _items.fold<double>(0.0, (sum, item) => sum + (item.fat ?? 0.0));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: headerOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chỉnh sửa combo',
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
              
              // Tên combo
              Text(
                'Tên combo',
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
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF132439),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Cơm tấm sườn',
                    hintStyle: GoogleFonts.baloo2(
                      fontSize: context.sp(5),
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: context.h(0.03)),

              // Meal type
              Text(
                'Bữa ăn',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF132439),
                ),
              ),
              SizedBox(height: context.h(0.015)),
              Wrap(
                spacing: context.w(0.02),
                runSpacing: context.h(0.01),
                children: _mealTypes.map((type) {
                  final isSelected = _selectedMealType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMealType = type),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(0.04),
                        vertical: context.h(0.01),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? headerOrange : Colors.white,
                        borderRadius: BorderRadius.circular(context.sp(5)),
                        border: Border.all(
                          color: isSelected ? headerOrange : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: headerOrange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        _mealTypeLabels[type] ?? type,
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(4),
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: context.h(0.03)),

              // Items list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thành phần (${_items.length} món)',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5.5),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF132439),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectionScreen(
                            mealType: 'chon_thuc_pham',
                            mealTitle: 'Chọn thực phẩm',
                          ),
                        ),
                      );
                      
                      if (result != null) {
                        _addItemFromSelection(result);
                      }
                    },
                    icon: Icon(Icons.add, size: context.sp(5)),
                    label: Text(
                      'Thêm',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(0.04),
                        vertical: context.h(0.01),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.sp(3)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(0.015)),

              // Items
              if (_items.isEmpty)
                Container(
                  padding: EdgeInsets.all(context.w(0.08)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.sp(4)),
                  ),
                  child: Center(
                    child: Text(
                      'Chưa có món ăn nào\nNhấn "Thêm" để thêm món',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                )
              else
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: context.h(0.015)),
                    child: GestureDetector(
                      onTap: () => _editItem(index),
                      child: Container(
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
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.foodName ?? 'Món ăn #${item.foodId}',
                                    style: GoogleFonts.baloo2(
                                      fontSize: context.sp(5),
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF132439),
                                    ),
                                  ),
                                  SizedBox(height: context.h(0.006)),
                                  Text(
                                    '${item.amountGrams}g - ${item.calories ?? 0} calo',
                                    style: GoogleFonts.baloo2(
                                      fontSize: context.sp(4),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeItem(index),
                              icon: Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

              SizedBox(height: context.h(0.03)),

              // Total nutrition
              if (_items.isNotEmpty) ...[
                Text(
                  'Thành phần dinh dưỡng',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.5),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF132439),
                  ),
                ),
                SizedBox(height: context.h(0.015)),
                _NutritionSummary(
                  totalCalories: totalCalories,
                  totalProtein: totalProtein,
                  totalCarbs: totalCarbs,
                  totalFat: totalFat,
                ),
              ],

              SizedBox(height: context.h(0.04)),

              // Save button at bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: context.h(0.02)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.sp(3)),
                    ),
                    elevation: 4,
                    shadowColor: headerOrange.withOpacity(0.4),
                  ),
                  child: Text(
                    'Cập nhật',
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
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(0.008)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.w(0.02)),
              Text(
                label,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4.5),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF132439),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionSummary extends StatelessWidget {
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const _NutritionSummary({
    Key? key,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
