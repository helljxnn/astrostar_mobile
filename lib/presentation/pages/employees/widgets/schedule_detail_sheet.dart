import 'package:flutter/material.dart';
import '../../../../data/models/schedule_model.dart';

class ScheduleDetailSheet extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleDetailSheet({super.key, required this.schedule});

  String _getRecurrenceLabel() {
    switch (schedule.recurrence) {
      case 'no':
        return 'Sin repetición';
      case 'dia':
        return 'Diario';
      case 'semana':
        return 'Semanal';
      case 'mes':
        return 'Mensual';
      case 'anio':
        return 'Anual';
      case 'laboral':
        return 'Días laborales';
      case 'personalizado':
        return 'Personalizado';
      default:
        return schedule.recurrence;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutQuint,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF9FAFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Indicador de arrastre
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          /// Título
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
          const SizedBox(height: 28),

          /// Cargo
          _SectionCard(
            title: 'Cargo',
            children: [
              _DetailRow(
                icon: Icons.work_outline,
                text: schedule.position,
                color: schedule.roleColor,
              ),
            ],
          ),

          /// Fecha y hora
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Fecha y hora',
            children: [
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                text: schedule.formattedDate,
              ),
              const SizedBox(height: 14),
              _DetailRow(
                icon: Icons.access_time_rounded,
                text: schedule.scheduleRange,
              ),
            ],
          ),

          /// Repetición
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Repetición',
            children: [
              _DetailRow(
                icon: Icons.repeat_rounded,
                text: _getRecurrenceLabel(),
              ),
            ],
          ),

          /// Descripción
          if (schedule.description != null && schedule.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Descripción',
              children: [
                _DetailRow(
                  icon: Icons.notes_outlined,
                  text: schedule.description!,
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          /// Botón cerrar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18, color: Colors.black87),
              label: const Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reutilizable: Card de sección
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// Reutilizable: fila detalle
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _DetailRow({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Colors.grey[700]!;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, size: 18, color: iconColor),
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
