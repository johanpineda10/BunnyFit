import 'package:flutter/material.dart';
import '../models/test_detail.dart';
import '../models/test_user_type.dart';
import '../widgets/test_user_selection_dialog.dart';
import 'test_in_progress_screen.dart';

class TestDetailScreen extends StatelessWidget {
  final TestDetail test;

  const TestDetailScreen({
    Key? key,
    required this.test,
  }) : super(key: key);

  Future<void> _handleStartTest(BuildContext context) async {
    final userType = await showDialog<TestUserType>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TestUserSelectionDialog(),
    );

    if (userType != null && context.mounted) {
      final config = TestExecutionConfig.forUserType(userType);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestInProgressScreen(
            test: test,
            config: config,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(test.nombre),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(
                Icons.fitness_center,
                size: 64,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción breve
                  Text(
                    test.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Duración y categoría
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.timer,
                        test.duracion,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.category,
                        test.categoria,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Objetivo
                  _buildSection(
                    'Objetivo',
                    test.objetivo,
                  ),
                  const SizedBox(height: 24),
                  
                  // Cómo realizar el test
                  _buildSection(
                    'Cómo realizar el test',
                    test.pasos.join('\n\n'),
                  ),
                  const SizedBox(height: 24),
                  
                  // Precauciones
                  _buildSection(
                    'Precauciones',
                    test.precauciones.join('\n\n'),
                  ),
                  const SizedBox(height: 24),
                  
                  // Consejos
                  _buildSection(
                    'Consejos',
                    test.consejos.join('\n\n'),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar funcionalidad de guardar
                          },
                          icon: const Icon(Icons.bookmark),
                          label: const Text('Guardar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar funcionalidad de compartir
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Compartir'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Nuevos botones de acción
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar funcionalidad de ejercicios recomendados
                    },
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Ejercicios Recomendados'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _handleStartTest(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Empezar Test',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.blue[50],
      labelStyle: TextStyle(color: Colors.blue[700]),
    );
  }
} 