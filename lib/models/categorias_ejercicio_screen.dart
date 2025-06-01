import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'ejercicios_categoria_screen.dart';

class CategoriaEjercicio {
  final String nombre;
  final String imagenUrl;
  final int ejercicios;
  final int duracionMin;
  final int calorias;

  CategoriaEjercicio({
    required this.nombre,
    required this.imagenUrl,
    required this.ejercicios,
    required this.duracionMin,
    required this.calorias,
  });
}

class CategoriasEjercicioScreen extends StatefulWidget {
  const CategoriasEjercicioScreen({super.key});

  @override
  State<CategoriasEjercicioScreen> createState() => _CategoriasEjercicioScreenState();
}

class _CategoriasEjercicioScreenState extends State<CategoriasEjercicioScreen> {
  int selectedTab = 0; // 0: Casa, 1: Gimnasio
  bool isLoadingCasa = true;
  bool isLoadingGimnasio = true;
  List<CategoriaEjercicio> categoriasCasa = [];
  List<CategoriaEjercicio> categoriasGimnasio = [];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    await Future.wait([
      _loadCategoriasDesdeJson('assets/ejerciciosEnCasa/ejercicios.json', true),
      _loadCategoriasDesdeJson('assets/ejerciciosGimnasio/ejercicios.json', false),
    ]);
  }

  Future<void> _loadCategoriasDesdeJson(String path, bool esCasa) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final List<dynamic> data = json.decode(jsonString);
      List<CategoriaEjercicio> categorias = [];
      for (var cat in data) {
        final nombre = cat['titulo'] ?? 'Sin nombre';
        final ejercicios = (cat['ejercicios'] as List<dynamic>? ?? []).length;
        int duracion = 0;
        int calorias = 0;
        for (var ej in (cat['ejercicios'] as List<dynamic>? ?? [])) {
          duracion += ((ej['series'] ?? 0) * (ej['repeticiones'] ?? 0) * 3 ~/ 60);
          calorias += (ej['calorias'] ?? 0);
        }
        final imagenes = {
          'Pierna': 'https://images.unsplash.com/photo-1517960413843-0aee8e2d471c?auto=format&fit=crop&w=800&q=80',
          'Abdomen': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
          'Espalda': 'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=800&q=80',
          'Pecho': 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
          'Hombros': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
          'Hombro': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
          'Brazos': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
          'Estirar': 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80',
        };
        String imagenUrl = imagenes[nombre] ?? imagenes.values.first;
        categorias.add(CategoriaEjercicio(
          nombre: nombre,
          imagenUrl: imagenUrl,
          ejercicios: ejercicios,
          duracionMin: duracion > 0 ? duracion : 15,
          calorias: calorias > 0 ? calorias : 100,
        ));
      }
      setState(() {
        if (esCasa) {
          categoriasCasa = categorias;
          isLoadingCasa = false;
        } else {
          categoriasGimnasio = categorias;
          isLoadingGimnasio = false;
        }
      });
    } catch (e) {
      setState(() {
        if (esCasa) isLoadingCasa = false;
        else isLoadingGimnasio = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Ejercicios'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton('Casa', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('Gimnasio', 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedTab == 0
                ? _buildCategoriasList(isLoadingCasa, categoriasCasa, 'casa')
                : _buildCategoriasList(isLoadingGimnasio, categoriasGimnasio, 'gimnasio'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTab == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            setState(() {
              selectedTab = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriasList(bool isLoading, List<CategoriaEjercicio> categorias, String tipo) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (categorias.isEmpty) {
      return const Center(child: Text('No hay categorías disponibles.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EjerciciosCategoriaScreen(
                    categoria: categoria.nombre,
                    tipo: tipo,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    categoria.imagenUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.fitness_center, size: 18, color: Colors.deepPurple),
                          const SizedBox(width: 4),
                          Text('${categoria.ejercicios} ejercicios'),
                          const SizedBox(width: 16),
                          Icon(Icons.timer, size: 18, color: Colors.deepPurple),
                          const SizedBox(width: 4),
                          Text('${categoria.duracionMin} min'),
                          const SizedBox(width: 16),
                          Icon(Icons.local_fire_department, size: 18, color: Colors.deepPurple),
                          const SizedBox(width: 4),
                          Text('${categoria.calorias} kcal'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
} 