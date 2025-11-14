import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 650; // check màn nhỏ để điều chỉnh font/padding

    return Scaffold(
      body: SafeArea(
        // LayoutBuilder để lấy constraints hiện tại (dùng cho ConstrainedBox)
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            // SingleChildScrollView để tránh overflow nếu màn hình quá nhỏ
            child: ConstrainedBox(
              // Ép minHeight bằng chiều cao khả dụng để Column có thể stretch toàn màn hình
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                // IntrinsicHeight giúp Column hiểu được minHeight và hoạt động tốt với spaceBetween
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06, // responsive padding ngang
                    vertical: size.height * 0.03,   // responsive padding dọc
                  ),
                  child: Column(
                    // Trải đều các phần tử theo chiều dọc
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- TOP: logo + spacing (đặt vào một Column nhỏ để nhóm) ---
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.01), // responsive spacer top

                          // Logo app
                          Image.asset(
                            'assets/images/wello.png',
                            fit: BoxFit.contain,
                            width: size.width * 0.9, // responsive width logo
                            //height: size.height * 0.3, // responsive height (giữ tỉ lệ)
                          ),
                        ],
                      ),

                      // --- MIDDLE: Tên app + mô tả (giữa màn hình) ---
                      Column(
                        children: [
                          // Tên app - font size tính theo width để scale tốt trên cả phone & tablet
                          Text(
                            'Wello',
                            style: TextStyle(
                              fontSize: size.width * 0.1, // responsive text
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.pacifico().fontFamily,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: <Color>[
                                    Color.fromARGB(255, 148, 201, 244),
                                    Color.fromARGB(255, 114, 108, 231),
                                  ],
                                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: size.height * 0.012),

                          // Mô tả - font nhỏ hơn trên màn nhỏ
                          Text(
                            "Wello giúp bạn đạt được mục tiêu sức khỏe với các phân tích chuyên sâu, "
                            "theo dõi vấn đề sức khỏe và những thử thách hấp dẫn.\n\n"
                            "Hãy bắt đầu hành trình khỏe mạnh hơn ngay hôm nay!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? size.width * 0.035 : size.width * 0.04,
                              height: 1.5,
                              color: const Color.fromARGB(221, 80, 73, 73),
                            ),
                          ),
                        ],
                      ),

                      // --- BOTTOM: nút bắt đầu (ở đáy màn hình) ---
                      Column(
                        children: [
                          SizedBox(
                            width: size.width * 0.75, // responsive width cho nút
                            child: AnimatedStartButton(
                              text: "Bắt đầu ngay!",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoadingPage(nextPage: const LoginPage()),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: size.height * 0.02), // khoảng cách tới đáy
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
