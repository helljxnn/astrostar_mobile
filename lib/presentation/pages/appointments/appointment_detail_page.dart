import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/appointment_models.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late Appointment _appointment;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }

  void _showCancelAppointmentDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar Cita'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por favor, indica el motivo de la cancelación.'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  setState(() {
                    _appointment.status = AppointmentStatus.canceled;
                    _appointment.cancellationReason = reasonController.text;
                  });
                  Navigator.pop(context); // Cierra el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cita cancelada correctamente.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El motivo no puede estar vacío.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Confirmar Cancelación'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = _appointment.status == AppointmentStatus.canceled;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la Cita')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStatusCard(),
          const SizedBox(height: 20),
          _buildDetailCard(
            title: 'Información del Paciente',
            children: [
              _buildDetailRow(
                Icons.person_outline,
                'Deportista',
                _appointment.athlete.name,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            title: 'Información de la Cita',
            children: [
              _buildDetailRow(
                Icons.medical_services_outlined,
                'Especialidad',
                _appointment.specialist.specialty.name,
              ),
              _buildDetailRow(
                Icons.support_agent,
                'Especialista',
                _appointment.specialist.name,
              ),
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Fecha',
                DateFormat(
                  'EEEE, d \'de\' MMMM, y',
                  'es_ES',
                ).format(_appointment.dateTime),
              ),
              _buildDetailRow(
                Icons.access_time_outlined,
                'Hora',
                DateFormat('h:mm a', 'es_ES').format(_appointment.dateTime),
              ),
              _buildDetailRow(
                Icons.notes_outlined,
                'Motivo de Consulta',
                _appointment.description,
              ),
            ],
          ),
          if (isCancelled) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              title: 'Detalles de Cancelación',
              children: [
                _buildDetailRow(
                  Icons.comment_outlined,
                  'Motivo',
                  _appointment.cancellationReason ?? 'No especificado',
                ),
              ],
              borderColor: Colors.red.shade200,
            ),
          ],
        ],
      ),
      bottomNavigationBar: !isCancelled
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _showCancelAppointmentDialog,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _appointment.status.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _appointment.status.color),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _appointment.status.icon,
              color: _appointment.status.color,
              size: 30,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de la Cita',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  _appointment.status.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _appointment.status.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor ?? Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
