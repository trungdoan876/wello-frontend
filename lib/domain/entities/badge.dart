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

  factory Badge.fromJson(Map<String, dynamic> json) {
    final unlockedAtVal = json['unlockedAt'];
    final isUnlockedVal = json['unlocked'] ?? json['isUnlocked'] ?? (unlockedAtVal != null);

    return Badge(
      id: (json['badgeId'] ?? json['idBadge'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['imageUrl'] ?? json['iconUrl'] ?? '',
      isUnlocked: isUnlockedVal == true,
      unlockedAt: unlockedAtVal != null 
          ? DateTime.parse(unlockedAtVal as String) 
          : null,
      criteria: json['criteriaType'] ?? json['criteria'] ?? '',
    );
  }
}
