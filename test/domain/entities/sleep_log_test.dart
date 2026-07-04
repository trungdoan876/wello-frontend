import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/domain/entities/sleep_log.dart';

void main() {
  group('SleepLog Entity Tests', () {
    test('SleepLog status getters', () {
      final logPending = SleepLog(
        id: 1,
        sleepTime: '22:00',
        date: '2026-06-10',
        status: 'PENDING',
      );
      final logCompleted = SleepLog(
        id: 2,
        sleepTime: '22:00',
        wakeTime: '06:00',
        date: '2026-06-10',
        status: 'COMPLETED',
      );

      expect(logPending.isPending, isTrue);
      expect(logPending.isCompleted, isFalse);

      expect(logCompleted.isPending, isFalse);
      expect(logCompleted.isCompleted, isTrue);
    });

    test('SleepLog.fromJson parses valid map correctly', () {
      final json = {
        'id': 100,
        'sleepTime': '23:00',
        'wakeTime': '07:00',
        'duration': 480,
        'durationHours': 8.0,
        'quality': 4,
        'sleepEfficiency': 95.5,
        'sleepEfficiencyRating': 'Good',
        'complianceRate': 90.0,
        'complianceRating': 'Optimal',
        'notes': 'Slept well',
        'date': '2026-06-10',
        'status': 'COMPLETED',
      };

      final log = SleepLog.fromJson(json);

      expect(log.id, 100);
      expect(log.sleepTime, '23:00');
      expect(log.wakeTime, '07:00');
      expect(log.duration, 480);
      expect(log.durationHours, 8.0);
      expect(log.quality, 4);
      expect(log.sleepEfficiency, 95.5);
      expect(log.sleepEfficiencyRating, 'Good');
      expect(log.complianceRate, 90.0);
      expect(log.complianceRating, 'Optimal');
      expect(log.notes, 'Slept well');
      expect(log.date, '2026-06-10');
      expect(log.status, 'COMPLETED');
    });

    test('SleepLog.toJson serializes object correctly', () {
      final log = SleepLog(
        id: 200,
        sleepTime: '22:30',
        wakeTime: '06:30',
        duration: 480,
        durationHours: 8.0,
        quality: 5,
        sleepEfficiency: 98.0,
        sleepEfficiencyRating: 'Excellent',
        complianceRate: 100.0,
        complianceRating: 'Optimal',
        notes: 'Deep sleep',
        date: '2026-06-11',
        status: 'COMPLETED',
      );

      final json = log.toJson();

      expect(json['id'], 200);
      expect(json['sleepTime'], '22:30');
      expect(json['wakeTime'], '06:30');
      expect(json['duration'], 480);
      expect(json['durationHours'], 8.0);
      expect(json['quality'], 5);
      expect(json['sleepEfficiency'], 98.0);
      expect(json['sleepEfficiencyRating'], 'Excellent');
      expect(json['complianceRate'], 100.0);
      expect(json['complianceRating'], 'Optimal');
      expect(json['notes'], 'Deep sleep');
      expect(json['date'], '2026-06-11');
      expect(json['status'], 'COMPLETED');
    });
  });
}
