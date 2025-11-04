import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/auth/start_page.dart';
// import 'package:wello_frontend/ui//login/login_page.dart';
// import 'package:wello_frontend/ui/register/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
       home: StartPage(),
      //  routes: {
      //   '/login': (context) => const LoginPage(),
      //   '/register' : (context) => const RegisterPage(),
      // },
    );
  }
}
