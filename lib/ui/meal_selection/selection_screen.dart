import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/data_source/exercise_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/exercise_repository_impl.dart';
import 'package:wello_frontend/data/data_source/food_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/food_repository_impl.dart';
import 'widgets/meal_search_bar.dart';
import 'widgets/meal_item_card.dart';
import 'widgets/exercise_detail_sheet.dart';
import 'widgets/food_detail_sheet.dart';

class MealItem {
  final String name;
  final String description;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final int? exerciseId; // For exercises
  final int? foodId; // For foods

  const MealItem({
    required this.name,
    required this.description,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.exerciseId,
    this.foodId,
  });
}

class SelectionScreen extends StatefulWidget {
  final String mealType;
  final String mealTitle;

  const SelectionScreen({
    super.key,
    required this.mealType,
    required this.mealTitle,
  });

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  late TextEditingController _searchController;
  List<MealItem> _filteredItems = [];
  List<MealItem> _allItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.mealType == 'tap_luyen') {
        await _loadExercises();
      } else {
        await _loadFoods(); // Changed from _loadMealItems
      }
      _filterItems('');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExercises() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) {
      throw Exception('Not authenticated');
    }

    final repository = ExerciseRepositoryImpl(
      remoteDataSource: ExerciseRemoteDataSource(),
    );

    final exercises = await repository.getExercises(credentials.token);

    _allItems = exercises.map((exercise) {
      return MealItem(
        name: exercise.name,
        description: 'MET: ${exercise.metValue}',
        calories: 0, // Calculated based on duration later
        exerciseId: exercise.id,
      );
    }).toList();
  }

  Future<void> _loadFoods() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) {
      throw Exception('Not authenticated');
    }

    final foodRepository = FoodRepositoryImpl(
      remoteDataSource: FoodRemoteDataSource(),
    );

    final foods = await foodRepository.getAllFoods(credentials.token);

    _allItems = foods.map((food) {
      return MealItem(
        name: food.name,
        description:
            '${food.protein.toInt()}g protein, ${food.carbs.toInt()}g carbs',
        calories: food.calories,
        protein: food.protein,
        carbs: food.carbs,
        fat: food.fat,
        foodId: food.id,
      );
    }).toList();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = query.isEmpty
          ? _allItems
          : _allItems
                .where(
                  (item) =>
                      item.name.toLowerCase().contains(query.toLowerCase()) ||
                      item.description.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
    });
  }

  String _getErrorMessage(String error) {
    if (error.contains('404')) {
      return 'Dữ liệu chưa có sẵn trên server';
    } else if (error.contains('Not authenticated')) {
      return 'Vui lòng đăng nhập lại';
    } else if (error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'Không có kết nối internet';
    } else {
      return 'Đã có lỗi xảy ra. Vui lòng thử lại';
    }
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
          MealSearchBar(controller: _searchController, onChanged: _filterItems),
          SizedBox(height: context.h(0.02)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gợi ý',
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
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(0.1)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.sp(5)),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: context.sp(15),
                              color: Colors.red.shade300,
                            ),
                          ),
                          SizedBox(height: context.h(0.03)),
                          Text(
                            'Không thể tải dữ liệu',
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(6.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: context.h(0.01)),
                          Text(
                            _getErrorMessage(_errorMessage!),
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(4.5),
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.h(0.03)),
                          ElevatedButton.icon(
                            onPressed: _loadItems,
                            icon: Icon(Icons.refresh, size: context.sp(5)),
                            label: Text(
                              'Thử lại',
                              style: GoogleFonts.baloo2(
                                fontSize: context.sp(5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEBCF23),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(0.08),
                                vertical: context.h(0.015),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.sp(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      widget.mealType == 'tap_luyen'
                          ? 'Không tìm thấy bài tập'
                          : 'Không tìm thấy món ăn',
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
                          onAdd: () async {
                            if (widget.mealType == 'tap_luyen') {
                              // Show duration picker for exercises
                              final result = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ExerciseDetailSheet(
                                  exerciseId: item.exerciseId!,
                                  exerciseName: item.name,
                                ),
                              );

                              // Reload workout history if success
                              if (result == true && mounted) {
                                // Trigger a rebuild by updating parent if needed
                                // For now, just show success - the card will auto-reload on lifecycle
                              }
                            } else {
                              // If used in ingredient selection flow, return item to caller
                              if (widget.mealType == 'chon_thuc_pham') {
                                Navigator.pop(context, {
                                  'id': item.foodId,
                                  'name': item.name,
                                  'calories': item.calories,
                                  'protein': item.protein ?? 0.0,
                                  'carbs': item.carbs ?? 0.0,
                                  'fat': item.fat ?? 0.0,
                                  'portionText': '100 g',
                                });
                              } else {
                                // Default behavior: open food detail sheet to log food
                                final result = await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => FoodDetailSheet(
                                    foodId: item.foodId!,
                                    foodName: item.name,
                                    baseCalories: item.calories,
                                    mealType: _mapMealType(widget.mealType),
                                  ),
                                );

                                if (result == true && mounted) {
                                  // Success! SnackBar is already shown in the sheet
                                  // The main_navigation_screen or home_screen should refresh
                                  // because logFood calls loadDailySummary
                                }
                              }
                            }
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

  String _mapMealType(String rawType) {
    switch (rawType) {
      case 'bua_sang':
        return 'BREAKFAST';
      case 'bua_trua':
        return 'LUNCH';
      case 'bua_toi':
        return 'DINNER';
      case 'bua_phu':
        return 'SNACK';
      default:
        return 'SNACK';
    }
  }
}
