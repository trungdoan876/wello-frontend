import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/domain/entities/running_session.dart';

void main() {
  group('RunningSession Entity Tests', () {
    test('RunningSession.fromJson should parse correctly', () {
      final json = {
        'sessionId': 101,
        'userId': 9,
        'date': '2026-06-10',
        'activityType': 'running',
        'durationSeconds': 1800,
        'distanceKm': 5.2,
        'caloriesBurned': 350,
        'steps': 6000,
        'avgPaceSecPerKm': 346, // ~5m46s per km
        'goalType': 'distance',
        'goalValue': 5.0,
        'completionPercent': 100,
      };

      final session = RunningSession.fromJson(json);

      expect(session.sessionId, 101);
      expect(session.userId, 9);
      expect(session.date, '2026-06-10');
      expect(session.activityType, 'running');
      expect(session.durationSeconds, 1800);
      expect(session.distanceKm, 5.2);
      expect(session.caloriesBurned, 350);
      expect(session.steps, 6000);
      expect(session.avgPaceSecPerKm, 346);
      expect(session.goalType, 'distance');
      expect(session.goalValue, 5.0);
      expect(session.completionPercent, 100);
    });

    test('RunningSession.toJson should serialize correctly', () {
      final session = RunningSession(
        sessionId: 202,
        userId: 12,
        date: '2026-06-11',
        activityType: 'walking',
        durationSeconds: 1200,
        distanceKm: 2.0,
        caloriesBurned: 120,
        steps: 3000,
        avgPaceSecPerKm: 600,
        goalType: 'time',
        goalValue: 1000.0,
        completionPercent: 80,
      );

      final json = session.toJson();

      expect(json['userId'], 12);
      expect(json['date'], '2026-06-11');
      expect(json['activityType'], 'walking');
      expect(json['durationSeconds'], 1200);
      expect(json['distanceKm'], 2.0);
      expect(json['caloriesBurned'], 120);
      expect(json['steps'], 3000);
      expect(json['avgPaceSecPerKm'], 600);
      expect(json['goalType'], 'time');
      expect(json['goalValue'], 1000.0);
      expect(json['completionPercent'], 80);
    });
  });

  group('Running Weekly & Daily Summary Tests', () {
    test('RunningWeeklySummary.fromJson parses structure correctly', () {
      final json = {
        'totalDistanceKm': 25.5,
        'totalCaloriesBurned': 1800,
        'totalDurationSeconds': 9000,
        'totalSteps': 30000,
        'sessionsCount': 5,
        'dailySummaries': [
          {
            'date': '2026-06-08',
            'distanceKm': 5.0,
            'caloriesBurned': 350,
            'steps': 6000,
          },
          {
            'date': '2026-06-09',
            'distanceKm': 6.5,
            'caloriesBurned': 450,
            'steps': 7800,
          }
        ]
      };

      final summary = RunningWeeklySummary.fromJson(json);

      expect(summary.totalDistanceKm, 25.5);
      expect(summary.totalCaloriesBurned, 1800);
      expect(summary.totalDurationSeconds, 9000);
      expect(summary.totalSteps, 30000);
      expect(summary.sessionsCount, 5);
      expect(summary.dailySummaries.length, 2);
      expect(summary.dailySummaries[0].date, '2026-06-08');
      expect(summary.dailySummaries[1].distanceKm, 6.5);
    });
  });
}
