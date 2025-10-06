import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/pages/appointments/appointments_page.dart';
import 'presentation/pages/main_page.dart';
import 'screens/splash/splash_screen.dart';
import 'presentation/pages/auth/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AstroStar',
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // <-- Aquí defines cuál pantalla arranca
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
        '/appointments': (context) => const AppointmentsPage(),
        // Nota: La ruta de detalle no se usa directamente aquí, ya que pasamos el objeto
        // pero es buena práctica tenerla por si se necesita navegación por nombre con argumentos.
      },
    );
  }
}
