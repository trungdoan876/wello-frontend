import 'package:flutter/material.dart';

class DailyStreak {
  final DateTime date;
  final bool water;
  final bool meal;

  DailyStreak({
    required this.date,
    required this.water,
    required this.meal,
  });

  Color get color {
    if (water && meal) return Colors.orange;
    if (water) return Colors.blue;
    if (meal) return Colors.red;
    return Colors.transparent;
  }

  String get label {
    if (water && meal) return 'Uống nước & Ăn uống';
    if (water) return 'Uống nước';
    if (meal) return 'Ăn uống';
    return '';
  }
}
