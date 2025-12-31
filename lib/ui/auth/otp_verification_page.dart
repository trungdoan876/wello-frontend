import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../login/login_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String password;
  final String verificationToken;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.password,
    required this.verificationToken,
  });
  
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  bool _isLoading = false;
  bool _isResending = false;

  // Timer for OTP expiration (5 minutes)
  late Timer _timer;
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  bool _canResend = false;

  String _currentVerificationToken = '';

  String _cleanErrorMessage(String raw) {
    var msg = raw;
    // Remove common prefixes
    msg = msg.replaceAll('Exception: ', '');
    msg = msg.replaceAll('Error verifying OTP:', '');
    msg = msg.replaceAll('error verifying otp:', '');
    msg = msg.replaceAll('Error:', '');
    // Trim whitespace
    msg = msg.trim();
    // Fallback
    if (msg.isEmpty) {
      msg = 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
    return msg;
  }

  @override
  void initState() {
    super.initState();
    _currentVerificationToken = widget.verificationToken;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Thiếu thông tin',
        text: 'Vui lòng nhập mã OTP',
      );
      return;
    }

    if (otp.length != 6) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Mã OTP không hợp lệ',
        text: 'Mã OTP phải có 6 chữ số',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Verify OTP
      final verifyResponse = await _authRepository.verifyOtp(
        verificationToken: _currentVerificationToken,
        otp: otp,
      );

      if (!mounted) return;

      // Check if this is registration flow
      if (verifyResponse.type == 'registration') {
        if (verifyResponse.hashedPassword == null) {
          setState(() => _isLoading = false);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Lỗi',
            text: 'Không nhận được thông tin mật khẩu từ server',
          );
          return;
        }

        // Step 2: Register user with hashed password
        final registerResponse = await _authRepository.register(
          email: verifyResponse.email,
          hashedPassword: verifyResponse.hashedPassword!,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          if (registerResponse.success) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Thành công!',
              text: registerResponse.message,
              onConfirmBtnTap: () {
                Navigator.of(context).pop(); // Close alert
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            );
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Đăng ký thất bại',
              text: registerResponse.message,
            );
          }
        }
      } else {
        // Not a registration flow
        setState(() => _isLoading = false);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi',
          text: 'OTP này không dùng cho đăng ký',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Xác thực thất bại',
          text: _cleanErrorMessage(e.toString()),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      // Use sendOtp instead of resendOtp (backend removed resend-otp endpoint)
      final response = await _authRepository.sendOtp(
        email: widget.email,
        password: widget.password,
      );

      if (mounted) {
        setState(() {
          _isResending = false;
          _currentVerificationToken = response.verificationToken;
          _remainingSeconds = 300; // Reset timer to 5 minutes
          _canResend = false;
        });

        // Restart timer
        _timer.cancel();
        _startTimer();

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Mã OTP mới đã được gửi đến email của bạn',
        );

        // Clear OTP input
        _otpController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi',
          text: _cleanErrorMessage(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  'Xác thực OTP',
                  style: GoogleFonts.baloo2(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập mã OTP đã được gửi đến',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                widget.email,
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEBCF23),
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 16,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: GoogleFonts.baloo2(
                    fontSize: 32,
                    color: Colors.grey.shade300,
                    letterSpacing: 16,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFEBCF23),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Timer
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _canResend
                        ? Colors.red.shade50
                        : const Color(0xFFEBCF23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: _canResend
                            ? Colors.red
                            : const Color(0xFFEBCF23),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _canResend ? 'Hết hạn' : _timerText,
                        style: GoogleFonts.baloo2(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _canResend ? Colors.red : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBCF23),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Xác thực',
                          style: GoogleFonts.baloo2(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: _canResend && !_isResending ? _resendOtp : null,
                  child: _isResending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFEBCF23),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Đang gửi lại...',
                              style: GoogleFonts.baloo2(
                                fontSize: 16,
                                color: Color(0xFFEBCF23),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Không nhận được mã? Gửi lại',
                          style: GoogleFonts.baloo2(
                            fontSize: 16,
                            color: _canResend
                                ? const Color(0xFFEBCF23)
                                : Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                          ),
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
