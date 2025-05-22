import 'package:flutter/material.dart';
import '../enums/vista_recetas.dart';

class FiltrosMacros {
  final bool altoProteinas;
  final bool bajoCarbohidratos;
  final bool bajoGrasas;

  const FiltrosMacros({
    this.altoProteinas = false,
    this.bajoCarbohidratos = false,
    this.bajoGrasas = false,
  });

  bool get tieneAlgunFiltroActivo => 
    altoProteinas || bajoCarbohidratos || bajoGrasas;

  FiltrosMacros copyWith({
    bool? altoProteinas,
    bool? bajoCarbohidratos,
    bool? bajoGrasas,
  }) {
    return FiltrosMacros(
      altoProteinas: altoProteinas ?? this.altoProteinas,
      bajoCarbohidratos: bajoCarbohidratos ?? this.bajoCarbohidratos,
      bajoGrasas: bajoGrasas ?? this.bajoGrasas,
    );
  }
}

class FiltrosRecetas {
  final String? dificultad;
  final RangeValues? tiempoPreparacion;
  final RangeValues? calorias;
  final FiltrosMacros macros;
  final List<String>? ingredientes;
  final VistaRecetas vista;

  FiltrosRecetas({
    this.dificultad,
    this.tiempoPreparacion,
    this.calorias,
    this.macros = const FiltrosMacros(),
    this.ingredientes,
    this.vista = VistaRecetas.swipe,
  });

  FiltrosRecetas copyWith({
    String? dificultad,
    RangeValues? tiempoPreparacion,
    RangeValues? calorias,
    FiltrosMacros? macros,
    List<String>? ingredientes,
    VistaRecetas? vista,
  }) {
    return FiltrosRecetas(
      dificultad: dificultad ?? this.dificultad,
      tiempoPreparacion: tiempoPreparacion ?? this.tiempoPreparacion,
      calorias: calorias ?? this.calorias,
      macros: macros ?? this.macros,
      ingredientes: ingredientes ?? this.ingredientes,
      vista: vista ?? this.vista,
    );
  }

  bool get tieneAlgunFiltroActivo {
    return dificultad != null ||
        tiempoPreparacion != null ||
        calorias != null ||
        macros.tieneAlgunFiltroActivo ||
        (ingredientes?.isNotEmpty ?? false);
  }

  Map<String, dynamic> toMap() {
    return {
      'dificultad': dificultad,
      'tiempoPreparacionMin': tiempoPreparacion?.start.round(),
      'tiempoPreparacionMax': tiempoPreparacion?.end.round(),
      'caloriasMin': calorias?.start.round(),
      'caloriasMax': calorias?.end.round(),
      'altoProteinas': macros.altoProteinas,
      'bajoCarbohidratos': macros.bajoCarbohidratos,
      'bajoGrasas': macros.bajoGrasas,
      'ingredientes': ingredientes,
      'vista': vista.toString(),
    };
  }
} 