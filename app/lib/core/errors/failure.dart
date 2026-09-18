/// ============================================================================
/// EXAMEN 4 — JERARQUÍA DE ERRORES SEMÁNTICOS (Failures)
///
/// Modela los errores de dominio de FixTrack para independizar la capa
/// de presentación (UI) de las librerías técnicas de red (Dio/Sockets).
///
/// PUNTO 3:
/// - [SinConexion]: Error semántico con mensaje «Sin conexión».
/// - [TiempoAgotado]: Error semántico con mensaje «Tiempo agotado».
/// ============================================================================
sealed class Failure {
  const Failure(this.mensaje);

  /// Mensaje visible y amigable para el usuario en la interfaz.
  final String mensaje;
}

/// Representa la pérdida o ausencia total de conectividad (ej. Modo Avión,
/// corte de red o SocketException). Mensaje por defecto: «Sin conexión».
final class SinConexion extends Failure {
  const SinConexion([super.mensaje = 'Sin conexión']);
}

/// Representa que una petición superó el tiempo límite de espera (timeout).
/// Mensaje por defecto: «Tiempo agotado».
final class TiempoAgotado extends Failure {
  const TiempoAgotado([super.mensaje = 'Tiempo agotado']);
}



final class NoAutorizado extends Failure {
  const NoAutorizado() : super('Su sesión expiró.');
}

final class SinPermiso extends Failure {
  const SinPermiso() : super('No tiene permiso para esta acción.');
}

final class NoEncontrado extends Failure {
  const NoEncontrado() : super('No se encontró lo solicitado.');
}

final class ErrorValidacion extends Failure {
  const ErrorValidacion(super.mensaje);
}

final class Conflicto extends Failure {
  const Conflicto() : super('El recurso cambió. Actualice e intente de nuevo.');
}

final class DemasiadasPeticiones extends Failure {
  const DemasiadasPeticiones()
    : super('Demasiadas solicitudes. Espere un momento.');
}

final class ErrorServidor extends Failure {
  const ErrorServidor() : super('Error del servidor. Intente más tarde.');
}
