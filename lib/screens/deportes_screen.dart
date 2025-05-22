import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/deporte.dart';
import '../services/deportes_service.dart';
import 'deporte_detalle_screen.dart';
import 'todos_deportes_screen.dart';
import 'todas_noticias_screen.dart';

class DeportesScreen extends StatefulWidget {
  const DeportesScreen({super.key});

  @override
  State<DeportesScreen> createState() => _DeportesScreenState();
}

class _DeportesScreenState extends State<DeportesScreen> {
  List<Deporte> _deportes = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _searchSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _cargarDeportes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSearchSection() {
    final RenderBox renderBox = _searchSectionKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final offset = position.dy;
    
    _scrollController.animateTo(
      offset - AppBar().preferredSize.height - 20,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _cargarDeportes() async {
    try {
      final deportes = await DeportesService.getDeportes();
      setState(() {
        _deportes = deportes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar deportes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y mensaje de bienvenida
                      const Text(
                        'Deportes',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWelcomeCard(),
                      const SizedBox(height: 32),

                      // Sección de actividad con gráfico
                      _buildActivitySection(),
                      const Divider(height: 40),

                      // Sección de logros
                      _buildAchievementsSection(),
                      const Divider(height: 40),

                      // Deportes recientes
                      _buildRecentSportsSection(),
                      const Divider(height: 40),

                      // Sección de búsqueda
                      _buildSearchSection(),
                      const Divider(height: 40),

                      // Deportes recomendados (carrusel)
                      _buildRecommendedSportsSection(),
                      const Divider(height: 40),

                      // Sección de objetivos
                      _buildObjectivesSection(),
                      const Divider(height: 40),

                      // Noticias deportivas
                      _buildSportsNewsSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡Bienvenido a tu centro deportivo!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Descubre ejercicios personalizados para mejorar tu rendimiento en cualquier deporte. Encuentra rutinas específicas y consejos de expertos.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _scrollToSearchSection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade800,
            ),
            child: const Text('Explorar Deportes'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      key: _searchSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de búsqueda
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar deportes, ejercicios, rutinas...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // TODO: Implementar filtros de búsqueda
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade400),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              // TODO: Implementar lógica de búsqueda
            },
          ),
        ),
        const SizedBox(height: 16),

        // Chips de filtros rápidos
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Todos los deportes'),
              _buildFilterChip('Deportes de equipo'),
              _buildFilterChip('Deportes individuales'),
              _buildFilterChip('Deportes de raqueta'),
              _buildFilterChip('Deportes acuáticos'),
            ],
          ),
        ),

        // Resultados de búsqueda (ocultos inicialmente)
        // Este contenedor se mostrará cuando haya una búsqueda activa
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resultados de búsqueda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'Realiza una búsqueda para ver los resultados',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool selected) {
          // TODO: Implementar filtrado por categoría
        },
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.blue.shade100),
        labelStyle: TextStyle(color: Colors.blue.shade800),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Logros',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
        itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getAchievementIcon(index),
                      size: 32,
                      color: Colors.blue.shade800,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getAchievementTitle(index),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (index + 1) * 0.25,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu Actividad',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(2.6, 2),
                    const FlSpot(4.9, 5),
                    const FlSpot(6.8, 3.1),
                    const FlSpot(8, 4),
                    const FlSpot(9.5, 3),
                    const FlSpot(11, 4),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSportsNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Noticias Deportivas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TodasNoticiasScreen(),
                  ),
                );
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.photo,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getNewsTitle(index),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Hace ${index + 1} horas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deportes Recientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getPlaceholderIcon(index),
                      size: 32,
                      color: Colors.blue.shade800,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPlaceholderSportName(index),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Deportes Recomendados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TodosDeportesScreen(),
                  ),
                );
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_deportes.isEmpty)
          const Center(
            child: Text(
              'No hay deportes disponibles',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _deportes.length,
              itemBuilder: (context, index) {
                final deporte = _deportes[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeporteDetalleScreen(
                            deporte: deporte,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getIconForDeporte(deporte.id),
                              size: 40,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  deporte.nombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    deporte.descripcion,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${deporte.categorias.length} categorías disponibles',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
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

  Widget _buildObjectivesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué quieres mejorar?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildObjectiveButton('⚡ Fuerza explosiva'),
            _buildObjectiveButton('🏃‍♂️ Resistencia'),
            _buildObjectiveButton('🎯 Precisión'),
            _buildObjectiveButton('🦘 Salto'),
            _buildObjectiveButton('💪 Fuerza'),
            _buildObjectiveButton('⚖️ Balance'),
          ],
        ),
      ],
    );
  }

  Widget _buildObjectiveButton(String text) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implementar navegación a ejercicios por objetivo
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.shade100),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getPlaceholderIcon(int index) {
    final icons = [
      Icons.sports_soccer,
      Icons.sports_basketball,
      Icons.pool,
      Icons.sports_volleyball,
      Icons.sports_tennis,
    ];
    return icons[index % icons.length];
  }

  String _getPlaceholderSportName(int index) {
    if (_deportes.isEmpty) return 'Deporte ${index + 1}';
    return _deportes[index % _deportes.length].nombre;
  }

  IconData _getAchievementIcon(int index) {
    final icons = [
      Icons.emoji_events,
      Icons.local_fire_department,
      Icons.timer,
      Icons.trending_up,
    ];
    return icons[index];
  }

  String _getAchievementTitle(int index) {
    final achievements = [
      '3 días seguidos mejorando salto',
      '5 entrenamientos completados',
      '30 minutos de ejercicio diario',
      'Mejora en resistencia',
    ];
    return achievements[index];
  }

  String _getNewsTitle(int index) {
    final news = [
      'Nuevas técnicas de entrenamiento para mejorar tu rendimiento',
      'Los mejores ejercicios para aumentar tu resistencia',
      'Consejos de expertos para prevenir lesiones',
    ];
    return news[index];
  }
}
