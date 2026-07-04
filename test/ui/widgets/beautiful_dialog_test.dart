import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/ui/widgets/beautiful_dialog.dart';

void main() {
  
  // testWidgets() dùng để chạy các test case liên quan đến giao diện (Widget) thay vì logic Dart thuần túy.
  // Nó cung cấp đối tượng 'tester' để điều khiển giao diện giả lập.
  testWidgets('BeautifulDialog renders message and closes on OK tap', (tester) async {
    
    // 1. Arrange: Khởi dựng widget ảo sử dụng tester.pumpWidget.
    // Vì BeautifulDialog.show yêu cầu một context hợp lệ có MaterialApp và Scaffold, ta bọc nó trong một nút bấm.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  BeautifulDialog.show(
                    context,
                    title: 'Alert',
                    message: 'Operation Successful!',
                    isError: false,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    // 2. Act: Thực hiện click nút 'Open' để hiển thị hộp thoại.
    // find.text('Open') tìm Widget chứa đoạn text 'Open'.
    await tester.tap(find.text('Open'));
    
    // pumpAndSettle() chờ cho tất cả các hoạt ảnh (animations) hoặc render khung hình hoàn tất hoàn toàn.
    await tester.pumpAndSettle();

    // 3. Assert: Kiểm tra xem Dialog đã hiển thị các thông tin mong muốn chưa.
    // - Đoạn tin nhắn hiển thị đúng một lần:
    expect(find.text('Operation Successful!'), findsOneWidget);
    // - Nút bấm 'OK' hiển thị đúng một lần:
    expect(find.text('OK'), findsOneWidget);
    // - Icon tích xanh thành công hiển thị đúng một lần:
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    // 4. Act: Click nút OK trên dialog để đóng hộp thoại.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle(); // Chờ hộp thoại đóng hoàn toàn

    // 5. Assert: Đảm bảo hộp thoại không còn nằm trên màn hình nữa (findsNothing).
    expect(find.text('Operation Successful!'), findsNothing);
  });

  testWidgets('BeautifulDialog shows error icon when isError is true', (tester) async {
    // 1. Arrange: Dựng widget ảo cấu hình hiển thị lỗi (isError: true).
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  BeautifulDialog.show(
                    context,
                    title: 'Error',
                    message: 'Something went wrong',
                    isError: true,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    // 2. Act: Mở hộp thoại.
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // 3. Assert: Kiểm tra xem giao diện có chứa thông điệp lỗi và icon cảnh báo lỗi (Icons.error_outline) hay không.
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
