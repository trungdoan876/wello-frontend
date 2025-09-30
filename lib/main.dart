import 'package:flutter/material.dart';

import 'ui/auth/start_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wello',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StartPage(),
      debugShowCheckedModeBanner: false, //tắt banner debug
    );
  }
}
