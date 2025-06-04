import 'test_fisico.dart';

class TestDetail {
  final String id;
  final String nombre;
  final String objetivo;
  final String descripcion;
  final String duracion;
  final String categoria;
  final List<String> pasos;
  final List<String> precauciones;
  final List<String> consejos;
  final List<Formula>? formulas;
  final Map<String, dynamic> parametros;

  const TestDetail({
    required this.id,
    required this.nombre,
    required this.objetivo,
    required this.descripcion,
    required this.duracion,
    required this.categoria,
    required this.pasos,
    required this.precauciones,
    required this.consejos,
    this.formulas,
    required this.parametros,
  });

  factory TestDetail.fromJson(Map<String, dynamic> json) {
    return TestDetail(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] as String,
      objetivo: json['objetivo'] as String,
      descripcion: json['descripcion'] as String,
      duracion: json['duracion'] as String,
      categoria: json['categoria'] as String,
      pasos: List<String>.from(json['pasos'] as List),
      precauciones: List<String>.from(json['precauciones'] as List),
      consejos: List<String>.from(json['consejos'] as List),
      formulas: json['formulas'] != null ? List<Formula>.from(json['formulas'] as List) : null,
      parametros: json['parametros'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'objetivo': objetivo,
      'descripcion': descripcion,
      'duracion': duracion,
      'categoria': categoria,
      'pasos': pasos,
      'precauciones': precauciones,
      'consejos': consejos,
      'formulas': formulas,
      'parametros': parametros,
    };
  }
} 