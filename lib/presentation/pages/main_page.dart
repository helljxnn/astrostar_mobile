import 'package:astrostar_mobile/presentation/pages/more/more_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/shared/bottom_navigation.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/permissions_service.dart';
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

  Widget _getCurrentPage(PermissionsService? permissions) {
    // Mapear índices considerando tabs ocultos
    final visiblePages = _getVisiblePages(permissions);
    
    if (_currentIndex >= visiblePages.length) {
      _currentIndex = 0;
    }
    
    return visiblePages[_currentIndex];
  }

  List<Widget> _getVisiblePages(PermissionsService? permissions) {
    final pages = <Widget>[];
    
    // Home - siempre visible
    pages.add(const HomePage());
    
    // Citas - solo si tiene permiso
    if (permissions == null || permissions.canAccessAppointments) {
      pages.add(const AppointmentsPage());
    }
    
    // Eventos - siempre visible
    pages.add(const EventPage());
    
    // Asistencia - solo si tiene permiso
    if (permissions == null || permissions.canAccessAttendance) {
      pages.add(const AttendancePage());
    }
    
    // Más - siempre visible
    pages.add(const MorePage());
    
    return pages;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    
    // Obtener permisos si está autenticado
    PermissionsService? permissions;
    if (authState is AuthAuthenticated) {
      permissions = PermissionsService(authState.user);
    }
    
    return Scaffold(
      body: _getCurrentPage(permissions),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        permissions: permissions,
      ),
    );
  }
}
