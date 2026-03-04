import 'dart:developer' as developer;
import 'core/api_service.dart';
import 'data/repositories/event_repository.dart';

Future<void> testApiConnection() async {
  try {
    developer.log('=== TESTING API CONNECTION ===');
    developer.log('Base URL: ${ApiService.baseUrl}');
    
    final repository = EventRepository();
    developer.log('Fetching events...');
    
    final events = await repository.getEvents();
    developer.log('SUCCESS! Events loaded: ${events.length}');
    
    for (var event in events) {
      developer.log('Event: ${event.name} - ${event.status}');
    }
  } catch (e) {
    developer.log('ERROR: $e');
  }
}
