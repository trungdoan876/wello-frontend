import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/domain/providers/survey_provider.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/ui/auth/initial_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wello',
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
      home: const InitialPage(), // Wrapper that uses LoadingPage
    );
  }
}
