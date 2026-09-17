import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/login_page.dart';
import 'features/incidencias/presentation/incidencias_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

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
      home: const _AppEntryPoint(),
    );
  }
}

class _AppEntryPoint extends StatelessWidget {
  const _AppEntryPoint();

  @override
  Widget build(BuildContext context) {
    try {
      final session = Supabase.instance.client.auth.currentSession;

      return session == null ? const LoginPage() : const IncidenciasPage();
    } on StateError {
      return const IncidenciasPage();
    }
  }
}