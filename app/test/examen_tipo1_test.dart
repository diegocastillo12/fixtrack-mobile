import 'dart:convert';
import 'dart:typed_data';

import 'package:app/core/network/dio_client.dart';
import 'package:app/features/auth/domain/login_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Examen Tipo 1', () {
    test('a: estado inicial sin sesión', () {
      final login = LoginController(gateway: _AuthFake(), tokens: _TokensFake());
      expect(login.status, LoginStatus.unauthenticated);
      expect(login.failedAttempts, 0);
    });

    test('b: login exitoso guarda token y autentica', () async {
      final auth = _AuthFake();
      final tokens = _TokensFake();
      final login = LoginController(gateway: auth, tokens: tokens);
      expect(await login.signIn(' usuario@upt.pe ', 'secreto'), isTrue);
      expect(auth.calls, 1);
      expect(auth.lastEmail, 'usuario@upt.pe');
      expect(login.status, LoginStatus.authenticated);
      expect(tokens.token, 'token-de-prueba');
    });

    test('c: login rechazado registra error sin reintento', () async {
      final auth = _AuthFake(reject: true);
      final login = LoginController(gateway: auth, tokens: _TokensFake());
      expect(await login.signIn('usuario@upt.pe', 'invalida'), isFalse);
      expect(login.status, LoginStatus.error);
      expect(auth.calls, 1);
    });

    test('d: el cuarto intento bloqueado genera cero llamadas', () async {
      final auth = _AuthFake(reject: true);
      final login = LoginController(gateway: auth, tokens: _TokensFake());
      for (var i = 0; i < 3; i++) {
        expect(await login.signIn('usuario@upt.pe', 'invalida'), isFalse);
      }
      final callsBeforeFourth = auth.calls;
      expect(await login.signIn('usuario@upt.pe', 'invalida'), isFalse);
      expect(auth.calls - callsBeforeFourth, 0);
      expect(login.status, LoginStatus.blocked);
      expect(login.error, contains('Espera 30 segundos'));
    });

    test('e: HTTP 401 borra token y no reintenta', () async {
      final tokens = _TokensFake()..token = 'token-de-prueba';
      var sessionActive = true;
      final client = DioClient(
        baseUrl: 'http://localhost:4010',
        tokenProvider: () async => sessionActive ? tokens.token : null,
        onUnauthorized: () async {
          await tokens.clear();
          sessionActive = false;
        },
      );
      final adapter = _UnauthorizedAdapter();
      client.dio.httpClientAdapter = adapter;
      await expectLater(client.dio.get<dynamic>('/recurso'),
          throwsA(isA<DioException>()));
      expect(tokens.token, isNull);
      expect(sessionActive, isFalse);
      expect(adapter.calls, 1);
      expect(adapter.hadAuthorization, isTrue);
    });
  });
}

class _AuthFake implements AuthGateway {
  _AuthFake({this.reject = false});
  final bool reject;
  int calls = 0;
  String? lastEmail;

  @override
  Future<String> signIn(String email, String password) async {
    calls++;
    lastEmail = email;
    if (reject) throw StateError('Credenciales rechazadas');
    return 'token-de-prueba';
  }
}

class _TokensFake implements TokenStore {
  String? token;

  @override
  Future<void> save(String value) async {
    token = value;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  int calls = 0;
  bool hadAuthorization = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    calls++;
    hadAuthorization = options.headers.containsKey('Authorization');
    return ResponseBody.fromString(jsonEncode({'error': 'unauthorized'}), 401,
        headers: {'content-type': ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}
