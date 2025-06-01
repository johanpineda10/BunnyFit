import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database/database_helper.dart';
import '../database/recetas_model.dart';
import '../services/cargador_recetas.dart';

class TestRecetasScreen extends StatefulWidget {
  @override
  _TestRecetasScreenState createState() => _TestRecetasScreenState();
}

class _TestRecetasScreenState extends State<TestRecetasScreen> {
  List<Receta> recetas = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final cargador = CargadorRecetas();
    await cargador.cargarRecetasSiNoExisten();

    final recetasDB = await DatabaseHelper.instance.obtenerRecetas();
    setState(() {
      recetas = recetasDB;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Recetas'),
      ),
      body: FutureBuilder<List<Receta>>(
        future: DatabaseHelper.instance.obtenerRecetas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recetasDB = snapshot.data ?? [];

          return ListView.builder(
            itemCount: recetasDB.length,
            itemBuilder: (context, index) {
              final receta = recetasDB[index];
              return ListTile(
                title: Text(receta.titulo),
                subtitle: Text(receta.descripcion),
              );
            },
          );
        },
      ),
    );
  }
}
