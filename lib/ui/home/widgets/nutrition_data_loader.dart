import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/auth_helper.dart';
import '../../../domain/providers/nutrition_provider.dart';

/// Mixin to help widgets load nutrition data easily
mixin NutritionDataLoader<T extends StatefulWidget> on State<T> {
  
  /// Load all home screen data
  Future<void> loadNutritionData() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      return;
    }
    
    final provider = context.read<NutritionProvider>();
    await provider.loadHomeData(credentials.token, credentials.userIdString);
  }
  
  /// Load only daily summary
  Future<void> loadDailySummary(String date) async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;
    
    final provider = context.read<NutritionProvider>();
    await provider.loadDailySummary(
      credentials.token,
      credentials.userIdString,
      date,
    );
  }
  
  /// Add water glass
  Future<void> addWater({int glassSize = 325}) async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;
    
    final provider = context.read<NutritionProvider>();
    await provider.addWaterGlass(
      credentials.token,
      credentials.userIdString,
      glassSize: glassSize,
    );
  }
  
  /// Change selected date
  Future<void> changeDate(String newDate) async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;
    
    final provider = context.read<NutritionProvider>();
    await provider.changeDate(
      credentials.token,
      credentials.userIdString,
      newDate,
    );
  }
  
  /// Refresh all data
  Future<void> refreshNutritionData() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;
    
    final provider = context.read<NutritionProvider>();
    await provider.refresh(credentials.token, credentials.userIdString);
  }
}

/// Example widget showing how to use the mixin
class NutritionDataExample extends StatefulWidget {
  const NutritionDataExample({super.key});

  @override
  State<NutritionDataExample> createState() => _NutritionDataExampleState();
}

class _NutritionDataExampleState extends State<NutritionDataExample> 
    with NutritionDataLoader {
  
  @override
  void initState() {
    super.initState();
    // Simply call the mixin method!
    loadNutritionData();
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshNutritionData,
      child: Consumer<NutritionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dailySummary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView(
            children: [
              // Your UI here
              ElevatedButton(
                onPressed: () => addWater(),
                child: const Text('Add Water'),
              ),
            ],
          );
        },
      ),
    );
  }
}
