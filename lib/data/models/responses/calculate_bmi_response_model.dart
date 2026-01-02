class CalculateBmiResponse {
  final double bmi;
  final String status; // UNDERWEIGHT, NORMAL, OVERWEIGHT, OBESE
  final String statusText; // Vietnamese text
  final String? warning;

  CalculateBmiResponse({
    required this.bmi,
    required this.status,
    required this.statusText,
    this.warning,
  });

  factory CalculateBmiResponse.fromJson(Map<String, dynamic> json) {
    return CalculateBmiResponse(
      bmi: (json['bmi'] ?? 0.0) as double,
      status: (json['status'] ?? 'NORMAL') as String,
      statusText: (json['statusText'] ?? 'Bình thường') as String,
      warning: json['warning'] as String?,
    );
  }

  // Helper method to get color based on status
  String getStatusColor() {
    switch (status) {
      case 'UNDERWEIGHT':
        return '#FF6B6B'; // Red
      case 'NORMAL':
        return '#51CF66'; // Green
      case 'OVERWEIGHT':
        return '#FFD93D'; // Yellow
      case 'OBESE':
        return '#FF8C42'; // Orange
      default:
        return '#868E96'; // Gray
    }
  }

  bool get hasWarning => warning != null && warning!.isNotEmpty;
}
