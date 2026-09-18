import 'package:flutter/material.dart';
import '../data/incidencia_repository_impl.dart';
import 'incidencias_view_model.dart';

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

    viewModel = IncidenciasViewModel(
      IncidenciaRepositoryImpl(),
    );

    viewModel.addListener(_actualizar);
    viewModel.cargarIncidencias();
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
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

  Widget _construirContenido() {
    switch (viewModel.estado) {
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

      case IncidenciasEstado.vacio:
        return const Center(
          child: Text('No existen incidencias registradas.'),
        );

      case IncidenciasEstado.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.mensajeError.isNotEmpty
                      ? viewModel.mensajeError
                      : 'Error de conexión.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // ── Sub-estado 1: Bloqueo activo ───────────────────────────
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
                    // onPressed: null deshabilita el botón visualmente
                    onPressed: null,
                    child: const Text('Reintentar'),
                  ),

                // ── Sub-estado 2: Reintento en progreso ────────────────────
                ] else if (viewModel.reintentoEnProgreso) ...[
                  ElevatedButton(
                    onPressed: null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Reintentando...'),
                      ],
                    ),
                  ),

                // ── Sub-estado 3: Listo para reintentar ────────────────────
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