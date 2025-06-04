import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'test_detail_screen.dart';
import 'category_tests_screen.dart';
import '../services/test_fisico_service.dart';
import '../models/test_fisico.dart';
import 'all_tests_screen.dart';

// TODO: Mover estas constantes a un archivo separado de constantes
class TestsScreenStyles {
  static const double paddingDefault = 16.0;
  static const double borderRadius = 16.0;
  static const double titleSize = 24.0;
  static const double subtitleSize = 20.0;
  static const double textSize = 16.0;
  static const double smallTextSize = 14.0;
  static const Color appBlueColor = Color(0xFF007BFF);
}

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final TestFisicoService _testService = TestFisicoService();
  List<TestFisico> _tests = [];
  List<TestFisico> _filteredTests = [];
  bool _isLoading = true;
  bool _isSearchExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categoriasKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final PageController _tipsPageController;
  int _currentTipPage = 0;

  @override
  void initState() {
    super.initState();
    _loadTests();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _tipsPageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentTipPage,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tipsPageController.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      setState(() {
        _isSearchExpanded = true;
      });
    }
  }

  void _toggleSearchExpanded() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchFocusNode.unfocus();
      }
    });
  }

  Future<void> _loadTests() async {
    try {
      final tests = await _testService.getTestsFisicos();
      setState(() {
        _tests = tests;
        _filteredTests = tests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los tests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTests = _tests;
      } else {
        _filteredTests = _tests.where((test) {
          final nombreMatch = test.nombre.toLowerCase().contains(query.toLowerCase());
          final objetivoMatch = test.objetivo.toLowerCase().contains(query.toLowerCase());
          final categoriaMatch = test.categorias.any(
            (categoria) => categoria.toLowerCase().contains(query.toLowerCase()),
          );
          return nombreMatch || objetivoMatch || categoriaMatch;
        }).toList();
      }
    });
  }

  // TODO: Mover a un archivo de constantes o servicio de datos
  final List<Map<String, dynamic>> categorias = [
    {
      'nombre': 'Resistencia',
      'icono': Icons.directions_run,
      'descripcion': 'Evalúa tu capacidad cardiovascular y resistencia aeróbica'
    },
    {
      'nombre': 'Fuerza',
      'icono': Icons.fitness_center,
      'descripcion': 'Mide tu fuerza muscular en diferentes grupos musculares'
    },
    {
      'nombre': 'Potencia',
      'icono': Icons.flash_on,
      'descripcion': 'Evalúa tu capacidad de generar fuerza en el menor tiempo posible'
    },
    {
      'nombre': 'Velocidad',
      'icono': Icons.speed,
      'descripcion': 'Mide tu capacidad de movimiento rápido y explosivo'
    },
    {
      'nombre': 'Agilidad',
      'icono': Icons.change_circle,
      'descripcion': 'Evalúa tu capacidad de cambiar de dirección rápidamente'
    },
    {
      'nombre': 'Equilibrio y Coordinación',
      'icono': Icons.balance,
      'descripcion': 'Mide tu control corporal y coordinación motora'
    },
    {
      'nombre': 'Flexibilidad',
      'icono': Icons.accessibility_new,
      'descripcion': 'Analiza tu rango de movimiento y elasticidad'
    },
    {
      'nombre': 'Composición Corporal',
      'icono': Icons.person,
      'descripcion': 'Evalúa tu masa muscular, grasa y otros componentes corporales'
    },
    {
      'nombre': 'Recuperación',
      'icono': Icons.healing,
      'descripcion': 'Mide tu capacidad de recuperación post-ejercicio'
    },
    {
      'nombre': 'Militares',
      'icono': Icons.military_tech,
      'descripcion': 'Tests específicos para preparación militar'
    },
    {
      'nombre': 'Policías',
      'icono': Icons.local_police,
      'descripcion': 'Pruebas físicas para cuerpos policiales'
    }
  ];

  // TODO: Mover a un servicio de consejos/tips
  final List<String> consejos = [
    "Recuerda calentar adecuadamente antes de cada test",
    "Mantén una buena hidratación antes, durante y después",
    "Usa ropa y calzado apropiado para cada prueba",
    "Respeta tus límites y progresa gradualmente"
  ];

  // Estructura de datos para los consejos por categoría
  final Map<String, List<String>> consejosCategoria = {
    'Resistencia': [
      'Placeholder consejo 1 resistencia',
      'Placeholder consejo 2 resistencia',
      'Placeholder consejo 3 resistencia',
    ],
    'Fuerza': [
      'Placeholder consejo 1 fuerza',
      'Placeholder consejo 2 fuerza',
      'Placeholder consejo 3 fuerza',
    ],
    'Potencia': [
      'Placeholder consejo 1 potencia',
      'Placeholder consejo 2 potencia',
      'Placeholder consejo 3 potencia',
    ],
    // ... más categorías con sus consejos
  };

  void _scrollToCategories() {
    final RenderBox renderBox = _categoriasKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    _scrollController.animateTo(
      position.dy,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleTipPageChanged(int page) {
    setState(() {
      if (page < 0) {
        // Si vamos hacia la izquierda desde la primera página
        _currentTipPage = categorias.length - 1;
        _tipsPageController.jumpToPage(_currentTipPage);
      } else {
        // Normalizar el índice para el comportamiento cíclico
        _currentTipPage = page % categorias.length;
        if (page != _currentTipPage) {
          _tipsPageController.jumpToPage(_currentTipPage);
        }
      }
    });
  }

  Widget _buildSearchResults() {
    if (!_isSearchExpanded) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultados de búsqueda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton.icon(
                  onPressed: _toggleSearchExpanded,
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_filteredTests.isEmpty && _searchController.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No se encontraron tests que coincidan con tu búsqueda',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredTests.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final test = _filteredTests[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestDetailScreen(
                            test: test.toTestDetail(),
                          ),
                        ),
                      );
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TestsScreenStyles.appBlueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: TestsScreenStyles.appBlueColor,
                      ),
                    ),
                    title: Text(
                      test.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      test.objetivo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: _isSearchExpanded ? 8 : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(_isSearchExpanded ? 0 : 12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _filterTests,
            decoration: InputDecoration(
              hintText: 'Buscar tests físicos...',
              prefixIcon: const Icon(Icons.search, color: TestsScreenStyles.appBlueColor),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: TestsScreenStyles.appBlueColor),
                      onPressed: () {
                        _searchController.clear();
                        _filterTests('');
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      _isSearchExpanded ? Icons.expand_less : Icons.expand_more,
                      color: TestsScreenStyles.appBlueColor,
                    ),
                    onPressed: _toggleSearchExpanded,
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        _buildSearchResults(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Tests Físicos',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _scrollToCategories,
                          icon: const Icon(Icons.fitness_center, size: 20),
                          label: const Text('Realizar nuevo test'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TestsScreenStyles.appBlueColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMotivationalBanner(),
                  _buildSearchBar(),
                  _buildProgresoUsuario(),
                  _buildTestsDestacados(context),
                  const SizedBox(height: 24),
                  _buildQuickTips(),
                  const SizedBox(height: 24),
                  _buildSection(
                    key: _categoriasKey,
                    title: 'Categorías',
                    child: _buildCategoriasGrid(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildTestsDestacados(BuildContext context) {
    final testsToShow = _searchController.text.isEmpty ? _tests : _filteredTests;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tests Destacados',
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
                      builder: (context) => const AllTestsScreen(),
                    ),
                  );
                },
                child: const Text('Ver Todos'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (testsToShow.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: Text(
                'No se encontraron tests que coincidan con tu búsqueda',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: testsToShow.length,
              itemBuilder: (context, index) {
                return _buildTestCard(context, testsToShow[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriasGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
          ),
          itemCount: categorias.length,
        itemBuilder: (context, index) {
            return _buildCategoriaCard(context, categorias[index]);
          },
        );
      },
    );
  }

  Widget _buildCategoriaCard(BuildContext context, Map<String, dynamic> categoria) {
          return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TestsScreenStyles.borderRadius),
      ),
      child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
              builder: (context) => CategoryTestsScreen(
                categoriaNombre: categoria['nombre'],
                categoriaIcono: categoria['icono'],
                categoriaDescripcion: categoria['descripcion'],
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(TestsScreenStyles.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categoria['icono'],
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                categoria['nombre'],
                style: const TextStyle(
                  fontSize: TestsScreenStyles.textSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Text(
                categoria['descripcion'],
                style: TextStyle(
                  fontSize: TestsScreenStyles.smallTextSize,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, TestFisico test) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestDetailScreen(test: test.toTestDetail()),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      test.objetivo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            test.duracion,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[300]!.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡Mejora tu rendimiento!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre tu nivel actual y establece nuevas metas.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoUsuario() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tu Progreso',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Último Test Realizado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Gráfica de progreso\n(Placeholder)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Consejos Rápidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber[600],
                    size: 24,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      final newPage = _currentTipPage - 1;
                      if (newPage < 0) {
                        _tipsPageController.jumpToPage(categorias.length - 1);
                      } else {
                        _tipsPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      _tipsPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _tipsPageController,
            onPageChanged: _handleTipPageChanged,
            itemBuilder: (context, index) {
              final normalizedIndex = index % categorias.length;
              if (normalizedIndex < 0) {
                return Container(); // Evitar índices negativos
              }
              final categoria = categorias[normalizedIndex];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[700]!.withOpacity(0.8),
                      Colors.blue[500]!.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[300]!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            categoria['icono'],
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Consejos ${categoria['nombre']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Próximamente consejos específicos para esta categoría',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swipe,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Desliza para más consejos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
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

  Widget _buildSection({
    Key? key,
    required String title,
    required Widget child,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
