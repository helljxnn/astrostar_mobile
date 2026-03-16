import 'package:flutter/material.dart';
import 'package:astrostar_mobile/data/models/schedule_model.dart';
import 'package:astrostar_mobile/core/app_colors.dart';

class ScheduleDetailPage extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleDetailPage({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detalles del Horario'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con información principal
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: _buildHeaderCard(),
            ),
            const SizedBox(height: 12),

            // Información del empleado
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppColors.authPrimaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Información del Empleado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.badge_outlined,
                    'Nombre',
                    schedule.employeeName,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.work_outline,
                    'Cargo',
                    schedule.position,
                  ),
                  if (schedule.department != null &&
                      schedule.department!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.business_outlined,
                      'Departamento',
                      schedule.department!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Información del horario
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppColors.authPrimaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Detalles del Horario',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Fecha',
                    schedule.formattedDate,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.access_time_outlined,
                    'Horario',
                    schedule.scheduleRange,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.schedule_outlined,
                    'Tipo de turno',
                    schedule.shiftLabel,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.timer_outlined,
                    'Duración',
                    '${schedule.durationInHours.toStringAsFixed(1)} horas',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.repeat_outlined,
                    'Repetición',
                    schedule.recurrenceLabel,
                  ),
                  if (schedule.customWeekdayNames != null &&
                      schedule.customWeekdayNames!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.event_note_outlined,
                      'Días personalizados',
                      schedule.customWeekdayNames!.join(', '),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Descripción
            if (schedule.description != null &&
                schedule.description!.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: AppColors.authPrimaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        schedule.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Lugar de trabajo
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.authPrimaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lugar de Trabajo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      schedule.workplace,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authPrimaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            schedule.roleColor.withOpacity(0.1),
            schedule.roleColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.roleColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: schedule.roleColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              schedule.shiftIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.dayOfWeek,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.shiftLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: schedule.roleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.authPrimaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.authPrimaryLight,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
