import 'package:flutter/material.dart';
import '../models/deporte.dart';
import 'categoria_ejercicios_screen.dart';

class TodasCategoriasScreen extends StatelessWidget {
  final Deporte deporte;

  const TodasCategoriasScreen({
    super.key,
    required this.deporte,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías de ${deporte.nombre}'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deporte.categorias.length,
        itemBuilder: (context, index) {
          final categoria = deporte.categorias[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CategoriaCard(
              categoria: categoria,
              deporteNombre: deporte.nombre,
              colorIndex: index,
            ),
          );
        },
      ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final CategoriaDeporte categoria;
  final String deporteNombre;
  final int colorIndex;

  const _CategoriaCard({
    required this.categoria,
    required this.deporteNombre,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriaEjerciciosScreen(
                deporteNombre: deporteNombre,
                categoria: categoria,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getCategoryColor(colorIndex).withOpacity(0.7),
                _getCategoryColor(colorIndex),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(categoria.nombre),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categoria.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${categoria.ejercicios.length} ejercicios disponibles',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'fuerza':
        return Icons.fitness_center;
      case 'flexibilidad':
        return Icons.accessibility_new;
      case 'resistencia':
        return Icons.timer;
      case 'equilibrio':
        return Icons.balance;
      case 'velocidad':
        return Icons.speed;
      case 'coordinación':
        return Icons.sports_gymnastics;
      default:
        return Icons.sports;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF6C63FF), // Violeta
      const Color(0xFF4CAF50), // Verde
      const Color(0xFFFF5252), // Rojo
      const Color(0xFF2196F3), // Azul
      const Color(0xFFFF9800), // Naranja
      const Color(0xFF9C27B0), // Púrpura
      const Color(0xFF009688), // Verde azulado
    ];
    return colors[index % colors.length];
  }
} 