import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/pages/main_page.dart';
import 'screens/splash/splash_screen.dart';
import 'presentation/pages/auth/pages/login_page.dart';
import 'blocs/event/event_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => EventBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AstroStar',
        initialRoute: "/login",
        routes: {
          "/login": (context) => const LoginPage(),
          "/main": (context) => const MainPage(),
        },
      ),
    );
  }
}
