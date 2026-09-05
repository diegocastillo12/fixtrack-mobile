import 'package:flutter/material.dart';
import 'features/incidencias/presentation/incidencias_page.dart';

void main() {
  runApp(const FixTrackApp());
}

class FixTrackApp extends StatelessWidget {
  const FixTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixTrack',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const IncidenciasPage(),
    );
  }
}