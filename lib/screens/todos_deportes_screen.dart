import 'package:flutter/material.dart';
import '../models/deporte.dart';
import '../services/deportes_service.dart';
import 'deporte_detalle_screen.dart';

class TodosDeportesScreen extends StatefulWidget {
  const TodosDeportesScreen({super.key});

  @override
  State<TodosDeportesScreen> createState() => _TodosDeportesScreenState();
}

class _TodosDeportesScreenState extends State<TodosDeportesScreen> {
  List<Deporte> _deportes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDeportes();
  }

  Future<void> _cargarDeportes() async {
    try {
      final deportes = await DeportesService.getDeportes();
      setState(() {
        _deportes = deportes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar los deportes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Deportes'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _cargarDeportes,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _deportes.length,
                itemBuilder: (context, index) {
                  final deporte = _deportes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _DeporteCard(deporte: deporte),
                  );
                },
              ),
            ),
    );
  }
}

class _DeporteCard extends StatelessWidget {
  final Deporte deporte;

  const _DeporteCard({required this.deporte});

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
              builder: (context) => DeporteDetalleScreen(deporte: deporte),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sports,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deporte.nombre,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deporte.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${deporte.categorias.length} categorías disponibles',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 