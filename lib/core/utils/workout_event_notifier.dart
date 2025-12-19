import 'package:flutter/material.dart';

/// Event notifier for workout updates
class WorkoutEventNotifier {
  static final ValueNotifier<int> workoutAdded = ValueNotifier<int>(0);
  
  /// Notify that a new workout was added
  static void notifyWorkoutAdded() {
    workoutAdded.value++;
  }
}
