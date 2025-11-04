import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';


class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // đẩy ảnh xuống từ trên

              Image.asset('assets/images/wello.png', fit: BoxFit.contain),

              const SizedBox(height: 20), // khoảng cách giữa ảnh và chữ
              Text(
                'Wello',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.lobster().fontFamily,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: <Color>[
                        Color.fromARGB(255, 148, 201, 244),
                        Color.fromARGB(255, 114, 108, 231),
                      ],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Wello giúp bạn đạt được mục tiêu sức khỏe với các phân tích chuyên sâu, "
                "theo dõi vấn đề sức khỏe và những thử thách hấp dẫn.\n\n"
                "Hãy bắt đầu hành trình khỏe mạnh hơn ngay hôm nay!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(221, 80, 73, 73),
                ),
              ),

              const Spacer(), // đẩy button xuống dưới

              SizedBox(
                width: 280,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
