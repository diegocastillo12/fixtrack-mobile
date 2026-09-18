import 'dart:io';

import 'package:dio/dio.dart';

import 'failure.dart';

/// ============================================================================
/// EXAMEN 4 — PUNTO 3: CAPTURA Y TRANSFORMACIÓN DE ERRORES DE TRANSPORTE
///
/// Mapeador centralizado para transformar errores técnicos de red (DioException,
/// SocketException) en errores semánticos entendibles por el usuario y la UI:
/// - Caso A: Timeout de conexión/envío/recepción -> [TiempoAgotado] («Tiempo agotado»)
/// - Caso B: Desconexión o SocketException -> [SinConexion] («Sin conexión»)
/// - Evita doble transformación devolviendo el [Failure] si ya fue procesado.
/// - Discrimina errores HTTP (400, 500) para no confundirlos con fallas de red.
/// ============================================================================
class DioFailureMapper {
  /// Transforma cualquier error de red en un [Failure] semántico de la aplicación.
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