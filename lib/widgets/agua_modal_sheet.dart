import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AguaModalSheet extends StatefulWidget {
  // 🔹 Agregamos un parámetro opcional para el objetivo diario
  final double objetivoDiario;

  const AguaModalSheet({
    super.key,
    this.objetivoDiario = 2.5, // 🔹 Valor por defecto para pruebas
  });

  @override
  State<AguaModalSheet> createState() => _AguaModalSheetState();
}

class _AguaModalSheetState extends State<AguaModalSheet> {
  bool _ajusteManual = false;
  double _valorSlider = 2.5;
  bool _ajusteClima = false;
  String _climaSeleccionado = 'Cálido';
  double? _temperaturaActual;
  bool _cargandoTemperatura = false;
  final WeatherService _weatherService = WeatherService();
  String? _tiempoRestante;

  @override
  void initState() {
    super.initState();
    _actualizarTiempoRestante();
  }

  Future<void> _actualizarTiempoRestante() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_update');
    
    if (lastUpdate != null) {
      final lastUpdateTime = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      final diferencia = now.difference(lastUpdateTime);
      
      if (diferencia.inHours < 24) {
        final horasRestantes = 24 - diferencia.inHours;
        final minutosRestantes = 60 - diferencia.inMinutes % 60;
        
        setState(() {
          _tiempoRestante = '$horasRestantes horas y $minutosRestantes minutos';
        });
      } else {
        setState(() {
          _tiempoRestante = null;
        });
      }
    }
  }

  Future<void> _cargarTemperatura() async {
    setState(() {
      _cargandoTemperatura = true;
    });

    try {
      final temperatura = await _weatherService.getCurrentTemperature();
      setState(() {
        _temperaturaActual = temperatura;
        _cargandoTemperatura = false;
      });
      _actualizarTiempoRestante();
    } catch (e) {
      setState(() {
        _cargandoTemperatura = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar la temperatura: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
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
                      "Agua",
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

              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Objetivo diario
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Objetivo diario",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${_ajusteManual ? _valorSlider : widget.objetivoDiario} L",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.water_drop,
                                size: 40,
                                color: Colors.blue[400],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // 🔹 Configuración de meta
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Configurar meta de agua",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Switch(
                                    value: _ajusteManual,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _ajusteManual = value;
                                        if (!value) {
                                          _valorSlider = widget.objetivoDiario;
                                        }
                                      });
                                    },
                                    activeColor: Colors.blue,
                                  ),
                                ],
                              ),
                              if (_ajusteManual) ...[
                                SizedBox(height: 16),
                                Text(
                                  "Ajuste manual",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Slider(
                                  value: _valorSlider,
                                  min: 1.0,
                                  max: 5.0,
                                  divisions: 8, // Para incrementos de 0.5L
                                  label: "${_valorSlider.toStringAsFixed(1)}L",
                                  onChanged: (double value) {
                                    setState(() {
                                      _valorSlider = value;
                                    });
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("1L"),
                                    Text("5L"),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        // 🔹 Ajuste por clima
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ajuste por clima",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Switch(
                                    value: _ajusteClima,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _ajusteClima = value;
                                        if (!value) {
                                          _climaSeleccionado = 'Cálido';
                                        }
                                      });
                                    },
                                    activeColor: Colors.blue,
                                  ),
                                ],
                              ),
                              if (_ajusteClima) ...[
                                SizedBox(height: 16),
                                Text(
                                  "Seleccione el clima",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildClimaOption(
                                        'Cálido',
                                        Icons.wb_sunny,
                                        Colors.orange,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: _buildClimaOption(
                                        'Frío',
                                        Icons.ac_unit,
                                        Colors.blue,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: _buildClimaOption(
                                        'Automático',
                                        Icons.auto_awesome,
                                        Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                if (_cargandoTemperatura)
                                  Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else if (_temperaturaActual != null) ...[
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.thermostat,
                                              color: Colors.blue[700],
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Temperatura actual: ${_temperaturaActual!.toStringAsFixed(1)}°C",
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_tiempoRestante != null) ...[
                                          SizedBox(height: 8),
                                          Text(
                                            "Próxima actualización en: $_tiempoRestante",
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        // 🔹 Espacio para contenido futuro
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Contenido adicional de agua aparecerá aquí",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClimaOption(String label, IconData icon, Color color) {
    final isSelected = _climaSeleccionado == label;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _climaSeleccionado = label;
        });

        if (label == 'Automático') {
          await _cargarTemperatura();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 