class LogFoodResponse {
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String message;
  final Map<String, dynamic>? engagement;

  LogFoodResponse({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.message,
    this.engagement,
  });

  factory LogFoodResponse.fromJson(Map<String, dynamic> json) {
    return LogFoodResponse(
      foodName: json['foodName'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      message: json['message'],
      engagement: json['engagement'],
    );
  }
}
