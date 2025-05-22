import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_fisico.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TestFisicoService {
  static const String _cacheKey = 'tests_fisicos_cache';
  static const String _lastUpdateKey = 'tests_fisicos_last_update';
  static const Duration _cacheDuration = Duration(days: 7);
  static const String _jsonPath = 'assets/tests_fisicos/tests_fisicos.json';

  List<TestFisico>? _cachedTests;
  DateTime? _lastUpdate;
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tests_fisicos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await _createTables(db);
      },
    );
  }

  Future<List<TestFisico>> getTestsFisicos() async {
    if (_cachedTests != null) {
      print('📊 ${_cachedTests!.length} tests físicos disponibles en la base de datos');
      return _cachedTests!;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastUpdateStr = prefs.getString(_lastUpdateKey);
    final cachedData = prefs.getString(_cacheKey);

    if (lastUpdateStr != null && cachedData != null) {
      final lastUpdate = DateTime.parse(lastUpdateStr);
      if (DateTime.now().difference(lastUpdate) < _cacheDuration) {
        try {
          final Map<String, dynamic> jsonData = json.decode(cachedData);
          _cachedTests = _parseTestsFromJson(jsonData);
          print('📊 ${_cachedTests!.length} tests físicos disponibles en la base de datos');
          return _cachedTests!;
        } catch (e) {
          print('❌ Error al decodificar datos en caché: $e');
          // Si hay error en el caché, recargar desde JSON
          return await _loadTestsFromJson();
        }
      }
    }

    print('📊 No hay tests físicos en la base de datos, cargando desde JSON...');
    return await _loadTestsFromJson();
  }

  Future<List<TestFisico>> getTestsByCategoria(String categoria) async {
    try {
      final tests = await getTestsFisicos();
      final categoriaNormalizada = _normalizarTexto(categoria);
      final filteredTests = tests.where((test) {
        return test.categorias.any((cat) => _normalizarTexto(cat) == categoriaNormalizada);
      }).toList();
      
      print('📊 ${filteredTests.length} tests físicos encontrados en la categoría "$categoria"');
      if (filteredTests.isNotEmpty) {
        print('📋 Tests encontrados: ${filteredTests.map((t) => t.nombre).join(', ')}');
      }
      return filteredTests;
    } catch (e) {
      print('❌ Error al filtrar tests por categoría: $e');
      return [];
    }
  }

  String _normalizarTexto(String texto) {
    return texto.toLowerCase().trim();
  }

  Future<List<TestFisico>> _loadTestsFromJson() async {
    try {
      print('🔄 Cargando tests físicos desde JSON...');
      final String jsonString = await rootBundle.loadString(_jsonPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cachedTests = _parseTestsFromJson(jsonData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());

      print('✅ ${_cachedTests!.length} tests físicos guardados en la base de datos');
      return _cachedTests!;
    } catch (e) {
      print('❌ Error al cargar los tests físicos: $e');
      rethrow;
    }
  }

  List<TestFisico> _parseTestsFromJson(Map<String, dynamic> jsonData) {
    try {
      final testsList = jsonData['tests'] as List;
      final tests = testsList.map((test) => TestFisico.fromJson(test)).toList();
      print('📋 Tests cargados: ${tests.map((t) => '${t.nombre} (${t.categorias.join(', ')})').join('\n')}');
      return tests;
    } catch (e) {
      print('❌ Error al parsear tests desde JSON: $e');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
      _cachedTests = null;
      _lastUpdate = null;
      print('🗑️ Base de datos de tests físicos limpiada');
    } catch (e) {
      print('❌ Error al limpiar caché: $e');
    }
  }

  Future<DateTime?> getLastUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateStr = prefs.getString(_lastUpdateKey);
      if (lastUpdateStr != null) {
        return DateTime.parse(lastUpdateStr);
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener última actualización: $e');
      return null;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tests_fisicos (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        objetivo TEXT NOT NULL,
        dificultad TEXT NOT NULL,
        categorias TEXT NOT NULL,
        como_realizar TEXT NOT NULL,
        equipamiento_necesario TEXT NOT NULL,
        duracion TEXT NOT NULL,
        precauciones TEXT NOT NULL,
        consejos TEXT NOT NULL,
        formulas TEXT
      )
    ''');
  }

  Future<void> saveTestFisico(TestFisico test) async {
    final db = await _database;
    await db.insert(
      'tests_fisicos',
      {
        'id': test.id,
        'nombre': test.nombre,
        'objetivo': test.objetivo,
        'dificultad': jsonEncode(test.dificultad),
        'categorias': jsonEncode(test.categorias),
        'como_realizar': jsonEncode(test.comoRealizar),
        'equipamiento_necesario': jsonEncode(test.equipamientoNecesario),
        'duracion': test.duracion,
        'precauciones': jsonEncode(test.precauciones),
        'consejos': jsonEncode(test.consejos),
        'formulas': test.formulas != null ? jsonEncode(test.formulas!.map((e) => e.toJson()).toList()) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TestFisico?> getTestFisico(String id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tests_fisicos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;
    return TestFisico(
      id: map['id'],
      nombre: map['nombre'],
      objetivo: map['objetivo'],
      dificultad: List<String>.from(jsonDecode(map['dificultad'])),
      categorias: List<String>.from(jsonDecode(map['categorias'])),
      comoRealizar: List<String>.from(jsonDecode(map['como_realizar'])),
      equipamientoNecesario: List<String>.from(jsonDecode(map['equipamiento_necesario'])),
      duracion: map['duracion'],
      precauciones: List<String>.from(jsonDecode(map['precauciones'])),
      consejos: List<String>.from(jsonDecode(map['consejos'])),
      formulas: map['formulas'] != null
          ? List<Formula>.from(
              (jsonDecode(map['formulas']) as List)
                  .map((e) => Formula.fromJson(e as Map<String, dynamic>)))
          : null,
    );
  }
} 