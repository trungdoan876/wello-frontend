import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/core/utils/validators.dart';

void main() {
  // Nhóm các bài kiểm thử liên quan đến kiểm tra tính hợp lệ của Email.
  group('Validators - Email', () {
    
    test('validateEmail rỗng hoặc null', () {
      // Kiểm tra khi giá trị truyền vào là null hoặc chuỗi chỉ chứa dấu cách.
      // Kỳ vọng: Trả về chuỗi thông báo lỗi phù hợp.
      expect(Validators.validateEmail(null), 'Email không được để trống');
      expect(Validators.validateEmail(''), 'Email không được để trống');
      expect(Validators.validateEmail('   '), 'Email không được để trống');
    });

    test('validateEmail sai định dạng', () {
      // Kiểm tra các trường hợp email không hợp lệ về mặt định dạng regex.
      // Kỳ vọng: Trả về câu thông báo yêu cầu định dạng đúng (ví dụ: ten@domain.com).
      expect(Validators.validateEmail('invalid-email'), 'Email không hợp lệ (ví dụ: ten@domain.com)');
      expect(Validators.validateEmail('invalid@'), 'Email không hợp lệ (ví dụ: ten@domain.com)');
      expect(Validators.validateEmail('@domain.com'), 'Email không hợp lệ (ví dụ: ten@domain.com)');
      expect(Validators.validateEmail('test@com'), 'Email không hợp lệ (ví dụ: ten@domain.com)');
    });

    test('validateEmail hợp lệ', () {
      // Kiểm tra các email có cấu trúc chuẩn xác.
      // Kỳ vọng: Trả về null (nghĩa là không có lỗi, email hợp lệ).
      expect(Validators.validateEmail('test@gmail.com'), null);
      expect(Validators.validateEmail('user.name+label@example.co.uk'), null);
    });
  });

  // Nhóm kiểm thử liên quan đến Mật khẩu.
  group('Validators - Password', () {
    
    test('validatePassword rỗng hoặc null', () {
      // Mật khẩu không được bỏ trống.
      expect(Validators.validatePassword(null), 'Mật khẩu không được để trống');
      expect(Validators.validatePassword(''), 'Mật khẩu không được để trống');
    });

    test('validatePassword ngắn hơn 6 ký tự', () {
      // Kiểm tra độ dài mật khẩu (yêu cầu tối thiểu 6 ký tự).
      expect(Validators.validatePassword('12345'), 'Mật khẩu phải có ít nhất 6 ký tự');
    });

    test('validatePassword hợp lệ', () {
      // Mật khẩu từ 6 ký tự trở lên sẽ được chấp nhận.
      expect(Validators.validatePassword('123456'), null);
      expect(Validators.validatePassword('securePassword123'), null);
    });
  });

  // Nhóm kiểm thử liên quan đến Nhập lại mật khẩu (Confirm Password).
  group('Validators - Confirm Password', () {
    
    test('validateConfirmPassword rỗng hoặc null', () {
      // Khi người dùng chưa điền vào ô xác nhận mật khẩu.
      expect(Validators.validateConfirmPassword('123456', null), 'Vui lòng xác nhận mật khẩu');
      expect(Validators.validateConfirmPassword('123456', ''), 'Vui lòng xác nhận mật khẩu');
    });

    test('validateConfirmPassword không khớp', () {
      // Khi mật khẩu nhập ở 2 ô khác nhau.
      expect(Validators.validateConfirmPassword('123456', '12345'), 'Mật khẩu xác nhận không khớp');
    });

    test('validateConfirmPassword trùng khớp', () {
      // Khi cả hai mật khẩu hoàn toàn trùng nhau.
      expect(Validators.validateConfirmPassword('123456', '123456'), null);
    });
  });

  // Nhóm kiểm thử cho tính năng bắt buộc nhập các trường chung.
  group('Validators - Required Field', () {
    
    test('validateRequired rỗng hoặc null', () {
      // Thử bỏ trống trường dữ liệu "Họ tên".
      // Kỳ vọng: Trả về câu thông báo lỗi chứa tên trường tương ứng.
      expect(Validators.validateRequired(null, 'Họ tên'), 'Họ tên không được để trống');
      expect(Validators.validateRequired('', 'Họ tên'), 'Họ tên không được để trống');
      expect(Validators.validateRequired('   ', 'Họ tên'), 'Họ tên không được để trống');
    });

    test('validateRequired hợp lệ', () {
      // Điền giá trị đầy đủ.
      expect(Validators.validateRequired('Nguyễn Văn A', 'Họ tên'), null);
    });
  });
}
