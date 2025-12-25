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
          
          // Group items by favoriteName
          final Map<String, List<FoodHistoryItem>> comboGroups = {};
          final List<FoodHistoryItem> standaloneItems = [];

          for (var item in items) {
            if (item.favoriteName != null && item.favoriteName!.isNotEmpty) {
              if (!comboGroups.containsKey(item.favoriteName)) {
                comboGroups[item.favoriteName!] = [];
              }
              comboGroups[item.favoriteName!]!.add(item);
            } else {
              standaloneItems.add(item);
            }
          }

          final List<Widget> sectionWidgets = [];

          // 1. Add Combos first
          comboGroups.forEach((comboName, comboItems) {
            // Calculate totals for combo
            final comboCalories = comboItems.fold<double>(0, (sum, item) => sum + item.calories);
            
            // Create a description of items in the combo
            final itemNames = comboItems.map((e) => e.foodName).join(', ');

            // Use the image of the first item that has one, or null
            final firstImage = comboItems.firstWhere(
              (e) => e.imageUrl != null && e.imageUrl!.isNotEmpty, 
              orElse: () => comboItems.first
            ).imageUrl;

            sectionWidgets.add(_buildComboItem(
              name: comboName, 
              calories: comboCalories, 
              description: itemNames,
              imageUrl: firstImage,
              itemCount: comboItems.length,
              context: context
            ));
          });

          // 2. Add standalone items
          for (var item in standaloneItems) {
            sectionWidgets.add(_buildFoodItem(item, context));
          }

          // Add to main list respecting expansion state
          for (var widget in sectionWidgets) {
            if (!_isExpanded && itemsShown >= maxItemsCompact) break;
            mealSections.add(widget);
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
          // Food Image (if available)
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(right: context.w(0.03)),
              width: context.w(0.12),
              height: context.w(0.12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.sp(2)),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

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
                Row(
                  children: [
                    Text(
                      '${item.amountGrams}g',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.5),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (item.favoriteName != null) ...[
                      SizedBox(width: context.w(0.02)),
                      Icon(
                        Icons.favorite,
                        size: context.sp(3),
                        color: const Color(0xFFFF6B6B),
                      ),
                      SizedBox(width: context.w(0.01)),
                      Expanded(
                        child: Text(
                          item.favoriteName!,
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(3.2),
                            color: const Color(0xFFFF6B6B),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
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

  Widget _buildComboItem({
    required String name,
    required double calories,
    required String description,
    required String? imageUrl,
    required int itemCount,
    required BuildContext context,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(0.01)),
      padding: EdgeInsets.all(context.sp(3)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withOpacity(0.3), // Light yellow background for combos
        borderRadius: BorderRadius.circular(context.sp(2.5)),
        border: Border.all(color: const Color(0xFFEBCF23).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Combo Image (or fallback icon)
          Container(
            margin: EdgeInsets.only(right: context.w(0.03)),
            width: context.w(0.12),
            height: context.w(0.12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.sp(2)),
              color: Colors.white,
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.bento, color: const Color(0xFFEBCF23), size: context.sp(6))
                : null,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, size: context.sp(3.5), color: const Color(0xFFFF6B6B)),
                    SizedBox(width: context.w(0.01)),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(4.8),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE65100), // Slightly darker orange/red
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.5),
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${calories.toInt()}',
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
