import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class EjerciciosCategoriaScreen extends StatefulWidget {
  final String categoria;
  final String tipo; // 'casa' o 'gimnasio'
  const EjerciciosCategoriaScreen({super.key, required this.categoria, required this.tipo});

  @override
  State<EjerciciosCategoriaScreen> createState() => _EjerciciosCategoriaScreenState();
}

class _EjerciciosCategoriaScreenState extends State<EjerciciosCategoriaScreen> {
  List<dynamic> ejercicios = [];
  bool isLoading = true;

  // Imagen de ejemplo por categoría
  final Map<String, String> imagenes = {
    'Pierna': 'https://images.unsplash.com/photo-1517960413843-0aee8e2d471c?auto=format&fit=crop&w=800&q=80',
    'Abdomen': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    'Espalda': 'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=800&q=80',
    'Pecho': 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
    'Hombros': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
    'Hombro': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
    'Brazos': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
    'Estirar': 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80',
  };

  @override
  void initState() {
    super.initState();
    _loadEjercicios();
  }

  Future<void> _loadEjercicios() async {
    setState(() { isLoading = true; });
    final path = widget.tipo == 'casa'
        ? 'assets/ejerciciosEnCasa/ejercicios.json'
        : 'assets/ejerciciosGimnasio/ejercicios.json';
    final String jsonString = await rootBundle.loadString(path);
    final List<dynamic> data = json.decode(jsonString);
    
    print('Buscando categoría: ${widget.categoria}');
    print('Tipo de ejercicio: ${widget.tipo}');
    
    // Buscar la categoría que contenga el nombre buscado
    final cat = data.firstWhere(
      (c) {
        final titulo = (c['titulo'] as String).toLowerCase();
        final categoriaBuscada = widget.categoria.toLowerCase();
        final contieneCategoria = titulo.contains(categoriaBuscada);
        final contieneEjerciciosDe = titulo.contains('ejercicios de $categoriaBuscada');
        
        print('Comparando: $titulo con $categoriaBuscada');
        print('Contiene categoría: $contieneCategoria');
        print('Contiene ejercicios de: $contieneEjerciciosDe');
        
        return contieneCategoria || contieneEjerciciosDe;
      },
      orElse: () {
        print('No se encontró la categoría');
        return null;
      },
    );
    
    setState(() {
      ejercicios = cat != null ? (cat['ejercicios'] as List<dynamic>? ?? []) : [];
      print('Ejercicios encontrados: ${ejercicios.length}');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagenCategoria = imagenes[widget.categoria] ?? imagenes.values.first;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ejercicios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay ejercicios en esta categoría.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ejercicios.length,
                    itemBuilder: (context, index) {
                      final ej = ejercicios[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Material(
                          elevation: 2,
                          shadowColor: Colors.black12,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              // Aquí puedes navegar a un detalle completo del ejercicio si lo deseas
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey[50]!,
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                    child: Image.network(
                                      imagenCategoria,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ej['nombre'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            ej['descripcion'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.fitness_center, size: 16, color: Colors.deepPurple),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${ej['series'] ?? 0}x${ej['repeticiones'] ?? 0}',
                                                      style: TextStyle(
                                                        color: Colors.deepPurple,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${ej['calorias'] ?? 0} kcal',
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                      child: Icon(Icons.arrow_forward, color: Colors.deepPurple),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 