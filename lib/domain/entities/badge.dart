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
    return Badge(
      id: (json['idBadge'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['imageUrl'] ?? json['iconUrl'] ?? '',
      isUnlocked: json['unlocked'] ?? json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      criteria: json['criteriaType'] ?? json['criteria'] ?? '',
    );
  }
}
