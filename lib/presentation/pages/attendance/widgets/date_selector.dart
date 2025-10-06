import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const DateSelector({
    super.key,
    required this.date,
    required this.onTap,
  });

  // Formatea la fecha en formato: "Lunes, 6 de Octubre de 2025"
  String _formatDate(DateTime date) {
    const meses = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    const dias = [
      "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"
    ];

    final nombreDia = dias[date.weekday - 1];
    final nombreMes = meses[date.month - 1];

    return "$nombreDia, ${date.day} de $nombreMes de ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.calendar_today, size: 20, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
