import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/mini_calendario.dart';
import '../widgets/progreso_calorias.dart';
import '../widgets/grafico_calorias.dart';

class NutricionScreen extends StatefulWidget {
  const NutricionScreen({super.key});

  @override
  _NutricionScreenState createState() => _NutricionScreenState();
}

class _NutricionScreenState extends State<NutricionScreen> {
  DateTime selectedDate = DateTime.now();
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // 🔹 Datos temporales simulando una base de datos de calorías por día y por comida
  Map<String, Map<String, double>> caloriasPorDia = {
    "2025-03-19": {"consumidas": 600, "objetivo": 2000},
    "2025-03-20": {"consumidas": 1200, "objetivo": 2000},
    "2025-03-21": {"consumidas": 1800, "objetivo": 2200},
  };

  Map<String, Map<String, double>> caloriasPorComida = {
    "2025-03-19": {"Desayuno": 200, "Almuerzo": 200, "Cena": 100, "Snacks": 100},
    "2025-03-20": {"Desayuno": 300, "Almuerzo": 500, "Cena": 300, "Snacks": 100},
    "2025-03-21": {"Desayuno": 400, "Almuerzo": 700, "Cena": 500, "Snacks": 200},
  };

  double caloriasConsumidas = 0;
  double caloriasObjetivo = 2000;

  Map<String, double> caloriasDiariasPorComida = {
    "Desayuno": 0,
    "Almuerzo": 0,
    "Cena": 0,
    "Snacks": 0,
  };

  void _actualizarCalorias(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      if (caloriasPorDia.containsKey(formattedDate)) {
        caloriasConsumidas = caloriasPorDia[formattedDate]!['consumidas']!;
        caloriasObjetivo = caloriasPorDia[formattedDate]!['objetivo']!;
      } else {
        caloriasConsumidas = 0;
        caloriasObjetivo = 2000;
      }

      // 🔹 Actualizar las calorías de cada comida según el día seleccionado
      caloriasDiariasPorComida = caloriasPorComida[formattedDate] ?? {
        "Desayuno": 0,
        "Almuerzo": 0,
        "Cena": 0,
        "Snacks": 0,
      };
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          MiniCalendario(onDateSelected: _actualizarCalorias, caloriasPorDia: caloriasPorDia),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      ProgresoCalorias(
                        caloriasConsumidas: caloriasConsumidas.toDouble(),
                        caloriasObjetivo: caloriasObjetivo.toDouble(),
                      ),
                      GraficoCalorias(
                        caloriasPorComida: caloriasDiariasPorComida,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Colors.amber : Colors.grey,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
