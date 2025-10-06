import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class ScheduleChip extends StatelessWidget {
  final String? shiftType;
  final String? status;
  final Color? customColor;

  const ScheduleChip({
    super.key,
    this.shiftType,
    this.status,
    this.customColor,
  });

  // Determina qué mostrar: primero intenta shiftType, luego status
  bool get _isShiftType => shiftType != null && shiftType!.isNotEmpty;

  Color _getColor() {
    if (customColor != null) return customColor!;

    if (_isShiftType) {
      // Colores para tipos de turno
      switch (shiftType?.toLowerCase()) {
        case 'morning':
        case 'mañana':
          return const Color(0xFFFFA726); // Naranja
        case 'afternoon':
        case 'tarde':
          return const Color(0xFF42A5F5); // Azul
        case 'night':
        case 'noche':
          return const Color(0xFF7E57C2); // Morado
        default:
          return AppColors.muted;
      }
    } else {
      // Colores para estados
      switch (status?.toLowerCase()) {
        case 'scheduled':
        case 'programado':
          return const Color(0xFF66BB6A); // Verde
        case 'completed':
        case 'completado':
          return const Color(0xFF42A5F5); // Azul
        case 'cancelled':
        case 'cancelado':
          return const Color(0xFFEF5350); // Rojo
        case 'in_progress':
        case 'en_curso':
          return const Color(0xFFFF9800); // Naranja
        default:
          return AppColors.muted;
      }
    }
  }

  IconData _getIcon() {
    if (_isShiftType) {
      // Iconos para tipos de turno
      switch (shiftType?.toLowerCase()) {
        case 'morning':
        case 'mañana':
          return Icons.wb_sunny;
        case 'afternoon':
        case 'tarde':
          return Icons.wb_twilight;
        case 'night':
        case 'noche':
          return Icons.nightlight_round;
        default:
          return Icons.schedule;
      }
    } else {
      // Iconos para estados
      switch (status?.toLowerCase()) {
        case 'scheduled':
        case 'programado':
          return Icons.check_circle_outline;
        case 'completed':
        case 'completado':
          return Icons.check_circle;
        case 'cancelled':
        case 'cancelado':
          return Icons.cancel_outlined;
        case 'in_progress':
        case 'en_curso':
          return Icons.pending_outlined;
        default:
          return Icons.info_outline;
      }
    }
  }

  String _getLabel() {
    if (_isShiftType) {
      // Etiquetas para tipos de turno
      switch (shiftType?.toLowerCase()) {
        case 'morning':
          return 'Mañana';
        case 'afternoon':
          return 'Tarde';
        case 'night':
          return 'Noche';
        default:
          return shiftType ?? 'Regular';
      }
    } else {
      // Etiquetas para estados
      switch (status?.toLowerCase()) {
        case 'scheduled':
          return 'Programado';
        case 'completed':
          return 'Completado';
        case 'cancelled':
          return 'Cancelado';
        case 'in_progress':
          return 'En Curso';
        default:
          return status ?? 'Sin Estado';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}