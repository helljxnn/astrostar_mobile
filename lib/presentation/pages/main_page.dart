import 'package:astrostar_mobile/presentation/pages/more/more_page.dart';
import 'package:flutter/material.dart';
import '../widgets/shared/bottom_navigation.dart';
import 'home/home_page.dart';
import 'appointments/appointments_page.dart';
import 'events/event_page.dart';
import 'attendance/attendance_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const AppointmentsPage();
      case 2:
        return const EventPage();
      case 3:
        return const AttendancePage();
      case 4:
        return const MorePage();
      default:
        return const HomePage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
