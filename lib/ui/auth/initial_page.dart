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
    print('🔍 Checking authentication...');
    
    // Get userId from SharedPreferences
    final userId = await UserPreferences.getUserId();
    print('📱 UserId from storage: $userId');
    
    if (userId == null) {
      // No userId in local storage → Go to login
      print('❌ No userId found → StartPage');
      if (!mounted) return;
      setState(() {
        _nextPage = const StartPage();
      });
      return;
    }
    
    // Verify userId exists in database
    print('🌐 Verifying userId=$userId with backend...');
    try {
      final dataSource = NutritionRemoteDataSource();
      
      // Call lightweight verify API
      final userExists = await dataSource.verifyUser(userId.toString());
      
      print('📡 Verify API response: userExists=$userExists');
      
      if (userExists) {
        print('✅ User verified in database!');
        
        // User exists → Go to home
        if (!mounted) return;
        setState(() {
          _nextPage = MainNavigationScreen();
          print('🎯 Next page: MainNavigation (Home)');
        });
      } else {
        print('❌ User not found in database (userId=$userId)');
        print('🗑️ Clearing session...');
        
        await UserPreferences.clearAll();
        
        if (!mounted) return;
        setState(() {
          _nextPage = const StartPage();
          print('🎯 Next page: StartPage (Login)');
        });
      }
      
    } catch (e) {
      // Network error or server down
      print('⚠️ User verification error: $e');
      print('⚠️ This could be network issue or server down');
      
      // Option 1: Clear session (strict - force re-login)
      // Option 2: Allow offline mode (keep session)
      // Choosing Option 1 for security
      print('🗑️ Clearing session due to verification failure...');
      
      await UserPreferences.clearAll();
      
      if (!mounted) return;
      setState(() {
        _nextPage = const StartPage();
        print('🎯 Next page: StartPage (Login) - Error recovery');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_nextPage == null) {
      // Still checking auth, show simple loading
      print('⏳ Still checking auth...');
      return const Scaffold(
        backgroundColor: Color(0xFFFFFBEA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
          ),
        ),
      );
    }
    
    print('🚀 Loading page ready, transitioning...');
    // Auth checked, show LoadingPage with transition to next page
    return LoadingPage(nextPage: _nextPage!);
  }
}
