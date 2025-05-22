import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'recetas_model.dart';
import '../models/filtros_recetas.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;
  static const int _version = 4; // Actualizar la versión a 4

  // Constructor privado
  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'recetas_db.db');

    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Crear tabla de recetas
    await db.execute('''
      CREATE TABLE recetas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        imagenUrl TEXT,
        tipoComida TEXT NOT NULL,
        dificultad TEXT,
        tiempoPreparacion INTEGER,
        calorias INTEGER,
        proteinas REAL,
        carbohidratos REAL,
        grasas REAL,
        instrucciones TEXT,
        ingredientes TEXT,
        infoNutricional TEXT
      )
    ''');

    // Crear tabla de ingredientes
    await db.execute('''
      CREATE TABLE ingredientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');

    // Crear tabla de ingredientes_receta
    await db.execute('''
      CREATE TABLE ingredientes_receta (
        receta_id INTEGER NOT NULL,
        ingrediente_id INTEGER NOT NULL,
        cantidad TEXT,
        FOREIGN KEY (receta_id) REFERENCES recetas(id),
        FOREIGN KEY (ingrediente_id) REFERENCES ingredientes(id),
        PRIMARY KEY (receta_id, ingrediente_id)
      )
    ''');

    // Crear tabla de alimentos
    await db.execute('''
      CREATE TABLE alimentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        calorias REAL NOT NULL,
        proteinas REAL NOT NULL,
        carbohidratos REAL NOT NULL,
        grasas REAL NOT NULL,
        porcion_estandar TEXT NOT NULL,
        unidad_medida TEXT NOT NULL,
        categoria TEXT,
        es_alimento_comun BOOLEAN DEFAULT 1,
        fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Crear índices para optimizar búsquedas
    await db.execute('CREATE INDEX idx_receta_tipo ON recetas(tipoComida)');
    await db.execute('CREATE INDEX idx_ingrediente_nombre ON ingredientes(nombre)');
    await db.execute('CREATE INDEX idx_ingrediente_receta ON ingredientes_receta(receta_id, ingrediente_id)');
    await db.execute('CREATE INDEX idx_alimento_nombre ON alimentos(nombre)');
    await db.execute('CREATE INDEX idx_alimento_categoria ON alimentos(categoria)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración a versión 2 (tablas de ingredientes)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ingredientes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ingredientes_receta (
          receta_id INTEGER NOT NULL,
          ingrediente_id INTEGER NOT NULL,
          cantidad TEXT,
          FOREIGN KEY (receta_id) REFERENCES recetas(id),
          FOREIGN KEY (ingrediente_id) REFERENCES ingredientes(id),
          PRIMARY KEY (receta_id, ingrediente_id)
        )
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_ingrediente_nombre ON ingredientes(nombre)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_ingrediente_receta ON ingredientes_receta(receta_id, ingrediente_id)');

      // Asegurarse de que la migración de ingredientes se complete
      await _migrarIngredientes(db);
    }

    if (oldVersion < 3) {
      // Migración a versión 3 (columna infoNutricional)
      try {
        // Verificar si la columna existe
        final tableInfo = await db.rawQuery('PRAGMA table_info(recetas)');
        final hasInfoNutricional = tableInfo.any((column) => column['name'] == 'infoNutricional');

        if (!hasInfoNutricional) {
          // Agregar la columna si no existe
          await db.execute('ALTER TABLE recetas ADD COLUMN infoNutricional TEXT NOT NULL DEFAULT ""');
        }
      } catch (e) {
        print('Error durante la migración a versión 3: $e');
        // Si hay un error, intentamos recrear la tabla
        await _recrearTablaRecetas(db);
      }
    }

    if (oldVersion < 4) {
      // Migración a versión 4 (tabla de alimentos)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS alimentos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE,
          calorias REAL NOT NULL,
          proteinas REAL NOT NULL,
          carbohidratos REAL NOT NULL,
          grasas REAL NOT NULL,
          porcion_estandar TEXT NOT NULL,
          unidad_medida TEXT NOT NULL,
          categoria TEXT,
          es_alimento_comun BOOLEAN DEFAULT 1,
          fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Crear índices para la tabla de alimentos
      await db.execute('CREATE INDEX IF NOT EXISTS idx_alimento_nombre ON alimentos(nombre)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_alimento_categoria ON alimentos(categoria)');

      // Cargar alimentos comunes
      await cargarAlimentosComunes();
    }
  }

  Future<void> _recrearTablaRecetas(Database db) async {
    // Crear tabla temporal
    await db.execute('''
      CREATE TABLE recetas_temp (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        imagenUrl TEXT NOT NULL,
        tipoComida TEXT NOT NULL,
        dificultad TEXT NOT NULL,
        tiempoPreparacion INTEGER NOT NULL,
        calorias INTEGER NOT NULL,
        proteinas REAL NOT NULL,
        carbohidratos REAL NOT NULL,
        grasas REAL NOT NULL,
        instrucciones TEXT NOT NULL,
        ingredientes TEXT NOT NULL,
        infoNutricional TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Copiar datos existentes
    await db.execute('''
      INSERT INTO recetas_temp 
      SELECT id, titulo, descripcion, imagenUrl, tipoComida, dificultad, 
             tiempoPreparacion, calorias, proteinas, carbohidratos, grasas, 
             instrucciones, ingredientes, '' as infoNutricional
      FROM recetas
    ''');

    // Eliminar tabla antigua
    await db.execute('DROP TABLE recetas');

    // Renombrar tabla temporal
    await db.execute('ALTER TABLE recetas_temp RENAME TO recetas');

    // Recrear índices
    await db.execute('CREATE INDEX idx_tipo_comida ON recetas(tipoComida)');
    await db.execute('CREATE INDEX idx_dificultad ON recetas(dificultad)');
    await db.execute('CREATE INDEX idx_tiempo_preparacion ON recetas(tiempoPreparacion)');
    await db.execute('CREATE INDEX idx_calorias ON recetas(calorias)');
    await db.execute('CREATE INDEX idx_proteinas ON recetas(proteinas)');
    await db.execute('CREATE INDEX idx_carbohidratos ON recetas(carbohidratos)');
    await db.execute('CREATE INDEX idx_grasas ON recetas(grasas)');
  }

  Future<void> _migrarIngredientes(Database db) async {
    print('🔄 Iniciando migración de ingredientes...');

    // Obtener todas las recetas con sus ingredientes en JSON
    final List<Map<String, dynamic>> recetas = await db.query('recetas');
    print('📊 Total de recetas encontradas: ${recetas.length}');

    // Usar una transacción para asegurar la integridad de los datos
    await db.transaction((txn) async {
      // Primero, limpiar las tablas de ingredientes existentes
      await txn.delete('ingredientes_receta');
      await txn.delete('ingredientes');

      // Crear un mapa para ingredientes únicos
      Map<String, int> ingredientesMap = {};

      for (var receta in recetas) {
        try {
          final List<dynamic> ingredientesJson = json.decode(receta['ingredientes']);
          print('📝 Procesando ingredientes para receta: ${receta['titulo']}');

          for (var ingrediente in ingredientesJson) {
            final String nombre = ingrediente['nombre'];

            // Si el ingrediente no existe, crearlo
            if (!ingredientesMap.containsKey(nombre)) {
              final int ingredienteId = await txn.insert('ingredientes', {
                'nombre': nombre,
              });
              ingredientesMap[nombre] = ingredienteId;
            }

            // Crear la relación en ingredientes_receta
            await txn.insert('ingredientes_receta', {
              'receta_id': receta['id'],
              'ingrediente_id': ingredientesMap[nombre]!,
              'cantidad': ingrediente['cantidad'],
            });
          }
        } catch (e) {
          print('❌ Error migrando ingredientes para receta ${receta['id']}: $e');
        }
      }

      print('✅ Migración de ingredientes completada');
      print('📊 Total de ingredientes únicos: ${ingredientesMap.length}');
    });
  }

  // Método para verificar la integridad de los ingredientes
  Future<void> _verificarIntegridadIngredientes(Database db) async {
    print('🔍 Verificando integridad de ingredientes...');

    // Verificar si hay recetas sin ingredientes
    final List<Map<String, dynamic>> recetasSinIngredientes = await db.rawQuery('''
      SELECT r.* FROM recetas r
      LEFT JOIN ingredientes_receta ir ON r.id = ir.receta_id
      WHERE ir.receta_id IS NULL
    ''');

    if (recetasSinIngredientes.isNotEmpty) {
      print('⚠️ Se encontraron ${recetasSinIngredientes.length} recetas sin ingredientes');
      await _migrarIngredientes(db);
    }

    // Verificar si hay ingredientes sin recetas
    final List<Map<String, dynamic>> ingredientesSinRecetas = await db.rawQuery('''
      SELECT i.* FROM ingredientes i
      LEFT JOIN ingredientes_receta ir ON i.id = ir.ingrediente_id
      WHERE ir.ingrediente_id IS NULL
    ''');

    if (ingredientesSinRecetas.isNotEmpty) {
      print('⚠️ Se encontraron ${ingredientesSinRecetas.length} ingredientes sin recetas');
      await db.delete('ingredientes', where: 'id IN (${ingredientesSinRecetas.map((i) => i['id']).join(',')})');
    }

    print('✅ Verificación de integridad completada');
  }

  // CRUD básico para recetas:

  // Insertar receta
  Future<int> insertarReceta(Receta receta) async {
    final db = await database;
    return await db.insert('recetas', receta.toMap());
  }

  // Obtener todas las recetas
  Future<List<Receta>> obtenerRecetas() async {
    final db = await database;
    final res = await db.query('recetas');

    return res.isNotEmpty
        ? res.map((receta) => Receta.fromMap(receta)).toList()
        : [];
  }

  // Obtener receta por ID
  Future<Receta?> obtenerRecetaPorId(int id) async {
    final db = await database;
    final res = await db.query('recetas', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? Receta.fromMap(res.first) : null;
  }

  // Actualizar receta
  Future<int> actualizarReceta(Receta receta) async {
    final db = await database;
    return await db.update(
      'recetas',
      receta.toMap(),
      where: 'id = ?',
      whereArgs: [receta.id],
    );
  }

  // Eliminar receta
  Future<int> eliminarReceta(int id) async {
    final db = await database;
    return await db.delete('recetas', where: 'id = ?', whereArgs: [id]);
  }

  // Método actualizado para obtener recetas filtradas incluyendo ingredientes
  Future<List<Receta>> getRecetasFiltradas(
      String tipoComida,
      FiltrosRecetas filtros, {
        String? textoBusqueda,
      }) async {
    final db = await database;
    final List<String> condiciones = ['tipoComida = ?'];
    final List<dynamic> argumentos = [tipoComida];

    // Agregar condición de búsqueda si hay texto
    if (textoBusqueda != null && textoBusqueda.isNotEmpty) {
      condiciones.add('titulo LIKE ?');
      argumentos.add('%$textoBusqueda%');
    }

    // Agregar condiciones de filtros
    if (filtros.dificultad != null && filtros.dificultad!.isNotEmpty) {
      condiciones.add('dificultad = ?');
      argumentos.add(filtros.dificultad);
    }

    if (filtros.tiempoPreparacion != null) {
      condiciones.add('tiempoPreparacion BETWEEN ? AND ?');
      argumentos.addAll([
        filtros.tiempoPreparacion!.start.round(),
        filtros.tiempoPreparacion!.end.round(),
      ]);
    }

    if (filtros.calorias != null) {
      condiciones.add('calorias BETWEEN ? AND ?');
      argumentos.addAll([
        filtros.calorias!.start.round(),
        filtros.calorias!.end.round(),
      ]);
    }

    // Filtros de macronutrientes
    if (filtros.macros.altoProteinas) {
      condiciones.add('proteinas >= (SELECT AVG(proteinas) * 1.2 FROM recetas WHERE tipoComida = ?)');
      argumentos.add(tipoComida);
    }

    if (filtros.macros.bajoCarbohidratos) {
      condiciones.add('carbohidratos <= (SELECT AVG(carbohidratos) * 0.8 FROM recetas WHERE tipoComida = ?)');
      argumentos.add(tipoComida);
    }

    if (filtros.macros.bajoGrasas) {
      condiciones.add('grasas <= (SELECT AVG(grasas) * 0.8 FROM recetas WHERE tipoComida = ?)');
      argumentos.add(tipoComida);
    }

    if (filtros.ingredientes != null && filtros.ingredientes!.isNotEmpty) {
      final placeholders = List.generate(
        filtros.ingredientes!.length,
            (index) => '?',
      ).join(',');

      condiciones.add('''
        id IN (
          SELECT receta_id 
          FROM ingredientes_receta 
          WHERE ingrediente_id IN (
            SELECT id FROM ingredientes 
            WHERE nombre IN ($placeholders)
          )
        )
      ''');
      argumentos.addAll(filtros.ingredientes!);
    }

    final whereClause = condiciones.join(' AND ');
    final query = '''
      SELECT DISTINCT r.* FROM recetas r
      WHERE $whereClause
      ORDER BY r.titulo ASC
    ''';

    print('🔍 Query de búsqueda: $query');
    print('📝 Argumentos: $argumentos');

    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(query, argumentos);
      print('📊 Número de recetas encontradas: ${maps.length}');
      print('🥗 Filtros de macronutrientes aplicados:');
      print('   - Alto en proteínas: ${filtros.macros.altoProteinas}');
      print('   - Bajo en carbohidratos: ${filtros.macros.bajoCarbohidratos}');
      print('   - Bajo en grasas: ${filtros.macros.bajoGrasas}');
      return List.generate(maps.length, (i) => Receta.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error en la consulta SQL: $e');
      rethrow;
    }
  }

  // Método para obtener los rangos de valores para los filtros
  Future<Map<String, dynamic>> getRangosFiltros(String tipoComida) async {
    final db = await database;

    final List<Map<String, dynamic>> resultados = await db.rawQuery('''
      SELECT 
        MIN(tiempoPreparacion) as tiempoMin,
        MAX(tiempoPreparacion) as tiempoMax,
        MIN(calorias) as caloriasMin,
        MAX(calorias) as caloriasMax
      FROM recetas
      WHERE tipoComida = ?
    ''', [tipoComida]);

    return resultados.first;
  }

  // Método para obtener las dificultades disponibles
  Future<List<String>> getDificultadesDisponibles(String tipoComida) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recetas',
      distinct: true,
      columns: ['dificultad'],
      where: 'tipoComida = ?',
      whereArgs: [tipoComida],
    );
    return maps.map((map) => map['dificultad'] as String).toList();
  }

  // Método para inicializar la base de datos con datos de ejemplo si está vacía
  Future<void> initializeDatabase() async {
    final db = await database;

    // Verificar si la base de datos está vacía
    final List<Map<String, dynamic>> recetas = await db.query('recetas');
    final List<Map<String, dynamic>> ingredientes = await db.query('ingredientes');
    final List<Map<String, dynamic>> alimentos = await db.query('alimentos');

    // Si no hay recetas ni ingredientes, cargar los datos iniciales
    if (recetas.isEmpty && ingredientes.isEmpty) {
      print('📦 Base de datos vacía, cargando datos iniciales...');
      await cargarRecetasDesdeJSON();
      await cargarAlimentosComunes();
    } else if (ingredientes.isEmpty) {
      // Si hay recetas pero no ingredientes, recargar solo los ingredientes
      print('📦 Base de datos sin ingredientes, recargando ingredientes...');
      await _recargarIngredientes(db);
    } else if (alimentos.isEmpty) {
      // Si no hay alimentos, cargar los alimentos comunes
      print('📦 Base de datos sin alimentos, cargando alimentos comunes...');
      await cargarAlimentosComunes();
    } else {
      print('📦 Base de datos ya contiene datos, verificando integridad...');
      await _verificarIntegridadIngredientes(db);
    }
  }

  // Método para recargar solo los ingredientes
  Future<void> _recargarIngredientes(Database db) async {
    final tiposComida = ['desayuno', 'almuerzo', 'cena', 'snack', 'bebida'];
    Set<String> ingredientesUnicos = {};

    // Recolectar ingredientes únicos de todos los tipos de comida
    for (final tipo in tiposComida) {
      try {
        final String jsonString = await rootBundle.loadString('assets/recetas/$tipo.json');
        final List<dynamic> jsonData = json.decode(jsonString);

        for (var recetaData in jsonData) {
          final List<dynamic> ingredientes = recetaData['ingredientes'] as List;
          for (var ingrediente in ingredientes) {
            ingredientesUnicos.add(ingrediente['nombre']);
          }
        }
      } catch (e) {
        print('Error cargando ingredientes de $tipo: $e');
      }
    }

    // Insertar ingredientes únicos en una transacción
    await db.transaction((txn) async {
      for (var nombre in ingredientesUnicos) {
        await txn.insert('ingredientes', {'nombre': nombre},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });

    print('✅ Ingredientes recargados exitosamente');
  }

  // Método para cargar recetas desde archivos JSON
  Future<void> cargarRecetasDesdeJSON() async {
    final db = await database;
    final tiposComida = ['desayuno', 'almuerzo', 'cena', 'snack', 'bebida'];

    // Usar una transacción para asegurar la integridad de los datos
    await db.transaction((txn) async {
      // Primero, cargar todos los ingredientes únicos
      Set<String> ingredientesUnicos = {};
      for (final tipo in tiposComida) {
        try {
          final String jsonString = await rootBundle.loadString('assets/recetas/$tipo.json');
          final List<dynamic> jsonData = json.decode(jsonString);

          // Recolectar ingredientes únicos
          for (var recetaData in jsonData) {
            final List<dynamic> ingredientes = recetaData['ingredientes'] as List;
            for (var ingrediente in ingredientes) {
              ingredientesUnicos.add(ingrediente['nombre']);
            }
          }
        } catch (e) {
          print('Error cargando ingredientes de $tipo: $e');
        }
      }

      // Insertar ingredientes únicos
      for (var nombre in ingredientesUnicos) {
        await txn.insert('ingredientes', {'nombre': nombre},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // Crear un mapa de ingredientes para acceso rápido
      final Map<String, int> ingredientesMap = {};
      final List<Map<String, dynamic>> ingredientesDB = await txn.query('ingredientes');
      for (var ingrediente in ingredientesDB) {
        ingredientesMap[ingrediente['nombre']] = ingrediente['id'];
      }

      // Cargar recetas y sus relaciones con ingredientes
      for (final tipo in tiposComida) {
        try {
          final String jsonString = await rootBundle.loadString('assets/recetas/$tipo.json');
          final List<dynamic> jsonData = json.decode(jsonString);

          for (var recetaData in jsonData) {
            // Insertar la receta
            final int recetaId = await txn.insert('recetas', {
              'titulo': recetaData['titulo'],
              'descripcion': recetaData['descripcion'],
              'imagenUrl': recetaData['imagenUrl'],
              'tipoComida': tipo,
              'dificultad': recetaData['dificultad'],
              'tiempoPreparacion': recetaData['tiempoPreparacion'],
              'calorias': recetaData['calorias'],
              'proteinas': recetaData['proteinas'],
              'carbohidratos': recetaData['carbohidratos'],
              'grasas': recetaData['grasas'],
              'instrucciones': json.encode(recetaData['instrucciones']),
              'ingredientes': json.encode(recetaData['ingredientes']),
              'infoNutricional': recetaData['infoNutricional'] ?? '',
            });

            // Insertar relaciones con ingredientes
            final List<dynamic> ingredientes = recetaData['ingredientes'] as List;
            for (var ingrediente in ingredientes) {
              final int? ingredienteId = ingredientesMap[ingrediente['nombre']];
              if (ingredienteId != null) {
                await txn.insert('ingredientes_receta', {
                  'receta_id': recetaId,
                  'ingrediente_id': ingredienteId,
                  'cantidad': ingrediente['cantidad'],
                });
              }
            }
          }
        } catch (e) {
          print('Error cargando recetas de $tipo: $e');
        }
      }
    });

    print('✅ Datos iniciales cargados exitosamente');
  }

  // Método optimizado para obtener ingredientes disponibles
  Future<List<String>> getIngredientesDisponibles() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'ingredientes',
        columns: ['nombre'],
        orderBy: 'nombre ASC',
      );
      return maps.map((map) => map['nombre'] as String).toList();
    } catch (e) {
      print('Error obteniendo ingredientes disponibles: $e');
      return [];
    }
  }

  // Método para verificar si hay ingredientes en la base de datos
  Future<bool> tieneIngredientes() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ingredientes')
    );
    return count != null && count > 0;
  }

  // Método para verificar si la base de datos está vacía
  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM recetas')
    );
    return count == 0;
  }

  // Método para cargar alimentos comunes desde JSON
  Future<void> cargarAlimentosComunes() async {
    try {
      print('📦 Iniciando carga de alimentos comunes desde JSON...');
      final db = await database;

      // Leer el archivo JSON
      final String jsonString = await rootBundle.loadString('assets/recetas/alimentos.json');
      final List<dynamic> alimentosJson = json.decode(jsonString);

      // Usar una transacción para asegurar la integridad de los datos
      await db.transaction((txn) async {
        int alimentosInsertados = 0;
        int alimentosExistentes = 0;

        for (var alimentoData in alimentosJson) {
          try {
            // Verificar si el alimento ya existe
            final List<Map<String, dynamic>> existente = await txn.query(
              'alimentos',
              where: 'nombre = ?',
              whereArgs: [alimentoData['nombre']],
            );

            if (existente.isEmpty) {
              await txn.insert(
                'alimentos',
                {
                  ...alimentoData as Map<String, dynamic>,
                  'es_alimento_comun': 1,
                  'fecha_creacion': DateTime.now().toIso8601String(),
                },
                conflictAlgorithm: ConflictAlgorithm.ignore,
              );
              alimentosInsertados++;
            } else {
              alimentosExistentes++;
            }
          } catch (e) {
            print('❌ Error insertando alimento ${alimentoData['nombre']}: $e');
          }
        }

        print('✅ Carga de alimentos completada:');
        print('📊 Alimentos insertados: $alimentosInsertados');
        print('📊 Alimentos existentes: $alimentosExistentes');
      });
    } catch (e) {
      print('❌ Error cargando alimentos desde JSON: $e');
      rethrow;
    }
  }

  // Método para verificar si existen alimentos
  Future<bool> existenAlimentos() async {
    final db = await database;
    final result = await db.query(
      'alimentos',
      columns: ['COUNT(*) as count'],
    );
    final count = Sqflite.firstIntValue(result);
    return count != null && count > 0;
  }

  // Método para agregar un nuevo alimento
  Future<void> agregarAlimento(Map<String, dynamic> alimento) async {
    final db = await database;
    await db.insert(
        'alimentos',
        {
          ...alimento,
          'es_alimento_comun': 0, // Indica que es un alimento personalizado
        },
        conflictAlgorithm: ConflictAlgorithm.ignore
    );
  }

  // Método para buscar alimentos
  Future<List<Map<String, dynamic>>> buscarAlimentos(String query) async {
    final db = await database;
    return await db.query(
      'alimentos',
      where: 'nombre LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nombre ASC',
    );
  }

  // Método para obtener alimentos por categoría
  Future<List<Map<String, dynamic>>> getAlimentosPorCategoria(String categoria) async {
    final db = await database;
    return await db.query(
      'alimentos',
      where: 'categoria = ?',
      whereArgs: [categoria],
      orderBy: 'nombre ASC',
    );
  }

  // Método para obtener un alimento por ID
  Future<Map<String, dynamic>?> getAlimentoPorId(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'alimentos',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Método para actualizar un alimento
  Future<void> actualizarAlimento(int id, Map<String, dynamic> datos) async {
    final db = await database;
    await db.update(
      'alimentos',
      datos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para eliminar un alimento
  Future<void> eliminarAlimento(int id) async {
    final db = await database;
    await db.delete(
      'alimentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para obtener categorías de alimentos
  Future<List<String>> getCategoriasAlimentos() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'alimentos',
      distinct: true,
      columns: ['categoria'],
      where: 'categoria IS NOT NULL',
      orderBy: 'categoria ASC',
    );
    return results.map((map) => map['categoria'] as String).toList();
  }

  // Método para verificar si un alimento existe
  Future<bool> existeAlimento(String nombre) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'alimentos',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    return results.isNotEmpty;
  }

  // Método para buscar alimentos por título
  Future<List<Map<String, dynamic>>> buscarAlimentosPorTitulo(String query, {String? categoria}) async {
    final db = await database;
    String sql = '''
      SELECT * FROM alimentos 
      WHERE nombre LIKE ?
    ''';
    List<dynamic> args = ['%$query%'];

    if (categoria != null) {
      sql += ' AND categoria = ?';
      args.add(categoria);
    }

    sql += ' ORDER BY nombre COLLATE NOCASE ASC LIMIT 50';

    try {
      final List<Map<String, dynamic>> resultados = await db.rawQuery(sql, args);
      return resultados;
    } catch (e) {
      print('Error en buscarAlimentosPorTitulo: $e');
      return [];
    }
  }
}
