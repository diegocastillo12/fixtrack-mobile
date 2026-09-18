import 'dart:convert';
import 'dart:typed_data';

import 'package:app/features/auth/presentation/login_page.dart';
import 'package:app/features/incidencias/data/incidencia_repository_impl.dart';
import 'package:app/features/incidencias/presentation/incidencias_view_model.dart';
import 'package:app/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Cliente HTTP simulado (Fake Adapter) ──────────────────────────────────────

class _FakeResponse {
  const _FakeResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final Object body;
}

class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter({required this.responder});

  final _FakeResponse Function(RequestOptions options) responder;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final response = responder(options);

    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// ── Suite de pruebas Punto 4 ──────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        publishableKey: 'test-publishable-key',
      );
    } catch (_) {
      // Ya inicializado previamente en la suite de pruebas
    }
  });

  group('Punto 4 — Tres pruebas unitarias con cliente falso', () {
    // ── Prueba 1: Sesión inicial vacía ────────────────────────────────────────
    testWidgets(
      'Prueba 1: Sesión inicial vacía indica que no hay sesión activa y muestra LoginPage',
      (WidgetTester tester) async {
        // Almacenamiento simulado sin sesión previa
        SharedPreferences.setMockInitialValues({});

        // Componente real de autenticación de FixTrack (Supabase Auth)
        final session = Supabase.instance.client.auth.currentSession;
        expect(session, isNull,
            reason: 'Al iniciar sin credenciales previas no debe existir sesión activa');

        // Renderizado del punto de entrada real de la aplicación FixTrack
        await tester.pumpWidget(const FixTrackApp());

        // La interfaz responde al estado sin sesión mostrando la pantalla de login
        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.text('Inicia sesión'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
      },
    );

    // ── Prueba 2: Respuesta exitosa con datos ─────────────────────────────────
    test(
      'Prueba 2: Respuesta exitosa con cliente falso termina en estado exito con datos esperados',
      () async {
        final fakeAdapter = _FakeHttpAdapter(
          responder: (options) => const _FakeResponse(
            statusCode: 200,
            body: {
              'data': [
                {
                  'id': 101,
                  'titulo': 'Monitor sin señal',
                  'descripcion': 'El monitor del laboratorio 2 no enciende',
                  'estado': 'Pendiente',
                },
                {
                  'id': 102,
                  'titulo': 'Teclado defectuoso',
                  'descripcion': 'Falta la tecla Enter',
                  'estado': 'En proceso',
                },
              ],
            },
          ),
        );

        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4010'));
        dio.httpClientAdapter = fakeAdapter;

        final repository = IncidenciaRepositoryImpl(dio: dio);
        final viewModel = IncidenciasViewModel(repository);

        expect(viewModel.estado, IncidenciasEstado.inicial);

        await viewModel.cargarIncidencias();

        expect(viewModel.estado, IncidenciasEstado.exito,
            reason: 'El ViewModel debe terminar en estado de éxito');
        expect(viewModel.incidencias, hasLength(2),
            reason: 'Debe contener exactamente las 2 incidencias simuladas');
        expect(viewModel.incidencias[0].id, 101);
        expect(viewModel.incidencias[0].titulo, 'Monitor sin señal');
        expect(viewModel.incidencias[1].id, 102);
        expect(viewModel.incidencias[1].titulo, 'Teclado defectuoso');
        expect(fakeAdapter.requestCount, 1,
            reason: 'Debe realizarse exactamente una solicitud HTTP');

        viewModel.dispose();
      },
    );

    // ── Prueba 3: Error del servidor HTTP 500 ──────────────────────────────────
    test(
      'Prueba 3: Error del servidor HTTP 500 termina en estado error, abandona carga y ejecuta una sola petición',
      () async {
        final fakeAdapter = _FakeHttpAdapter(
          responder: (options) => const _FakeResponse(
            statusCode: 500,
            body: {'message': 'Internal Server Error'},
          ),
        );

        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4010'));
        dio.httpClientAdapter = fakeAdapter;

        final repository = IncidenciaRepositoryImpl(dio: dio);
        final viewModel = IncidenciasViewModel(repository);

        expect(viewModel.estado, IncidenciasEstado.inicial);

        await viewModel.cargarIncidencias();

        // 1. Termina en estado de error y abandona estado de carga
        expect(viewModel.estado, IncidenciasEstado.error,
            reason: 'El ViewModel debe pasar al estado de error tras recibir HTTP 500');
        expect(viewModel.mensajeError, isNotEmpty,
            reason: 'Debe contener un mensaje de error visible');
        expect(viewModel.incidencias, isEmpty,
            reason: 'No debe haber incidencias registradas en estado de error');

        // 2. Comprobar que no realizó reintentos automáticos (exactamente 1 sola petición)
        expect(fakeAdapter.requestCount, 1,
            reason:
                'No deben ejecutarse reintentos automáticos: la petición fallida debe ejecutarse exactamente una sola vez');

        viewModel.dispose();
      },
    );
  });
}
