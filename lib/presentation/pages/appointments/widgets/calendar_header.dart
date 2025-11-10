import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;

  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
  });

  String _monthName(int month) {
    final monthName = DateFormat.MMMM('es_ES').format(DateTime(0, month));
    return monthName[0].toUpperCase() + monthName.substring(1);
  }

  Widget _chevronButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 22, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _chevronButton(Icons.chevron_left, onLeftArrowTap),
        Column(
          children: [
            Text(
              _monthName(focusedDay.month),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              focusedDay.year.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        _chevronButton(Icons.chevron_right, onRightArrowTap),
      ],
    );
  }
}
