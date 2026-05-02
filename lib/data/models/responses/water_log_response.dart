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
    // Fallback for old format or simple WaterIntake response
    return WaterLogResponse(
      waterIntake: WaterIntake.fromJson(json),
      engagement: null,
    );
  }
}
