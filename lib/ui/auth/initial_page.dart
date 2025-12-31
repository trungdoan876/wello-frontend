import 'package:flutter/material.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/ui/auth/start_page.dart';
import 'package:wello_frontend/ui/main_navigation_screen.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';
import 'package:wello_frontend/data/data_source/user_preferences.dart';
import 'package:wello_frontend/data/data_source/nutrition_remote_data_source.dart';

/// Initial page wrapper - checks auth and navigates appropriately
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  Widget? _nextPage;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('Dang kiem tra xac thuc...');
    
    // Get userId from SharedPreferences
    final userId = await UserPreferences.getUserId();
    print('UserId tu bo nho: $userId');
    
    if (userId == null) {
      // No userId in local storage → Go to login
      print('Khong tim thay userId -> Chuyen den StartPage');
      if (!mounted) return;
      setState(() {
        _nextPage = const StartPage();
      });
      return;
    }
    
    // Xác thực userId và email với backend
    print('Dang xac thuc thong tin dang nhap voi backend...');
    try {
      final isValid = await AuthHelper.verifyStoredCredentials();
      
      print('Ket qua xac thuc: hop le=$isValid');
      
      if (isValid) {
        print('Thong tin dang nhap hop le!');
        
        if (!mounted) return;
        setState(() {
          _nextPage = MainNavigationScreen();
          print('Trang tiep theo: NavNavigation (Home)');
        });
      } else {
        print('Thong tin dang nhap khong hop le hoac nguoi dung khong ton tai');
        print('Dang xoa phien lam viec...');
        
        await AuthHelper.logout();
        
        if (!mounted) return;
        setState(() {
          _nextPage = const StartPage();
          print('Trang tiep theo: StartPage (Login)');
        });
      }
      
    } catch (e) {
      // Network error or server down
      print('Loi xac thuc nguoi dung: $e');
      print('Day co the la loi mang hoac server dang bao tri');
      
      // Option 1: Clear session (strict - force re-login)
      // Option 2: Allow offline mode (keep session)
      // Choosing Option 1 for security
      print('Dang xoa phien lam viec do xac thuc that bai...');
      
      await AuthHelper.logout();
      
      if (!mounted) return;
      setState(() {
        _nextPage = const StartPage();
        print('Trang tiep theo: StartPage (Login) - Phuc hoi sau loi');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_nextPage == null) {
      // Still checking auth, show simple loading
      print('Dang kiem tra quyen xac thuc...');
      return const Scaffold(
        backgroundColor: Color(0xFFFFFBEA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
          ),
        ),
      );
    }
    
    print('Trang da san sang, dang chuyen tiep...');
    // Auth checked, show LoadingPage with transition to next page
    return LoadingPage(nextPage: _nextPage!);
  }
}
