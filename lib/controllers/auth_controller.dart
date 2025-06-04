import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_preferences.dart';
import '../firebase_service.dart';
import '../models/register_data.dart';

class AuthController {
  /// Método para realizar el login del usuario.
  /// Se encarga de autenticar y guardar la configuración del Firebase adecuado.
  static Future<bool> loginUser(String email, String password) async {
    try {
      // Llamada al servicio de autenticación para verificar las credenciales
      final result = await FirebaseService.loginWithEmailAndPassword(email, password);

      // Verificar si la autenticación fue exitosa
      if (result['success'] == true) {
        final String projectName = result['project'];
        final Map<String, dynamic> userData = result['userData'];

        // Guardar en las preferencias locales el proyecto de Firebase utilizado
        await UserPreferences.setFirebaseProject(projectName);
        
        // Guardar datos del usuario incluyendo tipo de usuario y datos adicionales
        await UserPreferences.setUserData(userData);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error en loginUser: $e');
      return false;
    }
  }

  /// Método para iniciar sesión como usuario anónimo
  static Future<bool> loginAnonymously(RegisterData registerData) async {
    try {
      final auth = await FirebaseService.getAuthInstance('AnonymousApp');
      final userCredential = await auth.signInAnonymously();
      
      if (userCredential.user != null) {
        // Guardar datos en Firestore
        await FirebaseService.saveGuestUserData(
          userCredential.user!.uid,
          registerData,
        );
        
        // Guardar en preferencias
        await UserPreferences.setFirebaseProject('AnonymousApp');
        final userData = {
          'userId': userCredential.user!.uid,
          'email': null,
          'isAnonymous': true,
        };
        await UserPreferences.setUserData(userData);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error en loginAnonymously: $e');
      return false;
    }
  }

  /// Método para cerrar sesión y limpiar la configuración
  static Future<void> logoutUser() async {
    try {
      // Obtener el proyecto actual
      String? projectName = await UserPreferences.getFirebaseProject();
      
      if (projectName != null) {
        // Obtener la instancia de Firebase Auth para el proyecto actual
        FirebaseAuth auth = await FirebaseService.getAuthInstance(projectName);
        // Cerrar sesión
        await auth.signOut();
      }
      
      // Limpiar la configuración guardada en las preferencias
      await UserPreferences.clearFirebaseProject();
    } catch (e) {
      print('Error en logoutUser: $e');
      // Asegurarse de limpiar las preferencias incluso si hay error
      await UserPreferences.clearFirebaseProject();
    }
  }

  /// Método para verificar si hay una sesión activa
  static Future<bool> isUserLoggedIn() async {
    try {
      String? projectName = await UserPreferences.getFirebaseProject();
      if (projectName == null) return false;

      FirebaseAuth auth = await FirebaseService.getAuthInstance(projectName);
      return auth.currentUser != null;
    } catch (e) {
      print('Error en isUserLoggedIn: $e');
      return false;
    }
  }

  /// Método para verificar si el usuario actual es anónimo
  static Future<bool> isAnonymousUser() async {
    try {
      final userData = await UserPreferences.getUserData();
      return userData['isAnonymous'] ?? false;
    } catch (e) {
      print('Error en isAnonymousUser: $e');
      return false;
    }
  }

  /// Método privado para extraer el nombre del proyecto a partir del mensaje recibido
  static String _extractProjectName(String message) {
    List<String> parts = message.split(':');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return '';
  }
} 