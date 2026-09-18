import 'dart:io';

import 'package:app/core/errors/dio_failure_mapper.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/incidencias/domain/incidencia.dart';
import 'package:app/features/incidencias/domain/incidencia_repository.dart';
import 'package:app/features/incidencias/presentation/incidencias_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepoLanzaError implements IncidenciaRepository {
  _FakeRepoLanzaError(this.error);
  final Object error;

  @override
  Future<List<Incidencia>> obtenerIncidencias() {
    return Future<List<Incidencia>>.error(error);
  }
}

void main() {
  group('Punto 3 — Captura y transformación de errores de conectividad', () {
    test('1. Un timeout de Dio se transforma en «Tiempo agotado»', () {
      final dioTimeout = DioException(
        requestOptions: RequestOptions(path: '/incidencias'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = DioFailureMapper.map(dioTimeout);

      expect(failure, isA<TiempoAgotado>());
      expect(failure.mensaje, 'Tiempo agotado');
    });

    test('2. Una SocketException se transforma en «Sin conexión»', () {
      const socketException = SocketException('Failed host lookup');

      final failure = DioFailureMapper.map(socketException);

      expect(failure, isA<SinConexion>());
      expect(failure.mensaje, 'Sin conexión');
    });

    test('3. DioExceptionType.connectionError se transforma en «Sin conexión»', () {
      final dioConnectionError = DioException(
        requestOptions: RequestOptions(path: '/incidencias'),
        type: DioExceptionType.connectionError,
        error: const SocketException('Connection refused'),
      );

      final failure = DioFailureMapper.map(dioConnectionError);

      expect(failure, isA<SinConexion>());
      expect(failure.mensaje, 'Sin conexión');
    });

    test('4. Errores HTTP del servidor (500) no se confunden con ausencia de conexión', () {
      final dioHttpError = DioException(
        requestOptions: RequestOptions(path: '/incidencias'),
        response: Response(
          requestOptions: RequestOptions(path: '/incidencias'),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );

      final transportFailure = DioFailureMapper.mapTransportError(dioHttpError);
      expect(transportFailure, isNull,
          reason: 'No debe clasificarse como falla de transporte');

      final failure = DioFailureMapper.map(dioHttpError);
      expect(failure, isNot(isA<SinConexion>()));
      expect(failure, isNot(isA<TiempoAgotado>()));
      expect(failure, isA<ErrorServidor>());
    });

    test('5. Ante un timeout, el ViewModel termina en estado de error con «Tiempo agotado» y deja de cargar', () async {
      final repo = _FakeRepoLanzaError(const TiempoAgotado());
      final vm = IncidenciasViewModel(repo);

      await vm.cargarIncidencias();

      expect(vm.estado, IncidenciasEstado.error);
      expect(vm.mensajeError, 'Tiempo agotado');
      expect(vm.incidencias, isEmpty);

      vm.dispose();
    });

    test('6. Ante una desconexión, el ViewModel termina en estado de error con «Sin conexión» y deja de cargar', () async {
      final repo = _FakeRepoLanzaError(const SinConexion());
      final vm = IncidenciasViewModel(repo);

      await vm.cargarIncidencias();

      expect(vm.estado, IncidenciasEstado.error);
      expect(vm.mensajeError, 'Sin conexión');
      expect(vm.incidencias, isEmpty);

      vm.dispose();
    });

    test('7. No se transforma dos veces un error ya mapeado', () {
      const original = TiempoAgotado();
      final remapped = DioFailureMapper.map(original);

      expect(identical(original, remapped), isTrue);
    });
  });
}
