import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'event_card.dart';
import 'event_detail_sheet.dart';

class EventList extends StatelessWidget {
  final List<EventModel> events;
  final String? selectedEventId;
  final Function(String) onTapEvent;

  const EventList({
    super.key,
    required this.events,
    required this.selectedEventId,
    required this.onTapEvent,
  });

  void _showEventDetail(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: events.isEmpty
          ? Container(
              key: const ValueKey('empty'),
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('No hay eventos'),
            )
          : ListView.builder(
              key: ValueKey(events.length),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final e = events[index];
                return EventCard(
                  event: e,
                  selected: selectedEventId == e.id,
                  onTap: () {
                    onTapEvent(e.id);
                    _showEventDetail(context, e);
                  },
                );
              },
            ),
    );
  }
}
