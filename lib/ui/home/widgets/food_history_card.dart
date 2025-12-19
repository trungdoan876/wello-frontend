import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/domain/entities/food_history_item.dart';

/// Card widget to display daily food intake history on Home Screen
class FoodHistoryCard extends StatefulWidget {
  const FoodHistoryCard({super.key});

  @override
  State<FoodHistoryCard> createState() => _FoodHistoryCardState();
}

class _FoodHistoryCardState extends State<FoodHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingHistory && provider.foodHistory.isEmpty) {
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
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
              ),
            ),
          );
        }

        if (provider.foodHistory.isEmpty) {
          return const SizedBox.shrink(); // Hide if no history
        }

        // Calculate total calories from history
        final totalCalories = provider.foodHistory.fold<double>(
          0.0,
          (sum, item) => sum + item.calories,
        );

        // Group items by meal type
        final Map<String, List<FoodHistoryItem>> groupedItems = {
          'BREAKFAST': [],
          'LUNCH': [],
          'DINNER': [],
          'SNACK': [],
        };

        for (var item in provider.foodHistory) {
          if (groupedItems.containsKey(item.mealType)) {
            groupedItems[item.mealType]!.add(item);
          } else {
            groupedItems['SNACK']!.add(item);
          }
        }

        final sortedMealTypes = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'];
        final List<Widget> mealSections = [];

        int itemsShown = 0;
        const int maxItemsCompact = 3;

        for (var type in sortedMealTypes) {
          final items = groupedItems[type]!;
          if (items.isEmpty) continue;

          // Calculate total calories for this specific meal type
          final mealTotal = items.fold<double>(0, (sum, item) => sum + item.calories);

          mealSections.add(_buildMealHeader(type, mealTotal.toInt(), context));
          
          for (var item in items) {
            if (!_isExpanded && itemsShown >= maxItemsCompact) break;
            
            mealSections.add(_buildFoodItem(item, context));
            itemsShown++;
          }
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
                        Icons.restaurant_menu,
                        color: const Color(0xFFEBCF23),
                        size: context.sp(6),
                      ),
                      SizedBox(width: context.w(0.02)),
                      Text(
                        'Lịch sử ăn uống',
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
                      color: const Color(0xFFEBCF23).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.sp(2)),
                    ),
                    child: Text(
                      '${totalCalories.toInt()} kcal',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEBCF23),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(0.02)),

              // Meal List
              ...mealSections,

              // Show more/less button
              if (provider.foodHistory.length > maxItemsCompact)
                Padding(
                  padding: EdgeInsets.only(top: context.h(0.01)),
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(0.04),
                        vertical: context.h(0.01),
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBCF23).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(context.sp(2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isExpanded ? 'Thu gọn' : 'Xem thêm ${provider.foodHistory.length - maxItemsCompact} món',
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(4),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEBCF23),
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: const Color(0xFFEBCF23),
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
      },
    );
  }

  Widget _buildMealHeader(String type, int total, BuildContext context) {
    String label = '';
    IconData icon = Icons.restaurant;
    Color color = Colors.grey.shade600;
    
    switch (type) {
      case 'BREAKFAST':
        label = 'Bữa sáng';
        icon = Icons.wb_sunny_rounded;
        color = const Color(0xFFFFB300);
        break;
      case 'LUNCH':
        label = 'Bữa trưa';
        icon = Icons.light_mode_rounded;
        color = const Color(0xFF4CAF50);
        break;
      case 'DINNER':
        label = 'Bữa tối';
        icon = Icons.nights_stay_rounded;
        color = const Color(0xFF3F51B5);
        break;
      case 'SNACK':
        label = 'Bữa phụ';
        icon = Icons.coffee_rounded;
        color = const Color(0xFF795548);
        break;
    }

    return Padding(
      padding: EdgeInsets.only(top: context.h(0.015), bottom: context.h(0.005)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: context.sp(5), color: color),
              SizedBox(width: context.w(0.02)),
              Text(
                label,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4.5),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          Text(
            '$total kcal',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.8),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodHistoryItem item, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(0.01)),
      padding: EdgeInsets.all(context.sp(3)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.sp(2.5)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodName,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.8),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.amountGrams}g',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.5),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.calories.toInt()}',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEBCF23),
                ),
              ),
              Text(
                'calo',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(3.2),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
