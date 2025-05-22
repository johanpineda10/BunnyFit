import 'package:flutter/material.dart';
import '../models/deporte.dart';
import 'categoria_ejercicios_screen.dart';
import 'todas_categorias_screen.dart';

class DeporteDetalleScreen extends StatefulWidget {
  final Deporte deporte;

  const DeporteDetalleScreen({
    super.key,
    required this.deporte,
  });

  @override
  State<DeporteDetalleScreen> createState() => _DeporteDetalleScreenState();
}

class _DeporteDetalleScreenState extends State<DeporteDetalleScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener ejercicios recomendados
    final ejerciciosRecomendados = _getEjerciciosRecomendados();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deporte.nombre),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
              ),
              child: Center(
                child: Icon(
                  _getIconForDeporte(widget.deporte.id),
                  size: 80,
                  color: Colors.blue.shade800,
                ),
              ),
            ),

            // Descripción
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.deporte.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Categorías
            _buildCategoriasSection(),

            // Ejercicios Recomendados
            if (ejerciciosRecomendados.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ejercicios Recomendados',
                          style: TextStyle(
                            fontSize: 22.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implementar ver todos los ejercicios
                          },
                          child: const Text('Ver todos'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ejerciciosRecomendados.length,
                        itemBuilder: (context, index) {
                          final ejercicio = ejerciciosRecomendados[index];
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen placeholder
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getCategoryIcon(ejercicio.categoria.nombre),
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ejercicio.titulo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.timer_outlined,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                ejercicio.duracion,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    ejercicio.categoria.nombre,
                                                    style: TextStyle(
                                                      color: Colors.blue.shade800,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Reto Semanal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade400,
                        Colors.purple.shade800,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reto Semanal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '¡Supera tus límites!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Completa 5 sesiones de entrenamiento esta semana y gana una medalla especial',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '6 días restantes',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implementar aceptar reto
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.purple.shade800,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Acepto el Reto',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Datos curiosos (PageView)
            if (widget.deporte.curiosidades.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos Curiosos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220, // Aumentamos la altura para evitar overflow
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: widget.deporte.curiosidades.length,
                        itemBuilder: (context, index) {
                          final curiosidad = widget.deporte.curiosidades[index];
                          return AnimatedPadding(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: _currentPage == index ? 0 : 8,
                            ),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade800,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Dato curioso',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      curiosidad.emoji,
                                      style: const TextStyle(
                                        fontSize: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          curiosidad.texto,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.deporte.curiosidades.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.blue.shade800
                                : Colors.blue.shade200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar ver más curiosidades
                        },
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Ver más curiosidades'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getIconForDeporte(String deporteId) {
    switch (deporteId.toLowerCase()) {
      case 'futbol':
        return Icons.sports_soccer;
      case 'basquetbol':
        return Icons.sports_basketball;
      case 'natacion':
        return Icons.pool;
      case 'voleibol':
        return Icons.sports_volleyball;
      case 'tenis':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
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

  // Helper method to get ejercicios recomendados
  List<_EjercicioRecomendado> _getEjerciciosRecomendados() {
    final ejercicios = <_EjercicioRecomendado>[];
    
    // Recorrer todas las categorías y sus ejercicios
    for (var categoria in widget.deporte.categorias) {
      for (var ejercicio in categoria.ejercicios) {
        ejercicios.add(
          _EjercicioRecomendado(
            titulo: ejercicio.titulo,
            descripcion: ejercicio.descripcion,
            duracion: ejercicio.duracion,
            categoria: categoria,
          ),
        );
      }
    }
    
    // Ordenar aleatoriamente y tomar los primeros 5 ejercicios
    ejercicios.shuffle();
    return ejercicios.take(5).toList();
  }

  Widget _buildCategoriasSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TodasCategoriasScreen(
                        deporte: widget.deporte,
                      ),
                    ),
                  );
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: widget.deporte.categorias.length,
              itemBuilder: (context, index) {
                final categoria = widget.deporte.categorias[index];
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(
                    right: 16,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriaEjerciciosScreen(
                            deporteNombre: widget.deporte.nombre,
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
                            _getCategoryColor(index).withOpacity(0.7),
                            _getCategoryColor(index),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(index).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(categoria.nombre),
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            categoria.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${categoria.ejercicios.length} ejercicios',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Clase auxiliar para mantener la referencia a la categoría
class _EjercicioRecomendado {
  final String titulo;
  final String descripcion;
  final String duracion;
  final CategoriaDeporte categoria;

  _EjercicioRecomendado({
    required this.titulo,
    required this.descripcion,
    required this.duracion,
    required this.categoria,
  });
} 