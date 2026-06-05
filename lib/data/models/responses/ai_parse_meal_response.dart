class AiParseMealResponse {
  final String aiMessage;
  final List<ParsedFood> parsedFoods;

  AiParseMealResponse({
    required this.aiMessage,
    required this.parsedFoods,
  });

  factory AiParseMealResponse.fromJson(Map<String, dynamic> json) {
    var list = json['parsedFoods'] as List? ?? [];
    List<ParsedFood> parsedList = list.map((i) => ParsedFood.fromJson(i)).toList();
    return AiParseMealResponse(
      aiMessage: json['aiMessage'] ?? '',
      parsedFoods: parsedList,
    );
  }
}

class ParsedFood {
  final String foodName;
  final int foodId;
  final int amountGrams;
  final String mealType;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final bool matchedFromDb;
  final List<IngredientInfo> ingredients;

  ParsedFood({
    required this.foodName,
    required this.foodId,
    required this.amountGrams,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.matchedFromDb,
    required this.ingredients,
  });

  factory ParsedFood.fromJson(Map<String, dynamic> json) {
    var list = json['ingredients'] as List? ?? [];
    List<IngredientInfo> ingList = list.map((i) => IngredientInfo.fromJson(i)).toList();
    return ParsedFood(
      foodName: json['foodName'] ?? '',
      foodId: json['foodId'] ?? 0,
      amountGrams: json['amountGrams'] ?? 100,
      mealType: json['mealType'] ?? 'SNACK',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      matchedFromDb: json['matchedFromDb'] ?? false,
      ingredients: ingList,
    );
  }
}

class IngredientInfo {
  final String name;
  final int weightGrams;
  final int calories;

  IngredientInfo({
    required this.name,
    required this.weightGrams,
    required this.calories,
  });

  factory IngredientInfo.fromJson(Map<String, dynamic> json) {
    return IngredientInfo(
      name: json['name'] ?? '',
      weightGrams: json['weightGrams'] ?? 0,
      calories: json['calories'] ?? 0,
    );
  }
}
