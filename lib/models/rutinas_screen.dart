import 'package:flutter/material.dart';
import 'ejercicios_casa_screen.dart';
import 'ejercicios_gimnasio_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ejercicios_completados_service.dart';
import '../services/cargador_ejercicios.dart';

class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Set<String> _diasCompletados = {}; // Para almacenar los días completados

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDiasCompletados();
    _configurarEjerciciosService();
    _recargarEjercicios();
  }

  void _configurarEjerciciosService() {
    final ejerciciosService = EjerciciosCompletadosService();
    ejerciciosService.setOnEjerciciosCompletadosCallback((completados) {
      if (completados == 5) {
        _marcarDiaCompletado();
      }
    });
  }

  Future<void> _cargarDiasCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    final diasCompletados = prefs.getStringList('dias_completados') ?? [];
    setState(() {
      _diasCompletados = diasCompletados.toSet();
    });
  }

  void _marcarDiaCompletado() async {
    final String fecha = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final prefs = await SharedPreferences.getInstance();
    final diasCompletados = prefs.getStringList('dias_completados') ?? [];
    
    if (!diasCompletados.contains(fecha)) {
      diasCompletados.add(fecha);
      await prefs.setStringList('dias_completados', diasCompletados);
      
      setState(() {
        _diasCompletados.add(fecha);
      });
    }
  }

  bool _esDiaCompletado(DateTime day) {
    final String fecha = DateFormat('yyyy-MM-dd').format(day);
    return _diasCompletados.contains(fecha);
  }

  bool _esDiaAnterior(DateTime day) {
    final now = DateTime.now();
    return day.year < now.year || 
           (day.year == now.year && day.month < now.month) ||
           (day.year == now.year && day.month == now.month && day.day < now.day);
  }

  Future<void> _recargarEjercicios() async {
    try {
      final cargador = CargadorEjercicios();
      await cargador.recargarEjercicios();
      print('✅ Ejercicios recargados exitosamente');
    } catch (e) {
      print('❌ Error al recargar ejercicios: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DateTime> _getCurrentWeekDays(DateTime focusedDay) {
    final int weekday = focusedDay.weekday;
    final DateTime firstDayOfWeek = focusedDay.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  void _goToPreviousWeek() {
    setState(() {
      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
      _selectedDay = _focusedDay;
    });
  }

  void _goToNextWeek() {
    setState(() {
      _focusedDay = _focusedDay.add(const Duration(days: 7));
      _selectedDay = _focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getCurrentWeekDays(_focusedDay);
    final String monthYear = DateFormat('MMMM yyyy', 'es').format(_focusedDay);
    final isDark = false;
    final Color bgColor = Colors.white;
    final Color circleColor = Colors.black;
    final Color selectedTextColor = Colors.white;
    final Color unselectedTextColor = Colors.black87;
    final Color fadedTextColor = Colors.black45;

    // Mapeo de días de la semana en español
    final Map<String, String> diasSemana = {
      'Mon': 'Lun',
      'Tue': 'Mar',
      'Wed': 'Mié',
      'Thu': 'Jue',
      'Fri': 'Vie',
      'Sat': 'Sáb',
      'Sun': 'Dom',
    };

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RUTINAS DE EJERCICIO'),
            const SizedBox(height: 4),
            Text(
              '¡Es momento de alcanzar tu mejor version!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, size: 20),
                      SizedBox(width: 4),
                      Text('En Casa'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fitness_center, size: 20),
                      SizedBox(width: 4),
                      Text('Gimnasio'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
                      onPressed: _goToPreviousWeek,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      monthYear[0].toUpperCase() + monthYear.substring(1),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.black, size: 24),
                      onPressed: _goToNextWeek,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: weekDays.map((day) {
                      final bool isSelected = day.year == _selectedDay.year && 
                                           day.month == _selectedDay.month && 
                                           day.day == _selectedDay.day;
                      final bool isCompleted = _esDiaCompletado(day);
                      final bool isPastDay = _esDiaAnterior(day);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCompleted 
                                    ? Colors.green 
                                    : isSelected 
                                      ? circleColor 
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: isPastDay && !isCompleted
                                    ? Border.all(color: Colors.grey[300]!)
                                    : null,
                                ),
                                child: Center(
                                  child: Text(
                                    diasSemana[DateFormat('E', 'en').format(day).substring(0, 3)] ?? 'Lun',
                                    style: TextStyle(
                                      color: isSelected || isCompleted ? selectedTextColor : unselectedTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: isCompleted 
                                    ? Colors.green 
                                    : isSelected 
                                      ? circleColor 
                                      : unselectedTextColor,
                                  fontWeight: isSelected || isCompleted ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EjerciciosCasaScreen(
                  onEjerciciosCompletados: (completados) {
                    if (completados == 5) {
                      _marcarDiaCompletado();
                    }
                  },
                ),
                EjerciciosGimnasioScreen(
                  onEjerciciosCompletados: (completados) {
                    if (completados == 5) {
                      _marcarDiaCompletado();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
