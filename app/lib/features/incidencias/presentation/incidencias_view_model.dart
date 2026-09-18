import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/dio_failure_mapper.dart';
import '../../../core/errors/failure.dart';
import '../domain/incidencia.dart';
import '../domain/incidencia_repository.dart';


enum IncidenciasEstado {
  inicial,
  cargando,
  exito,
  vacio,
  error,
}

class IncidenciasViewModel extends ChangeNotifier {
  final IncidenciaRepository repository;

  IncidenciasViewModel(this.repository);

  // ── Estado principal ────────────────────────────────────────────────────────
  IncidenciasEstado estado = IncidenciasEstado.inicial;
  List<Incidencia> incidencias = [];
  String mensajeError = '';

  // ── Estado del retry manual ─────────────────────────────────────────────────

  /// `true` mientras se ejecuta exactamente una petición de reintento.
  /// Impide que pulsaciones adicionales generen peticiones simultáneas.
  bool reintentoEnProgreso = false;

  /// Número de reintentos manuales fallidos **consecutivos**.
  /// La carga inicial NO incrementa este contador.
  /// Se reinicia a 0 cuando un reintento tiene éxito o cuando
  /// expira el bloqueo de 10 segundos.
  int fallosConsecutivos = 0;

  /// Segundos que faltan para que expire el bloqueo. Solo significativo
  /// cuando [bloqueado] es `true`.
  int segundosRestantes = 0;

  /// `true` cuando se han acumulado [_maxFallos] fallos consecutivos y el
  /// bloqueo de [_segundosBloqueo] segundos aún no ha expirado.
  bool get bloqueado =>
      _bloqueadoHasta != null && DateTime.now().isBefore(_bloqueadoHasta!);

  // ── Constantes ──────────────────────────────────────────────────────────────
  static const int _maxFallos = 3;
  static const int _segundosBloqueo = 10;

  // ── Internos ────────────────────────────────────────────────────────────────
  DateTime? _bloqueadoHasta;
  Timer? _timer;
  bool _disposed = false;

  // ── Carga inicial ───────────────────────────────────────────────────────────

  /// Realiza la carga inicial de incidencias.
  /// Un fallo aquí NO incrementa [fallosConsecutivos].
  Future<void> cargarIncidencias() async {
    estado = IncidenciasEstado.cargando;
    mensajeError = '';
    _notificar();

    try {
      final resultado = await repository.obtenerIncidencias();

      if (resultado.isEmpty) {
        incidencias = [];
        estado = IncidenciasEstado.vacio;
      } else {
        incidencias = resultado;
        estado = IncidenciasEstado.exito;
      }
    } catch (e) {
      incidencias = [];
      mensajeError = _resolverMensajeError(e);
      estado = IncidenciasEstado.error;
    }

    _notificar();
  }

  // ── Retry manual ────────────────────────────────────────────────────────────

  /// Ejecuta exactamente **una** nueva petición al repositorio.
  ///
  /// Condiciones de guarda:
  /// - Si ya hay una petición en curso ([reintentoEnProgreso]), no hace nada.
  /// - Si el botón está bloqueado ([bloqueado]), no hace nada.
  ///
  /// Comportamiento ante fallo:
  /// - Incrementa [fallosConsecutivos].
  /// - Al llegar a [_maxFallos], activa el bloqueo de [_segundosBloqueo] s.
  ///
  /// Comportamiento ante éxito:
  /// - Muestra los datos y reinicia [fallosConsecutivos] a 0.
  Future<void> reintentar() async {
    if (reintentoEnProgreso || bloqueado) return;

    // ► El estado visual de error se conserva; solo se deshabilita el botón
    //   y aparece el spinner local dentro del mismo estado error.
    reintentoEnProgreso = true;
    mensajeError = '';
    _notificar();

    try {
      final resultado = await repository.obtenerIncidencias();

      // Éxito → reiniciar contador y mostrar datos
      fallosConsecutivos = 0;
      reintentoEnProgreso = false;

      if (resultado.isEmpty) {
        incidencias = [];
        estado = IncidenciasEstado.vacio;
      } else {
        incidencias = resultado;
        estado = IncidenciasEstado.exito;
      }
    } catch (e) {
      reintentoEnProgreso = false;
      fallosConsecutivos++;
      mensajeError = _resolverMensajeError(e);
      estado = IncidenciasEstado.error;

      if (fallosConsecutivos >= _maxFallos) {
        _activarBloqueo();
      }
    }

    _notificar();
  }

  /// Resuelve el mensaje de error semántico para mostrar en la interfaz:
  /// - Si el error es un [Failure], devuelve su [Failure.mensaje]
  ///   (ej. 'Tiempo agotado' o 'Sin conexión').
  /// - Si es un error de Dio o SocketException sin mapear, lo transforma
  ///   a través de [DioFailureMapper.mapTransportError].
  /// - Para otros casos imprevistos, usa el mensaje por defecto.
  String _resolverMensajeError(Object error) {
    if (error is Failure) {
      return error.mensaje;
    }

    final failure = DioFailureMapper.mapTransportError(error);
    if (failure != null) {
      return failure.mensaje;
    }

    return 'No se pudieron cargar las incidencias.';
  }


  // ── Bloqueo de 10 segundos ──────────────────────────────────────────────────

  void _activarBloqueo() {
    _bloqueadoHasta = DateTime.now().add(
      const Duration(seconds: _segundosBloqueo),
    );
    segundosRestantes = _segundosBloqueo;

    _timer?.cancel();
    // Timer.periodic actualiza la cuenta regresiva cada segundo.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      segundosRestantes--;

      if (segundosRestantes <= 0) {
        // Bloqueo expirado: habilitar botón y reiniciar el ciclo
        timer.cancel();
        _timer = null;
        _bloqueadoHasta = null;
        fallosConsecutivos = 0;
        segundosRestantes = 0;
      }

      _notificar();
    });
  }

  // ── Ciclo de vida ───────────────────────────────────────────────────────────

  void _notificar() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}