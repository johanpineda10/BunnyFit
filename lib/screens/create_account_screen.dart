import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import '../routes/routes.dart';
import '../models/register_data.dart';
import '../services/project_assignment_service.dart';
import '../services/user_preferences.dart';
import '../firebase_service.dart';

class CreateAccountScreen extends StatefulWidget {
  final RegisterData registerData;

  const CreateAccountScreen({
    super.key,
    required this.registerData,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential? tempCredential;
      String? assignedProject;

      // Determinar el proyecto basado en el tipo de usuario
      if (widget.registerData.tipoUsuario == 'Profesor') {
        // Para profesores, usar directamente teachersApp
        final auth = await FirebaseService.getAuthInstance('teachersApp');
        tempCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (tempCredential.user == null) {
          throw Exception('Error al crear la cuenta de profesor');
        }

        assignedProject = 'teachersApp';
      } else {
        // Para otros usuarios, mantener la lógica existente
        final firstAuth = await FirebaseService.getAuthInstance('FirstApp');
        tempCredential = await firstAuth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final tempUser = tempCredential.user;
        if (tempUser == null) {
          throw Exception('Error al crear la cuenta temporal');
        }

        // Calculamos el proyecto asignado basado en el UID
        assignedProject = ProjectAssignmentService.getProjectForUID(
          tempUser.uid,
          tipoUsuario: widget.registerData.tipoUsuario,
        );

        // Si el proyecto asignado no es FirstApp, movemos la cuenta
        if (assignedProject != 'FirstApp') {
          await tempUser.delete();
          
          final assignedAuth = await FirebaseService.getAuthInstance(assignedProject);
          final finalCredential = await assignedAuth.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          
          final finalUser = finalCredential.user;
          if (finalUser == null) {
            throw Exception('Error al crear la cuenta en el proyecto asignado');
          }

          tempCredential = finalCredential;
        }
      }

      final user = tempCredential.user;
      if (user == null) {
        throw Exception('Error al crear la cuenta');
      }

      // Guardar datos en Firestore
      await ProjectAssignmentService.saveUserData(
        uid: user.uid,
        projectName: assignedProject!,
        registerData: widget.registerData,
        email: _emailController.text,
      );

      // Guardar datos de sesión
      await UserPreferences.setFirebaseProject(assignedProject);
      final userData = {
        'userId': user.uid,
        'email': _emailController.text,
        'isAnonymous': false,
        'tipoUsuario': widget.registerData.tipoUsuario,
      };
      await UserPreferences.setUserData(userData);

      if (mounted) {
        // Navegar a la pantalla principal
        Routes.goToMain(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la cuenta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Crea tu cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa tus datos para crear tu cuenta',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo electrónico';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un correo electrónico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear Cuenta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 