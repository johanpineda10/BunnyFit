import 'package:flutter/material.dart';

class TodasNoticiasScreen extends StatelessWidget {
  const TodasNoticiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias Deportivas'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implementar actualización de noticias cuando se integre con API/JSON
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _getNoticiasDePrueba().length,
          itemBuilder: (context, index) {
            final noticia = _getNoticiasDePrueba()[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _NoticiaCard(noticia: noticia),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, String>> _getNoticiasDePrueba() {
    // TODO: Esto será reemplazado por datos reales de API/JSON
    return [
      {
        'titulo': 'Nuevas técnicas de entrenamiento para mejorar tu rendimiento',
        'descripcion': 'Descubre las últimas innovaciones en métodos de entrenamiento que están revolucionando el mundo del deporte...',
        'fecha': 'Hace 1 hora',
        'categoria': 'Entrenamiento'
      },
      {
        'titulo': 'Los mejores ejercicios para aumentar tu resistencia',
        'descripcion': 'Una guía completa con los ejercicios más efectivos para desarrollar tu resistencia cardiovascular...',
        'fecha': 'Hace 2 horas',
        'categoria': 'Ejercicios'
      },
      {
        'titulo': 'Consejos de expertos para prevenir lesiones',
        'descripcion': 'Especialistas comparten las mejores prácticas para mantener tu cuerpo en óptimas condiciones y evitar lesiones...',
        'fecha': 'Hace 3 horas',
        'categoria': 'Salud'
      },
      {
        'titulo': 'Nutrición deportiva: Lo que necesitas saber',
        'descripcion': 'Guía completa sobre alimentación para deportistas: qué comer antes, durante y después del entrenamiento...',
        'fecha': 'Hace 4 horas',
        'categoria': 'Nutrición'
      },
      {
        'titulo': 'Tecnología en el deporte: Las últimas innovaciones',
        'descripcion': 'Conoce los nuevos dispositivos y aplicaciones que están transformando la manera de entrenar y competir...',
        'fecha': 'Hace 5 horas',
        'categoria': 'Tecnología'
      }
    ];
  }
}

class _NoticiaCard extends StatelessWidget {
  final Map<String, String> noticia;

  const _NoticiaCard({required this.noticia});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.photo,
                size: 48,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        noticia['categoria']!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      noticia['fecha']!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  noticia['titulo']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  noticia['descripcion']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: Implementar navegación al detalle de la noticia
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Leer más',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 