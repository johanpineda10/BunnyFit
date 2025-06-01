class Ejercicio {
  final int? id;
  final String nombre;
  final String descripcion;
  final int? calorias;
  final int? series;
  final int? repeticiones;
  final int? duracion;
  final List<String> musculos;
  final List<String> equipamiento;
  final List<String> instrucciones;
  final String consejos;
  final String dificultad;
  final int? tiempoDescanso;
  final String categoria;
  final String? imagenUrl;
  final String? icono;

  Ejercicio({
    this.id,
    required this.nombre,
    required this.descripcion,
    this.calorias,
    this.series,
    this.repeticiones,
    this.duracion,
    required this.musculos,
    required this.equipamiento,
    required this.instrucciones,
    required this.consejos,
    required this.dificultad,
    this.tiempoDescanso,
    required this.categoria,
    this.imagenUrl,
    this.icono,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'calorias': calorias ?? 0,
      'series': series ?? 0,
      'repeticiones': repeticiones ?? 0,
      'duracion': duracion,
      'musculos': musculos.join(','),
      'equipamiento': equipamiento.join(','),
      'instrucciones': instrucciones.join(','),
      'consejos': consejos,
      'dificultad': dificultad,
      'tiempoDescanso': tiempoDescanso ?? 0,
      'categoria': categoria,
      'imagenUrl': imagenUrl,
      'icono': icono,
    };
  }

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    return Ejercicio(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      calorias: map['calorias'],
      series: map['series'],
      repeticiones: map['repeticiones'],
      duracion: map['duracion'],
      musculos: map['musculos'].split(','),
      equipamiento: map['equipamiento'].split(','),
      instrucciones: map['instrucciones'].split(','),
      consejos: map['consejos'],
      dificultad: map['dificultad'],
      tiempoDescanso: map['tiempoDescanso'],
      categoria: map['categoria'],
      imagenUrl: map['imagenUrl'],
      icono: map['icono'],
    );
  }
} 