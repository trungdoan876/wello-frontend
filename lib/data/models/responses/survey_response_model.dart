class SurveyResponseModel {
  final double bmi;
  final String bmiStatus;
  final double bmr;
  final double tdee;
  final int dailyCalories;
  final int proteinGram;
  final int carbsGram;
  final int fatGram;
  final int? waterIntakeMl;
  final double? height;
  final double? weight;

  SurveyResponseModel({
    required this.bmi,
    required this.bmiStatus,
    required this.bmr,
    required this.tdee,
    required this.dailyCalories,
    required this.proteinGram,
    required this.carbsGram,
    required this.fatGram,
    this.waterIntakeMl,
    this.height,
    this.weight,
  });

  factory SurveyResponseModel.fromJson(Map<String, dynamic> json) {
    return SurveyResponseModel(
      bmi: (json['bmi'] as num).toDouble(),
      bmiStatus: json['bmiStatus'] as String,
      bmr: (json['bmr'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
      dailyCalories: json['dailyCalories'] as int,
      proteinGram: json['proteinGram'] as int,
      carbsGram: json['carbsGram'] as int,
      fatGram: json['fatGram'] as int,
      waterIntakeMl: json.containsKey('waterIntakeMl')
          ? (json['waterIntakeMl'] as int)
          : null,
      height: json.containsKey('height')
          ? (json['height'] as num).toDouble()
          : null,
      weight: json.containsKey('weight')
          ? (json['weight'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bmi': bmi,
      'bmiStatus': bmiStatus,
      'bmr': bmr,
      'tdee': tdee,
      'dailyCalories': dailyCalories,
      'proteinGram': proteinGram,
      'carbsGram': carbsGram,
      'fatGram': fatGram,
      'waterIntakeMl': waterIntakeMl,
      'height': height,
      'weight': weight,
    };
  }
}
