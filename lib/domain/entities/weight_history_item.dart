class WeightHistoryItem {
  final double weight;
  final DateTime recordedAt;

  WeightHistoryItem({required this.weight, required this.recordedAt});

  factory WeightHistoryItem.fromJson(Map<String, dynamic> json) {
    return WeightHistoryItem(
      weight: (json['weight'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }
}
