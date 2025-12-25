import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wello_frontend/data/models/requests/favorite_combo_item.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/favorites_provider.dart';

/// Bottom sheet for editing a favorite meal
class EditFavoriteFoodSheet extends StatefulWidget {
  final int favoriteId;
  final String initialFoodName;
  final int initialCaloriesPer100g;
  final double initialProteinPer100g;
  final double initialCarbsPer100g;
  final double initialFatPer100g;
  final String initialMealType;

  const EditFavoriteFoodSheet({
    super.key,
    required this.favoriteId,
    required this.initialFoodName,
    required this.initialCaloriesPer100g,
    required this.initialProteinPer100g,
    required this.initialCarbsPer100g,
    required this.initialFatPer100g,
    required this.initialMealType,
  });

  @override
  State<EditFavoriteFoodSheet> createState() => _EditFavoriteFoodSheetState();
}

class _EditFavoriteFoodSheetState extends State<EditFavoriteFoodSheet> {
  late TextEditingController _foodNameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late String _selectedMealType;
  bool _isUpdating = false;
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
    _foodNameController = TextEditingController(text: widget.initialFoodName);
    _caloriesController = TextEditingController(text: widget.initialCaloriesPer100g.toString());
    _proteinController = TextEditingController(text: widget.initialProteinPer100g.toString());
    _carbsController = TextEditingController(text: widget.initialCarbsPer100g.toString());
    _fatController = TextEditingController(text: widget.initialFatPer100g.toString());
    _selectedMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _updateFavorite() async {
    // Validate inputs
    if (_foodNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên món ăn');
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      final userId = int.tryParse(credentials.userIdString) ?? 0;
      if (userId == 0) throw Exception('Invalid user ID');

      final favoritesProvider = context.read<FavoritesProvider>();

      // Fetch the actual combo data to get the items
      final favoriteCombo = await favoritesProvider.getFavoriteById(
        favoriteId: widget.favoriteId,
        userId: userId,
      );

      if (favoriteCombo == null) {
        throw Exception('Không thể tải dữ liệu combo');
      }

      // Use the existing items from the fetched combo
      final items = favoriteCombo.items;

      final success = await favoritesProvider.updateCombo(
        userId: userId,
        favoriteId: widget.favoriteId,
        favoriteName: _foodNameController.text.trim(),
        mealType: _selectedMealType,
        items: items,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true); // Return true to indicate success
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công!',
          text: 'Đã cập nhật món ăn yêu thích',
          confirmBtnText: 'Đồng ý',
          confirmBtnColor: const Color(0xFFEBCF23),
        );
      } else {
        setState(() {
          _errorMessage = favoritesProvider.errorMessage ?? 'Có lỗi xảy ra';
          _isUpdating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isUpdating = false;
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
      child: SingleChildScrollView(
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
              'Chỉnh sửa món ăn yêu thích',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(7),
                fontWeight: FontWeight.bold,
                color: const Color(0xFFEBCF23),
              ),
            ),
            SizedBox(height: context.h(0.03)),

            // Food Name
            _buildTextField(
              controller: _foodNameController,
              label: 'Tên món ăn',
              icon: Icons.restaurant,
            ),
            SizedBox(height: context.h(0.02)),

            // Calories
            _buildTextField(
              controller: _caloriesController,
              label: 'Calories (trên 100g)',
              icon: Icons.local_fire_department,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: context.h(0.02)),

            // Protein
            _buildTextField(
              controller: _proteinController,
              label: 'Protein (g/100g)',
              icon: Icons.fitness_center,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: context.h(0.02)),

            // Carbs
            _buildTextField(
              controller: _carbsController,
              label: 'Carbs (g/100g)',
              icon: Icons.grain,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: context.h(0.02)),

            // Fat
            _buildTextField(
              controller: _fatController,
              label: 'Fat (g/100g)',
              icon: Icons.water_drop,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: context.h(0.02)),

            // Meal Type Selector
            Container(
              padding: EdgeInsets.all(context.sp(4)),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEA),
                borderRadius: BorderRadius.circular(context.sp(3)),
                border: Border.all(color: const Color(0xFFEBCF23).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bữa ăn',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.5),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: context.h(0.01)),
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
                            color: isSelected ? const Color(0xFFEBCF23) : Colors.white,
                            borderRadius: BorderRadius.circular(context.sp(5)),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFEBCF23) : Colors.grey.shade300,
                            ),
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
                ],
              ),
            ),
            SizedBox(height: context.h(0.03)),

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

            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateFavorite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEBCF23),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.h(0.02)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.sp(3)),
                  ),
                  elevation: 2,
                ),
                child: _isUpdating
                    ? SizedBox(
                        width: context.sp(6),
                        height: context.sp(6),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.baloo2(
          fontSize: context.sp(4.5),
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFEBCF23)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.sp(3)),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.sp(3)),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.sp(3)),
          borderSide: BorderSide(color: const Color(0xFFEBCF23), width: 2),
        ),
      ),
      style: GoogleFonts.baloo2(
        fontSize: context.sp(5),
        color: Colors.black87,
      ),
    );
  }
}
