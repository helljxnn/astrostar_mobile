// lib/presentation/pages/appointments/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/appointment_models.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

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
      appBar: AppBar(title: const Text('Gestión de Citas'), centerTitle: true),
      body: Column(
        children: [
          // Calendario para visualizar citas
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            locale: 'es_ES',
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),
          const Expanded(
            child: Center(
              child: Text(
                'Aquí se mostrarán los detalles de la cita seleccionada.',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleAppointmentForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Agendar Cita'),
      ),
    );
  }
}

class _ScheduleAppointmentForm extends StatefulWidget {
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
