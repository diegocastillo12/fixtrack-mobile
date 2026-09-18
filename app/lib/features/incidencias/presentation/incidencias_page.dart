import 'package:flutter/material.dart';
import '../data/incidencia_repository_impl.dart';
import 'incidencias_view_model.dart';

/// ============================================================================
/// EXAMEN 4 — PANTALLA DE INCIDENCIAS (UI)
///
/// Esta página implementa la interfaz visual de los siguientes puntos:
///
/// PUNTO 1 — RETRY MANUAL:
/// - Muestra un botón «Reintentar» visible cuando hay un error de red.
/// - Al pulsarlo, se deshabilita el botón y aparece un spinner local
///   con el texto «Reintentando...» (sub-estado 2).
/// - Tras 3 fallos consecutivos, muestra un mensaje de degradación en naranja
///   con cuenta regresiva de 10 segundos y botón deshabilitado (sub-estado 1).
/// - Al expirar el bloqueo, el botón vuelve a habilitarse (sub-estado 3).
///
/// PUNTO 3 — MENSAJES SEMÁNTICOS:
/// - Muestra «Sin conexión» o «Tiempo agotado» según el tipo de error,
///   gracias al [mensajeError] proporcionado por el ViewModel.
/// ============================================================================
class IncidenciasPage extends StatefulWidget {
  const IncidenciasPage({super.key});

  @override
  State<IncidenciasPage> createState() => _IncidenciasPageState();
}

class _IncidenciasPageState extends State<IncidenciasPage> {
  late final IncidenciasViewModel viewModel;

  @override
  void initState() {
    super.initState();

    // Crea el ViewModel con el repositorio real de incidencias.
    // El repositorio usa DioClient con enableAutoRetry: false y timeout: 3s.
    viewModel = IncidenciasViewModel(
      IncidenciaRepositoryImpl(),
    );

    // Escucha cambios en el ViewModel para reconstruir la UI
    viewModel.addListener(_actualizar);
    // Ejecuta la carga inicial de incidencias (no cuenta como reintento manual)
    viewModel.cargarIncidencias();
  }

  /// Callback que reconstruye la UI cuando el ViewModel notifica cambios.
  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Limpia el listener y destruye el ViewModel al salir de la página.
    // Esto cancela el timer de bloqueo si estaba activo.
    viewModel.removeListener(_actualizar);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixTrack - Incidencias'),
      ),
      body: _construirContenido(),
    );
  }

  /// Construye el contenido de la pantalla según el estado actual del ViewModel.
  /// Utiliza un switch exhaustivo sobre [IncidenciasEstado].
  Widget _construirContenido() {
    switch (viewModel.estado) {
      // ── Estado de carga (spinner central) ────────────────────────────────
      case IncidenciasEstado.inicial:
      case IncidenciasEstado.cargando:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando incidencias...'),
            ],
          ),
        );

      // ── Estado de éxito (lista de incidencias) ──────────────────────────
      case IncidenciasEstado.exito:
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.incidencias.length,
          itemBuilder: (context, index) {
            final incidencia = viewModel.incidencias[index];

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${incidencia.id}'),
                ),
                title: Text(incidencia.titulo),
                subtitle: Text(
                  '${incidencia.descripcion}\nEstado: ${incidencia.estado}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );

      // ── Estado vacío (sin incidencias) ──────────────────────────────────
      case IncidenciasEstado.vacio:
        return const Center(
          child: Text('No existen incidencias registradas.'),
        );

      // ══════════════════════════════════════════════════════════════════════
      // ══ PUNTO 1 & 3 — ESTADO DE ERROR CON RETRY MANUAL ═══════════════════
      // ══════════════════════════════════════════════════════════════════════
      // La interfaz de error tiene 3 sub-estados visuales:
      // Sub-estado 1: Bloqueado (tras 3 fallos) → mensaje naranja + botón gris
      // Sub-estado 2: Reintento en progreso → spinner local + botón deshabilitado
      // Sub-estado 3: Listo para reintentar → botón azul activo
      case IncidenciasEstado.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono visual de error de conexión
                const Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                // PUNTO 3: Muestra el mensaje semántico del error
                // (ej. «Sin conexión», «Tiempo agotado» o mensaje genérico)
                Text(
                  viewModel.mensajeError.isNotEmpty
                      ? viewModel.mensajeError
                      : 'Error de conexión.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // ── Sub-estado 1: Bloqueo activo (PUNTO 1) ──────────────────
                // Se muestra tras 3 reintentos manuales fallidos consecutivos.
                // El botón queda deshabilitado y aparece un mensaje de
                // degradación con cuenta regresiva de 10 segundos.
                if (viewModel.bloqueado) ...[
                  Text(
                    'Servicio temporalmente no disponible.\n'
                    'Intenta nuevamente en ${viewModel.segundosRestantes} '
                    'segundo${viewModel.segundosRestantes == 1 ? '' : 's'}.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.orange.shade800),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    // onPressed: null → botón visualmente deshabilitado
                    onPressed: null,
                    child: const Text('Reintentar'),
                  ),

                // ── Sub-estado 2: Reintento en progreso (PUNTO 1) ───────────
                // Se muestra mientras la petición HTTP está en curso.
                // El botón se deshabilita y muestra un spinner local con
                // el texto «Reintentando...» para indicar actividad.
                ] else if (viewModel.reintentoEnProgreso) ...[
                  ElevatedButton(
                    onPressed: null, // Deshabilitado durante la petición
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          // Spinner local pequeño dentro del botón
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Reintentando...'),
                      ],
                    ),
                  ),

                // ── Sub-estado 3: Listo para reintentar (PUNTO 1) ───────────
                // Estado normal del botón: habilitado y azul.
                // Al pulsarlo llama a viewModel.reintentar(), que ejecuta
                // exactamente UNA nueva petición HTTP al servidor.
                ] else ...[
                  ElevatedButton(
                    onPressed: viewModel.reintentar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }
}
