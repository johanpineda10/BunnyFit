import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/recetas_model.dart';

class CargadorRecetas {
  Future<void> cargarRecetasSiNoExisten() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> recetas = await db.query('recetas');

      if (recetas.isEmpty) {
        print('📦 No hay recetas en la base de datos, cargando desde JSON...');
        await cargarRecetasDesdeJSON();
      } else {
        print('📦 Ya existen ${recetas.length} recetas en la base de datos');
      }
    } catch (e) {
      print('❌ Error al cargar recetas: $e');
    }
  }

  Future<void> cargarRecetasDesdeJSON() async {
    final tiposComida = ['desayuno', 'almuerzo', 'cena', 'snack', 'bebida'];

    for (final tipo in tiposComida) {
      try {
        final String jsonString = await rootBundle.loadString('assets/recetas/$tipo.json');
        final List<dynamic> jsonData = json.decode(jsonString);

        for (var recetaData in jsonData) {
          final recetaFinal = Receta(
            titulo: recetaData['titulo'],
            descripcion: recetaData['descripcion'],
            calorias: recetaData['calorias'],
            proteinas: recetaData['proteinas'].toDouble(),
            carbohidratos: recetaData['carbohidratos'].toDouble(),
            grasas: recetaData['grasas'].toDouble(),
            ingredientes: (recetaData['ingredientes'] as List)
                .map((i) => Ingrediente(nombre: i['nombre'], cantidad: i['cantidad']))
                .toList(),
            instrucciones: List<String>.from(recetaData['instrucciones']),
            infoNutricional: recetaData['infoNutricional'] ?? '',
            tiempoPreparacion: recetaData['tiempoPreparacion'],
            imagenUrl: recetaData['imagenUrl'],
            dificultad: recetaData['dificultad'],
            tipoComida: tipo,
          );

          await DatabaseHelper.instance.insertarReceta(recetaFinal);
        }
      } catch (e) {
        print('❌ Error cargando recetas de $tipo: $e');
      }
    }
  }
}
