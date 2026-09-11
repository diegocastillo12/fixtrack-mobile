import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/dio_client.dart';
import '../domain/incidencia.dart';
import '../domain/incidencia_repository.dart';
import 'incidencia_dto.dart';
import 'incidencia_mapper.dart';

class IncidenciaRepositoryImpl implements IncidenciaRepository {
  IncidenciaRepositoryImpl({Dio? dio}) : _dio = dio ?? _crearDio();

  final Dio _dio;

  static const _cacheKey = 'incidencias_cache';

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
    try {
      final response = await _dio.get<dynamic>(
        '/incidencias',
        queryParameters: {'limit': 20},
      );

      final datos = _extraerLista(response.data);

      final incidencias = datos
          .map(
            (json) =>
                IncidenciaDto.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .map(IncidenciaMapper.toDomain)
          .toList();

      await _guardarCache(incidencias);

      return incidencias;
    } on DioException {
      final cache = await _leerCache();

      if (cache.isNotEmpty) {
        return cache;
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

  List<dynamic> _extraerLista(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final lista = data['data'];

      if (lista is List) {
        return lista;
      }
    }

    return <dynamic>[];
  }

  Future<void> _guardarCache(List<Incidencia> incidencias) async {
    final prefs = await SharedPreferences.getInstance();

    final datos = incidencias
        .map(
          (incidencia) => {
            'id': incidencia.id,
            'titulo': incidencia.titulo,
            'descripcion': incidencia.descripcion,
            'estado': incidencia.estado,
          },
        )
        .toList();

    await prefs.setString(_cacheKey, jsonEncode(datos));
  }

  Future<List<Incidencia>> _leerCache() async {
    final prefs = await SharedPreferences.getInstance();
    final contenido = prefs.getString(_cacheKey);

    if (contenido == null || contenido.isEmpty) {
      return [];
    }

    final datos = jsonDecode(contenido);

    if (datos is! List) {
      return [];
    }

    return datos
        .map(
          (json) =>
              IncidenciaDto.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .map(IncidenciaMapper.toDomain)
        .toList();
  }
}
