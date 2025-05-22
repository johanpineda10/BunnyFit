import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/register_screen.dart';
import '../screens/registration_complete_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/user_type_selection_screen.dart';
import '../screens/experience_screen.dart';
import '../models/register_data.dart';

class Routes {
  // Rutas constantes
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String main = '/main';
  static const String register = '/register';
  static const String registrationComplete = '/registration-complete';
  static const String createAccount = '/create-account';
  static const String userTypeSelection = '/user-type-selection';
  static const String experience = '/experience';

  // Mapa de rutas
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => LoginScreen(),
      home: (context) => const HomeScreen(),
      main: (context) => const MainScreen(),
      register: (context) => RegisterScreen(
        registerData: ModalRoute.of(context)!.settings.arguments as RegisterData,
      ),
      registrationComplete: (context) => RegistrationCompleteScreen(
        registerData: ModalRoute.of(context)!.settings.arguments as RegisterData,
      ),
      createAccount: (context) => CreateAccountScreen(
        registerData: ModalRoute.of(context)!.settings.arguments as RegisterData,
      ),
      userTypeSelection: (context) => UserTypeSelectionScreen(
        registerData: ModalRoute.of(context)!.settings.arguments as RegisterData,
      ),
      experience: (context) => ExperienceScreen(
        registerData: ModalRoute.of(context)!.settings.arguments as RegisterData,
      ),
    };
  }

  // Métodos de navegación
  static Future<void> navigateTo(BuildContext context, String routeName) {
    return Navigator.pushNamed(context, routeName);
  }

  static Future<void> navigateToReplacement(BuildContext context, String routeName) {
    return Navigator.pushReplacementNamed(context, routeName);
  }

  static Future<void> navigateToAndRemoveUntil(BuildContext context, String routeName) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  // Métodos específicos para cada ruta
  static Future<void> goToLogin(BuildContext context) {
    return navigateToReplacement(context, login);
  }

  static Future<void> goToMain(BuildContext context) {
    return navigateToReplacement(context, main);
  }

  static Future<void> goToRegister(BuildContext context, RegisterData registerData) {
    return Navigator.pushNamed(context, register, arguments: registerData);
  }

  static void goToRegistrationComplete(BuildContext context, RegisterData registerData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationCompleteScreen(
          registerData: registerData,
        ),
      ),
    );
  }

  static void goToCreateAccount(BuildContext context, RegisterData registerData) {
    Navigator.pushNamed(context, createAccount, arguments: registerData);
  }

  static void goToUserTypeSelection(BuildContext context, RegisterData registerData) {
    Navigator.pushNamed(context, userTypeSelection, arguments: registerData);
  }

  static void goToExperienceScreen(BuildContext context, RegisterData registerData) {
    Navigator.pushNamed(context, experience, arguments: registerData);
  }
} 