import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deporte.dart';

class DeportesService {
  static const String _cacheKey = 'deportes_cache';
  static List<Deporte>? _deportesCache;

  /// Carga los deportes desde el caché o el archivo JSON si es necesario
  static Future<List<Deporte>> getDeportes() async {
    // Si ya están en memoria, retornarlos
    if (_deportesCache != null) {
      print('🏃‍♂️ Deportes: Usando datos de memoria');
      return _deportesCache!;
    }

    // Intentar cargar desde SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        _deportesCache = jsonList.map((json) => Deporte.fromJson(json)).toList();
        print('📱 Deportes: Datos cargados desde caché local');
        return _deportesCache!;
      } catch (e) {
        print('❌ Error al cargar deportes desde caché: $e');
        // Si hay error, cargar desde JSON
      }
    }

    // Si no hay caché, cargar desde el archivo JSON
    print('🆕 Deportes: Dispositivo nuevo detectado - Cargando datos desde JSON');
    final String jsonContent = await rootBundle.loadString('assets/deportes/deportes.json');
    final List<dynamic> jsonList = json.decode(jsonContent);
    _deportesCache = jsonList.map((json) => Deporte.fromJson(json)).toList();
    
    // Guardar en SharedPreferences
    await prefs.setString(_cacheKey, jsonContent);
    
    print('✅ Deportes: ${_deportesCache!.length} deportes cargados y guardados en caché');
    return _deportesCache!;
  }

  /// Limpia la caché de deportes
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    _deportesCache = null;
    print('🗑️ Deportes: Caché limpiada');
  }

  /// Verifica si hay datos en caché
  static Future<bool> hasCachedData() async {
    if (_deportesCache != null) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey);
  }
} 