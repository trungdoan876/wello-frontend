import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/addfood/widgets/circular_calorie_indicator.dart';
import 'package:wello_frontend/ui/addfood/widgets/macro_info.dart';
import 'package:wello_frontend/ui/addfood/widgets/meal_card.dart';
import 'add_food_method_screen.dart';

class CalorieTrackerScreen extends StatelessWidget {
  const CalorieTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi lượng Calo'),
        centerTitle: true,
        leading: const Icon(Icons.arrow_back),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircularCalorieIndicator(),
            const SizedBox(height: 16),
            const MacroInfo(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  MealCard(
                    title: "Bữa sáng",
                    icon: Icons.wb_sunny_outlined,
                    onAdd: () => _openAddMethod(context),
                  ),
                  MealCard(
                    title: "Bữa trưa",
                    icon: Icons.lunch_dining_outlined,
                    onAdd: () => _openAddMethod(context),
                  ),
                  MealCard(
                    title: "Bữa tối",
                    icon: Icons.dinner_dining_outlined,
                    onAdd: () => _openAddMethod(context),
                  ),
                  MealCard(
                    title: "Snacks",
                    icon: Icons.fastfood_outlined,
                    onAdd: () => _openAddMethod(context),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openAddMethod(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodMethodScreen()),
    );
  }
}
