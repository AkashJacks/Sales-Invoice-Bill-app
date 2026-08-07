import 'package:flutter/material.dart';
import 'package:master_app/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP App',
      debugShowCheckedModeBanner: false,
theme: ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
),
      // First Screen
      home: LoginScreen(),
    );
  }
}

