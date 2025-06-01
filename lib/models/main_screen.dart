import 'package:flutter/material.dart';
import 'deportes_screen.dart';
import 'home_screen.dart';
import 'nutricion_screen.dart';
import 'rutinas_screen.dart';
import 'tests_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Asegúrate de que las pantallas estén en el orden correcto
  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const NutricionScreen(), // ← Asegurar que aquí va Nutrición
    const RutinasScreen(),   // ← Aquí va Rutinas
    TestsScreen(),
    DeportesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Nutrición'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Rutinas'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tests Físicos'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Deportes'),
        ],
      ),
    );
  }
}
