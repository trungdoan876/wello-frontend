import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// QUAN TRỌNG: Đảm bảo đã thêm và import gói google_fonts
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';// ignore: depend_on_referenced_packages
import 'package:wello_frontend/ui/widgets/loading_page.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Định nghĩa Màu sắc ---
    const Color lightCream = Color(0xFFFFFBEA);
    // Màu Wello cũ: const Color welloYellow = Color(0xFFFDC000); 
    // Màu Healthy Food cũ: const Color healthyGreen = Color(0xFF4CAF50);
    
    // Màu Wello ):
    const Color newWelloOrange = Color(0xFFEBCF23); 
    const Color darkText = Color(0xFF5A5A5A);

    return Scaffold(
      backgroundColor: lightCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Thêm khoảng trống ở trên
              SizedBox(height: context.h(0.1)), 

              // --- Tiêu đề "Wello" (Áp dụng style mới) ---
              Text(
                'Wello',
                textAlign: TextAlign.center,
                style: GoogleFonts.pacifico(
                  // Font size responsive (ví dụ: 11% cạnh ngắn nhất)
                  fontSize: context.sp(18), 
                  // Màu sắc mới: Xanh da trời nhạt
                  color: newWelloOrange, 
                  // Sử dụng fontWeight.w400 như yêu cầu
                  fontWeight: FontWeight.w400, 
                ),
              ),
              
              // Khoảng trống 3% chiều cao màn hình
              SizedBox(height: context.h(0.03)),

              // --- Đoạn mô tả 1 ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.08)), 
                child: Text(
                  'Wello giúp bạn đạt được mục tiêu sức khỏe với các phân tích chuyên sâu, theo dõi vấn đề sức khỏe và những thử thách hấp dẫn.',
                  textAlign: TextAlign.center,
                 style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(4.0), 
                    color: darkText,
                    height: 1.5,
                  ),
                ),
              ),

              // Khoảng trống 2% chiều cao màn hình
              SizedBox(height: context.h(0.02)),

              // --- Đoạn mô tả 2 ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
                child: Text(
                  'Hãy bắt đầu hành trình khỏe mạnh hơn ngay hôm nay!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(4.0),
                    color: darkText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Khoảng trống 5% chiều cao màn hình
              SizedBox(height: context.h(0.05)),

              // --- Nút "Bắt đầu ngay" ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.1)),
                child: SizedBox(
                  width: context.w(0.8), // responsive theo chiều ngang
                  child: AnimatedStartButton(
                    text: "Bắt đầu ngay",
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadingPage(
                            nextPage: const LoginPage(),
                          ),
                        ),
                      );
                      // TODO: Xử lý logic login
                    },
                  ),
                ),
              ),

              // Khoảng trống 2% chiều cao màn hình
              SizedBox(height: context.h(0.01)),

              // --- Hình ảnh ---
              //Spacer(), 
              Padding(
                padding: EdgeInsets.all(context.w(0.05)),
                child: SizedBox(
                  height: context.h(0.35), 
                  child: Image.asset(
                    'assets/images/healthy_food.png', 
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}