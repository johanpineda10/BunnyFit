import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'filtros_modal_sheet.dart';
import '../database/database_helper.dart';
import '../database/recetas_model.dart';
import 'receta_detalle_screen.dart';
import '../models/filtros_recetas.dart';
import '../enums/vista_recetas.dart';
import 'dart:isolate';

// 🔹 Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

enum VistaModal {
  lista,
  buscar,
  recetas,
}

class ComidaModalSheet extends StatefulWidget {
  final String tipoComida;
  final String? categoriaInicial;

  const ComidaModalSheet({
    Key? key,
    required this.tipoComida,
    this.categoriaInicial,
  }) : super(key: key);

  @override
  State<ComidaModalSheet> createState() => _ComidaModalSheetState();
}

class _ComidaModalSheetState extends State<ComidaModalSheet> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _selectorScrollController = ScrollController();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _alimentoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  bool _isScrollControllerAttached = false;
  bool _isSelectorScrollControllerAttached = false;
  bool _isPageControllerAttached = false;

  String _categoriaSeleccionada = '';
  bool _mostrarFormulario = false;
  String _unidadSeleccionada = 'g';
  List<Map<String, dynamic>> _sugerenciasAlimentos = [];
  Map<String, dynamic>? _alimentoSeleccionado;
  final FocusNode _alimentoFocusNode = FocusNode();

  final List<String> categorias = ["Desayuno", "Almuerzo", "Cena", "Snacks"];
  int _currentIndex = 0;
  VistaModal _vistaActual = VistaModal.lista;
  String _tipoComidaSeleccionado = 'desayuno';
  List<Receta> _recetas = [];
  bool _cargandoRecetas = false;
  bool _inicializandoDB = false;
  String? _errorInicializacion;
  FiltrosRecetas _filtrosActuales = FiltrosRecetas();
  String _textoBusqueda = '';

  // Variables de estado para la búsqueda
  List<Map<String, dynamic>> _alimentosEncontrados = [];
  bool _buscandoAlimentos = false;
  String _textoBusquedaAlimentos = '';

  final List<Map<String, dynamic>> _tiposComida = [
    {'tipo': 'desayuno', 'icono': Icons.wb_sunny},
    {'tipo': 'almuerzo', 'icono': Icons.restaurant},
    {'tipo': 'cena', 'icono': Icons.nights_stay},
    {'tipo': 'snack', 'icono': Icons.cake},
  ];

  final Map<String, String> _categoriaToTipoComida = {
    'Desayuno': 'desayuno',
    'Almuerzo': 'almuerzo',
    'Cena': 'cena',
    'Snacks': 'snack',
  };

  final Map<String, double> _tiposComidaAncho = {
    'desayuno': 120.0,
    'almuerzo': 120.0,
    'cena': 100.0,
    'snack': 100.0,
    'bebida': 100.0,
  };

  // Variables para el selector de categorías
  final ScrollController _categoriasScrollController = ScrollController();
  bool _mostrarVistaExpandida = false;
  String _categoriaSeleccionadaAlimentos = 'todos';

  // Lista de categorías de alimentos con sus iconos
  final List<Map<String, dynamic>> _categoriasAlimentos = [
    {'id': 'todos', 'nombre': 'Todos', 'icono': Icons.all_inclusive},
    {'id': 'cereales', 'nombre': 'Cereales', 'icono': Icons.grain},
    {'id': 'frutas', 'nombre': 'Frutas', 'icono': Icons.apple},
    {'id': 'verduras', 'nombre': 'Verduras', 'icono': Icons.eco},
    {'id': 'proteinas', 'nombre': 'Proteínas', 'icono': Icons.fitness_center},
    {'id': 'lacteos', 'nombre': 'Lácteos', 'icono': Icons.local_drink},
    {'id': 'carnes', 'nombre': 'Carnes', 'icono': Icons.restaurant},
    {'id': 'pescados', 'nombre': 'Pescados', 'icono': Icons.water},
    {'id': 'huevos', 'nombre': 'Huevos', 'icono': Icons.egg},
    {'id': 'legumbres', 'nombre': 'Legumbres', 'icono': Icons.agriculture},
    {'id': 'frutos_secos', 'nombre': 'Frutos Secos', 'icono': Icons.forest},
    {'id': 'aceites', 'nombre': 'Aceites', 'icono': Icons.water_drop},
    {'id': 'bebidas', 'nombre': 'Bebidas', 'icono': Icons.local_cafe},
    {'id': 'snacks', 'nombre': 'Snacks', 'icono': Icons.cake},
    {'id': 'postres', 'nombre': 'Postres', 'icono': Icons.icecream},
    {'id': 'salsas', 'nombre': 'Salsas', 'icono': Icons.liquor},
    {'id': 'condimentos', 'nombre': 'Condimentos', 'icono': Icons.spa},
    {'id': 'panaderia', 'nombre': 'Panadería', 'icono': Icons.bakery_dining},
    {'id': 'otros', 'nombre': 'Otros', 'icono': Icons.more_horiz},
  ];

  // Lista de categorías visibles inicialmente (primeras 5 + botón "Ver todas")
  List<Map<String, dynamic>> get _categoriasVisibles {
    if (_mostrarVistaExpandida) {
      return _categoriasAlimentos;
    }
    return [..._categoriasAlimentos.take(5), {'id': 'ver_todas', 'nombre': 'Ver todas', 'icono': Icons.more_horiz}];
  }

  List<Map<String, dynamic>> _getTiposComidaOrdenados() {
    final List<Map<String, dynamic>> ordenados = [];
    final int indexSeleccionado = _tiposComida.indexWhere((item) => item['tipo'] == _tipoComidaSeleccionado);

    for (int i = indexSeleccionado; i < _tiposComida.length; i++) {
      ordenados.add(_tiposComida[i]);
    }

    for (int i = 0; i < indexSeleccionado; i++) {
      ordenados.add(_tiposComida[i]);
    }

    return ordenados;
  }

  // Lista temporal para almacenar los alimentos agregados por categoría
  final Map<String, List<Map<String, dynamic>>> _alimentosAgregados = {
    'Desayuno': [],
    'Almuerzo': [],
    'Cena': [],
    'Snacks': [],
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    _categoriaSeleccionada = widget.categoriaInicial ?? '';
    _tipoComidaSeleccionado = widget.tipoComida;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inicializarBaseDatos();
      }
    });

    _configurarControladores();
  }

  void _initializeControllers() {
    _scrollController.addListener(_checkScrollControllerAttachment);
    _selectorScrollController.addListener(_checkSelectorScrollControllerAttachment);
    _pageController.addListener(_checkPageControllerAttachment);
  }

  void _checkScrollControllerAttachment() {
    if (_scrollController.hasClients && !_isScrollControllerAttached) {
      setState(() => _isScrollControllerAttached = true);
    }
  }

  void _checkSelectorScrollControllerAttachment() {
    if (_selectorScrollController.hasClients && !_isSelectorScrollControllerAttached) {
      setState(() => _isSelectorScrollControllerAttached = true);
    }
  }

  void _checkPageControllerAttachment() {
    if (_pageController.hasClients && !_isPageControllerAttached) {
      setState(() => _isPageControllerAttached = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollControllerAttachment);
    _selectorScrollController.removeListener(_checkSelectorScrollControllerAttachment);
    _pageController.removeListener(_checkPageControllerAttachment);

    _scrollController.dispose();
    _selectorScrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _alimentoController.dispose();
    _cantidadController.dispose();
    _categoriasScrollController.dispose();

    super.dispose();
  }

  void _scrollToCategoria(String categoria) {
    if (!_isScrollControllerAttached) return;

    final index = categorias.indexOf(categoria);
    if (index != -1) {
      _currentIndex = index;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isScrollControllerAttached) {
          _scrollController.animateTo(
            index * 200.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _scrollToTipoComida(String tipo) {
    if (!_isSelectorScrollControllerAttached) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isSelectorScrollControllerAttached) {
        _selectorScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _cambiarVista(VistaModal vista) {
    if (!mounted) return;

    setState(() {
      _vistaActual = vista;
      if (vista == VistaModal.recetas) {
        final categoriaInicial = _categoriaToTipoComida[widget.categoriaInicial] ?? widget.tipoComida;
        if (_tipoComidaSeleccionado != categoriaInicial) {
          _tipoComidaSeleccionado = categoriaInicial;
        }
      }
    });

    if (vista == VistaModal.recetas) {
      if (_filtrosActuales.vista == VistaRecetas.swipe) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        });
      }
      _cargarRecetas(_tipoComidaSeleccionado);
    }
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FiltrosModalSheet(
        tipoComida: _tipoComidaSeleccionado,
        filtrosActuales: _filtrosActuales,
        onFiltrosAplicados: (nuevosFiltros) async {
          if (!mounted) return;

          setState(() {
            _filtrosActuales = nuevosFiltros;
          });

          final categoriaActual = _vistaActual == VistaModal.recetas
              ? _tipoComidaSeleccionado
              : _categoriaToTipoComida[widget.categoriaInicial] ?? widget.tipoComida;

          await _cargarRecetas(categoriaActual);
        },
        vistaActual: _filtrosActuales.vista,
        onVistaCambiada: (nuevaVista) {
          setState(() {
            _filtrosActuales = _filtrosActuales.copyWith(vista: nuevaVista);
          });
        },
        rangos: {
          'tiempoMin': 0.0,
          'tiempoMax': 120.0,
          'caloriasMin': 0.0,
          'caloriasMax': 1000.0,
        },
        dificultades: ['fácil', 'medio', 'difícil'],
      ),
    );
  }

  Widget _buildRecetasListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _recetas.length,
      itemBuilder: (context, index) {
        final receta = _recetas[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecetaDetalleScreen(receta: receta),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                receta.titulo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                receta.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoNutricionalCompact('${receta.calorias} kcal'),
                  SizedBox(width: 8),
                  _buildInfoNutricionalCompact('${receta.proteinas}g'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoNutricionalCompact(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _configurarControladores() {
    _alimentoController.addListener(() {
      if (_alimentoController.text.isNotEmpty) {
        _buscarAlimentos(query: _alimentoController.text);
      } else {
        setState(() {
          _sugerenciasAlimentos = [];
        });
      }
    });

    _alimentoFocusNode.addListener(() {
      if (_alimentoFocusNode.hasFocus && _alimentoController.text.isNotEmpty) {
        _buscarAlimentos(query: _alimentoController.text);
      }
    });
  }

  Future<void> _buscarAlimentos({String? query}) async {
    final textoBusqueda = query ?? _searchController.text.trim();

    if (!mounted) return;

    setState(() {
      _buscandoAlimentos = true;
      _textoBusquedaAlimentos = textoBusqueda;
    });

    try {
      final resultados = await DatabaseHelper.instance.buscarAlimentosPorTitulo(
        textoBusqueda,
        categoria: _categoriaSeleccionadaAlimentos == 'todos' ? null : _categoriaSeleccionadaAlimentos,
      );

      if (!mounted) return;

      setState(() {
        if (_vistaActual == VistaModal.buscar) {
          _alimentosEncontrados = resultados;
        } else {
          _sugerenciasAlimentos = resultados;
        }
        _buscandoAlimentos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _buscandoAlimentos = false;
      });
      _mostrarMensajeError('Error al buscar alimentos: $e');
    }
  }

  void _seleccionarAlimento(Map<String, dynamic> alimento) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _InfoNutricionalBottomSheet(
        alimento: alimento,
        onAgregarAlimento: (alimentoAgregado) {
          setState(() {
            _alimentosAgregados[alimentoAgregado['categoria_comida']]!.add(alimentoAgregado);
            _mostrarFormulario = false;
            _alimentoController.clear();
            _cantidadController.clear();
            _alimentoSeleccionado = null;
          });
        },
      ),
    );
  }

  Widget _buildAgregarAlimentoForm(String categoria) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _alimentoController,
                focusNode: _alimentoFocusNode,
                decoration: InputDecoration(
                  labelText: 'Nombre del alimento',
                  hintText: 'Buscar alimento...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: () {
                  if (_alimentoController.text.isNotEmpty) {
                    _buscarAlimentos(query: _alimentoController.text);
                  }
                },
              ),
              // Lista de sugerencias
              if (_sugerenciasAlimentos.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: BoxConstraints(
                    maxHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _sugerenciasAlimentos.length,
                    itemBuilder: (context, index) {
                      final alimento = _sugerenciasAlimentos[index];
                      return ListTile(
                        title: Text(alimento['nombre']),
                        subtitle: Text(
                          '${alimento['calorias']} kcal / ${alimento['porcion_estandar']} ${alimento['unidad_medida']}',
                        ),
                        onTap: () {
                          setState(() {
                            _alimentoSeleccionado = alimento;
                            _alimentoController.text = alimento['nombre'];
                            _unidadSeleccionada = alimento['unidad_medida'] ?? 'g';
                            _sugerenciasAlimentos = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Campos de cantidad y unidad
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unidadSeleccionada,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['g', 'ml', 'unidad', 'taza', 'cucharada', 'cucharadita', 'porción']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _unidadSeleccionada = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_alimentoSeleccionado != null &&
                            _cantidadController.text.isNotEmpty) {
                          _agregarAlimento(categoria);
                        } else {
                          _mostrarMensajeError(
                              'Por favor, selecciona un alimento y especifica la cantidad'
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Agregar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _mostrarFormulario = false;
                        _alimentoController.clear();
                        _cantidadController.clear();
                        _alimentoSeleccionado = null;
                        _sugerenciasAlimentos = [];
                      });
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _agregarAlimento(String categoria) {
    if (_alimentoSeleccionado == null || _cantidadController.text.isEmpty) return;

    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    if (cantidad <= 0) return;

    final nuevoAlimento = {
      ..._alimentoSeleccionado!,
      'cantidad': cantidad,
      'unidad': _unidadSeleccionada,
      'fecha_registro': DateTime.now().toIso8601String(),
    };

    setState(() {
      _alimentosAgregados[categoria]!.add(nuevoAlimento);
      _mostrarFormulario = false;
      _alimentoController.clear();
      _cantidadController.clear();
      _alimentoSeleccionado = null;
    });
  }

  Widget _buildBloqueComida(String categoria) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              categoria,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Lista de alimentos agregados
          if (_alimentosAgregados[categoria]!.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _alimentosAgregados[categoria]!.length,
              itemBuilder: (context, index) {
                final alimento = _alimentosAgregados[categoria]![index];
                return ListTile(
                  title: Text(alimento['nombre']),
                  subtitle: Text(
                    '${alimento['cantidad']} ${alimento['unidad']} - ${alimento['calorias']} kcal',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _alimentosAgregados[categoria]!.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          if (_mostrarFormulario && _categoriaSeleccionada == categoria)
            _buildAgregarAlimentoForm(categoria)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _categoriaSeleccionada = categoria;
                    _mostrarFormulario = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar alimento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectorCategorias() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _categoriasScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categoriasAlimentos.length,
                  itemBuilder: (context, index) {
                    final categoria = _categoriasAlimentos[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoriaChip(categoria),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _mostrarVistaExpandida = !_mostrarVistaExpandida;
                    });
                  },
                  icon: Icon(
                    _mostrarVistaExpandida ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: _mostrarVistaExpandida ? 'Ver menos' : 'Ver más',
                ),
              ),
            ],
          ),
        ),
        if (_mostrarVistaExpandida)
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Todas las categorías',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _categoriasAlimentos.length,
                      itemBuilder: (context, index) {
                        final categoria = _categoriasAlimentos[index];
                        return _buildCategoriaGridItem(categoria);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriaChip(Map<String, dynamic> categoria) {
    final bool isSelected = _categoriaSeleccionadaAlimentos == categoria['id'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _categoriaSeleccionadaAlimentos = categoria['id'];
            _mostrarVistaExpandida = false;
          });
          _buscarAlimentos();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoria['icono'],
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                categoria['nombre'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaGridItem(Map<String, dynamic> categoria) {
    final bool isSelected = _categoriaSeleccionadaAlimentos == categoria['id'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _categoriaSeleccionadaAlimentos = categoria['id'];
            _mostrarVistaExpandida = false;
          });
          _buscarAlimentos();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categoria['icono'],
                size: 24,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(height: 4),
              Text(
                categoria['nombre'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVistaBusqueda() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Buscar alimentos",
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _buscarAlimentos();
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onSubmitted: (_) => _buscarAlimentos(),
            onChanged: (value) {
              if (value.isEmpty) {
                _buscarAlimentos();
              }
            },
          ),
        ),
        _buildSelectorCategorias(),
        Expanded(
          child: _buscandoAlimentos
              ? const Center(child: CircularProgressIndicator())
              : _alimentosEncontrados.isEmpty
              ? Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _textoBusquedaAlimentos.isEmpty
                              ? Icons.search
                              : Icons.no_food,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _textoBusquedaAlimentos.isEmpty
                              ? _categoriaSeleccionadaAlimentos == 'todos'
                              ? "Escribe para buscar alimentos"
                              : "Escribe para buscar en ${_obtenerNombreCategoria(_categoriaSeleccionadaAlimentos)}"
                              : "No se encontraron alimentos${_categoriaSeleccionadaAlimentos != 'todos' ? ' en ${_obtenerNombreCategoria(_categoriaSeleccionadaAlimentos)}' : ''}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _alimentosEncontrados.length,
            itemBuilder: (context, index) {
              final alimento = _alimentosEncontrados[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    _obtenerIconoCategoria(alimento['categoria']),
                    color: Colors.grey[600],
                    size: 28,
                  ),
                  title: Text(
                    alimento['nombre'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${alimento['porcion_estandar']} ${alimento['unidad_medida']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${alimento['calorias']} kcal',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _seleccionarAlimento(alimento),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _obtenerNombreCategoria(String categoriaId) {
    final categoria = _categoriasAlimentos.firstWhere(
          (cat) => cat['id'] == categoriaId,
      orElse: () => {'nombre': 'Desconocida'},
    );
    return categoria['nombre'];
  }

  IconData _obtenerIconoCategoria(String categoriaId) {
    final categoria = _categoriasAlimentos.firstWhere(
          (cat) => cat['id'] == categoriaId,
      orElse: () => {'icono': Icons.help_outline},
    );
    return categoria['icono'];
  }

  Widget _construirContenido() {
    if (_inicializandoDB) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Inicializando base de datos...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorInicializacion != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              _errorInicializacion!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _inicializarBaseDatos,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    switch (_vistaActual) {
      case VistaModal.lista:
        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBloqueComida("Desayuno"),
              _buildBloqueComida("Almuerzo"),
              _buildBloqueComida("Cena"),
              _buildBloqueComida("Snacks"),
            ],
          ),
        );
      case VistaModal.buscar:
        return _buildVistaBusqueda();
      case VistaModal.recetas:
        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar receta por nombre...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: _textoBusqueda.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: _limpiarBusqueda,
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                      ),
                    ),
                    onSubmitted: (_) => _realizarBusqueda(),
                    onChanged: (value) {
                      setState(() {
                        _textoBusqueda = value.trim();
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SingleChildScrollView(
                    controller: _selectorScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getTiposComidaOrdenados().map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildTipoComidaChip(item['tipo']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: _cargandoRecetas
                      ? Center(child: CircularProgressIndicator())
                      : _recetas.isEmpty
                      ? Center(
                    child: Text(
                      'No hay recetas disponibles para esta categoría',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : _filtrosActuales.vista == VistaRecetas.swipe
                      ? PageView.builder(
                    controller: _pageController,
                    itemCount: _recetas.length,
                    itemBuilder: (context, index) {
                      final receta = _recetas[index];
                      return _buildRecetaCard(receta);
                    },
                  )
                      : _buildRecetasListView(),
                ),
              ],
            ),
            _buildFiltroButton(),
          ],
        );
    }
  }

  Widget _buildRecetaCard(Receta receta) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecetaDetalleScreen(receta: receta),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: receta.imagenUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.error, size: 40, color: Colors.grey[400]),
                  ),
                  memCacheWidth: 800,
                  memCacheHeight: 450,
                  maxWidthDiskCache: 800,
                  maxHeightDiskCache: 450,
                  fadeInDuration: Duration(milliseconds: 300),
                  fadeOutDuration: Duration(milliseconds: 300),
                  imageBuilder: (context, imageProvider) {
                    print('🖼️ Imagen cargada exitosamente: ${receta.imagenUrl}');
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receta.titulo,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      receta.descripcion,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoNutricional('Calorías', '${receta.calorias} kcal'),
                        _buildInfoNutricional('Proteínas', '${receta.proteinas}g'),
                        _buildInfoNutricional('Carbos', '${receta.carbohidratos}g'),
                        _buildInfoNutricional('Grasas', '${receta.grasas}g'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNutricional(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTipoComidaChip(String tipo) {
    final isSelected = tipo == _tipoComidaSeleccionado;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          tipo[0].toUpperCase() + tipo.substring(1),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            _cambiarCategoria(tipo);
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroButton() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: FloatingActionButton.extended(
        onPressed: _abrirFiltros,
        backgroundColor: _filtrosActuales.tieneAlgunFiltroActivo ? Colors.blue : Colors.amber,
        icon: Icon(Icons.filter_list,
            color: _filtrosActuales.tieneAlgunFiltroActivo ? Colors.white : Colors.black),
        label: Text(
          'Filtros',
          style: TextStyle(
            color: _filtrosActuales.tieneAlgunFiltroActivo ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.91,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _vistaActual == VistaModal.lista ? "Agregar Comida" :
                  _vistaActual == VistaModal.buscar ? "Buscar Alimentos" :
                  "Recetas",
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

          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _construirContenido(),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(
                  icon: Icons.restaurant_menu,
                  label: "Recetas",
                  isSelected: _vistaActual == VistaModal.recetas,
                  onPressed: () => _cambiarVista(VistaModal.recetas),
                ),
                _buildNavButton(
                  icon: Icons.list,
                  label: "Registro Diario",
                  isSelected: _vistaActual == VistaModal.lista,
                  onPressed: () => _cambiarVista(VistaModal.lista),
                ),
                _buildNavButton(
                  icon: Icons.search,
                  label: "Buscar",
                  isSelected: _vistaActual == VistaModal.buscar,
                  onPressed: () => _cambiarVista(VistaModal.buscar),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.amber : Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.amber : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensajeError(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _cargarRecetas(String tipoComida) async {
    if (!mounted) return;

    setState(() {
      _cargandoRecetas = true;
      _recetas = [];
    });

    try {
      print('🔄 Cargando recetas para tipo: $tipoComida');
      print('📋 Filtros actuales: ${_filtrosActuales.toMap()}');

      final categoriaParaCargar = _vistaActual == VistaModal.recetas
          ? tipoComida
          : _categoriaToTipoComida[widget.categoriaInicial] ?? widget.tipoComida;

      final recetas = await DatabaseHelper.instance.getRecetasFiltradas(
        categoriaParaCargar,
        _filtrosActuales,
        textoBusqueda: _textoBusqueda,
      );

      print('✅ Recetas encontradas: ${recetas.length}');

      if (!mounted) return;

      setState(() {
        _recetas = recetas;
        _cargandoRecetas = false;
      });
    } catch (e) {
      print('❌ Error al cargar recetas: $e');
      if (!mounted) return;

      setState(() {
        _cargandoRecetas = false;
      });
      _mostrarMensajeError('Error al cargar las recetas');
    }
  }

  Future<void> _inicializarBaseDatos() async {
    if (!mounted) return;

    setState(() {
      _inicializandoDB = true;
      _errorInicializacion = null;
    });

    try {
      await DatabaseHelper.instance.initializeDatabase();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (_isScrollControllerAttached) {
          _scrollToCategoria(widget.categoriaInicial ?? 'desayuno');
        }

        _tipoComidaSeleccionado = _categoriaToTipoComida[widget.categoriaInicial] ?? widget.tipoComida;

        if (_isSelectorScrollControllerAttached) {
          _scrollToTipoComida(_tipoComidaSeleccionado);
        }

        _cargarRecetas(_tipoComidaSeleccionado);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorInicializacion = 'Error al inicializar la base de datos: $e';
        print('Error de inicialización: $_errorInicializacion');
      });
      _mostrarMensajeError('Error al inicializar la base de datos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _inicializandoDB = false;
        });
      }
    }
  }

  Future<void> _realizarBusqueda() async {
    if (!mounted) return;

    setState(() {
      _textoBusqueda = _searchController.text.trim();
      _cargandoRecetas = true;
    });

    try {
      final recetas = await DatabaseHelper.instance.getRecetasFiltradas(
        _tipoComidaSeleccionado,
        _filtrosActuales,
        textoBusqueda: _textoBusqueda,
      );

      if (mounted) {
        setState(() {
          _recetas = recetas;
          _cargandoRecetas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoRecetas = false;
        });
        _mostrarMensajeError('Error al buscar recetas: $e');
      }
    }
  }

  void _limpiarBusqueda() {
    if (!mounted) return;

    _searchController.clear();
    setState(() {
      _textoBusqueda = '';
    });
    _cargarRecetas(_tipoComidaSeleccionado);
  }

  void _cambiarCategoria(String categoria) {
    if (!mounted) return;

    setState(() {
      _categoriaSeleccionada = categoria;
      _tipoComidaSeleccionado = categoria;
      _recetas = [];
      _cargandoRecetas = true;
    });

    if (_pageController.hasClients) {
      final index = categorias.indexOf(categoria);
      if (index != -1) {
        _pageController.jumpToPage(index);
      }
    }

    _cargarRecetas(categoria);
  }
}

class _InfoNutricionalBottomSheet extends StatefulWidget {
  final Map<String, dynamic> alimento;
  final Function(Map<String, dynamic>) onAgregarAlimento;

  const _InfoNutricionalBottomSheet({
    Key? key,
    required this.alimento,
    required this.onAgregarAlimento,
  }) : super(key: key);

  @override
  State<_InfoNutricionalBottomSheet> createState() => _InfoNutricionalBottomSheetState();
}

class _InfoNutricionalBottomSheetState extends State<_InfoNutricionalBottomSheet> {
  final TextEditingController _cantidadController = TextEditingController();
  String _categoriaSeleccionada = 'Desayuno';
  String _unidadSeleccionada = 'g';
  bool _mostrarFormulario = false;

  final List<String> _categorias = ["Desayuno", "Almuerzo", "Cena", "Snacks"];
  final List<String> _unidades = ['g', 'ml', 'unidad', 'taza', 'cucharada', 'cucharadita', 'porción'];

  @override
  void initState() {
    super.initState();
    _unidadSeleccionada = widget.alimento['unidad_medida'] ?? 'g';
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _agregarAlimento() {
    if (_cantidadController.text.isEmpty) {
      _mostrarMensajeError('Por favor, ingresa una cantidad');
      return;
    }

    final cantidad = double.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      _mostrarMensajeError('Por favor, ingresa una cantidad válida');
      return;
    }

    final alimentoAgregado = {
      ...widget.alimento,
      'cantidad': cantidad,
      'unidad': _unidadSeleccionada,
      'categoria_comida': _categoriaSeleccionada,
      'fecha_registro': DateTime.now().toIso8601String(),
    };

    widget.onAgregarAlimento(alimentoAgregado);
    Navigator.pop(context);
  }

  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      _obtenerIconoCategoria(widget.alimento['categoria']),
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.alimento['nombre'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.alimento['porcion_estandar']} ${widget.alimento['unidad_medida']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 24,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoNutricionalGrid(),
                const SizedBox(height: 24),
                if (!_mostrarFormulario)
                  ElevatedButton(
                    onPressed: () => setState(() => _mostrarFormulario = true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Agregar alimento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detalles del registro',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _categoriaSeleccionada,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Categoría de comida',
                                    ),
                                    items: _categorias.map((String categoria) {
                                      return DropdownMenuItem<String>(
                                        value: categoria,
                                        child: Text(
                                          categoria,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _categoriaSeleccionada = newValue;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          controller: _cantidadController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                            labelText: 'Cantidad',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          value: _unidadSeleccionada,
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Unidad',
                                          ),
                                          items: _unidades.map((String unidad) {
                                            return DropdownMenuItem<String>(
                                              value: unidad,
                                              child: Text(
                                                unidad,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _unidadSeleccionada = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => _mostrarFormulario = false),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _agregarAlimento,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Confirmar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoNutricionalGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildNutrienteCard(
                  'Calorías',
                  '${widget.alimento['calorias']}',
                  'kcal',
                  Icons.local_fire_department,
                  Colors.orange[700]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrienteCard(
                  'Proteínas',
                  '${widget.alimento['proteinas']}',
                  'g',
                  Icons.egg_alt,
                  Colors.red[700]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutrienteCard(
                  'Carbohidratos',
                  '${widget.alimento['carbohidratos']}',
                  'g',
                  Icons.grain,
                  Colors.green[700]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrienteCard(
                  'Grasas',
                  '${widget.alimento['grasas']}',
                  'g',
                  Icons.opacity,
                  Colors.blue[700]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrienteCard(
      String titulo,
      String valor,
      String unidad,
      IconData icono,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(text: valor),
                TextSpan(
                  text: ' $unidad',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _obtenerIconoCategoria(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case 'frutas':
        return Icons.apple;
      case 'verduras':
        return Icons.eco;
      case 'carnes':
        return Icons.restaurant;
      case 'lacteos':
        return Icons.water_drop;
      case 'cereales':
        return Icons.grain;
      case 'legumbres':
        return Icons.spa;
      case 'pescados':
        return Icons.set_meal;
      case 'frutos_secos':
        return Icons.forest;
      case 'huevos':
        return Icons.egg;
      case 'bebidas':
        return Icons.local_drink;
      case 'salsas':
        return Icons.liquor;
      default:
        return Icons.restaurant_menu;
    }
  }
} 