import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherService {
  static const String _apiKey = "439555101ac86d634ee481bcb4626ef4";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  
  // 🔹 Claves para SharedPreferences
  static const String _lastTemperatureKey = "last_temperature";
  static const String _lastUpdateKey = "last_update";
  static const String _lastRealDateKey = "last_real_date";
  
  // 🔹 Instancia singleton
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // 🔹 Método para obtener la temperatura actual
  Future<double?> getCurrentTemperature() async {
    try {
      // 🔹 Verificar si podemos hacer una nueva llamada
      if (!await _canMakeNewCall()) {
        return await _getCachedTemperature();
      }

      // 🔹 Obtener ubicación
      final position = await _getCurrentLocation();
      
      // 🔹 Hacer llamada a la API
      final response = await http.get(Uri.parse(
        "$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric"
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temperature = data['main']['temp'].toDouble();
        
        // 🔹 Guardar en caché
        await _cacheTemperature(temperature);
        
        return temperature;
      }
      
      return null;
    } catch (e) {
      print("Error al obtener temperatura: $e");
      return await _getCachedTemperature();
    }
  }

  // 🔹 Obtener ubicación actual
  Future<Position> _getCurrentLocation() async {
    // 🔹 Verificar y solicitar permisos de ubicación
    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    // 🔹 Verificar si los servicios de ubicación están habilitados
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados');
    }

    // 🔹 Obtener la ubicación
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      throw Exception('Error al obtener la ubicación: $e');
    }
  }

  // 🔹 Verificar si podemos hacer una nueva llamada
  Future<bool> _canMakeNewCall() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 🔹 Obtener última fecha real
    final lastRealDate = prefs.getString(_lastRealDateKey);
    final currentRealDate = DateTime.now().toIso8601String().split('T')[0];
    
    // 🔹 Si no hay fecha real guardada, guardar la actual
    if (lastRealDate == null) {
      await prefs.setString(_lastRealDateKey, currentRealDate);
      return true;
    }
    
    // 🔹 Si la fecha real actual es diferente a la última guardada
    if (currentRealDate != lastRealDate) {
      // 🔹 Verificar si han pasado 24 horas desde la última actualización
      final lastUpdate = DateTime.parse(prefs.getString(_lastUpdateKey)!);
      final now = DateTime.now();
      
      if (now.difference(lastUpdate).inHours >= 24) {
        await prefs.setString(_lastRealDateKey, currentRealDate);
        return true;
      }
    }
    
    return false;
  }

  // 🔹 Obtener temperatura en caché
  Future<double?> _getCachedTemperature() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lastTemperatureKey);
  }

  // 🔹 Guardar temperatura en caché
  Future<void> _cacheTemperature(double temperature) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastTemperatureKey, temperature);
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  // 🔹 Método para limpiar caché (útil para pruebas)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastTemperatureKey);
    await prefs.remove(_lastUpdateKey);
    await prefs.remove(_lastRealDateKey);
  }
} 