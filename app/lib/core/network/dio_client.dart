import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// ============================================================================
/// EXAMEN 4 — CLIENTE DE RED CENTRALIZADO (DioClient)
/// 
/// Responsabilidades:
/// - PUNTO 2: Timeout configurable mediante parámetro en el constructor (Duration).
///   Permite inyectar tiempos de espera personalizados (ej. 3 segundos para
///   incidencias) sin quemar constantes dentro de pantallas ni ViewModels.
/// - PUNTO 1 & 4: Parámetro [enableAutoRetry] que permite desactivar reintentos
///   automáticos en flujos manuales, garantizando exactamente 1 petición de red
///   por cada pulsación del usuario.
/// ============================================================================
class DioClient {
  /// Constructor configurable de [DioClient].
  ///
  /// Parámetros:
  /// - [baseUrl]: URL base del backend o servicio REST.
  /// - [tokenProvider]: Función asíncrona para obtener el token de autenticación.
  /// - [enableAutoRetry]: Si es `true` (por defecto), reintenta automáticamente
  ///   ante errores de red transitorios (HTTP 503, 429, timeouts). Si es `false`,
  ///   se omite el interceptor de reintento para que la lógica manual de la UI
  ///   controle cada solicitud sin peticiones duplicadas.
  /// - [timeout]: Duración de espera máxima para conexión, envío y recepción.
  ///   Por defecto 10 segundos, personalizable (ej. 3 segundos en Incidencias).
  DioClient({
    required String baseUrl,
    required Future<String?> Function() tokenProvider,
    bool enableAutoRetry = true,
    Duration timeout = const Duration(seconds: 10),
  }) {
    // Configuración de opciones base con timeout configurable (Punto 2)
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );



    // Interceptor de autenticación.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );

    // Interceptor de registro seguro.
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          developer.log('$object', name: 'FixTrack HTTP');
        },
      ),
    );

    // Interceptor de reintentos automáticos (solo cuando está habilitado).
    // Cuando enableAutoRetry=false, el caller es responsable de los reintentos
    // manuales, lo que garantiza exactamente una petición por acción del usuario.
    if (enableAutoRetry) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onError: (error, handler) async {
            final request = error.requestOptions;
            final retries = request.extra['retryCount'] as int? ?? 0;

            final retryable =
                error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.connectionError ||
                error.response?.statusCode == 503 ||
                error.response?.statusCode == 429;

            if (retryable && retries < 3) {
              request.extra['retryCount'] = retries + 1;

              final retryAfter = error.response?.headers.value('retry-after');
              final retryAfterSeconds = int.tryParse(retryAfter ?? '');
              final delay = retryAfterSeconds != null
                ? Duration(seconds: retryAfterSeconds)
                : Duration(seconds: 1 << retries);

              await Future<void>.delayed(delay);

              try {
                final response = await dio.fetch<dynamic>(request);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }

            handler.next(error);
          },
        ),
      );
    }
  }

  late final Dio dio;
}

