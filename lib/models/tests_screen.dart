import 'package:flutter/material.dart';
import 'detalle_test_screen.dart';

class TestsScreen extends StatelessWidget {
  TestsScreen({super.key});

  // Lista de tests físicos con nombres y descripciones
  final List<Map<String, String>> testsFisicos = [
    {"nombre": "Test de Cooper", "descripcion": "Mide la resistencia aeróbica en 12 minutos."},
    {"nombre": "Test de Rockport", "descripcion": "Evalúa la condición aeróbica caminando 1.6 km."},
    {"nombre": "Test de Course Navette", "descripcion": "Test progresivo de resistencia con cambios de ritmo."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tests Físicos')),
      body: ListView.builder(
        itemCount: testsFisicos.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.fitness_center, size: 40, color: Colors.blue),
              title: Text(testsFisicos[index]["nombre"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(testsFisicos[index]["descripcion"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleTestScreen(nombreTest: testsFisicos[index]["nombre"]!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
