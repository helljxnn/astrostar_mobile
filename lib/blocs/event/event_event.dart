abstract class EventEvent {}

class LoadEvents extends EventEvent {}

class LoadEventById extends EventEvent {
  final int id;

  LoadEventById(this.id);
}
