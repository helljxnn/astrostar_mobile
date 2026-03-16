import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';

class AppointmentService {
  final ApiService _api = ApiService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  // Obtener citas con filtros
  Future<Map<String, dynamic>> fetchAppointments({
    DateTime? startDate,
    DateTime? endDate,
    String? athleteId,
    String? specialistId,
    String? status,
    int page = 1,
    int limit = 100,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.clamp(1, 100).toString(),
    };

    if (startDate != null) {
      queryParams['startDate'] = _dateFormat.format(startDate);
    }
    if (endDate != null) {
      queryParams['endDate'] = _dateFormat.format(endDate);
    }
    if (athleteId != null && athleteId.isNotEmpty) {
      queryParams['athleteId'] = athleteId;
    }
    if (specialistId != null && specialistId.isNotEmpty) {
      queryParams['specialistId'] = specialistId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _api.get('/appointments?$queryString');
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al cargar citas');
    }

    return {
      'appointments': (data['data'] as List<dynamic>? ?? [])
          .map((e) => _parseAppointment(e as Map<String, dynamic>))
          .toList(),
      'pagination': data['pagination'] ?? {},
    };
  }

  // Obtener una cita por ID
  Future<Map<String, dynamic>> getAppointmentById(String id) async {
    final response = await _api.get('/appointments/$id');
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al cargar la cita');
    }

    return _parseAppointment(data['data']);
  }

  // Crear nueva cita
  Future<Map<String, dynamic>> createAppointment({
    required String athleteId,
    required String specialistId,
    required String specialty,
    required DateTime appointmentDate,
    required String startTime,
    required String endTime,
    String? description,
  }) async {
    final body = {
      'athleteId': athleteId,
      'specialistId': specialistId,
      'specialty': specialty,
      'appointmentDate': _dateFormat.format(appointmentDate),
      'startTime': startTime,
      'endTime': endTime,
      if (description != null && description.isNotEmpty)
        'description': description,
    };

    final response = await _api.post('/appointments', body);
    final data = jsonDecode(response.body);

    if (response.statusCode != 201 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al crear la cita');
    }

    return _parseAppointment(data['data']);
  }

  // Actualizar cita
  Future<Map<String, dynamic>> updateAppointment({
    required String id,
    String? athleteId,
    String? specialistId,
    String? specialty,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    String? description,
    String? status,
  }) async {
    final body = <String, dynamic>{};

    if (athleteId != null) body['athleteId'] = athleteId;
    if (specialistId != null) body['specialistId'] = specialistId;
    if (specialty != null) body['specialty'] = specialty;
    if (appointmentDate != null) {
      body['appointmentDate'] = _dateFormat.format(appointmentDate);
    }
    if (startTime != null) body['startTime'] = startTime;
    if (endTime != null) body['endTime'] = endTime;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status;

    final response = await _api.put('/appointments/$id', body);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al actualizar la cita');
    }

    return _parseAppointment(data['data']);
  }

  // Cancelar cita
  Future<void> cancelAppointment(String id, String reason) async {
    final body = {
      'status': 'Cancelado',
      'cancelReason': reason,
    };

    final response = await _api.put('/appointments/$id', body);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al cancelar la cita');
    }
  }

  // Completar cita
  Future<void> completeAppointment(String id, {String? notes}) async {
    final body = {
      'status': 'Cumplido',
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final response = await _api.put('/appointments/$id', body);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al completar la cita');
    }
  }

  // Eliminar cita
  Future<void> deleteAppointment(String id) async {
    final response = await _api.delete('/appointments/$id');
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al eliminar la cita');
    }
  }

  // Obtener especialistas disponibles
  Future<List<Map<String, dynamic>>> getAvailableSpecialists({
    String? specialty,
  }) async {
    String endpoint = '/employees?role=Especialista&limit=100';
    if (specialty != null && specialty.isNotEmpty) {
      endpoint += '&specialty=$specialty';
    }

    final response = await _api.get(endpoint);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al cargar especialistas');
    }

    return (data['data'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  // Parsear cita desde API
  Map<String, dynamic> _parseAppointment(Map<String, dynamic> raw) {
    return {
      'id': raw['id']?.toString() ?? '',
      'athleteId': raw['athleteId']?.toString() ?? '',
      'athleteName': _extractName(raw['athlete']),
      'specialistId': raw['specialistId']?.toString() ?? '',
      'specialistName': _extractName(raw['specialist']),
      'specialty': raw['specialty'] ?? '',
      'appointmentDate': raw['appointmentDate'] ?? '',
      'startTime': raw['startTime'] ?? '',
      'endTime': raw['endTime'] ?? '',
      'description': raw['description'] ?? '',
      'status': raw['status'] ?? 'Programado',
      'cancelReason': raw['cancelReason'],
      'notes': raw['notes'],
      'createdAt': raw['createdAt'],
      'updatedAt': raw['updatedAt'],
    };
  }

  String _extractName(dynamic entity) {
    if (entity == null) return '';
    if (entity is String) return entity;
    if (entity is Map) {
      final user = entity['user'] ?? entity;
      final firstName = user['firstName'] ?? user['nombre'] ?? '';
      final lastName = user['lastName'] ?? user['apellido'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return '';
  }
}
