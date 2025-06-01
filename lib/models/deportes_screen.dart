import 'package:flutter/material.dart';
import 'detalle_deporte_screen.dart';

class DeportesScreen extends StatelessWidget {
  DeportesScreen({super.key});

  // Lista de deportes disponibles
  final List<Map<String, String>> deportes = [
    {"nombre": "Fútbol", "imagen": "assets/deportes/futbol.jpg"},
    {"nombre": "Natación", "imagen": "assets/deportes/natacion.jpg"},
    {"nombre": "Baloncesto", "imagen": "assets/deportes/baloncesto.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deportes')),
      body: ListView.builder(
        itemCount: deportes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Image.asset(
                deportes[index]["imagen"]!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                deportes[index]["nombre"]!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleDeporteScreen(nombreDeporte: deportes[index]["nombre"]!),
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
