import 'package:flutter/material.dart';
import '../models/test_fisico.dart';
import '../services/test_fisico_service.dart';
import 'test_detail_screen.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron tests que coincidan con "$query"',
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
      padding: const EdgeInsets.all(16),
      itemCount: filteredTests.length,
      itemBuilder: (context, index) {
        final test = filteredTests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.fitness_center,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              test.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              test.objetivo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              onTestSelected(test);
              close(context, '');
            },
          ),
        );
      },
    );
  }
}

class AllTestsScreen extends StatefulWidget {
  const AllTestsScreen({super.key});

  @override
  State<AllTestsScreen> createState() => _AllTestsScreenState();
}

class _AllTestsScreenState extends State<AllTestsScreen> {
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
      final tests = await _testService.getTestsFisicos();
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los tests: $e');
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
        title: const Text('Todos los Tests'),
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTests.isEmpty
              ? Center(
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
                              ? 'No hay tests disponibles'
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredTests.length,
                  itemBuilder: (context, index) {
                    return _buildTestCard(context, _filteredTests[index]);
                  },
                ),
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
                      const SizedBox(width: 16),
                      Icon(Icons.category, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          test.categorias.join(', '),
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
    );
  }
} 