import 'dart:io';

import 'package:dio/dio.dart';

import 'failure.dart';

/// Mapeador centralizado para transformar errores de transporte y red
/// en errores semánticos ([Failure]) de la aplicación FixTrack.
class DioFailureMapper {
  /// Transforma un error de transporte (timeout, conectividad, SocketException)
  /// en su correspondiente [Failure] semántico:
  /// - Timeout -> [TiempoAgotado] ('Tiempo agotado')
  /// - Conectividad / SocketException -> [SinConexion] ('Sin conexión')
  /// - Si ya es un [Failure], se devuelve directamente (evita doble transformación).
  /// - Errores HTTP de servidor o validación no se confunden con desconexión.
  static Failure map(Object error) {
    // Evita doble transformación
    if (error is Failure) {
      return error;
    }

    if (error is SocketException) {
      return const SinConexion();
    }

    if (error is DioException) {
      // Caso A: Tiempo agotado
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const TiempoAgotado();
      }

      // Caso B: Sin conexión (SocketException o error de conexión Dio)
      if (error.type == DioExceptionType.connectionError ||
          error.error is SocketException) {
        return const SinConexion();
      }

      // Errores HTTP del servidor (no confundir con desconexión)
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 500) {
          return const ErrorServidor();
        }
        if (statusCode == 404) {
          return const NoEncontrado();
        }
      }
    }

    return const ErrorServidor();
  }

  /// Retorna un [Failure] semántico únicamente si el error representa
  /// una falla de transporte (timeout o ausencia de conexión).
  /// Si no es un error de transporte (ej. errores HTTP 400, 422, 500), retorna `null`
  /// para permitir que el repositorio maneje o relance el error sin clasificarlo erróneamente.
  static Failure? mapTransportError(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is SocketException) {
      return const SinConexion();
    }

    if (error is DioException) {
      // Caso A: Tiempo agotado
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const TiempoAgotado();
      }

      // Caso B: Sin conexión
      if (error.type == DioExceptionType.connectionError ||
          error.error is SocketException) {
        return const SinConexion();
      }
    }

    return null;
  }
}