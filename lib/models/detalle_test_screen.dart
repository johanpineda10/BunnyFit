import 'package:flutter/material.dart';

class DetalleTestScreen extends StatelessWidget {
  final String nombreTest;
  DetalleTestScreen({super.key, required this.nombreTest});

  // Mapa con guías de cada test
  final Map<String, String> guias = {
    "Test de Cooper": "Corre la mayor distancia posible en 12 minutos. Evalúa la resistencia aeróbica.",
    "Test de Rockport": "Camina 1.6 km lo más rápido posible. Evalúa la capacidad aeróbica.",
    "Test de Course Navette": "Corre entre dos líneas al ritmo de señales de audio. Incrementa la velocidad progresivamente.",
  };

  // Mapa con ejercicios recomendados para cada test
  final Map<String, List<String>> ejercicios = {
    "Test de Cooper": ["Correr en intervalos", "HIIT", "Sprints de 200m"],
    "Test de Rockport": ["Caminar a paso rápido", "Ejercicios de resistencia", "Subidas de escaleras"],
    "Test de Course Navette": ["Ejercicios de agilidad", "Saltos laterales", "Sprint en distancias cortas"],
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas: Guía y Ejercicios
      child: Scaffold(
        appBar: AppBar(
          title: Text(nombreTest),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Guía'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Sección de Guía del Test
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                guias[nombreTest] ?? "Información no disponible.",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            // Sección de Ejercicios Recomendados
            ListView.builder(
              itemCount: ejercicios[nombreTest]?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(ejercicios[nombreTest]![index]),
                  leading: const Icon(Icons.fitness_center),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
