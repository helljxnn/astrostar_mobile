import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../../../../core/app_colors.dart';

class EmployeeScheduleDetailSheet extends StatelessWidget {
  final ScheduleModel schedule;

  const EmployeeScheduleDetailSheet({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: schedule.color.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con botón de volver
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: Colors.black87,
                  iconSize: 20,
                ),
                const Spacer(),
                // Barra superior (handle)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48), // Espaciador para centrar el handle
              ],
            ),
            const SizedBox(height: 12),

            // Nombre del empleado
            Center(
              child: Text(
                schedule.employeeName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cargo/Posición
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: schedule.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  schedule.position,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Horario
            _SectionCard(
              title: 'Horario',
              color: schedule.color,
              children: [
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  text: schedule.scheduleRange,
                  color: schedule.color,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  text: schedule.formattedDate,
                  color: schedule.color,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.wb_sunny_outlined,
                  text: _getShiftTypeName(schedule.shiftType),
                  color: schedule.color,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lugar de trabajo
            _SectionCard(
              title: 'Lugar de trabajo',
              color: schedule.color,
              children: [
                _DetailRow(
                  icon: Icons.location_on_rounded,
                  text: schedule.workplace,
                  color: schedule.color,
                ),
              ],
            ),

            // Descripción (si existe)
            if (schedule.description != null &&
                schedule.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Descripción',
                color: schedule.color,
                children: [
                  _DetailRow(
                    icon: Icons.description_outlined,
                    text: schedule.description!,
                    color: schedule.color,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Información adicional
            _SectionCard(
              title: 'Información adicional',
              color: schedule.color,
              children: [
                _DetailRow(
                  icon: Icons.badge_outlined,
                  text: 'ID: ${schedule.employeeId}',
                  color: schedule.color,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.schedule,
                  text:
                      'Duración: ${schedule.durationInHours.toStringAsFixed(1)} horas',
                  color: schedule.color,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Botón cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: schedule.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShiftTypeName(String? shiftType) {
    switch (shiftType?.toLowerCase()) {
      case 'morning':
        return 'Turno Mañana';
      case 'afternoon':
        return 'Turno Tarde';
      case 'night':
        return 'Turno Noche';
      default:
        return 'Turno Regular';
    }
  }
}

/// Card de sección con color personalizado
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color color;

  const _SectionCard({
    required this.title,
    required this.children,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Fila de detalle con color personalizado
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
