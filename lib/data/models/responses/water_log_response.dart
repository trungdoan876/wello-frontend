import '../../../domain/entities/nutrition_summary.dart';
import '../../../domain/entities/engagement_result.dart';

class WaterLogResponse {
  final WaterIntake waterIntake;
  final EngagementResult? engagement;

  WaterLogResponse({
    required this.waterIntake,
    this.engagement,
  });

  factory WaterLogResponse.fromJson(Map<String, dynamic> json) {
    // If it's the new format with engagement
    if (json.containsKey('engagement') || json.containsKey('waterIntake')) {
      return WaterLogResponse(
        waterIntake: WaterIntake.fromJson(json['waterIntake'] ?? {}),
        engagement: json['engagement'] != null 
            ? EngagementResult.fromJson(json['engagement']) 
            : null,
      );
    }
    // If the API directly returns an EngagementResult (flat JSON with isStreak or newBadges)
    if (json.containsKey('isStreak') || json.containsKey('newBadges')) {
      return WaterLogResponse(
        waterIntake: WaterIntake(consumed: 0, target: 0, unit: "ml", glasses: 0),
        engagement: EngagementResult.fromJson(json),
      );
    }

    // Fallback for old format or simple WaterIntake response
    return WaterLogResponse(
      waterIntake: WaterIntake.fromJson(json),
      engagement: null,
    );
  }
}
