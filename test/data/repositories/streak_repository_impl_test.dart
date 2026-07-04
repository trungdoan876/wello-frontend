import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wello_frontend/data/repositories/streak_repository_impl.dart';
import 'package:wello_frontend/data/data_source/streak_remote_data_source.dart';
import 'package:wello_frontend/domain/entities/daily_streak_model.dart';

// Tạo Mock Class giả lập cho nguồn dữ liệu từ xa (StreakRemoteDataSource).
// Điều này giúp chúng ta test Repository độc lập mà không cần thực sự gọi API thật qua mạng.
class MockStreakRemoteDataSource implements StreakRemoteDataSource {
  
  // Ném lỗi UnimplementedError nếu thuộc tính client bị gọi, vì ta không cần dùng đến client thật.
  @override
  http.Client get client => throw UnimplementedError();

  // Biến cấu hình hành vi của mock.
  List<DailyStreakModel> mockResult = []; // Danh sách kết quả giả lập trả về.
  bool shouldThrow = false;              // Cờ kích hoạt ném lỗi giả lập.

  // Biến lưu vết (spy) để kiểm tra xem Repository có truyền đúng tham số xuống DataSource hay không.
  String? lastToken;
  int? lastUserId;
  int? lastYear;
  int? lastMonth;

  @override
  Future<List<DailyStreakModel>> getMonthlyStreak({
    required String token,
    required int userId,
    required int year,
    required int month,
  }) async {
    // Lưu lại các tham số truyền vào để đối chiếu kiểm tra.
    lastToken = token;
    lastUserId = userId;
    lastYear = year;
    lastMonth = month;

    // Giả lập lỗi server nếu cờ shouldThrow được bật.
    if (shouldThrow) {
      throw Exception('Server error');
    }
    
    // Trả về dữ liệu danh sách mock đã được thiết lập trước.
    return mockResult;
  }
}

void main() {
  group('StreakRepositoryImpl Tests', () {
    late MockStreakRemoteDataSource mockDataSource;
    late StreakRepositoryImpl repository;

    // setUp() sẽ chạy trước mỗi hàm test() đơn lẻ trong nhóm này.
    // Dùng để làm sạch và khởi tạo lại đối tượng test, tránh việc dữ liệu bị nhiễm chéo từ các test case trước.
    setUp(() {
      mockDataSource = MockStreakRemoteDataSource();
      repository = StreakRepositoryImpl(mockDataSource);
    });

    test('getMonthly should invoke getMonthlyStreak and return list of DailyStreak', () async {
      // 1. Arrange: Chuẩn bị dữ liệu trả về giả lập cho DataSource.
      final mockData = [
        DailyStreakModel(date: DateTime(2026, 6, 10), water: true, meal: false),
        DailyStreakModel(date: DateTime(2026, 6, 11), water: true, meal: true),
      ];
      mockDataSource.mockResult = mockData;

      // 2. Act: Thực thi hàm getMonthly của Repository.
      final result = await repository.getMonthly('token123', 1, 2026, 6);

      // 3. Assert: Kiểm tra xem Repository có hoạt động đúng không.
      // - Số lượng bản ghi nhận được có bằng 2 không?
      expect(result.length, 2);
      // - Dữ liệu bên trong có khớp không?
      expect(result[0].water, isTrue);
      expect(result[1].meal, isTrue);
      // - Các tham số truyền xuống DataSource có đúng như ban đầu không?
      expect(mockDataSource.lastToken, 'token123');
      expect(mockDataSource.lastUserId, 1);
      expect(mockDataSource.lastYear, 2026);
      expect(mockDataSource.lastMonth, 6);
    });

    test('getMonthly should throw when remote data source throws exception', () async {
      // 1. Arrange: Cấu hình cho DataSource ném lỗi khi được gọi.
      mockDataSource.shouldThrow = true;

      // 2. Act & Assert: Kỳ vọng hàm getMonthly() sẽ ném ra lỗi Exception.
      expect(
        () => repository.getMonthly('token123', 1, 2026, 6),
        throwsA(isA<Exception>()),
      );
    });
  });
}
