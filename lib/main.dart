import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/auth/start_page.dart';
import 'package:wello_frontend/ui/question/question_page.dart';
import 'package:wello_frontend/ui/question_1/activity_level_screen.dart';
import 'package:wello_frontend/ui/question_2/target_screen.dart';
import 'package:wello_frontend/ui/summary/summary_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
    title: 'My Flutter App',
    theme: ThemeData(
      primarySwatch: Colors.blue,

      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    ),
    debugShowCheckedModeBanner: false,
    home: SummaryPage(),
  );
  }
}
