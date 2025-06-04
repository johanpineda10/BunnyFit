import 'package:flutter/material.dart';
import 'ejercicios_casa_screen.dart';
import 'ejercicios_gimnasio_screen.dart';

class RutinasScreen extends StatelessWidget {
  const RutinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rutinas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'En Casa'),
              Tab(icon: Icon(Icons.fitness_center), text: 'En el Gimnasio'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EjerciciosCasaScreen(),
            EjerciciosGimnasioScreen(),
          ],
        ),
      ),
    );
  }
}
