import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../data/models/appointment_models.dart';
import '../appointment_detail_page.dart';

class AppointmentListSheet extends StatefulWidget {
  final List<Appointment> selectedAppointments;
  final DateTime selectedDay;
  final Function(DateTime) onRefresh;

  const AppointmentListSheet({
    super.key,
    required this.selectedAppointments,
    required this.selectedDay,
    required this.onRefresh,
  });

  @override
  State<AppointmentListSheet> createState() => _AppointmentListSheetState();
}

class _AppointmentListSheetState extends State<AppointmentListSheet> {
  Widget _buildTrailingInfo(Appointment appointment) {
    return Text(
      DateFormat('h:mm a', 'es_ES').format(appointment.dateTime),
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: appointment.status == AppointmentStatus.canceled
            ? Colors.grey.shade500
            : const Color(0xFFA78BFA),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // Igual que en la pantalla de eventos
      minChildSize: 0.4, // Igual que en la pantalla de eventos
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: widget.selectedAppointments.isEmpty
                    ? Center(
                        child: Text(
                          'No hay citas para este día.',
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: widget.selectedAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment =
                              widget.selectedAppointments[index];
                          return Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: appointment.status.color,
                                child: Icon(
                                  appointment.status.icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                appointment.specialist.specialty.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Con ${appointment.specialist.name}',
                                    style: GoogleFonts.inter(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appointment.status.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: appointment.status.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: _buildTrailingInfo(appointment),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentDetailPage(
                                      appointment: appointment,
                                    ),
                                  ),
                                ).then(
                                  (_) => widget.onRefresh(widget.selectedDay),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
