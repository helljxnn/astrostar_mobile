import 'package:flutter/material.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario Empleados'),
        backgroundColor: const Color(0xFF9370DB),
      ),
      body: const Center(
        child: Text('Página de Horario de Empleados'),
      ),
    );
  }
}