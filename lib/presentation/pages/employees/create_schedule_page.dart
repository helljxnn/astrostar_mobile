import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/alerts.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/schedule_service.dart';
import 'customize_schedule_page.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleService _scheduleService = ScheduleService();

  bool _isLoading = false;
  String? _selectedEmployeeId;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _recurrence = 'no';

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Datos temporales para personalización
  Map<String, dynamic>? _scheduleData;

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  void _goToCustomize() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEmployeeId == null || _selectedEmployeeId!.isEmpty) {
      AppAlerts.showWarning(context, 'Debe ingresar el ID del empleado');
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

    // Guardar datos temporales
    _scheduleData = {
      'employeeId': _selectedEmployeeId!,
      'scheduleDate': _selectedDate!.toIso8601String(),
      'startTime': _timeOfDayToString(_startTime!),
      'endTime': _timeOfDayToString(_endTime!),
      'description': _descriptionController.text.trim(),
      'recurrence': _recurrence,
    };

    // Navegar a personalización
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomizeSchedulePage(
          scheduleData: _scheduleData!,
          onSave: _handleSave,
        ),
      ),
    );
  }

  Future<void> _handleSave(Map<String, dynamic> finalData) async {
    setState(() => _isLoading = true);
    try {
      await _scheduleService.createSchedule(finalData);
      if (mounted) {
        AppAlerts.showSuccess(context, 'Horario creado exitosamente');
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Crear Horario'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icons.schedule,
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
                                'Información Básica',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Complete los datos del horario',
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

                    // ID Empleado
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'ID Empleado',
                        hintText: 'Ingrese el ID del empleado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      onChanged: (value) => _selectedEmployeeId = value.trim(),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Campo requerido' : null,
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

                    // Recurrencia
                    DropdownButtonFormField<String>(
                      value: _recurrence,
                      decoration: const InputDecoration(
                        labelText: 'Repetición',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'no', child: Text('No se repite')),
                        DropdownMenuItem(value: 'dia', child: Text('Cada día')),
                        DropdownMenuItem(value: 'semana', child: Text('Cada semana')),
                        DropdownMenuItem(value: 'mes', child: Text('Cada mes')),
                        DropdownMenuItem(value: 'laboral', child: Text('Días laborales')),
                        DropdownMenuItem(value: 'personalizado', child: Text('Personalizado')),
                      ],
                      onChanged: (value) {
                        setState(() => _recurrence = value ?? 'no');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describa el horario...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
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
                      onPressed: _isLoading ? null : _goToCustomize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.authPrimaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Personalizar'),
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
