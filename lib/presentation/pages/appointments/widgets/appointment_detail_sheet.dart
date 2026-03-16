import 'package:flutter/material.dart';
import '../../../../core/alerts.dart';
import '../../../../data/services/appointment_service.dart';

class AppointmentDetailSheet extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onUpdate;

  const AppointmentDetailSheet({
    super.key,
    required this.appointment,
    this.onUpdate,
  });

  @override
  State<AppointmentDetailSheet> createState() => _AppointmentDetailSheetState();
}

class _AppointmentDetailSheetState extends State<AppointmentDetailSheet> {
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = false;
  late Map<String, dynamic> _appointment;

  @override
  void initState() {
    super.initState();
    _appointment = Map.from(widget.appointment);
  }

  String get _status => _appointment['status'] ?? 'Programado';
  bool get _canModify => _status.toLowerCase() == 'programado';

  /// La cita solo se puede completar si la fecha ya llegó (hoy o pasado)
  bool get _canComplete {
    try {
      final dateStr = _appointment['appointmentDate'] as String?;
      if (dateStr == null) return false;
      final appointmentDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final appointmentDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      final todayDay = DateTime(today.year, today.month, today.day);
      return !appointmentDay.isAfter(todayDay);
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      const months = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];
      return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '$hour:$minute $period';
      }
    } catch (e) {
      // Return original if parsing fails
    }
    return timeStr;
  }

  Future<void> _completeAppointment() async {
    final notes = await _showNotesDialog(
      'Completar Cita',
      'Notas de la cita (opcional)',
      true,
    );
    if (notes == null) return;

    setState(() => _isLoading = true);
    try {
      await _appointmentService.completeAppointment(
        _appointment['id'],
        notes: notes.isEmpty ? null : notes,
      );
      if (mounted) {
        setState(() {
          _appointment['status'] = 'Cumplido';
          if (notes.isNotEmpty) _appointment['notes'] = notes;
        });
        AppAlerts.showSuccess(context, 'Cita completada exitosamente');
        widget.onUpdate?.call();
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment() async {
    final reason = await _showNotesDialog(
      'Cancelar Cita',
      'Motivo de cancelación',
      false,
    );
    if (reason == null || reason.isEmpty) {
      AppAlerts.showWarning(
        context,
        'Debe proporcionar un motivo de cancelación',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _appointmentService.cancelAppointment(_appointment['id'], reason);
      if (mounted) {
        setState(() {
          _appointment['status'] = 'Cancelado';
          _appointment['cancelReason'] = reason;
        });
        AppAlerts.showSuccess(context, 'Cita cancelada');
        widget.onUpdate?.call();
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _showNotesDialog(
    String title,
    String hint,
    bool isComplete,
  ) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isComplete
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      color: isComplete
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: hint,
                  hintText: isComplete
                      ? 'Ej: Sesión completada satisfactoriamente'
                      : 'Ej: Deportista no pudo asistir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isComplete
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isComplete
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startTime = _formatTime(_appointment['startTime'] ?? '');
    final endTime = _formatTime(_appointment['endTime'] ?? '');
    final timeRange = '$startTime - $endTime';

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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                    _appointment['specialty'] ?? 'Cita',
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

                /// Deportista
                _SectionCard(
                  title: 'Deportista',
                  children: [
                    _DetailRow(
                      icon: Icons.person_outline,
                      text: _appointment['athleteName'] ?? 'N/A',
                    ),
                  ],
                ),

                /// Especialista
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Especialista',
                  children: [
                    _DetailRow(
                      icon: Icons.support_agent,
                      text: _appointment['specialistName'] ?? 'N/A',
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
                      text: _formatDate(_appointment['appointmentDate'] ?? ''),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      text: timeRange,
                    ),
                  ],
                ),

                /// Estado
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Estado',
                  children: [
                    _DetailRow(icon: Icons.info_outline_rounded, text: _status),
                  ],
                ),

                const SizedBox(height: 28),

                /// Botones de acción
                if (_canModify)
                  Row(
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: _canComplete
                              ? ''
                              : 'Solo se puede completar en la fecha de la cita o después',
                          child: ElevatedButton.icon(
                            onPressed: _canComplete
                                ? _completeAppointment
                                : null,
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 20,
                            ),
                            label: const Text('Completar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              disabledForegroundColor: Colors.grey.shade500,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _cancelAppointment,
                          icon: const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text('Cancelar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black87,
                      ),
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

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[100],
          child: Icon(icon, size: 18, color: Colors.grey[700]),
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
