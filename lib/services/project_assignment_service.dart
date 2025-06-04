import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/register_data.dart';
import '../firebase_options_1.dart';
import '../firebase_options_2.dart';
import '../firebase_options_3.dart';
import '../firebase_options_teachers.dart';
import '../firebase_options_anonymous.dart';

class ProjectAssignmentService {
  static const List<String> _projects = ['FirstApp', 'SecondApp', 'ThirdApp'];
  static const String _teachersProject = 'teachersApp';
  static const String _anonymousProject = 'anonymousApp';

  /// Calcula el índice del proyecto basado en el UID
  static int _calculateProjectIndex(String uid) {
    int hash = 0;
    // Suma los códigos Unicode de cada carácter
    for (int i = 0; i < uid.length; i++) {
      hash += uid.codeUnitAt(i);
    }
    // Aplica el módulo para obtener un índice válido (0, 1, o 2)
    return hash % 3;
  }

  /// Obtiene el nombre del proyecto basado en el tipo de usuario y UID
  static String getProjectForUID(String uid, {String? tipoUsuario}) {
    if (tipoUsuario == 'Profesor') {
      return _teachersProject;
    } else if (tipoUsuario == 'invitado') {
      return _anonymousProject;
    }
    // Para usuarios normales, usar la distribución por hash
    final index = _calculateProjectIndex(uid);
    return _projects[index];
  }

  /// Guarda los datos del usuario en Firestore
  static Future<void> saveUserData({
    required String uid,
    required String projectName,
    required RegisterData registerData,
    required String email,
  }) async {
    try {
      // Asegurarse de que el proyecto sea el correcto para profesores
      final adjustedProjectName = registerData.tipoUsuario == 'Profesor' ? _teachersProject : projectName;
      
      final app = await Firebase.initializeApp(
        name: adjustedProjectName,
        options: _getFirebaseOptions(adjustedProjectName),
      );
      
      final firestore = FirebaseFirestore.instanceFor(app: app);
      
      // Convertir intereses a Map<String, bool>
      final Map<String, bool> opciones = {
        'deportes': registerData.intereses?.contains('Deportes') ?? false,
        'nutricion': registerData.intereses?.contains('Nutrición') ?? false,
        'rutinas': registerData.intereses?.contains('Rutinas') ?? false,
        'tests_fisicos': registerData.intereses?.contains('Test físicos') ?? false,
      };

      // Datos base para todos los usuarios
      final Map<String, dynamic> userData = {
        'objetivo': registerData.objetivo,
        'nivel_actividad': registerData.nivelActividad,
        'genero': registerData.genero,
        'altura': registerData.altura,
        'edad': registerData.edad,
        'peso': registerData.peso,
        'opciones': opciones,
        'nombre': registerData.nombre,
        'username': registerData.username,
        'email': email,
        'projectAssigned': adjustedProjectName,
        'fecha_registro': FieldValue.serverTimestamp(),
      };

      // Agregar datos específicos según el tipo de usuario
      if (registerData.tipoUsuario == 'Profesor') {
        userData.addAll({
          'tipo_usuario': 'profesor',
          'anos_experiencia': registerData.anosExperiencia,
          'estado': 'pendiente', // Los profesores requieren aprobación
          'calificacion': 0.0,
          'total_valoraciones': 0,
          'alumnos_asignados': [],
          'especialidades': [],
          'horario_disponible': {},
        });
      } else {
        userData['tipo_usuario'] = registerData.tipoUsuario ?? 'registrado';
      }

      // Guardar en Firestore
      await firestore.collection('usuarios').doc(uid).set(userData);
    } catch (e) {
      print('Error al guardar datos de usuario: $e');
      rethrow;
    }
  }

  /// Obtiene las opciones de Firebase para un proyecto específico
  static FirebaseOptions _getFirebaseOptions(String projectName) {
    switch (projectName) {
      case 'FirstApp':
        return DefaultFirebaseOptions1.currentPlatform;
      case 'SecondApp':
        return DefaultFirebaseOptions2.currentPlatform;
      case 'ThirdApp':
        return DefaultFirebaseOptions3.currentPlatform;
      case 'teachersApp':
        return DefaultFirebaseOptionsTeachers.currentPlatform;
      case 'anonymousApp':
        return DefaultFirebaseOptionsAnonymous.currentPlatform;
      default:
        throw Exception('Proyecto desconocido: $projectName');
    }
  }
} 