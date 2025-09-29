import 'package:flutter/material.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/auth/pages/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AstroStar',
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage(), 
        "/main": (context) => const MainPage(),
      },
    );
  }
}
