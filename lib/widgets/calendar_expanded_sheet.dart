import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarExpandedSheet extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  const CalendarExpandedSheet({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.help_outline, color: Colors.grey),
              Text("Calendario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.share, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var day in ["L", "M", "X", "J", "V", "S", "D"])
                Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildMonthCalendar(context, "Febrero 2025", 2, 2025),
                _buildMonthCalendar(context, "Marzo 2025", 3, 2025),
                _buildMonthCalendar(context, "Abril 2025", 4, 2025),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(BuildContext context, String monthName, int month, int year) {
    List<DateTime> daysInMonth = List.generate(
      DateTime(year, month + 1, 0).day,
          (index) => DateTime(year, month, index + 1),
    );

    int firstWeekday = daysInMonth.first.weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(monthName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 13.038,
          runSpacing: 8,
          children: [
            for (int i = 1; i < firstWeekday; i++)
              Container(width: 40, height: 40),
            for (var date in daysInMonth)
              GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text("${date.day}",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}