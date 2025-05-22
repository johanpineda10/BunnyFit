import 'package:flutter/material.dart';
import '../models/filtros_recetas.dart';
import '../database/database_helper.dart';
import 'comida_modal_sheet.dart';
import '../enums/vista_recetas.dart';
import 'ingredientes_selector.dart';

class FiltrosModalSheet extends StatefulWidget {
  final String tipoComida;
  final FiltrosRecetas filtrosActuales;
  final Function(FiltrosRecetas) onFiltrosAplicados;
  final VistaRecetas vistaActual;
  final Function(VistaRecetas) onVistaCambiada;
  final Map<String, double> rangos;
  final List<String> dificultades;

  const FiltrosModalSheet({
    Key? key,
    required this.tipoComida,
    required this.filtrosActuales,
    required this.onFiltrosAplicados,
    required this.vistaActual,
    required this.onVistaCambiada,
    required this.rangos,
    required this.dificultades,
  }) : super(key: key);

  @override
  _FiltrosModalSheetState createState() => _FiltrosModalSheetState();
}

class _FiltrosModalSheetState extends State<FiltrosModalSheet> {
  late FiltrosRecetas _filtros;
  late RangeValues _tiempoPreparacion;
  late RangeValues _calorias;
  List<String> _dificultadesDisponibles = [];
  List<String> _ingredientesSeleccionados = [];

  @override
  void initState() {
    super.initState();
    _filtros = widget.filtrosActuales;
    _tiempoPreparacion = widget.filtrosActuales.tiempoPreparacion ?? RangeValues(
      widget.rangos['tiempoMin']!,
      widget.rangos['tiempoMax']!,
    );
    _calorias = widget.filtrosActuales.calorias ?? RangeValues(
      widget.rangos['caloriasMin']!,
      widget.rangos['caloriasMax']!,
    );
    _ingredientesSeleccionados = widget.filtrosActuales.ingredientes ?? [];
    _dificultadesDisponibles = widget.dificultades;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Barra superior con indicador de arrastre
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filtros y Vista",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de Tipo de Vista
                  Text(
                    "Tipo de Vista",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildVistaOption(
                          icon: Icons.swipe,
                          label: "Vista Swipe",
                          isSelected: _filtros.vista == VistaRecetas.swipe,
                          onTap: () {
                            setState(() {
                              _filtros = _filtros.copyWith(
                                vista: VistaRecetas.swipe,
                              );
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildVistaOption(
                          icon: Icons.list,
                          label: "Vista Lista",
                          isSelected: _filtros.vista == VistaRecetas.scroll,
                          onTap: () {
                            setState(() {
                              _filtros = _filtros.copyWith(
                                vista: VistaRecetas.scroll,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 24),

                  // Sección de Dificultad
                  _buildSeccionDificultad(),
                  SizedBox(height: 24),

                  // Sección de Tiempo de Preparación
                  _buildSeccionTiempoPreparacion(),
                  SizedBox(height: 24),

                  // Sección de Calorías
                  _buildSeccionCalorias(),
                  SizedBox(height: 24),

                  // Sección de Ingredientes
                  Text(
                    'Filtrar por ingredientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  IngredientesSelector(
                    ingredientesSeleccionados: _ingredientesSeleccionados,
                    onIngredientesChanged: (ingredientes) {
                      setState(() {
                        _ingredientesSeleccionados = ingredientes;
                      });
                    },
                    hintText: 'Buscar ingrediente para filtrar...',
                  ),
                  SizedBox(height: 24),

                  // Sección de Macronutrientes
                  Text(
                    'Macronutrientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMacronutrientesSection(),
                  SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _limpiarFiltros,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[800],
                          ),
                          child: Text('Limpiar Filtros'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _aplicarFiltros,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVistaOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionDificultad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dificultad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dificultadesDisponibles.map((dificultad) {
            final isSelected = _filtros.dificultad == dificultad;
            return FilterChip(
              label: Text(dificultad.capitalize()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filtros = _filtros.copyWith(
                    dificultad: selected ? dificultad : null,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeccionTiempoPreparacion() {
    final min = widget.rangos['tiempoMin']!;
    final max = widget.rangos['tiempoMax']!;
    final values = RangeValues(
      _tiempoPreparacion.start.clamp(min, max).toDouble(),
      _tiempoPreparacion.end.clamp(min, max).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiempo de Preparación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: 12,
          labels: RangeLabels(
            '${values.start.round()} min',
            '${values.end.round()} min',
          ),
          onChanged: (newValues) {
            setState(() {
              _tiempoPreparacion = newValues;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${values.start.round()} min'),
              Text('${values.end.round()} min'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionCalorias() {
    final min = widget.rangos['caloriasMin']!;
    final max = widget.rangos['caloriasMax']!;
    final values = RangeValues(
      _calorias.start.clamp(min, max).toDouble(),
      _calorias.end.clamp(min, max).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calorías',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: 20,
          labels: RangeLabels(
            '${values.start.round()} kcal',
            '${values.end.round()} kcal',
          ),
          onChanged: (newValues) {
            setState(() {
              _calorias = newValues;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${values.start.round()} kcal'),
              Text('${values.end.round()} kcal'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacronutrientesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildMacroChip(
          label: 'Alto en proteínas',
          icon: Icons.fitness_center,
          isSelected: _filtros.macros.altoProteinas,
          onSelected: (selected) {
            setState(() {
              _filtros = _filtros.copyWith(
                macros: _filtros.macros.copyWith(
                  altoProteinas: selected,
                ),
              );
            });
          },
        ),
        _buildMacroChip(
          label: 'Bajo en carbohidratos',
          icon: Icons.grain,
          isSelected: _filtros.macros.bajoCarbohidratos,
          onSelected: (selected) {
            setState(() {
              _filtros = _filtros.copyWith(
                macros: _filtros.macros.copyWith(
                  bajoCarbohidratos: selected,
                ),
              );
            });
          },
        ),
        _buildMacroChip(
          label: 'Bajo en grasas',
          icon: Icons.opacity,
          isSelected: _filtros.macros.bajoGrasas,
          onSelected: (selected) {
            setState(() {
              _filtros = _filtros.copyWith(
                macros: _filtros.macros.copyWith(
                  bajoGrasas: selected,
                ),
              );
            });
          },
        ),
        _buildMacroChip(
          label: 'Equilibrado',
          icon: Icons.balance,
          isSelected: false,
          onSelected: null, // No interactuable
          backgroundColor: Colors.grey[100],
        ),
      ],
    );
  }

  Widget _buildMacroChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    Function(bool)? onSelected,
    Color? backgroundColor,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: backgroundColor ?? Colors.grey[50],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[800],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _filtros = FiltrosRecetas(
        macros: FiltrosMacros(),
        vista: widget.vistaActual,
      );
      _tiempoPreparacion = RangeValues(
        widget.rangos['tiempoMin']!,
        widget.rangos['tiempoMax']!,
      );
      _calorias = RangeValues(
        widget.rangos['caloriasMin']!,
        widget.rangos['caloriasMax']!,
      );
      _ingredientesSeleccionados = [];
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Filtros limpiados con éxito'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Aplicar los filtros limpios automáticamente
    final nuevosFiltros = FiltrosRecetas(vista: widget.vistaActual);
    widget.onFiltrosAplicados(nuevosFiltros);
    Navigator.pop(context);
  }

  void _aplicarFiltros() {
    final nuevosFiltros = FiltrosRecetas(
      dificultad: _filtros.dificultad,
      tiempoPreparacion: _tiempoPreparacion,
      calorias: _calorias,
      macros: _filtros.macros,
      ingredientes: _ingredientesSeleccionados,
      vista: _filtros.vista,
    );
    widget.onFiltrosAplicados(nuevosFiltros);
    Navigator.pop(context);
  }
} 