import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options_1.dart';
import 'firebase_options_2.dart';
import 'firebase_options_3.dart';
import 'firebase_options_anonymous.dart';
import 'firebase_options_teachers.dart';
import '../models/register_data.dart';


class FirebaseService {
  // Inicializar una instancia de Firebase Auth para cada proyecto
  static Future<FirebaseAuth> getAuthInstance(String projectName) async {
    FirebaseApp app = await Firebase.initializeApp(
      name: projectName,
      options: _getFirebaseOptions(projectName),
    );
    return FirebaseAuth.instanceFor(app: app);
  }

  // Opciones específicas para cada proyecto
  static FirebaseOptions _getFirebaseOptions(String projectName) {
    if (projectName == 'FirstApp') {
      return DefaultFirebaseOptions1.currentPlatform;
    } else if (projectName == 'SecondApp') {
      return DefaultFirebaseOptions2.currentPlatform;
    } else if (projectName == 'ThirdApp') {
      return DefaultFirebaseOptions3.currentPlatform;
    } else if (projectName == 'AnonymousApp') {
      return DefaultFirebaseOptionsAnonymous.currentPlatform;
    } else if (projectName == 'teachersApp') {
      return DefaultFirebaseOptionsTeachers.currentPlatform;
    } else {
      throw Exception("Proyecto desconocido: $projectName");
    }
  }

  // Intentar autenticar al usuario en todos los proyectos
  static Future<Map<String, dynamic>> loginWithEmailAndPassword(String email, String password) async {
    // Primero intentamos en teachersApp para profesores
    try {
      FirebaseAuth teacherAuth = await getAuthInstance('teachersApp');
      UserCredential userCredential = await teacherAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Verificar si es profesor en Firestore
        final app = await Firebase.initializeApp(
          name: 'teachersApp',
          options: DefaultFirebaseOptionsTeachers.currentPlatform,
        );
        final firestore = FirebaseFirestore.instanceFor(app: app);
        final userDoc = await firestore.collection('usuarios').doc(userCredential.user!.uid).get();
        
        if (userDoc.exists && userDoc.data()?['tipo_usuario'] == 'profesor') {
          return {
            'success': true,
            'project': 'teachersApp',
            'userData': {
              'userId': userCredential.user!.uid,
              'email': email,
              'tipoUsuario': 'Profesor',
              'isAnonymous': false,
              ...userDoc.data() ?? {},
            }
          };
        }
      }
    } catch (e) {
      print('Error en teachersApp: $e');
    }

    // Si no es profesor, intentar en los demás proyectos
    List<String> projects = ['FirstApp', 'SecondApp', 'ThirdApp', 'AnonymousApp'];

    for (String project in projects) {
      try {
        FirebaseAuth auth = await getAuthInstance(project);
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          // Verificar el tipo de usuario en Firestore
          final app = await Firebase.initializeApp(
            name: project,
            options: _getFirebaseOptions(project),
          );
          final firestore = FirebaseFirestore.instanceFor(app: app);
          final userDoc = await firestore.collection('usuarios').doc(userCredential.user!.uid).get();

          if (userDoc.exists) {
            return {
              'success': true,
              'project': project,
              'userData': {
                'userId': userCredential.user!.uid,
                'email': email,
                'tipoUsuario': userDoc.data()?['tipo_usuario'] ?? 'registrado',
                'isAnonymous': false,
                ...userDoc.data() ?? {},
              }
            };
          }
        }
      } catch (e) {
        print('Error en $project: $e');
      }
    }

    // Si el usuario no está en ningún proyecto
    return {
      'success': false,
      'error': 'Usuario no encontrado en ningún proyecto'
    };
  }

  static Future<void> saveGuestUserData(String uid, RegisterData data) async {
    try {
      // Obtener la instancia de Firestore para el proyecto anónimo
      final app = await Firebase.initializeApp(
        name: 'AnonymousApp',
        options: DefaultFirebaseOptionsAnonymous.currentPlatform,
      );
      
      final firestore = FirebaseFirestore.instanceFor(app: app);
      
      // Convertir intereses a Map<String, bool>
      final Map<String, bool> opciones = {
        'deportes': data.intereses?.contains('Deportes') ?? false,
        'nutricion': data.intereses?.contains('Nutrición') ?? false,
        'rutinas': data.intereses?.contains('Rutinas') ?? false,
        'tests_fisicos': data.intereses?.contains('Test físicos') ?? false,
      };

      // Guardar datos en Firestore
      await firestore.collection('usuarios').doc(uid).set({
        'objetivo': data.objetivo,
        'nivel_actividad': data.nivelActividad,
        'genero': data.genero,
        'altura': data.altura,
        'edad': data.edad,
        'peso': data.peso,
        'opciones': opciones,
        'nombre': data.nombre,
        'username': data.username,
        'tipo_usuario': 'invitado',
        'fecha_registro': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al guardar datos de usuario invitado: $e');
      rethrow;
    }
  }
}
