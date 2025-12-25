import 'favorite_combo_item.dart';

class UpdateFavoriteComboRequest {
  final int userId;
  final int favoriteId;
  final String favoriteName;
  final String mealType;
  final List<FavoriteComboItem> items;

  UpdateFavoriteComboRequest({
    required this.userId,
    required this.favoriteId,
    required this.favoriteName,
    required this.mealType,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteId': favoriteId,
      'favoriteName': favoriteName,
      'mealType': mealType,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
