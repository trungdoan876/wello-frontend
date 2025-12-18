import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/nutrition_provider.dart';

/// Simple example widget to display calorie information
/// This is a complete, working example showing how to use NutritionProvider
class SimpleCalorieDisplay extends StatelessWidget {
  const SimpleCalorieDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        // Handle loading state
        if (provider.isLoadingSummary && provider.dailySummary == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Handle error state
        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage ?? 'An error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        // Get data from provider
        final summary = provider.dailySummary;
        final profile = provider.userProfile;
        
        final consumed = summary?.caloriesConsumed ?? 0;
        final remaining = summary?.caloriesRemaining ?? 
                          profile?.dailyCalorieTarget ?? 2000;
        final burned = summary?.caloriesBurned ?? 0;
        final total = consumed + remaining;
        final percentage = total > 0 ? consumed / total : 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Title
              const Text(
                'Daily Calories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Circular progress
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFFB300),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$remaining',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Consumed', '$consumed', Icons.restaurant),
                  _buildStat('Burned', '$burned', Icons.local_fire_department),
                  _buildStat('Target', '$total', Icons.flag),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFB300)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
