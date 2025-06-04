import 'package:flutter/material.dart';
import '../models/test_fisico.dart';
import '../services/test_fisico_service.dart';
import 'test_detail_screen.dart';

class CategoryTestsScreen extends StatefulWidget {
  final String categoriaNombre;
  final IconData categoriaIcono;
  final String categoriaDescripcion;

  const CategoryTestsScreen({
    Key? key,
    required this.categoriaNombre,
    required this.categoriaIcono,
    required this.categoriaDescripcion,
  }) : super(key: key);

  @override
  State<CategoryTestsScreen> createState() => _CategoryTestsScreenState();
}

class _CategoryTestsScreenState extends State<CategoryTestsScreen> {
  final TestFisicoService _testService = TestFisicoService();
  List<TestFisico> _tests = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    try {
      final tests = await _testService.getTestsByCategoria(widget.categoriaNombre);
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los tests de la categoría: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TestFisico> get _filteredTests {
    if (_searchQuery.isEmpty) return _tests;
    return _tests.where((test) =>
      test.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      test.objetivo.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoriaNombre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TestSearchDelegate(
                  tests: _tests,
                  onTestSelected: (test) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestDetailScreen(test: test.toTestDetail()),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros en categoría
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildTestsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.categoriaIcono,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoriaNombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.categoriaDescripcion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[50],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestsList() {
    if (_filteredTests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No hay tests disponibles en esta categoría'
                    : 'No se encontraron tests que coincidan con "$_searchQuery"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTests.length,
      itemBuilder: (context, index) {
        return _buildTestCard(context, _filteredTests[index]);
      },
    );
  }

  Widget _buildTestCard(BuildContext context, TestFisico test) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 160,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test.objetivo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        test.duracion,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
    );
  }
}

class TestSearchDelegate extends SearchDelegate<String> {
  final List<TestFisico> tests;
  final Function(TestFisico) onTestSelected;

  TestSearchDelegate({
    required this.tests,
    required this.onTestSelected,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredTests = tests.where((test) =>
      test.nombre.toLowerCase().contains(query.toLowerCase()) ||
      test.objetivo.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (filteredTests.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron tests que coincidan con "$query"',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTests.length,
      itemBuilder: (context, index) {
        final test = filteredTests[index];
        return ListTile(
          title: Text(test.nombre),
          subtitle: Text(test.objetivo),
          leading: Icon(
            Icons.fitness_center,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            onTestSelected(test);
            close(context, '');
          },
        );
      },
    );
  }
} 