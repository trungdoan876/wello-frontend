/// Model for a single day in the week overview
class DayData {
  final String date;
  final String dayOfWeek;
  final int caloriesConsumed;
  final bool hasData;

  DayData({
    required this.date,
    required this.dayOfWeek,
    this.caloriesConsumed = 0,
    this.hasData = false,
  });

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      date: json['date'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      caloriesConsumed: json['caloriesConsumed'] ?? 0,
      hasData: json['hasData'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayOfWeek': dayOfWeek,
      'caloriesConsumed': caloriesConsumed,
      'hasData': hasData,
    };
  }
}

/// Model for weekly nutrition overview (for calendar)
class WeekOverview {
  final List<DayData> weekData;
  final String currentDate;

  WeekOverview({
    required this.weekData,
    required this.currentDate,
  });

  factory WeekOverview.fromJson(Map<String, dynamic> json) {
    final weekDataList = json['weekData'] as List<dynamic>? ?? [];
    return WeekOverview(
      weekData: weekDataList.map((item) => DayData.fromJson(item)).toList(),
      currentDate: json['currentDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekData': weekData.map((day) => day.toJson()).toList(),
      'currentDate': currentDate,
    };
  }

  /// Get day data for a specific date
  DayData? getDayByDate(String date) {
    try {
      return weekData.firstWhere((day) => day.date == date);
    } catch (e) {
      return null;
    }
  }

  /// Check if a date is the current date
  bool isCurrentDate(String date) {
    return date == currentDate;
  }
}
