import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar_expanded_sheet.dart';

class MiniCalendario extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Map<String, Map<String, double>> caloriasPorDia; // 🔹 Agregar esto

  const MiniCalendario({super.key, required this.onDateSelected, required this.caloriasPorDia});

  @override
  _MiniCalendarioState createState() => _MiniCalendarioState();
}

class _MiniCalendarioState extends State<MiniCalendario> {
  DateTime selectedDate = DateTime.now();
  late List<DateTime> weekDates;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
    _initializeScrollController();
  }

  void _generateWeekDates() {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 7));
    weekDates = List.generate(30, (index) => startDate.add(Duration(days: index)));
  }

  void _initializeScrollController() {
    int todayIndex = weekDates.indexWhere((date) =>
    date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year);

    double scrollPosition = (todayIndex - 2) * 56.0;

    _scrollController = ScrollController(
      initialScrollOffset: scrollPosition < 0 ? 0 : scrollPosition,
    );
  }

  void _scrollToToday() {
    int todayIndex = weekDates.indexWhere((date) =>
    date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year);

    if (todayIndex != -1) {
      double scrollPosition = (todayIndex - 2) * 56.0;
      _scrollController.animateTo(
        scrollPosition < 0 ? 0 : scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        selectedDate = DateTime.now();
      });
      widget.onDateSelected(selectedDate);
    }
  }

  void _showExpandedCalendar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return CalendarExpandedSheet(
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
            });
            widget.onDateSelected(date);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 12.0, top: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.more_horiz),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _scrollToToday, // Desplaza al día de hoy al tocar la fecha
                    child: Text(
                      selectedDate.day == DateTime.now().day
                          ? "Hoy"
                          : DateFormat('dd MMM').format(selectedDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showExpandedCalendar,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.amber),
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: List.generate(weekDates.length, (index) {
                final date = weekDates[index];
                final isSelected = date.day == selectedDate.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                    widget.onDateSelected(date);
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.amber : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            DateFormat.E('es').format(date)[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? Colors.black : Colors.black,
                            ),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: widget.caloriasPorDia.containsKey(DateFormat('yyyy-MM-dd').format(date))
                                  ? (widget.caloriasPorDia[DateFormat('yyyy-MM-dd').format(date)]!['consumidas']! /
                                  widget.caloriasPorDia[DateFormat('yyyy-MM-dd').format(date)]!['objetivo']!)
                                  : 0.0, // Si no hay datos, progreso 0
                              backgroundColor: Colors.grey[300],
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.amber, // Color del progreso
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                                color: isSelected ? Colors.black : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}