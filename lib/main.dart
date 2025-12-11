import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/auth/pages/login_page.dart';
import 'blocs/event/event_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'core/storage_service.dart';

Future<void> _configureApp() async {
  await initializeDateFormatting('es');
  Intl.defaultLocale = 'es';
  await StorageService().init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => EventBloc()),
        BlocProvider(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),
      ],
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
