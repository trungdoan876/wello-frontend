import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:wello_frontend/ui/addfood/calorie_tracker_screen.dart';
import 'package:wello_frontend/ui/auth/start_page.dart';
import 'package:wello_frontend/ui/question/question_page.dart';
import 'package:wello_frontend/ui/question/yes_no_question_page.dart';
import 'package:wello_frontend/ui/workout/workout_detail_page.dart';
import 'package:wello_frontend/ui/workout/workout_plan_page.dart';
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
      debugShowCheckedModeBanner: false,
        home: WorkoutDetailPage(), 
       //home: StartPage(),
    );
  }
}
