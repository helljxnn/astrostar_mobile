import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/alerts.dart';
import '../../../data/services/appointment_service.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final VoidCallback? onUpdate;

  const AppointmentDetailPage({
    super.key,
    required this.appointmentData,
    this.onUpdate,
  });

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = false;
  late Map<String, dynamic> _appointment;

  @override
  void initState() {
    super.initState();
    _appointment = Map.from(widget.appointmentData);
  }

  String get _status => _appointment['status'] ?? 'Programado';
  bool get _canModify => _status.toLowerCase() == 'programado';

  Color _getStatusColor() {
    switch (_status.toLowerCase()) {
      case 'programado':
        return Colors.green;
      case 'cumplido':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_status.toLowerCase()) {
      case 'programado':
        return Icons.check_circle_outline;
      case 'cumplido':
        return Icons.task_alt_outlined;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
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
    final notes = await _showNotesDialog('Completar Cita', 'Notas de la cita (opcional)');
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
    final reason = await _showNotesDialog('Cancelar Cita', 'Motivo de cancelación');
    if (reason == null || reason.isEmpty) {
      AppAlerts.showWarning(context, 'Debe proporcionar un motivo de cancelación');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _appointmentService.cancelAppointment(
        _appointment['id'],
        reason,
      );
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

  Future<String?> _showNotesDialog(String title, String hint) async {
    final controller = TextEditingController();
    final isComplete = title.contains('Completar');
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                      color: isComplete ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isComplete ? Icons.check_circle_outline : Icons.cancel_outlined,
                      color: isComplete ? Colors.green.shade600 : Colors.red.shade600,
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
                  hintText: isComplete ? 'Ej: Sesión completada satisfactoriamente' : 'Ej: Deportista no pudo asistir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isComplete ? Colors.green.shade600 : Colors.red.shade600,
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
                        backgroundColor: isComplete ? Colors.green.shade600 : Colors.red.shade600,
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
    final isCancelled = _status.toLowerCase() == 'cancelado';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detalle de la Cita'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20.0),
                    child: _buildStatusCard(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información del Deportista',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.person_outline,
                          'Deportista',
                          _appointment['athleteName'] ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información de la Cita',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.medical_services_outlined,
                          'Especialidad',
                          _appointment['specialty'] ?? 'N/A',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.support_agent,
                          'Especialista',
                          _appointment['specialistName'] ?? 'N/A',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.calendar_today_outlined,
                          'Fecha',
                          _formatDate(_appointment['appointmentDate'] ?? ''),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.access_time_outlined,
                          'Hora',
                          '${_formatTime(_appointment['startTime'] ?? '')} - ${_formatTime(_appointment['endTime'] ?? '')}',
                        ),
                        if (_appointment['description'] != null &&
                            (_appointment['description'] as String).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            Icons.notes_outlined,
                            'Motivo de Consulta',
                            _appointment['description'],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCancelled && _appointment['cancelReason'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.red.shade600, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Detalles de Cancelación',
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.comment_outlined, color: Colors.red.shade600, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Motivo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _appointment['cancelReason'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomNavigationBar: _canModify
          ? Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _completeAppointment,
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text('Cumplida'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cancelAppointment,
                        icon: const Icon(Icons.cancel_outlined, size: 20),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
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
                  'Estado de la Cita',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
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
