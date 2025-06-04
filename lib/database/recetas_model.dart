import 'dart:convert';

class Ingrediente {
  final String nombre;
  final String cantidad; // Puede incluir peso o volumen ej: "3/4 taza, 180 ml"

  Ingrediente({required this.nombre, required this.cantidad});

  Map<String, dynamic> toMap() {
    return {'nombre': nombre, 'cantidad': cantidad};
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      nombre: map['nombre'],
      cantidad: map['cantidad'],
    );
  }
}

class DificultadReceta {
  static const facil = 'fácil';
  static const medio = 'medio';
  static const dificil = 'difícil';
}

class TipoComida {
  static const desayuno = 'desayuno';
  static const almuerzo = 'almuerzo';
  static const cena = 'cena';
  static const snack = 'snack'; // opcional, si deseas snacks también
  static const bebida = 'bebida';
}

class Receta {
  final int? id;
  final String titulo;
  final String descripcion;
  final int calorias;
  final double proteinas;
  final double carbohidratos;
  final double grasas;
  final List<Ingrediente> ingredientes; // Lista estructurada
  final List<String> instrucciones;     // Lista estructurada de pasos
  final String infoNutricional;
  final int tiempoPreparacion; // en minutos
  final String imagenUrl;
  final String dificultad; // "fácil", "medio", "difícil"
  final String tipoComida;

  Receta({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.calorias,
    required this.proteinas,
    required this.carbohidratos,
    required this.grasas,
    required this.ingredientes,
    required this.instrucciones,
    required this.infoNutricional,
    required this.tiempoPreparacion,
    required this.imagenUrl,
    required this.dificultad,
    required this.tipoComida,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'calorias': calorias,
      'proteinas': proteinas,
      'carbohidratos': carbohidratos,
      'grasas': grasas,
      'ingredientes': jsonEncode(ingredientes.map((i) => i.toMap()).toList()),
      'instrucciones': jsonEncode(instrucciones),
      'infoNutricional': infoNutricional,
      'tiempoPreparacion': tiempoPreparacion,
      'imagenUrl': imagenUrl,
      'dificultad': dificultad,
      'tipoComida': tipoComida,
    };
  }

  factory Receta.fromMap(Map<String, dynamic> map) {
    final ingredientesRaw = map['ingredientes'];
    final instruccionesRaw = map['instrucciones'];

    final ingredientes = (ingredientesRaw is String)
        ? List<Ingrediente>.from(
        jsonDecode(ingredientesRaw).map((x) => Ingrediente.fromMap(x)))
        : List<Ingrediente>.from(
        ingredientesRaw.map((x) => Ingrediente.fromMap(x)));

    final instrucciones = (instruccionesRaw is String)
        ? List<String>.from(jsonDecode(instruccionesRaw))
        : List<String>.from(instruccionesRaw);

    return Receta(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      calorias: map['calorias'],
      proteinas: map['proteinas'].toDouble(),
      carbohidratos: map['carbohidratos'].toDouble(),
      grasas: map['grasas'].toDouble(),
      ingredientes: ingredientes,
      instrucciones: instrucciones,
      infoNutricional: map['infoNutricional'],
      tiempoPreparacion: map['tiempoPreparacion'],
      imagenUrl: map['imagenUrl'],
      dificultad: map['dificultad'],
      tipoComida: map['tipoComida'],
    );
  }
}
