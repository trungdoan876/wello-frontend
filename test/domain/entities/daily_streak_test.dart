import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/domain/entities/daily_streak.dart';
import 'package:wello_frontend/domain/entities/daily_streak_model.dart';

// Hàm main() là điểm khởi đầu (entry point) để chạy tất cả các bài kiểm thử trong file này.
void main() {
  
  // group() dùng để gom nhóm các test case có liên quan lại với nhau (ví dụ: nhóm test cho Entity DailyStreak).
  group('DailyStreak Entity Tests', () {
    
    // test() định nghĩa một ca kiểm thử (test case) cụ thể kèm theo mô tả về kỳ vọng đầu ra.
    test('Should return correct color and label for water=true, meal=true', () {
      // 1. Arrange: Chuẩn bị dữ liệu đầu vào.
      // Tạo đối tượng DailyStreak với cả hai cờ water và meal đều bằng true.
      final streak = DailyStreak(
        date: DateTime(2026, 6, 10),
        water: true,
        meal: true,
      );
      
      // 2. Act & Assert: Thực hiện kiểm tra xem thuộc tính thực tế có khớp với kỳ vọng hay không.
      // Kỳ vọng: Khi hoàn thành cả uống nước & ăn uống thì màu phải là màu cam (Colors.orange)
      expect(streak.color, Colors.orange);
      // Kỳ vọng: Nhãn hiển thị phải là 'Uống nước & Ăn uống'
      expect(streak.label, 'Uống nước & Ăn uống');
    });

    test('Should return correct color and label for water=true, meal=false', () {
      // Khởi tạo trạng thái: chỉ uống nước (water=true), không log bữa ăn (meal=false).
      final streak = DailyStreak(
        date: DateTime(2026, 6, 10),
        water: true,
        meal: false,
      );
      
      // Kiểm tra: Chỉ uống nước thì có màu xanh dương (Colors.blue) và nhãn là 'Uống nước'.
      expect(streak.color, Colors.blue);
      expect(streak.label, 'Uống nước');
    });

    test('Should return correct color and label for water=false, meal=true', () {
      // Khởi tạo trạng thái: không uống nước (water=false), chỉ log bữa ăn (meal=true).
      final streak = DailyStreak(
        date: DateTime(2026, 6, 10),
        water: false,
        meal: true,
      );
      
      // Kiểm tra: Chỉ ăn uống thì có màu đỏ (Colors.red) và nhãn là 'Ăn uống'.
      expect(streak.color, Colors.red);
      expect(streak.label, 'Ăn uống');
    });

    test('Should return correct color and label for water=false, meal=false', () {
      // Khởi tạo trạng thái: chưa hoàn thành mục tiêu nào cả.
      final streak = DailyStreak(
        date: DateTime(2026, 6, 10),
        water: false,
        meal: false,
      );
      
      // Kiểm tra: Chưa làm gì thì màu trong suốt (transparent) và nhãn rỗng.
      expect(streak.color, Colors.transparent);
      expect(streak.label, '');
    });
  });

  // Gom nhóm kiểm thử cho phần chuyển đổi dữ liệu JSON của DailyStreakModel.
  group('DailyStreakModel JSON Serialization Tests', () {
    
    test('DailyStreakModel.fromJson should parse valid json map correctly', () {
      // 1. Arrange: Chuẩn bị một Map giả lập JSON nhận về từ API.
      final json = {
        'date': '2026-06-10T00:00:00.000',
        'water': true,
        'meal': false,
      };
      
      // 2. Act: Thực hiện chuyển đổi JSON thành thực thể DailyStreakModel.
      final model = DailyStreakModel.fromJson(json);

      // 3. Assert: Kiểm tra xem các trường dữ liệu có được phân tích (parse) chính xác không.
      expect(model.date, DateTime(2026, 6, 10));
      expect(model.water, true);
      expect(model.meal, false);
    });

    test('DailyStreakModel.fromJson should handle null fields and use default values', () {
      // 1. Arrange: Giả lập JSON chứa giá trị null cho cờ water và meal.
      final json = {
        'date': '2026-06-10T00:00:00.000',
        'water': null,
        'meal': null,
      };
      
      // 2. Act: Tiến hành parse JSON.
      final model = DailyStreakModel.fromJson(json);

      // 3. Assert: Kiểm tra xem các giá trị mặc định (false) có được áp dụng khi nhận null không.
      expect(model.date, DateTime(2026, 6, 10));
      expect(model.water, false); // Mặc định là false nếu null
      expect(model.meal, false);  // Mặc định là false nếu null
    });
  });
}
