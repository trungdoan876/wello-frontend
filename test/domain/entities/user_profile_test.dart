import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/domain/entities/user_profile.dart';

void main() {
  group('UserProfile - suggestedTargetWeight', () {
    test('Should reduce weight by 5kg when goal is lose_weight', () {
      final profile = UserProfile(
        userId: '1',
        currentWeight: 75.5,
        goalType: 'lose_weight',
        dailyCalorieTarget: 1800,
        macroTargets: MacroTargets(carb: 150, protein: 117, fat: 45),
      );
      expect(profile.suggestedTargetWeight, 70.5);
    });

    test('Should increase weight by 3kg when goal is gain_weight', () {
      final profile = UserProfile(
        userId: '2',
        currentWeight: 60.0,
        goalType: 'gain_weight',
        dailyCalorieTarget: 2500,
        macroTargets: MacroTargets(carb: 200, protein: 130, fat: 55),
      );
      expect(profile.suggestedTargetWeight, 63.0);
    });

    test('Should maintain weight when goal is maintain', () {
      final profile = UserProfile(
        userId: '3',
        currentWeight: 68.0,
        goalType: 'maintain',
        dailyCalorieTarget: 2000,
        macroTargets: MacroTargets(carb: 150, protein: 110, fat: 45),
      );
      expect(profile.suggestedTargetWeight, 68.0);
    });

    test('Should maintain weight for invalid goal type (default case)', () {
      final profile = UserProfile(
        userId: '4',
        currentWeight: 72.0,
        goalType: 'invalid_goal',
        dailyCalorieTarget: 2000,
        macroTargets: MacroTargets(carb: 150, protein: 110, fat: 45),
      );
      expect(profile.suggestedTargetWeight, 72.0);
    });
  });

  group('UserProfile & MacroTargets JSON Mapping', () {
    test('UserProfile.fromJson should parse valid json correctly', () {
      final json = {
        'userId': 99,
        'startDate': '2026-06-01',
        'currentWeight': 70.5,
        'goalType': 'lose_weight',
        'dailyCalorieTarget': 1800,
        'dailyCalorieBurned': 300,
        'dailyWaterTarget': 2000,
        'streakCount': 5,
        'macroTargets': {
          'carb': 160,
          'protein': 120,
          'fat': 50,
        },
        'sleepTargetHours': 8.0,
        'sleepBedtimeTarget': '22:30',
        'sleepWakeTimeTarget': '06:30',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.userId, '99');
      expect(profile.startDate, '2026-06-01');
      expect(profile.currentWeight, 70.5);
      expect(profile.goalType, 'lose_weight');
      expect(profile.dailyCalorieTarget, 1800);
      expect(profile.dailyCalorieBurned, 300);
      expect(profile.dailyWaterTarget, 2000);
      expect(profile.streakCount, 5);
      expect(profile.macroTargets.carb, 160);
      expect(profile.macroTargets.protein, 120);
      expect(profile.macroTargets.fat, 50);
      expect(profile.sleepTargetHours, 8.0);
      expect(profile.sleepBedtimeTarget, '22:30');
      expect(profile.sleepWakeTimeTarget, '06:30');
    });

    test('UserProfile.toJson should serialize object to correct map', () {
      final profile = UserProfile(
        userId: '100',
        startDate: '2026-06-10',
        currentWeight: 80.0,
        goalType: 'maintain',
        dailyCalorieTarget: 2200,
        dailyCalorieBurned: 150,
        dailyWaterTarget: 2200,
        streakCount: 2,
        macroTargets: MacroTargets(carb: 180, protein: 125, fat: 55),
        sleepTargetHours: 7.5,
        sleepBedtimeTarget: '23:00',
        sleepWakeTimeTarget: '06:30',
      );

      final json = profile.toJson();

      expect(json['userId'], '100');
      expect(json['startDate'], '2026-06-10');
      expect(json['currentWeight'], 80.0);
      expect(json['goalType'], 'maintain');
      expect(json['dailyCalorieTarget'], 2200);
      expect(json['dailyCalorieBurned'], 150);
      expect(json['dailyWaterTarget'], 2200);
      expect(json['streakCount'], 2);
      expect(json['macroTargets']['carb'], 180);
      expect(json['macroTargets']['protein'], 125);
      expect(json['macroTargets']['fat'], 55);
      expect(json['sleepTargetHours'], 7.5);
      expect(json['sleepBedtimeTarget'], '23:00');
      expect(json['sleepWakeTimeTarget'], '06:30');
    });

    test('MacroTargets default values when json is empty', () {
      final macro = MacroTargets.fromJson({});
      expect(macro.carb, 150);
      expect(macro.protein, 117);
      expect(macro.fat, 45);
    });
  });
}
