import 'package:flutter/material.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/auth/login_page.dart';

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
      initialRoute: "/login", // 👈 Arranca en LoginPage
      routes: {
        "/login": (context) => const LoginPage(),
        "/main": (context) => const MainPage(),
      },
    );
  }
}
