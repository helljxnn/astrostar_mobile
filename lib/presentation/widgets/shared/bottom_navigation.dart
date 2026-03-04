import 'package:flutter/material.dart';
import '../../../core/permissions_service.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final PermissionsService? permissions;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    // Construir items dinámicamente según permisos
    final items = _buildNavigationItems();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF9BE9FF),
        unselectedItemColor: const Color(0xFFB595FF),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
        iconSize: 26,
        items: items,
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    final items = <BottomNavigationBarItem>[];
    
    // Home - siempre visible
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: 'Horario',
    ));
    
    // Citas - solo si tiene permiso
    if (permissions == null || permissions!.canAccessAppointments) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.list_alt),
        label: 'Citas',
      ));
    }
    
    // Eventos - siempre visible
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.event),
      label: 'Eventos',
    ));
    
    // Asistencia - solo si tiene permiso
    if (permissions == null || permissions!.canAccessAttendance) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.assignment),
        label: 'Asistencia',
      ));
    }
    
    // Más - siempre visible
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Más',
    ));
    
    return items;
  }
}
