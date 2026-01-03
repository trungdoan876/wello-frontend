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
  final double? sleepTargetHours;
  final String? sleepBedtimeTarget;
  final String? sleepWakeTimeTarget;

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
    this.sleepTargetHours,
    this.sleepBedtimeTarget,
    this.sleepWakeTimeTarget,
  });

  factory SurveyResponseModel.fromJson(Map<String, dynamic> json) {
    return SurveyResponseModel(
      bmi: (json['bmi'] ?? 0.0) as double,
      bmiStatus: (json['bmiStatus'] ?? 'NORMAL') as String,
      bmr: (json['bmr'] ?? 0.0) as double,
      tdee: (json['tdee'] ?? 0.0) as double,
      dailyCalories: (json['dailyCalories'] ?? 0) as int,
      proteinGram: (json['proteinGram'] ?? 0) as int,
      carbsGram: (json['carbsGram'] ?? 0) as int,
      fatGram: (json['fatGram'] ?? 0) as int,
      waterIntakeMl: json['waterIntakeMl'] as int?,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      sleepTargetHours: json['sleepTargetHours'] != null ? (json['sleepTargetHours'] as num).toDouble() : null,
      sleepBedtimeTarget: json['sleepBedtimeTarget'] as String?,
      sleepWakeTimeTarget: json['sleepWakeTimeTarget'] as String?,
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
      'sleepTargetHours': sleepTargetHours,
      'sleepBedtimeTarget': sleepBedtimeTarget,
      'sleepWakeTimeTarget': sleepWakeTimeTarget,
    };
  }
}
