import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/dio_client.dart';
import '../domain/incidencia.dart';
import '../domain/incidencia_repository.dart';
import 'incidencia_dto.dart';
import 'incidencia_mapper.dart';

class IncidenciaRepositoryImpl implements IncidenciaRepository {
  IncidenciaRepositoryImpl({Dio? dio}) : _dio = dio ?? _crearDio();

  final Dio _dio;

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
    );

    return cliente.dio;
  }

  @override
  Future<List<Incidencia>> obtenerIncidencias() async {
    const datosDemo = [
      {
        'id': 'INC-001',
        'titulo': 'Mouse no funciona',
        'descripcion': 'El mouse de la computadora LAB-01 no responde.',
        'estado': 'Pendiente',
      },
      {
        'id': 'INC-002',
        'titulo': 'Proyector sin imagen',
        'descripcion': 'El proyector del laboratorio LAB-02 no muestra imagen.',
        'estado': 'En progreso',
      },
      {
        'id': 'INC-003',
        'titulo': 'Teclado defectuoso',
        'descripcion': 'Varias teclas del equipo LAB-03 no funcionan.',
        'estado': 'Resuelto',
      },
    ];

    return datosDemo
        .map((json) => IncidenciaDto.fromJson(json))
        .map(IncidenciaMapper.toDomain)
        .toList();
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
