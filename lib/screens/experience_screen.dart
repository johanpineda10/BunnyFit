import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../models/register_data.dart';

class ExperienceScreen extends StatefulWidget {
  final RegisterData registerData;

  const ExperienceScreen({
    super.key,
    required this.registerData,
  });

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  final _experienceController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      _isValid = value.isNotEmpty && int.tryParse(value) != null;
    });
  }

  void _continueToNextStep() {
    final experience = int.tryParse(_experienceController.text) ?? 0;
    widget.registerData.anosExperiencia = experience;
    
    // Aquí puedes agregar la lógica para determinar el siguiente paso adicional
    // Por ahora, vamos directamente a crear cuenta
    _goToCreateAccount();
  }

  void _goToCreateAccount() {
    Routes.goToCreateAccount(context, widget.registerData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Años de Experiencia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Ingrese sus años de experiencia',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta información nos ayudará a personalizar mejor tu experiencia como profesor.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _experienceController,
              decoration: const InputDecoration(
                labelText: 'Años de experiencia',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                helperText: 'Ingrese un número válido',
              ),
              keyboardType: TextInputType.number,
              onChanged: _validateInput,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isValid ? _continueToNextStep : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continuar'),
            ),
            // Aquí puedes agregar un indicador de progreso para mostrar
            // en qué paso adicional se encuentra el profesor
            const SizedBox(height: 16),
            const Text(
              'Paso 1 de 1',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 