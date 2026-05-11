class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String criteria;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.isUnlocked,
    this.unlockedAt,
    required this.criteria,
  });
}
