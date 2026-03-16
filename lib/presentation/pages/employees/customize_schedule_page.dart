import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class CustomizeSchedulePage extends StatefulWidget {
  final Map<String, dynamic> scheduleData;
  final Function(Map<String, dynamic>) onSave;

  const CustomizeSchedulePage({
    super.key,
    required this.scheduleData,
    required this.onSave,
  });

  @override
  State<CustomizeSchedulePage> createState() => _CustomizeSchedulePageState();
}

class _CustomizeSchedulePageState extends State<CustomizeSchedulePage> {
  late Map<String, dynamic> _customizedData;
  final Set<int> _selectedWeekdays = {};
  String? _timezone;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _weekdays = [
    {'value': 1, 'label': 'Lunes', 'short': 'L'},
    {'value': 2, 'label': 'Martes', 'short': 'M'},
    {'value': 3, 'label': 'Miércoles', 'short': 'X'},
    {'value': 4, 'label': 'Jueves', 'short': 'J'},
    {'value': 5, 'label': 'Viernes', 'short': 'V'},
    {'value': 6, 'label': 'Sábado', 'short': 'S'},
    {'value': 7, 'label': 'Domingo', 'short': 'D'},
  ];

  @override
  void initState() {
    super.initState();
    _customizedData = Map<String, dynamic>.from(widget.scheduleData);
    _timezone = 'America/Lima';
  }

  void _toggleWeekday(int day) {
    setState(() {
      if (_selectedWeekdays.contains(day)) {
        _selectedWeekdays.remove(day);
      } else {
        _selectedWeekdays.add(day);
      }
    });
  }

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);

    // Agregar personalización
    if (_customizedData['recurrence'] == 'personalizado' && _selectedWeekdays.isNotEmpty) {
      _customizedData['customRecurrence'] = {
        'daysOfWeek': _selectedWeekdays.toList()..sort(),
      };
    }

    _customizedData['timezone'] = _timezone ?? 'America/Lima';

    // Llamar al callback de guardado
    await widget.onSave(_customizedData);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPersonalized = _customizedData['recurrence'] == 'personalizado';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Personalizar Horario'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del horario
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
                          Icons.tune,
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
                              'Resumen',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Revise la información',
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
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.person, 'Empleado', 'ID: ${_customizedData['employeeId']}'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, 'Horario', '${_customizedData['startTime']} - ${_customizedData['endTime']}'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.repeat, 'Repetición', _getRecurrenceLabel(_customizedData['recurrence'])),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personalización de días (solo si es personalizado)
            if (isPersonalized) ...[
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
                    const Text(
                      'Días de la Semana',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seleccione los días en que se repetirá el horario',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _weekdays.map((day) {
                        final isSelected = _selectedWeekdays.contains(day['value']);
                        return GestureDetector(
                          onTap: () => _toggleWeekday(day['value'] as int),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.authPrimaryLight
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.authPrimaryLight
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                day['short'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Zona horaria
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
                  const Text(
                    'Zona Horaria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _timezone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'America/Lima', child: Text('Lima (UTC-5)')),
                      DropdownMenuItem(value: 'America/Bogota', child: Text('Bogotá (UTC-5)')),
                      DropdownMenuItem(value: 'America/Mexico_City', child: Text('Ciudad de México (UTC-6)')),
                      DropdownMenuItem(value: 'America/New_York', child: Text('Nueva York (UTC-5)')),
                      DropdownMenuItem(value: 'UTC', child: Text('UTC')),
                    ],
                    onChanged: (value) {
                      setState(() => _timezone = value);
                    },
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
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSchedule,
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
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
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
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRecurrenceLabel(String recurrence) {
    switch (recurrence) {
      case 'no':
        return 'No se repite';
      case 'dia':
        return 'Cada día';
      case 'semana':
        return 'Cada semana';
      case 'mes':
        return 'Cada mes';
      case 'laboral':
        return 'Días laborales';
      case 'personalizado':
        return 'Personalizado';
      default:
        return 'No se repite';
    }
  }
}
