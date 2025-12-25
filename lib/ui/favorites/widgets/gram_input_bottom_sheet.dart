import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class GramInputBottomSheet extends StatefulWidget {
  final String foodName;
  final int baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;

  const GramInputBottomSheet({
    required this.foodName,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
  });

  @override
  State<GramInputBottomSheet> createState() => _GramInputBottomSheetState();
}

class _GramInputBottomSheetState extends State<GramInputBottomSheet> {
  double _grams = 100.0;

  @override
  Widget build(BuildContext context) {
    // Calculate nutrition based on current grams
    final ratio = _grams / 100.0;
    final calories = (widget.baseCalories * ratio).toInt();
    final protein = widget.baseProtein * ratio;
    final carbs = widget.baseCarbs * ratio;
    final fat = widget.baseFat * ratio;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              
              // Food name
              Text(
                widget.foodName,
                style: GoogleFonts.baloo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEBCF23),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              // Grams display
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Khối lượng tiêu thụ',
                      style: GoogleFonts.baloo2(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_grams.toInt()}',
                          style: GoogleFonts.baloo2(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEBCF23),
                          ),
                        ),
                        Text(
                          'g',
                          style: GoogleFonts.baloo2(
                            fontSize: 24,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              // Nutrition info
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutritionItem('Calories', calories.toDouble(), 'kcal', Colors.red),
                    _buildNutritionItem('Protein', protein, 'g', Colors.blue),
                    _buildNutritionItem('Carbs', carbs, 'g', const Color(0xFFEBCF23)),
                    _buildNutritionItem('Fat', fat, 'g', Colors.orange),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Slider
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFFEBCF23),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: const Color(0xFFEBCF23),
                  overlayColor: const Color(0xFFEBCF23).withOpacity(0.2),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                ),
                child: Slider(
                  value: _grams,
                  min: 10,
                  max: 1000,
                  divisions: 99,
                  onChanged: (value) {
                    setState(() {
                      _grams = value;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '10g',
                    style: GoogleFonts.baloo2(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    '1000g',
                    style: GoogleFonts.baloo2(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _grams.toInt());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBCF23),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Thêm món ăn',
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
}
