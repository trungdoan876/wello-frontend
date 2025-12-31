import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/data/repositories/auth_repository_impl.dart';
import 'package:wello_frontend/ui/auth/reset_otp_verification_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/beautiful_dialog.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void showPopup({
    required String title,
    required String message,
    bool isError = true,
  }) {
    BeautifulDialog.show(
      context,
      title: title,
      message: message,
      isError: isError,
    );
  }

  Future<void> handleForgotPassword() async {
    final email = emailController.text.trim();

    // Validation
    if (email.isEmpty) {
      print('[ForgotPassword] Email trong');
      showPopup(
        title: "",
        message: "Vui lòng nhập email của bạn.",
      );
      return;
    }

    // Basic email validation
    if (!email.contains('@')) {
      print('[ForgotPassword] Email khong hop le: $email');
      showPopup(
        title: "",
        message: "Email không hợp lệ.",
      );
      return;
    }

    print('[ForgotPassword] Bat dau gui OTP reset cho email: $email');
    setState(() {
      isLoading = true;
    });

    try {
      final repository = AuthRepositoryImpl();
      print('[ForgotPassword] Goi API /forgot-password...');
      final response = await repository.forgotPassword(email: email);
      print('[ForgotPassword] Nhan phan hoi: success=${response.success}, message=${response.message}');

      setState(() {
        isLoading = false;
      });

      if (response.success) {
        // Navigate to OTP verification page
        if (response.verificationToken != null) {
          print('[ForgotPassword] Thanh cong! verificationToken: ${response.verificationToken!.substring(0, 20)}...');
          print('[ForgotPassword] Chuyen den ResetOtpVerificationPage');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetOtpVerificationPage(
                email: email,
                verificationToken: response.verificationToken!,
              ),
            ),
          );
        } else {
          print('[ForgotPassword] Thieu verificationToken!');
        }
      } else {
        print('[ForgotPassword] That bai: ${response.message}');
        showPopup(
          title: "",
          message: response.message,
        );
      }
    } catch (e) {
      print('[ForgotPassword] Ngoai le: $e');
      setState(() {
        isLoading = false;
      });
      showPopup(
        title: "",
        message: "Không thể kết nối server: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFFFBEA);
    const Color titleYellow = Color(0xFFEBCF23);
    const Color darkText = Color(0xFF5A5A5A);

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: titleYellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.h(0.05)),

                // Title
                Text(
                  'QUÊN MẬT KHẨU',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w900,
                    color: titleYellow,
                  ),
                ),

                SizedBox(height: context.h(0.02)),

                // Description
                Text(
                  'Nhập email của bạn để nhận mã OTP đặt lại mật khẩu',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(4.0),
                    color: darkText,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                // Email input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.sp(3.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: context.sp(4.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.sp(3.0)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.w(0.05),
                        vertical: context.h(0.02),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.h(0.04)),

                // Submit button
                SizedBox(
                  width: context.w(0.8),
                  child: AnimatedStartButton(
                    text: isLoading ? "Đang gửi..." : "Gửi mã OTP",
                    onPressed: isLoading ? () {} : handleForgotPassword,
                  ),
                ),

                SizedBox(height: context.h(0.03)),

                // Back to login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(
                      fontSize: context.sp(4.0),
                      color: Colors.grey.shade700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
