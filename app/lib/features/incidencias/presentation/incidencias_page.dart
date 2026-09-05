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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(viewModel.mensajeError),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewModel.cargarIncidencias,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
    }
  }
}