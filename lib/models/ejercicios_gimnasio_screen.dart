import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../database/ejercicios_model.dart';
import '../services/cargador_ejercicios.dart';
import '../services/ejercicios_completados_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class EjerciciosGimnasioScreen extends StatefulWidget {
  final Function(int) onEjerciciosCompletados;
  const EjerciciosGimnasioScreen({
    Key? key, 
    required this.onEjerciciosCompletados,
  }) : super(key: key);

  @override
  State<EjerciciosGimnasioScreen> createState() => _EjerciciosGimnasioScreenState();
}

class _EjerciciosGimnasioScreenState extends State<EjerciciosGimnasioScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CargadorEjercicios _cargadorEjercicios = CargadorEjercicios();
  final EjerciciosCompletadosService _ejerciciosService = EjerciciosCompletadosService();
  List<String> categorias = [];
  Map<String, List<Ejercicio>> ejerciciosPorCategoria = {};
  bool isLoading = true;
  String? error;
  int selectedCategoria = 0;

  final Map<String, IconData> iconosCategoria = {
    'Pecho': Icons.fitness_center,
    'Espalda': Icons.fitness_center,
    'Piernas': Icons.fitness_center,
    'Hombros': Icons.fitness_center,
    'Brazos': Icons.fitness_center,
  };

  @override
  void initState() {
    super.initState();
    print('🔄 Iniciando EjerciciosGimnasioScreen...');
    _cargarEjercicios();
    _ejerciciosService.cargarEjerciciosCompletadosHoy();
  }

  Future<void> _cargarEjercicios() async {
    try {
      print('🔄 Iniciando carga de ejercicios...');
      setState(() {
        isLoading = true;
        error = null;
      });
      await _cargadorEjercicios.cargarEjerciciosSiNoExisten();
      print('✅ Ejercicios cargados/verificados');
      categorias = await _dbHelper.obtenerCategoriasEjercicios();
      // Filtrar solo las categorías de gimnasio
      categorias = categorias.where((categoria) => categoria.contains('(Gimnasio)')).toList();
      print('📋 Categorías obtenidas: ${categorias.length}');
      if (categorias.isEmpty) {
        throw Exception('No se encontraron categorías de ejercicios de gimnasio');
      }
      ejerciciosPorCategoria.clear();
      for (String categoria in categorias) {
        final ejercicios = await _dbHelper.obtenerEjerciciosPorCategoria(categoria);
        ejerciciosPorCategoria[categoria] = ejercicios;
        print('💪 Ejercicios en categoría $categoria: ${ejercicios.length}');
      }
      if (ejerciciosPorCategoria.isEmpty) {
        throw Exception('No se encontraron ejercicios en ninguna categoría de gimnasio');
      }
      setState(() {
        isLoading = false;
      });
      print('✅ Carga de ejercicios completada exitosamente');
    } catch (e) {
      print('❌ Error en _cargarEjercicios: $e');
      setState(() {
        isLoading = false;
        error = 'Error al cargar los ejercicios: $e';
      });
    }
  }

  // Helper para obtener IconData desde el nombre del icono
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center; // Icono por defecto para ejercicios de gimnasio
    }
  }

  Future<void> _marcarEjercicioCompletado(Ejercicio ejercicio) async {
     if (ejercicio.id == null) {
      print('Error: El ejercicio no tiene ID');
      return;
    }

    await _ejerciciosService.marcarEjercicioCompletado(ejercicio.id!, ejercicio.categoria);
    setState(() {}); // Actualizar UI

    // No hay navegación ni SnackBar aquí, eso se maneja en RutinasScreen
  }

  void _mostrarDetallesEjercicio(Ejercicio ejercicio) {
    final bool isCompleted = _ejerciciosService.estaCompletado(ejercicio.id!);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Barra de arrastre
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del ejercicio
                      if (ejercicio.imagenUrl != null && ejercicio.imagenUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: ejercicio.imagenUrl!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 250,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error_outline, size: 50),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Título y descripción
                      Text(
                        ejercicio.nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ejercicio.descripcion,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Información del ejercicio
                      _buildInfoRow('Series', '${ejercicio.series}'),
                      _buildInfoRow('Repeticiones', '${ejercicio.repeticiones}'),
                      if (ejercicio.duracion != null)
                        _buildInfoRow('Duración', '${ejercicio.duracion} seg'),
                      _buildInfoRow('Calorías', '${ejercicio.calorias}'),
                      _buildInfoRow('Dificultad', ejercicio.dificultad),
                      const SizedBox(height: 16),
                      // Músculos trabajados
                      const Text(
                        'Músculos trabajados:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ejercicio.musculos.map((musculo) => Chip(
                          label: Text(musculo),
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Equipamiento
                      const Text(
                        'Equipamiento necesario:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ejercicio.equipamiento.map((equipo) => Chip(
                          label: Text(equipo),
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Instrucciones
                      const Text(
                        'Instrucciones:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...ejercicio.instrucciones.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}. ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 16),
                      // Consejos
                      if (ejercicio.consejos != null && ejercicio.consejos!.isNotEmpty) ...[
                        const Text(
                          'Consejos:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ejercicio.consejos!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Botón de completado
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isCompleted) {
                              _marcarEjercicioCompletado(ejercicio);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted ? Colors.green : Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted ? Icons.check_circle : Icons.check,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCompleted ? 'Completado' : 'Marcar como completado',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando ejercicios...'),
            ],
          ),
        ),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ejercicios de Gimnasio'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print('🔄 Reintentando carga de ejercicios...');
                  _cargarEjercicios();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (categorias.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No hay categorías de ejercicios de gimnasio disponibles'),
        ),
      );
    }
    return Scaffold(
       appBar: AppBar(
        title: Row(
          children: [
             const Text('Ejercicios de Gimnasio'),
            const SizedBox(width: 12),
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_ejerciciosService.ejerciciosCompletadosGimnasio}/5',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categorias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categorias[index];
                final isSelected = selectedCategoria == index;
                final nombreLimpio = cat.replaceAll(' (Gimnasio)', '');
                 // Aquí mantenemos el icono de la categoría con el mapa original si lo necesitas
                final categoriaIcon = iconosCategoria[nombreLimpio] ?? Icons.fitness_center;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurple : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        setState(() {
                          selectedCategoria = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              categoriaIcon, // Icono de la categoría
                              color: isSelected ? Colors.white : Colors.deepPurple,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              nombreLimpio,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: ejerciciosPorCategoria[categorias[selectedCategoria]]?.length ?? 0,
              itemBuilder: (context, index) {
                final ejercicio = ejerciciosPorCategoria[categorias[selectedCategoria]]![index];
                // Verificar si el ejercicio está completado hoy
                final bool isCompleted = _ejerciciosService.estaCompletado(ejercicio.id!);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      _mostrarDetallesEjercicio(ejercicio);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mostrar la imagen si está disponible, o un icono por defecto
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ejercicio.imagenUrl != null && ejercicio.imagenUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: ejercicio.imagenUrl!,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 160,
                                      memCacheHeight: 160,
                                      maxWidthDiskCache: 160,
                                      maxHeightDiskCache: 160,
                                      cacheManager: DefaultCacheManager(),
                                      fadeInDuration: const Duration(milliseconds: 300),
                                      fadeOutDuration: const Duration(milliseconds: 300),
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) {
                                        print('❌ Error al cargar imagen: $error');
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _getIconData(ejercicio.icono),
                                                size: 32,
                                                color: Colors.deepPurple,
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Sin imagen',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getIconData(ejercicio.icono),
                                            size: 32,
                                            color: Colors.deepPurple,
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Sin imagen',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ejercicio.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ejercicio.descripcion,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (ejercicio.series != null && ejercicio.series! > 0)
                                      _buildInfoChip(Icons.fitness_center, '${ejercicio.series} series'),
                                    if (ejercicio.repeticiones != null && ejercicio.repeticiones! > 0)
                                      _buildInfoChip(Icons.repeat, '${ejercicio.repeticiones} reps'),
                                    if (ejercicio.duracion != null && ejercicio.duracion! > 0)
                                      _buildInfoChip(Icons.timer, '${ejercicio.duracion} seg'),
                                    if (ejercicio.calorias != null && ejercicio.calorias! > 0)
                                      _buildInfoChip(Icons.whatshot, '${ejercicio.calorias} kcal'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Mostrar el indicador de completado aquí
                                if (isCompleted)
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      SizedBox(width: 4),
                                      Text('Completado hoy', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          // Flecha de navegación o icono de completado
                          Icon(
                             isCompleted ? Icons.check_circle : Icons.arrow_forward,
                             color: isCompleted ? Colors.green : Colors.deepPurple,
                             size: 30,
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

  // Helper widget para los chips de información (series, reps, etc.)
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
