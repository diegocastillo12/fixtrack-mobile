import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/dio_failure_mapper.dart';
import '../../../core/errors/failure.dart';
import '../domain/incidencia.dart';
import '../domain/incidencia_repository.dart';

/// ============================================================================
/// EXAMEN 4 — VIEWMODEL DE INCIDENCIAS
///
/// Este ViewModel centraliza la lógica de negocio de la pantalla de incidencias
/// e implementa los siguientes puntos del examen:
///
/// PUNTO 1 — RETRY MANUAL:
/// - Método [reintentar] para ejecutar exactamente UNA nueva petición HTTP.
/// - Guard doble: [reintentoEnProgreso] y [bloqueado] impiden peticiones extra.
/// - Contador de fallos consecutivos que activa un bloqueo tras 3 fallos.
/// - Bloqueo temporal de 10 segundos con cuenta regresiva en [segundosRestantes].
/// - La carga inicial NO incrementa el contador de fallos.
///
/// PUNTO 3 — TRANSFORMACIÓN DE ERRORES:
/// - Método [_resolverMensajeError] que traduce errores de transporte
///   (timeout y desconexión) a mensajes semánticos legibles para el usuario:
///   «Tiempo agotado» o «Sin conexión», utilizando [DioFailureMapper].
/// ============================================================================

/// Estados posibles de la pantalla de incidencias.
/// La UI observa este enum para decidir qué mostrar en cada momento.
enum IncidenciasEstado {
  inicial,   // Estado al crear el ViewModel, antes de cualquier petición
  cargando,  // Se está realizando una petición HTTP
  exito,     // Datos cargados exitosamente
  vacio,     // La respuesta fue exitosa pero no contiene incidencias
  error,     // Falló la petición (red, timeout, servidor, etc.)
}

/// ViewModel que gestiona el estado de la pantalla de incidencias.
/// Extiende [ChangeNotifier] para notificar a la UI cuando cambia el estado.
class IncidenciasViewModel extends ChangeNotifier {
  /// Repositorio inyectado por constructor para facilitar testing con fakes.
  final IncidenciaRepository repository;

  IncidenciasViewModel(this.repository);

  // ── Estado principal ────────────────────────────────────────────────────────
  /// Estado actual de la pantalla (inicial, cargando, exito, vacio, error).
  IncidenciasEstado estado = IncidenciasEstado.inicial;
  /// Lista de incidencias obtenidas del servidor.
  List<Incidencia> incidencias = [];
  /// Mensaje de error semántico para mostrar en la UI
  /// (ej. «Sin conexión», «Tiempo agotado»).
  String mensajeError = '';

  // ── Estado del retry manual (PUNTO 1) ───────────────────────────────────────

  /// `true` mientras se ejecuta exactamente una petición de reintento.
  /// Actúa como guard para impedir que pulsaciones adicionales generen
  /// peticiones simultáneas duplicadas.
  bool reintentoEnProgreso = false;

  /// Número de reintentos manuales fallidos **consecutivos**.
  /// La carga inicial NO incrementa este contador (solo [reintentar] lo hace).
  /// Se reinicia a 0 cuando un reintento tiene éxito o cuando
  /// expira el bloqueo de 10 segundos.
  int fallosConsecutivos = 0;

  /// Segundos restantes de la cuenta regresiva del bloqueo.
  /// Solo es significativo cuando [bloqueado] es `true`.
  /// La UI lo muestra en tiempo real: «Intenta nuevamente en X segundos».
  int segundosRestantes = 0;

  /// Getter: `true` cuando se acumularon [_maxFallos] fallos consecutivos
  /// y el bloqueo de [_segundosBloqueo] segundos aún no ha expirado.
  bool get bloqueado =>
      _bloqueadoHasta != null && DateTime.now().isBefore(_bloqueadoHasta!);

  // ── Constantes del mecanismo de retry (PUNTO 1) ─────────────────────────────
  /// Cantidad máxima de fallos consecutivos antes de activar el bloqueo.
  static const int _maxFallos = 3;
  /// Duración del bloqueo temporal en segundos.
  static const int _segundosBloqueo = 10;

  // ── Variables internas ──────────────────────────────────────────────────────
  /// Fecha/hora en que expira el bloqueo actual (null si no hay bloqueo).
  DateTime? _bloqueadoHasta;
  /// Timer que actualiza la cuenta regresiva cada segundo.
  Timer? _timer;
  /// Flag para evitar llamar a [notifyListeners] después de [dispose].
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


  // ── Bloqueo de 10 segundos (PUNTO 1) ────────────────────────────────────────

  /// Activa el bloqueo temporal tras [_maxFallos] (3) reintentos manuales
  /// fallidos consecutivos.
  ///
  /// Funcionamiento:
  /// 1. Calcula la fecha/hora de expiración del bloqueo.
  /// 2. Inicia un Timer.periodic que decrementa [segundosRestantes] cada segundo.
  /// 3. Al llegar a 0, cancela el timer, limpia el bloqueo y reinicia
  ///    [fallosConsecutivos] a 0, permitiendo nuevos reintentos.
  /// 4. Protege contra llamadas post-dispose con el flag [_disposed].
  void _activarBloqueo() {
    // Establece la fecha/hora en que expira el bloqueo (ahora + 10 segundos)
    _bloqueadoHasta = DateTime.now().add(
      const Duration(seconds: _segundosBloqueo),
    );
    segundosRestantes = _segundosBloqueo;

    // Cancela cualquier timer previo antes de crear uno nuevo
    _timer?.cancel();
    // Timer.periodic actualiza la cuenta regresiva cada segundo
    // para que la UI muestre: «Intenta nuevamente en X segundos»
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Guard de ciclo de vida: evita notificar si el widget ya fue destruido
      if (_disposed) {
        timer.cancel();
        return;
      }

      segundosRestantes--;

      if (segundosRestantes <= 0) {
        // Bloqueo expirado → habilitar el botón y reiniciar el ciclo
        timer.cancel();
        _timer = null;
        _bloqueadoHasta = null;
        fallosConsecutivos = 0; // Reinicia el contador para un nuevo ciclo
        segundosRestantes = 0;
      }

      // Notifica a la UI para actualizar la cuenta regresiva
      _notificar();
    });
  }

  // ── Ciclo de vida ───────────────────────────────────────────────────────────

  /// Notifica a la UI solo si el ViewModel no ha sido destruido.
  /// Evita errores de tipo «notifyListeners called after dispose».
  void _notificar() {
    if (!_disposed) notifyListeners();
  }

  /// Libera recursos al destruir el ViewModel.
  /// Cancela el timer de bloqueo para evitar fugas de memoria y
  /// marca [_disposed] como `true` para proteger callbacks asíncronos.
  @override
  void dispose() {
    _disposed = true;     // Marca como destruido antes de cancelar
    _timer?.cancel();     // Cancela el timer de cuenta regresiva
    _timer = null;
    super.dispose();
  }
}
