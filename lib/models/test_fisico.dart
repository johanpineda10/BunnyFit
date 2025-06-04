import 'test_detail.dart';

class Formula {
  final String nombre;
  final String descripcion;
  final String formula;
  final Map<String, String> variables;

  const Formula({
    required this.nombre,
    required this.descripcion,
    required this.formula,
    required this.variables,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    return Formula(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      formula: json['formula'] as String,
      variables: Map<String, String>.from(json['variables'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'formula': formula,
      'variables': variables,
    };
  }
}

class TestFisico {
  final String id;
  final String nombre;
  final String objetivo;
  final List<String> dificultad;
  final List<String> categorias;
  final List<String> comoRealizar;
  final List<String> equipamientoNecesario;
  final String duracion;
  final List<String> precauciones;
  final List<String> consejos;
  final List<Formula>? formulas;

  TestFisico({
    required this.id,
    required this.nombre,
    required this.objetivo,
    required this.dificultad,
    required this.categorias,
    required this.comoRealizar,
    required this.equipamientoNecesario,
    required this.duracion,
    required this.precauciones,
    required this.consejos,
    this.formulas,
  });

  factory TestFisico.fromJson(Map<String, dynamic> json) {
    return TestFisico(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] as String,
      objetivo: json['objetivo'] as String,
      dificultad: List<String>.from(json['dificultad'] as List),
      categorias: List<String>.from(json['categorias'] as List),
      comoRealizar: List<String>.from(json['como_realizar'] as List),
      equipamientoNecesario: List<String>.from(json['equipamiento_necesario'] as List),
      duracion: json['duracion'] as String,
      precauciones: List<String>.from(json['precauciones'] as List),
      consejos: List<String>.from(json['consejos'] as List),
      formulas: json['formulas'] != null
          ? (json['formulas'] as List)
              .map((e) => Formula.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'objetivo': objetivo,
      'dificultad': dificultad,
      'categorias': categorias,
      'como_realizar': comoRealizar,
      'equipamiento_necesario': equipamientoNecesario,
      'duracion': duracion,
      'precauciones': precauciones,
      'consejos': consejos,
      if (formulas != null) 'formulas': formulas!.map((e) => e.toJson()).toList(),
    };
  }

  TestDetail toTestDetail() {
    return TestDetail(
      id: id,
      nombre: nombre,
      objetivo: objetivo,
      descripcion: objetivo,
      duracion: duracion,
      categoria: categorias.isNotEmpty ? categorias.first : '',
      pasos: comoRealizar,
      precauciones: precauciones,
      consejos: consejos,
      formulas: formulas,
      parametros: {
        'dificultad': dificultad,
        'equipamiento': equipamientoNecesario.join(', '),
      },
    );
  }
} 