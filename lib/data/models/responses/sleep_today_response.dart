class SleepTodayResponse {
  final bool hasRecord;
  final String date;
  final String? status;
  final SleepLogData? data;

  SleepTodayResponse({
    required this.hasRecord,
    required this.date,
    this.status,
    this.data,
  });

  factory SleepTodayResponse.fromJson(Map<String, dynamic> json) {
    // 1. Nếu có trường 'data', parse từ 'data'
    if (json['data'] != null) {
      final data = SleepLogData.fromJson(json['data'] as Map<String, dynamic>);
      return SleepTodayResponse(
        hasRecord: json['hasRecord'] as bool? ?? true,
        date: json['date'] as String? ?? '',
        status: (json['status'] ?? data.status) as String?,
        data: data,
      );
    } 
    
    // 2. Nếu không có 'data' nhưng có 'id' (đây là obj SleepLog phẳng) hoặc 'hasRecord' == true
    if (json['hasRecord'] == true || json['id'] != null) {
      final data = SleepLogData.fromJson(json);
      return SleepTodayResponse(
        hasRecord: true,
        date: json['date'] as String? ?? '',
        status: (json['status'] ?? data.status) as String?,
        data: data,
      );
    }

    // 3. Mặc định là không có record
    return SleepTodayResponse(
      hasRecord: false,
      date: json['date'] as String,
      status: json['status'] as String?,
      data: null,
    );
  }
}

class SleepLogData {
  final int id;
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
  final String status;

  SleepLogData({
    required this.id,
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

  factory SleepLogData.fromJson(Map<String, dynamic> json) {
    // Backend có thể trả về camelCase, snake_case hoặc tên theo API Spec cũ.
    // Chúng ta hỗ trợ tất cả để đảm bảo app không bị crash.
    return SleepLogData(
      id: json['id'] as int? ?? 0,
      sleepTime: (json['sleepTime'] ?? json['bedtime'] ?? json['sleep_time'] ?? '') as String,
      wakeTime: (json['wakeTime'] ?? json['wake_time']) as String?,
      duration: (json['duration'] as num?)?.toInt(),
      durationHours: (json['durationHours'] ?? json['actualHours'] ?? json['actual_hours'] ?? 0.0).toDouble(),
      quality: (json['quality'] as num?)?.toInt(),
      sleepEfficiency: (json['sleepEfficiency'] ?? json['sleep_efficiency'] as num?)?.toDouble(),
      sleepEfficiencyRating: (json['sleepEfficiencyRating'] ?? json['sleep_efficiency_rating']) as String?,
      complianceRate: (json['complianceRate'] ?? json['compliance_rate'] as num?)?.toDouble(),
      complianceRating: (json['complianceRating'] ?? json['compliance_rating']) as String?,
      notes: json['notes'] as String?,
      date: json['date'] as String? ?? '',
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
    );
  }
}
