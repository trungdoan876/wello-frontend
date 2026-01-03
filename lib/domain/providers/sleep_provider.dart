import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/data/data_source/sleep_remote_data_source.dart';
import 'package:wello_frontend/domain/entities/sleep_log.dart';
import 'package:wello_frontend/data/models/responses/sleep_today_response.dart';
import 'package:wello_frontend/ui/home/widgets/daily_sleep_card.dart';

class SleepProvider extends ChangeNotifier {
  final SleepRemoteDataSource _remoteDataSource = SleepRemoteDataSource();

  // State
  SleepLogData? _completedSleep; // The sleep that finished today
  SleepLogData? _activeSleep;    // The sleep that started tonight (active or completed)
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _testDate; // For debugging - override current date

  // Getters
  SleepLogData? get completedSleep => _completedSleep;
  SleepLogData? get activeSleep => _activeSleep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get testDate => _testDate;

  // Derive status based on dual records
  SleepStatus get status {
    if (_activeSleep == null) return SleepStatus.notLogged;
    if (_activeSleep!.status?.toUpperCase() == 'PENDING') return SleepStatus.sleeping;
    return SleepStatus.completed;
  }

  // Set test date for debugging
  void setTestDate(DateTime? date) {
    _testDate = date;
    notifyListeners();
  }

  // Get effective date (test date or today)
  DateTime get _effectiveDate => _testDate ?? DateTime.now();

  // Helper getters for UI
  // Primary info for "Current tracking" section (usually the active sleep)
  SleepLogData? get _mainRecord => _activeSleep ?? _completedSleep;

  String? get bedtime {
    final record = _mainRecord;
    if (record == null) return null;
    try {
      final dt = DateTime.parse(record.sleepTime);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return null;
    }
  }

  String? get bedtimeDate {
    final record = _mainRecord;
    if (record == null) return null;
    try {
      final dt = DateTime.parse(record.sleepTime);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return null;
    }
  }

  String? get wakeTime {
    final record = _mainRecord;
    if (record?.wakeTime == null) return null;
    try {
      final dt = DateTime.parse(record!.wakeTime!);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return null;
    }
  }

  String? get wakeTimeDate {
    final record = _mainRecord;
    if (record?.wakeTime == null) return null;
    try {
      final dt = DateTime.parse(record!.wakeTime!);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return null;
    }
  }

  double get actualHours => _completedSleep?.durationHours ?? 0.0;
  int get quality => _completedSleep?.quality ?? 0;
  String? get notes => _completedSleep?.notes;
  int? get sleepId => _activeSleep?.id ?? _completedSleep?.id;
  int? get activeSleepId => _activeSleep?.id;

  // Load today's sleep data
  Future<void> loadTodaySleep(int userId) async {
    print('[SLEEP] 🌙 Loading sleep data for userId=$userId at $_effectiveDate');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_effectiveDate);
      
      // 1. Fetch record for the current selected date
      final response = await _remoteDataSource.getTodaySleep(
        userId: userId,
        date: dateStr,
      );

      // 2. FETCH NEXT DAY as well: If current day is COMPLETED or empty,
      // we might have a PENDING record on the next day (meaning user is currently sleeping)
      final tomorrow = _effectiveDate.add(const Duration(days: 1));
      final tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);
      final tomorrowResponse = await _remoteDataSource.getTodaySleep(
        userId: userId,
        date: tomorrowStr,
      );

      print('[SLEEP DEBUG] Today Response ($dateStr): hasRecord=${response.hasRecord}, status=${response.status}');
      print('[SLEEP DEBUG] Tomorrow Response ($tomorrowStr): hasRecord=${tomorrowResponse.hasRecord}, status=${tomorrowResponse.status}');

      // RESET states
      _completedSleep = null;
      _activeSleep = null;

      // 1. Completed Sleep Section: Jan 2 dashboard shows record attributed to Jan 2.
      // If it's PENDING, user is waking up TODAY. If COMPLETED, user ALREADY woke up today.
      if (response.hasRecord) {
        _completedSleep = response.data;
      }

      // 2. Active Sleep Section: Jan 2 dashboard shows record for Tonight (attributed to Jan 3).
      // If it's NULL, user hasn't slept yet. If PENDING, user IS sleeping now.
      if (tomorrowResponse.hasRecord) {
        _activeSleep = tomorrowResponse.data;
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('Lỗi khi tải giấc ngủ: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Log bedtime
  Future<bool> logBedtime(int userId, String bedtime) async {
    print('[SLEEP] 🛏️ Logging bedtime: $bedtime');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // bedtime is already in ISO format from BedtimeBottomSheet
      final result = await _remoteDataSource.logBedtime(
        userId: userId,
        bedtime: bedtime,
      );

      // Cập nhật state cục bộ ngay lập tức để UI mượt mà
      _activeSleep = SleepLogData(
        id: result.id!,
        sleepTime: result.sleepTime,
        date: result.date,
        status: result.status,
      );
      
      print('[SLEEP] ✅ Bedtime logged successfully! Reloading data...');
      notifyListeners();

      // Vẫn reload để đảm bảo đồng bộ hoàn toàn với server logic
      await loadTodaySleep(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Lỗi khi ghi giờ đi ngủ: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Complete sleep (log wake time)
  Future<bool> completeSleep(
    int userId,
    String wakeTime, // ISO format: "2026-01-03T07:00:00"
    {
    required int quality,
    String? notes,
  }) async {
    print('[SLEEP] ☀️ Completing sleep with wakeTime: $wakeTime');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // wakeTime is already in ISO format from WaketimeBottomSheet
      final result = await _remoteDataSource.completeSleep(
        userId: userId,
        wakeTime: wakeTime,
        quality: quality,
        notes: notes,
      );

      // Cập nhật state cục bộ ngay lập tức
      _completedSleep = SleepLogData(
        id: result.id!,
        sleepTime: result.sleepTime,
        wakeTime: result.wakeTime,
        duration: result.duration,
        durationHours: result.durationHours,
        quality: result.quality,
        notes: result.notes,
        date: result.date,
        status: result.status,
      );
      
      print('[SLEEP] ✅ Sleep completed successfully! Reloading data...');
      notifyListeners();

      // Reload để đồng bộ với backend
      await loadTodaySleep(userId);
      print('[SLEEP] 🔄 Data reloaded after completeSleep');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Lỗi khi hoàn thành giấc ngủ: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete sleep
  Future<bool> deleteSleep(int userId, int sleepId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _remoteDataSource.deleteSleep(
        sleepId: sleepId,
        userId: userId,
      );

      // Reload to update state
      await loadTodaySleep(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Lỗi khi xóa giấc ngủ: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update sleep (for edit functionality)
  Future<bool> updateSleep({
    required int userId,
    required int sleepId,
    required DateTime originalSleepTime,
    required TimeOfDay newBedtime,
    required TimeOfDay newWakeTime,
    required int quality,
    String? notes,
  }) async {
    print('[SLEEP] 🔄 Updating sleep record: $sleepId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Construct Bedtime (Same day as original)
      final updatedSleepDateTime = DateTime(
        originalSleepTime.year,
        originalSleepTime.month,
        originalSleepTime.day,
        newBedtime.hour,
        newBedtime.minute,
      );

      // 2. Construct Wake Time (Starts with same day as original bedtime)
      var updatedWakeDateTime = DateTime(
        originalSleepTime.year,
        originalSleepTime.month,
        originalSleepTime.day,
        newWakeTime.hour,
        newWakeTime.minute,
      );

      // 3. Logic: If wake time is chronologically BEFORE bedtime, it must be the next day
      if (updatedWakeDateTime.isBefore(updatedSleepDateTime)) {
        updatedWakeDateTime = updatedWakeDateTime.add(const Duration(days: 1));
        print('[SLEEP] 📅 Edit: Adjusted wakeTime to next day: $updatedWakeDateTime');
      }

      final sleepIso = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(updatedSleepDateTime);
      final wakeIso = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(updatedWakeDateTime);

      await _remoteDataSource.updateSleep(
        sleepId: sleepId,
        userId: userId,
        sleepTime: sleepIso,
        wakeTime: wakeIso,
        quality: quality,
        notes: notes,
      );

      print('[SLEEP] ✅ Update successful!');
      // Reload to reflect changes
      await loadTodaySleep(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Lỗi khi cập nhật giấc ngủ: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
