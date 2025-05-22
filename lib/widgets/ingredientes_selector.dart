import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class IngredientesSelector extends StatefulWidget {
  final List<String> ingredientesSeleccionados;
  final Function(List<String>) onIngredientesChanged;
  final String? hintText;

  const IngredientesSelector({
    Key? key,
    required this.ingredientesSeleccionados,
    required this.onIngredientesChanged,
    this.hintText,
  }) : super(key: key);

  @override
  State<IngredientesSelector> createState() => _IngredientesSelectorState();
}

class _IngredientesSelectorState extends State<IngredientesSelector> {
  final TextEditingController _controller = TextEditingController();
  List<String> _ingredientesDisponibles = [];
  List<String> _sugerencias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarIngredientes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cargarIngredientes() async {
    setState(() => _isLoading = true);
    try {
      _ingredientesDisponibles = await DatabaseHelper.instance.getIngredientesDisponibles();
    } catch (e) {
      print('Error cargando ingredientes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _actualizarSugerencias(String query) {
    if (query.isEmpty) {
      setState(() => _sugerencias = []);
      return;
    }

    final queryLower = query.toLowerCase();
    setState(() {
      _sugerencias = _ingredientesDisponibles
          .where((ingrediente) =>
      ingrediente.toLowerCase().contains(queryLower) &&
          !widget.ingredientesSeleccionados.contains(ingrediente))
          .toList();
    });
  }

  void _agregarIngrediente(String ingrediente) {
    if (!widget.ingredientesSeleccionados.contains(ingrediente)) {
      final nuevosIngredientes = [...widget.ingredientesSeleccionados, ingrediente];
      widget.onIngredientesChanged(nuevosIngredientes);
      _controller.clear();
      setState(() => _sugerencias = []);
    }
  }

  void _eliminarIngrediente(String ingrediente) {
    final nuevosIngredientes = widget.ingredientesSeleccionados
        .where((i) => i != ingrediente)
        .toList();
    widget.onIngredientesChanged(nuevosIngredientes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _ingredientesDisponibles.where((ingrediente) =>
            ingrediente.toLowerCase()
                .contains(textEditingValue.text.toLowerCase()) &&
                !widget.ingredientesSeleccionados.contains(ingrediente));
          },
          onSelected: _agregarIngrediente,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Buscar ingrediente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.ingredientesSeleccionados.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.ingredientesSeleccionados.map((ingrediente) {
              return Chip(
                label: Text(ingrediente),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _eliminarIngrediente(ingrediente),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
} 