// lib/presentation/pages/appointments/appointments_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/appointment_models.dart';
import 'appointment_detail_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPage();
}

class _AppointmentsPage extends State<AppointmentsPage> {
  // --- Datos de ejemplo ---
  final Athlete _athlete1 = Athlete(id: 'ath1', name: 'Carlos Alcaraz');
  final Specialist _spec1 = Specialist(
    id: 'spec1',
    name: 'Dr. Fisioterapeuta 1',
    specialty: SpecialtyType.physiotherapy,
    schedule: 'L-V 9-17',
  );
  final Specialist _spec2 = Specialist(
    id: 'spec3',
    name: 'Dra. Nutricionista',
    specialty: SpecialtyType.nutrition,
    schedule: 'L,M 10-18',
  );

  late final List<Appointment> _allAppointments;

  @override
  void initState() {
    super.initState();
    _allAppointments = [
      Appointment(
        id: 'c1',
        athlete: _athlete1,
        specialist: _spec1,
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        description: 'Dolor de rodilla',
      ),
      Appointment(
        id: 'c2',
        athlete: _athlete1,
        specialist: _spec2,
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        description: 'Plan de alimentación',
      ),
      Appointment(
        id: 'c3',
        athlete: _athlete1,
        specialist: _spec1,
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        description: 'Seguimiento lesión',
      ),
    ];
    _selectedDay = _focusedDay;
    _selectedAppointments = _getAppointmentsForDay(_selectedDay!);
  }
  // --- Fin datos de ejemplo ---

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Appointment> _selectedAppointments = [];

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _allAppointments
        .where((appointment) => isSameDay(appointment.dateTime, day))
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedAppointments = _getAppointmentsForDay(selectedDay);
      });
    }
  }

  void _showScheduleAppointmentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const _ScheduleAppointmentForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(children: [_buildCalendar(), _buildAppointmentsSheet()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleAppointmentForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Agendar Cita'),
        // ignore: use_full_hex_values_for_flutter_colors
        backgroundColor: const Color(0xFFA78BFA), // Morado más claro
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAppointmentsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // El panel inicia justo debajo del calendario
      minChildSize: 0.5, // Mínimo para mantener la posición
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // Coincide con event_screen
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10, // Coincide con event_screen
                color: Colors.black26, // Coincide con event_screen
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                ), // Coincide con event_screen
                height: 4, // Coincide con event_screen
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400], // Coincide con event_screen
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Lista de citas
              Expanded(
                child: _selectedAppointments.isEmpty
                    ? Center(
                        child: Text(
                          'No hay citas para este día.',
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: _selectedAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _selectedAppointments[index];
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
                                ).then((_) {
                                  // Actualiza la lista por si el estado cambió
                                  setState(() {
                                    _selectedAppointments =
                                        _getAppointmentsForDay(
                                          _selectedDay ?? DateTime.now(),
                                        );
                                  });
                                });
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

  Widget _buildTrailingInfo(Appointment appointment) {
    return Text(
      DateFormat('h:mm a', 'es_ES').format(appointment.dateTime),
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: appointment.status == AppointmentStatus.canceled
            ? Colors.grey.shade500
            // ignore: use_full_hex_values_for_flutter_colors
            : const Color(0xFFA78BFA),
      ),
    );
  }

  Widget _buildCalendar() {
    // Calendario simplificado para coincidir con event_screen
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8.0,
        right: 8.0,
      ),
      child: TableCalendar<Appointment>(
        firstDay: DateTime.utc(2021, 1, 1),
        lastDay: DateTime.utc(2031, 12, 31),
        focusedDay: _focusedDay,
        locale: 'es_ES',
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        eventLoader: _getAppointmentsForDay,
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 11,
          ), // Letra más pequeña para días de semana
          weekendStyle: TextStyle(fontSize: 11, color: Colors.black54),
        ),
        calendarStyle: CalendarStyle(
          // Estilos para los números de los días
          defaultTextStyle: const TextStyle(fontSize: 13),
          weekendTextStyle: const TextStyle(fontSize: 13),
          outsideTextStyle: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
          // Estilo para el día de hoy (círculo más pequeño)
          todayDecoration: BoxDecoration(
            color: const Color(0xFF9BE9FF),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          // Estilo para el día seleccionado (círculo más pequeño)
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF9BE9FF),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(fontSize: 13, color: Colors.white),
          // Propiedades para hacer los círculos más pequeños
          cellMargin: const EdgeInsets.all(14.0),
          cellPadding: const EdgeInsets.all(0.05),
          // Marcador de evento
          markerDecoration: const BoxDecoration(
            color: Color(0xFF6C5CE7),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
          ),
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }
}

class _ScheduleAppointmentForm extends StatefulWidget {
  // Este widget no se modifica
  const _ScheduleAppointmentForm();

  @override
  State<_ScheduleAppointmentForm> createState() =>
      _ScheduleAppointmentFormState();
}

class _ScheduleAppointmentFormState extends State<_ScheduleAppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  // --- Datos de ejemplo (reemplazar con datos de tu backend/base de datos) ---
  final List<Athlete> _athletes = [
    Athlete(id: 'ath1', name: 'Carlos Alcaraz'),
    Athlete(id: 'ath2', name: 'Rafael Nadal'),
  ];

  final List<Specialist> _specialists = [
    Specialist(
      id: 'spec1',
      name: 'Dr. Fisioterapeuta 1',
      specialty: SpecialtyType.physiotherapy,
      schedule: 'Lunes a Viernes de 9:00 a 17:00',
    ),
    Specialist(
      id: 'spec2',
      name: 'Dr. Fisioterapeuta 2',
      specialty: SpecialtyType.physiotherapy,
      schedule: 'Martes y Jueves de 8:00 a 12:00',
    ),
    Specialist(
      id: 'spec3',
      name: 'Dra. Nutricionista',
      specialty: SpecialtyType.nutrition,
      schedule: 'Lunes y Miércoles de 10:00 a 18:00',
    ),
    Specialist(
      id: 'spec4',
      name: 'Dr. Psicólogo',
      specialty: SpecialtyType.psychology,
      schedule: 'Viernes de 14:00 a 20:00',
    ),
  ];
  // --- Fin de datos de ejemplo ---

  Athlete? _selectedAthlete;
  SpecialtyType? _selectedSpecialty;
  Specialist? _selectedSpecialist;
  List<Specialist> _availableSpecialists = [];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSpecialtyChanged(SpecialtyType? newSpecialty) {
    setState(() {
      _selectedSpecialty = newSpecialty;
      _selectedSpecialist = null;
      _availableSpecialists = newSpecialty != null
          ? _specialists.where((s) => s.specialty == newSpecialty).toList()
          : [];
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _dateController.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) _timeController.text = picked.format(context);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('Cita agendada:');
      print('Deportista: ${_selectedAthlete?.name}');
      print('Especialista: ${_selectedSpecialist?.name}');
      print('Motivo: ${_descriptionController.text}');
      print('Fecha: ${_dateController.text} a las ${_timeController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita agendada con éxito (simulación)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agendar Nueva Cita',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<Athlete>(
              value: _selectedAthlete,
              hint: const Text('Seleccione un deportista'),
              items: _athletes
                  .map(
                    (a) => DropdownMenuItem<Athlete>(
                      value: a,
                      child: Text(a.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedAthlete = value),
              validator: (value) => value == null ? 'Campo requerido' : null,
              decoration: const InputDecoration(
                labelText: 'Deportista',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SpecialtyType>(
              value: _selectedSpecialty,
              hint: const Text('Seleccione tipo de cita'),
              items: SpecialtyType.values
                  .map(
                    (s) => DropdownMenuItem<SpecialtyType>(
                      value: s,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: _onSpecialtyChanged,
              validator: (value) => value == null ? 'Campo requerido' : null,
              decoration: const InputDecoration(
                labelText: 'Tipo de Cita',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_availableSpecialists.isNotEmpty)
              DropdownButtonFormField<Specialist>(
                value: _selectedSpecialist,
                hint: const Text('Seleccione un especialista'),
                items: _availableSpecialists
                    .map(
                      (s) => DropdownMenuItem<Specialist>(
                        value: s,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedSpecialist = value),
                validator: (value) => value == null ? 'Campo requerido' : null,
                decoration: const InputDecoration(
                  labelText: 'Especialista',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_selectedSpecialist != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Horario de ${_selectedSpecialist!.name}:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_selectedSpecialist!.schedule),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Motivo de la consulta',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Seleccione una fecha'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Hora',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: _selectTime,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Seleccione una hora'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Agendar Cita'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
