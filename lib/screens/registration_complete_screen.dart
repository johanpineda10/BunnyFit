import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../controllers/auth_controller.dart';
import '../models/register_data.dart';

class RegistrationCompleteScreen extends StatelessWidget {
  final RegisterData registerData;

  const RegistrationCompleteScreen({
    super.key,
    required this.registerData,
  });

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Continuar como invitado?'),
        content: const Text(
          'Podrás cambiar a una cuenta completa en cualquier momento desde tu perfil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGuestMode(BuildContext context) async {
    final bool? confirm = await _showConfirmationDialog(context);
    if (confirm == true) {
      try {
        // Iniciar sesión anónima usando el AuthController
        final success = await AuthController.loginAnonymously(registerData);
        
        if (success && context.mounted) {
          // Navegar a la pantalla principal
          Routes.goToMain(context);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al iniciar sesión como invitado'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al iniciar sesión como invitado'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Completado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Gracias por registrarte!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Routes.goToCreateAccount(context, registerData),
              child: const Text('Crear Cuenta'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _handleGuestMode(context),
              child: const Text('Continuar como Invitado'),
            ),
          ],
        ),
      ),
    );
  }
} 