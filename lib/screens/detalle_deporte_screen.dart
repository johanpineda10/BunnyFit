import 'package:flutter/material.dart';

class DetalleDeporteScreen extends StatefulWidget {
  final String nombreDeporte;
  const DetalleDeporteScreen({super.key, required this.nombreDeporte});

  @override
  _DetalleDeporteScreenState createState() => _DetalleDeporteScreenState();
}

class _DetalleDeporteScreenState extends State<DetalleDeporteScreen> {
  // Mapa con ejercicios generales por deporte
  final Map<String, List<String>> ejerciciosGenerales = {
    "Fútbol": ["Sprints cortos", "Control de balón", "Trote de resistencia"],
    "Natación": ["Patada con tabla", "Ejercicios de respiración", "Series de velocidad"],
    "Baloncesto": ["Saltos explosivos", "Dribbling rápido", "Lanzamientos de precisión"],
  };

  // Mapa con ejercicios por zona y deporte
  final Map<String, Map<String, List<String>>> ejerciciosPorZona = {
    "Fútbol": {
      "Piernas": ["Sentadillas explosivas", "Sprints con peso", "Golpeo con técnica"],
      "Core": ["Plancha con balón", "Giros de tronco", "Estabilidad sobre una pierna"],
      "Brazos": ["Flexiones con pase de balón", "Press con balón medicinal"],
    },
    "Natación": {
      "Piernas": ["Patada de mariposa", "Patada de delfín"],
      "Core": ["Plancha con respiración controlada", "Abdominales en el agua"],
      "Brazos": ["Tirones con liga", "Trabajo de técnica de brazada"],
    },
    "Baloncesto": {
      "Piernas": ["Saltos verticales", "Sprints laterales"],
      "Core": ["Trabajo de estabilidad", "Giros rápidos"],
      "Brazos": ["Lanzamientos con resistencia", "Dominadas"],
    },
  };

  // Lista de zonas disponibles
  final List<String> zonas = ["Piernas", "Core", "Brazos"];
  String? zonaSeleccionada; // Zona seleccionada para el filtro

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas: Generales y Por Zona
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.nombreDeporte),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Ejercicios Generales'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicios por Zona'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 🏋 Ejercicios Generales
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ejerciciosGenerales[widget.nombreDeporte]?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(ejerciciosGenerales[widget.nombreDeporte]![index]),
                  leading: const Icon(Icons.fitness_center),
                );
              },
            ),

            // 🎯 Ejercicios por Zona con filtro
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    hint: const Text("Selecciona una zona"),
                    value: zonaSeleccionada,
                    isExpanded: true,
                    items: zonas.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        zonaSeleccionada = newValue;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: zonaSeleccionada == null
                      ? const Center(child: Text("Selecciona una zona para ver ejercicios"))
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ejerciciosPorZona[widget.nombreDeporte]?[zonaSeleccionada]?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(ejerciciosPorZona[widget.nombreDeporte]![zonaSeleccionada]![index]),
                        leading: const Icon(Icons.fitness_center),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
