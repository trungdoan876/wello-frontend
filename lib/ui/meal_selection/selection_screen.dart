import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/data_source/exercise_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/exercise_repository_impl.dart';
import 'package:wello_frontend/domain/entities/exercise.dart';
import 'widgets/meal_search_bar.dart';
import 'widgets/meal_item_card.dart';
import 'widgets/exercise_detail_sheet.dart';

class MealItem {
  final String name;
  final String description;
  final int calories;
  final int? exerciseId; // For exercises

  const MealItem({
    required this.name,
    required this.description,
    required this.calories,
    this.exerciseId,
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
        _loadMealItems();
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

  String _getErrorMessage(String error) {
    if (error.contains('404')) {
      return 'Dữ liệu chưa có sẵn trên server';
    } else if (error.contains('Not authenticated')) {
      return 'Vui lòng đăng nhập lại';
    } else if (error.contains('SocketException') || error.contains('Failed host lookup')) {
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
                                    borderRadius: BorderRadius.circular(context.sp(3)),
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
                                  onAdd: () {
                                    if (widget.mealType == 'tap_luyen') {
                                      // Show duration picker for exercises
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => ExerciseDetailSheet(
                                          exerciseId: item.exerciseId!,
                                          exerciseName: item.name,
                                        ),
                                      );
                                    } else {
                                      // Simple add for meals (placeholder)
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Đã thêm ${item.name}'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
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
}
