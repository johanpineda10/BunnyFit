import 'package:flutter/material.dart';

class GuiaTestsScreen extends StatelessWidget {
  const GuiaTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Guía con información sobre los diferentes tests físicos y cómo se realizan',
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
