import 'dart:convert';

class Deporte {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagen;
  final String icono;
  final List<CategoriaDeporte> categorias;
  final List<Curiosidad> curiosidades;

  Deporte({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.icono,
    required this.categorias,
    required this.curiosidades,
  });

  factory Deporte.fromJson(Map<String, dynamic> json) {
    return Deporte(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'] ?? '',
      icono: json['icono'] ?? '',
      categorias: json['categorias'] != null
          ? List<CategoriaDeporte>.from(
              json['categorias'].map((x) => CategoriaDeporte.fromJson(x)))
          : [],
      curiosidades: (json['curiosidades'] as List)
          .map((curiosidad) => Curiosidad.fromJson(curiosidad))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'imagen': imagen,
        'icono': icono,
        'categorias': categorias.map((x) => x.toJson()).toList(),
        'curiosidades': curiosidades.map((x) => x.toJson()).toList(),
      };
}

class CategoriaDeporte {
  final String nombre;
  final List<EjercicioDeporte> ejercicios;

  CategoriaDeporte({
    required this.nombre,
    required this.ejercicios,
  });

  factory CategoriaDeporte.fromJson(Map<String, dynamic> json) {
    return CategoriaDeporte(
      nombre: json['nombre'] ?? '',
      ejercicios: json['ejercicios'] != null
          ? List<EjercicioDeporte>.from(
              json['ejercicios'].map((x) => EjercicioDeporte.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'ejercicios': ejercicios.map((x) => x.toJson()).toList(),
      };
}

class EjercicioDeporte {
  final String titulo;
  final String descripcion;
  final String duracion;

  EjercicioDeporte({
    required this.titulo,
    required this.descripcion,
    required this.duracion,
  });

  factory EjercicioDeporte.fromJson(Map<String, dynamic> json) {
    return EjercicioDeporte(
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      duracion: json['duracion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'duracion': duracion,
      };
}

class Curiosidad {
  final String emoji;
  final String texto;

  Curiosidad({
    required this.emoji,
    required this.texto,
  });

  factory Curiosidad.fromJson(Map<String, dynamic> json) {
    return Curiosidad(
      emoji: json['emoji'] as String,
      texto: json['texto'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'texto': texto,
      };
} 