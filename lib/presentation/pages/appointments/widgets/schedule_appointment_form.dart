import 'package:flutter/material.dart';
import '../../../../core/alerts.dart';
import '../../../../core/app_colors.dart';
import '../../../../data/services/appointment_service.dart';
import 'package:intl/intl.dart';

class ScheduleAppointmentForm extends StatefulWidget {
  const ScheduleAppointmentForm({super.key});

  @override
  State<ScheduleAppointmentForm> createState() =>
      _ScheduleAppointmentFormState();
}

class _ScheduleAppointmentFormState extends State<ScheduleAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentService _appointmentService = AppointmentService();
  
  bool _isLoading = false;
  bool _loadingSpecialists = false;
  
  List<Map<String, dynamic>> _specialists = [];
  
  String? _selectedAthleteId;
  String? _selectedSpecialistId;
  String? _selectedSpecialty;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _specialties = [
    'Fisioterapia',
    'Nutrición',
    'Psicología',
    'Medicina Deportiva',
    'Entrenamiento',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpecialists();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialists() async {
    setState(() => _loadingSpecialists = true);
    try {
      final specialists = await _appointmentService.getAvailableSpecialists();
      if (mounted) {
        setState(() {
          _specialists = specialists;
          _loadingSpecialists = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSpecialists = false);
        AppAlerts.showError(context, 'Error al cargar especialistas: ${e.toString()}');
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredSpecialists() {
    if (_selectedSpecialty == null) return _specialists;
    return _specialists.where((s) {
      final specialty = s['specialty'] ?? '';
      return specialty.toLowerCase().contains(_selectedSpecialty!.toLowerCase());
    }).toList();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _startTimeController.text = picked.format(context);
        
        // Auto-set end time to 1 hour later
        if (_endTime == null) {
          final endHour = (picked.hour + 1) % 24;
          _endTime = TimeOfDay(hour: endHour, minute: picked.minute);
          _endTimeController.text = _endTime!.format(context);
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? (_startTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = picked.format(context);
      });
    }
  }

  String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAthleteId == null) {
      AppAlerts.showWarning(context, 'Debe seleccionar un deportista');
      return;
    }
    if (_selectedSpecialistId == null) {
      AppAlerts.showWarning(context, 'Debe seleccionar un especialista');
      return;
    }
    if (_selectedSpecialty == null) {
      AppAlerts.showWarning(context, 'Debe seleccionar una especialidad');
      return;
    }
    if (_selectedDate == null) {
      AppAlerts.showWarning(context, 'Debe seleccionar una fecha');
      return;
    }
    if (_startTime == null || _endTime == null) {
      AppAlerts.showWarning(context, 'Debe seleccionar hora de inicio y fin');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _appointmentService.createAppointment(
        athleteId: _selectedAthleteId!,
        specialistId: _selectedSpecialistId!,
        specialty: _selectedSpecialty!,
        appointmentDate: _selectedDate!,
        startTime: _timeOfDayToString(_startTime!),
        endTime: _timeOfDayToString(_endTime!),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        AppAlerts.showSuccess(context, 'Cita agendada exitosamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSpecialists = _getFilteredSpecialists();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.authPrimaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: AppColors.authPrimaryLight,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agendar Nueva Cita',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Complete los datos requeridos',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Deportista (Placeholder - en producción cargar desde API)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ID Deportista',
                  hintText: 'Ingrese el ID del deportista',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (value) => _selectedAthleteId = value.trim(),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // Especialidad
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: const InputDecoration(
                  labelText: 'Especialidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                hint: const Text('Seleccione una especialidad'),
                items: _specialties
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value;
                    _selectedSpecialistId = null;
                  });
                },
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // Especialista
              if (_loadingSpecialists)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filteredSpecialists.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No hay especialistas disponibles para esta especialidad',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedSpecialistId,
                  decoration: const InputDecoration(
                    labelText: 'Especialista',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.support_agent),
                  ),
                  hint: const Text('Seleccione un especialista'),
                  items: filteredSpecialists.map((s) {
                    final id = s['id']?.toString() ?? '';
                    // Intentar obtener el nombre de diferentes formas
                    String name = 'Especialista';
                    
                    if (s['name'] != null && s['name'].toString().isNotEmpty) {
                      name = s['name'].toString();
                    } else if (s['user'] != null) {
                      final user = s['user'] as Map<String, dynamic>;
                      final firstName = user['firstName'] ?? user['nombre'] ?? '';
                      final lastName = user['lastName'] ?? user['apellido'] ?? '';
                      name = '$firstName $lastName'.trim();
                    } else {
                      final firstName = s['firstName'] ?? s['nombre'] ?? '';
                      final lastName = s['lastName'] ?? s['apellido'] ?? '';
                      name = '$firstName $lastName'.trim();
                    }
                    
                    if (name.isEmpty) name = 'Especialista $id';
                    
                    return DropdownMenuItem(
                      value: id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSpecialistId = value);
                  },
                  validator: (value) => value == null ? 'Campo requerido' : null,
                ),
              const SizedBox(height: 16),

              // Fecha
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                  prefixIcon: Icon(Icons.event),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 16),

              // Horas
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Hora Inicio',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: _selectStartTime,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Hora Fin',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: _selectEndTime,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Motivo de la consulta',
                  hintText: 'Describa el motivo...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.authPrimaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Agendar'),
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
}
