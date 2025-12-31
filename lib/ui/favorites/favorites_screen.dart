import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wello_frontend/ui/favorites/widgets/create_meal_page.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/quick_actions_overlay.dart';
import 'package:wello_frontend/ui/meal_selection/selection_screen.dart';
import 'package:wello_frontend/ui/favorites/widgets/favorite_meal_card.dart';
import 'package:wello_frontend/ui/favorites/widgets/favorite_food_detail_sheet.dart';
import 'package:wello_frontend/ui/favorites/widgets/edit_combo_page.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/favorites_provider.dart';
import 'models/favorite_item.dart';
import 'widgets/empty_favorite_state.dart';
import 'widgets/favorites_tab_bar.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(bool)? onQuickActionsChanged;

  const FavoritesScreen({Key? key, this.onQuickActionsChanged})
    : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> favorites = [];
  int _selectedTabIndex = 0;
  bool _showQuickActions = false;
  List<MealItem> _favoritesMeals = [];
  bool _isLoadingFavorites = false;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _loadMyFavorites();
  }

  Future<void> _loadMyFavorites() async {
    setState(() {
      _isLoadingFavorites = true;
      _errorMessage = null;
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      final userId = credentials.userId;

      print('Dang tai danh sach yeu thich cua user: $userId...');
      
      final favoritesProvider = context.read<FavoritesProvider>();
      await favoritesProvider.fetchFavorites(userId);
      
      if (favoritesProvider.errorMessage != null) {
        throw Exception(favoritesProvider.errorMessage);
      }

      setState(() {
        _favoritesMeals = favoritesProvider.favorites.map((fav) {
          print('Them: ${fav.favoriteName} - ${fav.totalNutrition.totalCalories} calo');
          return MealItem(
            name: fav.favoriteName,
            description:
                '${fav.totalNutrition.totalProtein.toInt()}g protein, ${fav.totalNutrition.totalCarbs.toInt()}g carbs',
            calories: fav.totalNutrition.totalCalories,
            protein: fav.totalNutrition.totalProtein,
            carbs: fav.totalNutrition.totalCarbs,
            fat: fav.totalNutrition.totalFat,
            foodId: fav.id,
            mealType: fav.mealType,
          );
        }).toList();
        print('Tong: ${_favoritesMeals.length} items');
      });
    } catch (e) {
      print('Loi: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  void _setQuickActionsVisible(bool show) {
    setState(() => _showQuickActions = show);
    widget.onQuickActionsChanged?.call(show);
  }

  void _handleQuickAction(String key) {
    _setQuickActionsVisible(false);
    // TODO: điều hướng theo key
  }

  void _addFavorite(FavoriteItem item) {
    setState(() {
      if (!favorites.any((f) => f.id == item.id)) {
        favorites.add(item);
      }
    });
  }

  void _removeFavorite(String id) {
    setState(() {
      favorites.removeWhere((f) => f.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double navHeight = _showQuickActions ? 0 : context.h(0.05);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFEBCF23),
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          'Mục yêu thích',
          style: GoogleFonts.baloo2(
            fontSize: context.sp(7),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateMealPage(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.add,
                    size: context.sp(6),
                    color: Colors.white,
                  ),
                ),
                // Search icon removed
                // SizedBox(width: context.w(0.03)),
                // Icon(Icons.search, size: context.sp(6), color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab bar (commented out)
              // FavoritesTabBar(
              //   selectedIndex: _selectedTabIndex,
              //   onTabChanged: (index) =>
              //       setState(() => _selectedTabIndex = index),
              // ),
              // SizedBox(height: context.h(0.02)),
              // Content
              Expanded(
                child: _buildFavoritesContent(context), // Always show favorites content
                // child: _selectedTabIndex == 0
                //     ? const EmptyFavoriteState() // Suggestions tab commented out
                //     : _buildFavoritesContent(context),
              ),
            ],
          ),
          // Lớp phủ mờ khi mở quick actions
          if (_showQuickActions)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setQuickActionsVisible(false),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: 0.45,
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          // Panel quick actions + nút dấu cộng
          Positioned(
            right: context.w(0.05),
            bottom: _showQuickActions
                ? context.h(0.015)
                : navHeight + context.h(0.01),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IgnorePointer(
                  ignoring: !_showQuickActions,
                  child: AnimatedSlide(
                    offset: _showQuickActions
                        ? const Offset(0, 0)
                        : const Offset(0, 0.2),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showQuickActions ? 1 : 0,
                      child: QuickActionsPanel(onAction: _handleQuickAction),
                    ),
                  ),
                ),
                SizedBox(height: context.h(0.012)),
                PlusBubble(
                  onTap: () => _setQuickActionsVisible(!_showQuickActions),
                  open: _showQuickActions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent(BuildContext context) {
    if (_isLoadingFavorites) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.sp(15),
              color: Colors.red.shade300,
            ),
            SizedBox(height: context.h(0.02)),
            Text(
              'Lỗi tải dữ liệu',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5.5),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: context.h(0.01)),
            Text(
              _errorMessage!,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4),
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(0.02)),
            ElevatedButton.icon(
              onPressed: _loadMyFavorites,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEBCF23),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_favoritesMeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: context.sp(15),
              color: Colors.grey.shade300,
            ),
            SizedBox(height: context.h(0.02)),
            Text(
              'Chưa có món ăn yêu thích',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5),
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: context.h(0.03)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateMealPage(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Thêm món ăn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEBCF23),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(context.w(0.04)),
      itemCount: _favoritesMeals.length,
      itemBuilder: (context, index) {
        final item = _favoritesMeals[index];
        return Padding(
          padding: EdgeInsets.only(bottom: context.h(0.015)),
          child: FavoriteMealCard(
            item: item,
            onTap: () async {
              final mappedMealType = _mapMealTypeForSheet(item.mealType);
              print(
                'Mo chi tiet mon an tu yeu thich: foodId=${item.foodId}, name=${item.name}, kcal=${item.calories}, protein=${item.protein}, carbs=${item.carbs}, fat=${item.fat}, mealType=$mappedMealType',
              );
              await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FavoriteFoodDetailSheet(
                  foodId: item.foodId!,
                  foodName: item.name,
                  totalCalories: item.calories,
                  totalProtein: item.protein ?? 0,
                  totalCarbs: item.carbs ?? 0,
                  totalFat: item.fat ?? 0,
                  mealType: mappedMealType,
                ),
              );
            },
            onEdit: () async {
              try {
                final credentials = await AuthHelper.getCredentials();
                if (credentials == null) {
                  throw Exception('Not authenticated');
                }

                final userId = int.tryParse(credentials.userIdString) ?? 0;
                if (userId == 0) {
                  throw Exception('Invalid user ID');
                }

                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditComboPage(
                      favoriteId: item.foodId!,
                      userId: userId,
                    ),
                  ),
                );
                
                // Reload favorites if update was successful
                if (result == true) {
                  _loadMyFavorites();
                }
              } catch (e) {
                print('Loi khi mo trang chinh sua: $e');
              }
            },
            onDelete: () async {
              // Show beautiful confirmation dialog
              bool shouldDelete = false;
              
              await QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                title: 'Xóa món ăn yêu thích?',
                text: 'Bạn có chắc chắn muốn xóa "${item.name}" khỏi danh sách yêu thích?',
                confirmBtnText: 'Xóa',
                cancelBtnText: 'Hủy',
                confirmBtnColor: const Color(0xFFFF6B6B),
                onConfirmBtnTap: () {
                  shouldDelete = true;
                  Navigator.pop(context);
                },
              );

              if (shouldDelete) {
                print('Dang xoa mon an yeu thich: favoriteId=${item.foodId}');
                
                try {
                  final credentials = await AuthHelper.getCredentials();
                  if (credentials == null) {
                    throw Exception('Not authenticated');
                  }

                  final userId = int.tryParse(credentials.userIdString) ?? 0;
                  if (userId == 0) {
                    throw Exception('Invalid user ID');
                  }

                  final favoritesProvider = context.read<FavoritesProvider>();
                  
                  // Show loading
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
                      ),
                    ),
                  );

                  final success = await favoritesProvider.deleteFavorite(
                    favoriteId: item.foodId!,
                    userId: userId,
                  );

                  if (!mounted) return;
                  Navigator.pop(context); // Close loading dialog

                  if (success) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      title: 'Đã xóa!',
                      text: 'Món ăn đã được xóa khỏi danh sách yêu thích',
                      confirmBtnText: 'Đồng ý',
                      confirmBtnColor: const Color(0xFFEBCF23),
                    );
                    _loadMyFavorites();
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Lỗi!',
                      text: favoritesProvider.errorMessage ?? 'Không thể xóa món ăn',
                      confirmBtnText: 'Đồng ý',
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context); // Close loading dialog if still open
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Lỗi!',
                    text: e.toString(),
                    confirmBtnText: 'Đồng ý',
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  String _mapMealTypeForSheet(String? rawType) {
    if (rawType == null) return 'SNACK';
    switch (rawType.toUpperCase()) {
      case 'BREAKFAST':
      case 'BUA_SANG':
        return 'BREAKFAST';
      case 'LUNCH':
      case 'BUA_TRUA':
        return 'LUNCH';
      case 'DINNER':
      case 'BUA_TOI':
        return 'DINNER';
      case 'SNACK':
      case 'BUA_PHU':
        return 'SNACK';
      default:
        return 'SNACK';
    }
  }
}
