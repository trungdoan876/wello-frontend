import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'package:wello_frontend/ui/auth/new_password_page.dart';

class ResetOtpVerificationPage extends StatefulWidget {
  final String email;
  final String verificationToken;

  const ResetOtpVerificationPage({
    super.key,
    required this.email,
    required this.verificationToken,
  });

  @override
  State<ResetOtpVerificationPage> createState() =>
      _ResetOtpVerificationPageState();
}

class _ResetOtpVerificationPageState extends State<ResetOtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  bool _isLoading = false;
  bool _isResending = false;

  // Timer for OTP expiration (5 minutes)
  late Timer _timer;
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  bool _canResend = false;

  String _currentVerificationToken = '';

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
      print('🔴 [ResetOTP] OTP không đúng 6 chữ số: ${otp.length}');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Mã OTP không hợp lệ',
        text: 'Mã OTP phải có 6 chữ số',
      );
      return;
    }

    print('🔵 [ResetOTP] Bắt đầu xác thực OTP: $otp');
    setState(() => _isLoading = true);

    try {
      // Use the unified verify-otp endpoint
      print('🔵 [ResetOTP] Gọi API /verify-otp...');
      final response = await _authRepository.verifyOtp(
        verificationToken: _currentVerificationToken,
        otp: otp,
      );
      print('🔵 [ResetOTP] Nhận response: type=${response.type}, resetToken=${response.resetToken != null}');

      if (mounted) {
        setState(() => _isLoading = false);

        // Check if this is password reset flow
        if (response.type == 'password_reset' && response.resetToken != null) {
          print('✅ [ResetOTP] Xác thực thành công! resetToken: ${response.resetToken!.substring(0, 20)}...');
          print('🔵 [ResetOTP] Chuyển đến NewPasswordPage');
          // Navigate to new password page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => NewPasswordPage(
                resetToken: response.resetToken!,
              ),
            ),
          );
        } else if (response.type == 'password_reset') {
          print('🔴 [ResetOTP] Thiếu resetToken!');
          // Missing reset token
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Lỗi',
            text: 'Không nhận được reset token từ server',
          );
        } else {
          print('🔴 [ResetOTP] Sai loại OTP: ${response.type}');
          // Wrong OTP type
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Lỗi',
            text: 'OTP này không dùng cho đặt lại mật khẩu',
          );
        }
      }
    } catch (e) {
      print('🔴 [ResetOTP] Exception: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Xác thực thất bại',
          text: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      final response = await _authRepository.forgotPassword(
        email: widget.email,
      );

      if (mounted) {
        if (response.success && response.verificationToken != null) {
          setState(() {
            _isResending = false;
            _currentVerificationToken = response.verificationToken!;
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
        } else {
          setState(() => _isResending = false);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Lỗi',
            text: response.message,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi',
          text: e.toString().replaceAll('Exception: ', ''),
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
              Text(
                'Xác thực OTP',
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                        color: _canResend ? Colors.red : const Color(0xFFEBCF23),
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
                    foregroundColor: Colors.black87,
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
                              Colors.black87,
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
                  onPressed: _canResend && !_isResending
                      ? _resendOtp
                      : null,
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
