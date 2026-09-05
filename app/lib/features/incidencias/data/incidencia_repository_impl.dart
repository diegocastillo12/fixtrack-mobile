import '../domain/incidencia.dart';
import '../domain/incidencia_repository.dart';
import 'incidencia_dto.dart';
import 'incidencia_mapper.dart';

class IncidenciaRepositoryImpl implements IncidenciaRepository {
  @override
  Future<List<Incidencia>> obtenerIncidencias() async {
    await Future.delayed(const Duration(seconds: 2));

    final datos = [
      const IncidenciaDto(
        id: 1,
        titulo: 'Falla en lector QR',
        descripcion: 'El lector QR del almacén no responde.',
        estado: 'Pendiente',
      ),
      const IncidenciaDto(
        id: 2,
        titulo: 'Equipo sin conexión',
        descripcion: 'El activo perdió conexión con la red.',
        estado: 'En proceso',
      ),
      const IncidenciaDto(
        id: 3,
        titulo: 'Cámara dañada',
        descripcion: 'La cámara del dispositivo presenta fallas.',
        estado: 'Resuelto',
      ),
    ];

    return datos.map(IncidenciaMapper.toDomain).toList();
  }
}