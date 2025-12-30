enum GoalType { calories, protein, carbs, fat, water }

class GoalAchievement {
  final GoalType type;
  final bool reached;
  final bool exceeded;
  final String message;

  GoalAchievement({
    required this.type,
    required this.reached,
    required this.exceeded,
    required this.message,
  });
}
