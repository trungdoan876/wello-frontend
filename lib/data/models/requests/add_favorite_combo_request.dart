import 'favorite_combo_item.dart';

class AddFavoriteComboRequest {
  final int userId;
  final String favoriteName;
  final String mealType;
  final List<FavoriteComboItem> items;

  AddFavoriteComboRequest({
    required this.userId,
    required this.favoriteName,
    required this.mealType,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteName': favoriteName,
      'mealType': mealType,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
