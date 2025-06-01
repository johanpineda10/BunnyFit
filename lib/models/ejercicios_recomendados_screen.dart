import 'package:flutter/material.dart';

class EjerciciosRecomendadosScreen extends StatefulWidget {
  const EjerciciosRecomendadosScreen({super.key});

  @override
  _EjerciciosRecomendadosScreenState createState() => _EjerciciosRecomendadosScreenState();
}

class _EjerciciosRecomendadosScreenState extends State<EjerciciosRecomendadosScreen> {
  final Map<String, List<String>> _ejerciciosPorTest = {
    "Test de Cooper": ["Correr en intervalos", "Entrenamiento HIIT", "Sprints de 200m"],
    "Test de Rockport": ["Caminar a paso rápido", "Ejercicios de resistencia", "Subidas de escaleras"],
    "Otro Test": ["Ejercicio 1", "Ejercicio 2", "Ejercicio 3"]
  };

  String _testSeleccionado = "Test de Cooper"; // Test por defecto

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Selecciona un test físico:",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 120, // Espacio para la lista de tests físicos
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _ejerciciosPorTest.keys.map((String test) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _testSeleccionado = test;
                  });
                },
                child: Card(
                  color: _testSeleccionado == test ? Colors.blueAccent : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 30, color: _testSeleccionado == test ? Colors.white : Colors.black),
                        Text(test, style: TextStyle(color: _testSeleccionado == test ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _ejerciciosPorTest[_testSeleccionado]!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_ejerciciosPorTest[_testSeleccionado]![index]),
                leading: const Icon(Icons.fitness_center),
              );
            },
          ),
        ),
      ],
    );
  }
}
