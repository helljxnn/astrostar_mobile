import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repository;

  EventBloc({EventRepository? repository})
    : _repository = repository ?? EventRepository(),
      super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadEventById>(_onLoadEventById);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await _repository.getEvents();
      emit(EventLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventById(
    LoadEventById event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final eventData = await _repository.getEventById(event.id);
      emit(EventLoaded([eventData]));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
