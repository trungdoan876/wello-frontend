import '../requests/favorite_combo_item.dart';
import '../requests/total_nutrition.dart';

class FavoriteComboResponse {
  final int id;
  final String favoriteName;
  final String mealType;
  final List<FavoriteComboItem> items;
  final TotalNutrition totalNutrition;
  final String? createdAt;

  FavoriteComboResponse({
    required this.id,
    required this.favoriteName,
    required this.mealType,
    required this.items,
    required this.totalNutrition,
    this.createdAt,
  });

  factory FavoriteComboResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteComboResponse(
      id: json['id'] as int,
      favoriteName: json['favoriteName'] as String,
      mealType: json['mealType'] as String,
      items: (json['items'] as List)
          .map((item) => FavoriteComboItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalNutrition: TotalNutrition.fromJson(json['totalNutrition'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favoriteName': favoriteName,
      'mealType': mealType,
      'items': items.map((item) => item.toJson()).toList(),
      'totalNutrition': totalNutrition.toJson(),
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
