import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        backgroundColor: const Color(0xFF9370DB),
      ),
      body: const Center(
        child: Text('Página de Asistencia'),
      ),
    );
  }
}