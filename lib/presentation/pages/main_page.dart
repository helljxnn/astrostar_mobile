import 'package:flutter/material.dart';
import '../widgets/shared/bottom_navigation.dart';
import 'employees/employees_page.dart';
import 'appointments/appointments_page.dart';
import 'events/event_page.dart';
import 'attendance/attendance_page.dart';
import 'profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EmployeesPage(),
    const AppointmentsPage(),
    const EventPage(),
    const AttendancePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}