import 'dart:convert';
import 'dart:developer' as developer;
import '../../core/api_service.dart';
import '../models/event_model.dart';

class EventRepository {
  final ApiService _apiService;

  EventRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<EventApiModel>> getEvents() async {
    try {
      developer.log('Fetching events from API...');
      // No requiere autenticación
      // Nota: Cambiado temporalmente para mostrar todos los eventos (no solo publicados)
      final response = await _apiService.get('/events?limit=100', requiresAuth: false);

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // La respuesta del backend tiene estructura: { success: true, data: [...] }
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          developer.log('Events loaded: ${data.length}');
          
          // Parsear eventos
          final events = data.map((json) {
            try {
              return EventApiModel.fromJson(json);
            } catch (e) {
              developer.log('Error parsing event: $e');
              developer.log('Event data: $json');
              rethrow;
            }
          }).toList();
          
          developer.log('Events parsed successfully: ${events.length}');
          return events;
        } else {
          throw Exception('Respuesta inválida del servidor');
        }
      } else {
        throw Exception('Error al cargar eventos: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching events: $e');
      throw Exception('Error al obtener eventos: $e');
    }
  }

  Future<EventApiModel> getEventById(int id) async {
    try {
      // No requiere autenticación
      final response = await _apiService.get('/events/$id', requiresAuth: false);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // La respuesta del backend tiene estructura: { success: true, data: {...} }
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return EventApiModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Respuesta inválida del servidor');
        }
      } else {
        throw Exception('Error al cargar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener evento: $e');
    }
  }
}
