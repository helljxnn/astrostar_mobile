import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const DateSelector({super.key, required this.date, required this.onTap});

  String _formatDate(DateTime date) {
    final meses = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    return "${_dayName(date.weekday)}, ${date.day} de ${meses[date.month - 1]} de ${date.year}";
  }

  String _dayName(int day) {
    const dias = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
    return dias[day - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDate(date),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}
