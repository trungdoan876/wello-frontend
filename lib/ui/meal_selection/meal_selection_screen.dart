import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'widgets/meal_search_bar.dart';
import 'widgets/meal_item_card.dart';

class MealItem {
  final String name;
  final String description;
  final int calories;

  const MealItem({
    required this.name,
    required this.description,
    required this.calories,
  });
}

class MealSelectionScreen extends StatefulWidget {
  final String mealType;
  final String mealTitle;

  const MealSelectionScreen({
    super.key,
    required this.mealType,
    required this.mealTitle,
  });

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  late TextEditingController _searchController;
  List<MealItem> _filteredItems = [];
  List<MealItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadMealItems();
    _filterItems('');
  }

  void _loadMealItems() {
    _allItems = [
      const MealItem(name: 'Cơm ếch', description: '1 khẩu phần ăn - 203 calo', calories: 203),
      const MealItem(name: 'Cơm gà', description: '1 khẩu phần ăn - 250 calo', calories: 250),
      const MealItem(name: 'Cơm bò', description: '1 khẩu phần ăn - 280 calo', calories: 280),
      const MealItem(name: 'Canh chua', description: '1 tô - 50 calo', calories: 50),
      const MealItem(name: 'Salad rau', description: '1 bát - 80 calo', calories: 80),
      const MealItem(name: 'Xúc xích', description: '1 cái - 150 calo', calories: 150),
    ];
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = query.isEmpty
          ? _allItems
          : _allItems
              .where((item) =>
                  item.name.toLowerCase().contains(query.toLowerCase()) ||
                  item.description.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey.shade600,
            size: context.sp(6),
          ),
        ),
        title: Text(
          widget.mealTitle,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(9),
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFC107),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          MealSearchBar(
            controller: _searchController,
            onChanged: _filterItems,
          ),
          SizedBox(height: context.h(0.02)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bạn có thể thích',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(6),
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(0.015)),

          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy món ăn',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6),
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: context.h(0.015)),
                        child: MealItemCard(
                          item: item,
                          onAdd: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thêm ${item.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
