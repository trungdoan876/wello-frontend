class CalculateBmiRequest {
  final int weight;
  final int height;
  final String? goal; // Optional: LOSE_WEIGHT, GAIN_WEIGHT, MAINTAIN_WEIGHT

  CalculateBmiRequest({
    required this.weight,
    required this.height,
    this.goal,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'weight': weight,
      'height': height,
    };
    
    // Only include goal if it's not null
    if (goal != null) {
      json['goal'] = goal!;
    }
    
    return json;
  }
}
