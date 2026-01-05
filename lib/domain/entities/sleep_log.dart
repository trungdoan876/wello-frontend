class SleepLog {
  final int? id;
  final String sleepTime;
  final String? wakeTime;
  final int? duration;
  final double? durationHours;
  final int? quality;
  final double? sleepEfficiency;
  final String? sleepEfficiencyRating;
  final double? complianceRate;
  final String? complianceRating;
  final String? notes;
  final String date;
  final String status; // "PENDING" or "COMPLETED"

  SleepLog({
    this.id,
    required this.sleepTime,
    this.wakeTime,
    this.duration,
    this.durationHours,
    this.quality,
    this.sleepEfficiency,
    this.sleepEfficiencyRating,
    this.complianceRate,
    this.complianceRating,
    this.notes,
    required this.date,
    required this.status,
  });

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'] as int?,
      sleepTime: json['sleepTime'] as String,
      wakeTime: json['wakeTime'] as String?,
      duration: json['duration'] as int?,
      durationHours: (json['durationHours'] as num?)?.toDouble(),
      quality: (json['quality'] as num?)?.toInt(),
      sleepEfficiency: (json['sleepEfficiency'] as num?)?.toDouble(),
      sleepEfficiencyRating: json['sleepEfficiencyRating'] as String?,
      complianceRate: (json['complianceRate'] as num?)?.toDouble(),
      complianceRating: json['complianceRating'] as String?,
      notes: json['notes'] as String?,
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'duration': duration,
      'durationHours': durationHours,
      'quality': quality,
      'sleepEfficiency': sleepEfficiency,
      'sleepEfficiencyRating': sleepEfficiencyRating,
      'complianceRate': complianceRate,
      'complianceRating': complianceRating,
      'notes': notes,
      'date': date,
      'status': status,
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isCompleted => status == 'COMPLETED';
}
