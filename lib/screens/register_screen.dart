import 'package:flutter/material.dart';
import '../models/register_data.dart';
import '../widgets/bottom_sheets/gender_bottom_sheet.dart';
import '../widgets/bottom_sheets/height_bottom_sheet.dart';
import '../widgets/bottom_sheets/age_bottom_sheet.dart';
import '../widgets/bottom_sheets/weight_bottom_sheet.dart';
import '../routes/routes.dart';

class RegisterScreen extends StatefulWidget {
  final RegisterData registerData;

  const RegisterScreen({
    super.key,
    required this.registerData,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  late RegisterData _registerData;
  int _currentStep = 0;
  final int _totalSteps = 5;

  final List<String> _objetivos = [
    'Perder peso',
    'Ganar músculo',
    'Mantener forma',
    'Mejorar salud',
  ];

  final List<String> _nivelesActividad = [
    'Sedentario',
    'Ligeramente activo',
    'Moderadamente activo',
    'Muy activo',
  ];

  final List<String> _intereses = [
    'Deportes',
    'Nutrición',
    'Rutinas',
    'Test físicos',
  ];

  @override
  void initState() {
    super.initState();
    _registerData = widget.registerData;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showGenderBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenderBottomSheet(
        selectedGender: _registerData.genero,
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _registerData.genero = value;
        });
      }
    });
  }

  void _showHeightBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HeightBottomSheet(
        initialHeight: _registerData.altura,
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _registerData.altura = value;
        });
      }
    });
  }

  void _showAgeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AgeBottomSheet(
        initialAge: _registerData.edad,
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _registerData.edad = value;
        });
      }
    });
  }

  void _showWeightBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeightBottomSheet(
        initialWeight: _registerData.peso,
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _registerData.peso = value;
        });
      }
    });
  }

  void _finishRegistration() {
    if (_registerData.tipoUsuario == 'Profesor') {
      // Si es profesor, ir a la pantalla de años de experiencia
      Routes.goToExperienceScreen(context, _registerData);
    } else {
      // Si es usuario normal, ir a la pantalla de registro completo
      Routes.goToRegistrationComplete(context, _registerData);
    }
  }

  bool _isDatosPersonalesValid() {
    return _registerData.genero != null &&
           _registerData.altura != null &&
           _registerData.edad != null &&
           _registerData.peso != null;
  }

  bool _isInteresesValid() {
    return _registerData.intereses != null && _registerData.intereses!.isNotEmpty;
  }

  bool _isNombreValid() {
    return _registerData.nombre != null &&
           _registerData.nombre!.isNotEmpty &&
           _registerData.username != null &&
           _registerData.username!.isNotEmpty;
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: (_currentStep + 1) / _totalSteps,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        'Paso ${_currentStep + 1} de $_totalSteps',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildObjetivoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Cuál es tu objetivo?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ..._objetivos.map((objetivo) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _registerData.objetivo = objetivo;
              });
              _nextStep();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _registerData.objetivo == objetivo
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              foregroundColor: _registerData.objetivo == objetivo
                  ? Colors.white
                  : Colors.black,
            ),
            child: Text(objetivo),
          ),
        )),
      ],
    );
  }

  Widget _buildNivelActividadStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Qué tan activo eres diariamente?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ..._nivelesActividad.map((nivel) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _registerData.nivelActividad = nivel;
              });
              _nextStep();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _registerData.nivelActividad == nivel
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              foregroundColor: _registerData.nivelActividad == nivel
                  ? Colors.white
                  : Colors.black,
            ),
            child: Text(nivel),
          ),
        )),
      ],
    );
  }

  Widget _buildDatosPersonalesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Datos personales',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          title: const Text('Género'),
          subtitle: Text(_registerData.genero ?? 'Seleccionar'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showGenderBottomSheet,
        ),
        const Divider(),
        ListTile(
          title: const Text('Altura'),
          subtitle: Text(_registerData.altura != null
              ? '${_registerData.altura} cm'
              : 'Seleccionar'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showHeightBottomSheet,
        ),
        const Divider(),
        ListTile(
          title: const Text('Edad'),
          subtitle: Text(_registerData.edad != null
              ? '${_registerData.edad} años'
              : 'Seleccionar'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showAgeBottomSheet,
        ),
        const Divider(),
        ListTile(
          title: const Text('Peso'),
          subtitle: Text(_registerData.peso != null
              ? '${_registerData.peso} kg'
              : 'Seleccionar'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showWeightBottomSheet,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isDatosPersonalesValid() ? _nextStep : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _buildInteresesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Qué te interesa?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ..._intereses.map((interes) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _registerData.intereses = [...?_registerData.intereses, interes];
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _registerData.intereses?.contains(interes) == true
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              foregroundColor: _registerData.intereses?.contains(interes) == true
                  ? Colors.white
                  : Colors.black,
            ),
            child: Text(interes),
          ),
        )),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isInteresesValid() ? _nextStep : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _buildNombreStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Cómo te llamas?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _registerData.nombre = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nombre de usuario',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _registerData.username = value;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isNombreValid() ? _finishRegistration : null,
          child: const Text('Finalizar'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildObjetivoStep(),
                _buildNivelActividadStep(),
                _buildDatosPersonalesStep(),
                _buildInteresesStep(),
                _buildNombreStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 