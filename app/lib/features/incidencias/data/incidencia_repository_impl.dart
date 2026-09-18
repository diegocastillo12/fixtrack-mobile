import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/dio_failure_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../domain/incidencia.dart';
import '../domain/incidencia_repository.dart';
import 'incidencia_dto.dart';
import 'incidencia_mapper.dart';

class IncidenciaRepositoryImpl implements IncidenciaRepository {
  IncidenciaRepositoryImpl({Dio? dio}) : _dio = dio ?? _crearDio();

  final Dio _dio;

  /// Factoría para crear el cliente Dio utilizado por las incidencias.
  ///
  /// EXAMEN 4:
  /// - PUNTO 2: Se configura un timeout de 3 segundos (`const Duration(seconds: 3)`)
  ///   al instanciar el cliente, cumpliendo el requisito de no colocar constantes
  ///   dentro de las pantallas ni del ViewModel.
  /// - PUNTO 1: Se establece `enableAutoRetry: false` para que cada pulsación del
  ///   botón manual «Reintentar» genere exactamente una solicitud HTTP.
  static Dio _crearDio() {
    const baseUrl = String.fromEnvironment(
      'API_BASE',
      defaultValue: 'http://10.0.2.2:4010',
    );

    final cliente = DioClient(
      baseUrl: baseUrl,
      tokenProvider: () async {
        const token = String.fromEnvironment('API_TOKEN');
        return token.isEmpty ? null : token;
      },
      enableAutoRetry: false,
      timeout: const Duration(seconds: 3),
    );

    return cliente.dio;
  }

  /// Obtiene el listado de incidencias desde la API REST.
  ///
  /// EXAMEN 4 — PUNTO 3:
  /// - Captura errores de transporte mediante [DioFailureMapper.mapTransportError].
  /// - Transforma timeouts en [TiempoAgotado] («Tiempo agotado»).
  /// - Transforma SocketException o caídas de red en [SinConexion] («Sin conexión»).
  /// - Relanza errores HTTP (ej. 400, 500) para no clasificarlos indebidamente
  ///   como desconexiones.
  @override
  Future<List<Incidencia>> obtenerIncidencias() async {
    try {
      final response = await _dio.get<dynamic>(
        '/incidencias',
        queryParameters: {'limit': 20},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final datos = body['data'] as List<dynamic>;

      return datos
          .map((json) => IncidenciaDto.fromJson(
                Map<String, dynamic>.from(json as Map),
              ))
          .map(IncidenciaMapper.toDomain)
          .toList();
    } catch (error) {
      // Mapeo centralizado de errores de transporte a Failures semánticos
      final failure = DioFailureMapper.mapTransportError(error);
      if (failure != null) {
        throw failure;
      }
      rethrow;
    }
  }



  Future<Incidencia> crearIncidencia({
    required String titulo,
    required String descripcion,
  }) async {
    const uuid = Uuid();

    // La clave se crea una sola vez para esta operación.
    final idempotencyKey = uuid.v4();

    final response = await _dio.post<dynamic>(
      '/incidencias',
      data: {'titulo': titulo, 'descripcion': descripcion},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );

    final json = Map<String, dynamic>.from(response.data as Map);

    return IncidenciaMapper.toDomain(IncidenciaDto.fromJson(json));
  }

}
