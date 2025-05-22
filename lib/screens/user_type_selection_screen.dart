import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../models/register_data.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  final RegisterData registerData;

  const UserTypeSelectionScreen({
    super.key,
    required this.registerData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu tipo de usuario'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              '¿Qué tipo de usuario eres?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Continuar con el flujo de registro para Usuario
                registerData.tipoUsuario = 'Usuario';
                Routes.goToRegister(context, registerData);
              },
              icon: const Icon(Icons.person),
              label: const Text('👤 Usuario'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Continuar con el flujo de registro para Profesor
                registerData.tipoUsuario = 'Profesor';
                Routes.goToRegister(context, registerData);
              },
              icon: const Icon(Icons.person),
              label: const Text('👨‍🏫 Profesor'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 