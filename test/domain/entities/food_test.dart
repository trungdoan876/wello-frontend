import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/domain/entities/food.dart';

void main() {
  group('Food Entity Tests', () {
    test('Food.fromJson parses valid map correctly', () {
      final json = {
        'id': 1,
        'name': 'Apple',
        'calories': 52,
        'protein': 0.3,
        'carbs': 14.0,
        'fat': 0.2,
        'imageUrl': 'https://image.com/apple.jpg',
      };

      final food = Food.fromJson(json);

      expect(food.id, 1);
      expect(food.name, 'Apple');
      expect(food.calories, 52);
      expect(food.protein, 0.3);
      expect(food.carbs, 14.0);
      expect(food.fat, 0.2);
      expect(food.imageUrl, 'https://image.com/apple.jpg');
    });

    test('Food.toJson serializes object correctly', () {
      final food = Food(
        id: 2,
        name: 'Banana',
        calories: 89,
        protein: 1.1,
        carbs: 22.8,
        fat: 0.3,
        imageUrl: null,
      );

      final json = food.toJson();

      expect(json['id'], 2);
      expect(json['name'], 'Banana');
      expect(json['calories'], 89);
      expect(json['protein'], 1.1);
      expect(json['carbs'], 22.8);
      expect(json['fat'], 0.3);
      expect(json['imageUrl'], isNull);
    });
  });
}
