import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutricion_app/firebase_options_teachers.dart';
import 'firebase_options_1.dart';
import 'firebase_options_2.dart';
import 'firebase_options_3.dart';
import 'firebase_options_anonymous.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'database/database_helper.dart';
import 'services/cargador_recetas.dart';
import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter se inicializa correctamente

  await DatabaseHelper.instance.initDB(); // Asegura que la base esté lista
  final cargador = CargadorRecetas();
  await cargador.cargarRecetasSiNoExisten();

  final dbPath = await DatabaseHelper.instance.database;
  print('📦 Ruta de la base de datos: $dbPath');

  await initializeDateFormatting('es_ES', null); // Inicializa la configuración de fecha en español
  CloudinaryContext.cloudinary =
      Cloudinary.fromCloudName(cloudName: 'dujxb3l2b'); // Reemplaza con tu Cloud Name

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions1.currentPlatform,
  );

  FirebaseApp secondApp = await Firebase.initializeApp(
    name: 'SecondApp',
    options: DefaultFirebaseOptions2.currentPlatform,
  );

  FirebaseApp thirdApp = await Firebase.initializeApp(
    name: 'ThirdApp',
    options: DefaultFirebaseOptions3.currentPlatform,
  );

  FirebaseApp anonymousApp = await Firebase.initializeApp(
    name: 'AnonymousApp',
    options: DefaultFirebaseOptionsAnonymous.currentPlatform,
  );

  FirebaseApp teachersApp = await Firebase.initializeApp(
    name: 'TeachersApp',
    options: DefaultFirebaseOptionsTeachers.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFitApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF1976D2),
        ),
        useMaterial3: true,
      ),
      initialRoute: Routes.splash,
      routes: Routes.getRoutes(),
    );
  }
}
