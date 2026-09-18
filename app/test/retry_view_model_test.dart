// ignore_for_file: avoid_print
import 'package:app/features/incidencias/domain/incidencia.dart';
import 'package:app/features/incidencias/domain/incidencia_repository.dart';
import 'package:app/features/incidencias/presentation/incidencias_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Dobles de prueba ──────────────────────────────────────────────────────────

/// Siempre falla con una excepción genérica de red.
class _RepoSiempreFalla implements IncidenciaRepository {
  int llamadas = 0;

  @override
  Future<List<Incidencia>> obtenerIncidencias() {
    llamadas++;
    return Future<List<Incidencia>>.error(Exception('Sin conexión'));
  }
}

/// Falla las primeras [fallasPrimero] veces; luego tiene éxito.
class _RepoFallaLuegoExito implements IncidenciaRepository {
  _RepoFallaLuegoExito(this.fallasPrimero);
  final int fallasPrimero;
  int llamadas = 0;

  @override
  Future<List<Incidencia>> obtenerIncidencias() {
    llamadas++;
    if (llamadas <= fallasPrimero) {
      return Future<List<Incidencia>>.error(Exception('Error temporal'));
    }
    return Future<List<Incidencia>>.value(const [
      Incidencia(
        id: 2,
        titulo: 'Mouse roto',
        descripcion: 'No funciona',
        estado: 'Pendiente',
      ),
    ]);
  }
}

// ── Helper: genera 3 fallos de reintento para activar el bloqueo ──────────────
Future<void> _generarTresFallos(IncidenciasViewModel vm) async {
  // La carga inicial no cuenta; solo 3 reintentos manuales.
  await vm.cargarIncidencias();
  await vm.reintentar();
  await vm.reintentar();
  await vm.reintentar();
}

// ── Pruebas ───────────────────────────────────────────────────────────────────

void main() {
  group('Retry manual — Examen 4 punto 1', () {
    // ── Test 1 ────────────────────────────────────────────────────────────────
    test(
      '1. Ante un fallo de red se muestra estado error y el botón Reintentar',
      () async {
        final vm = IncidenciasViewModel(_RepoSiempreFalla());

        await vm.cargarIncidencias();

        expect(vm.estado, IncidenciasEstado.error,
            reason: 'Debe quedar en estado error tras fallo de red');
        expect(vm.mensajeError, isNotEmpty,
            reason: 'Debe haber un mensaje de error');
        // El botón Reintentar está disponible cuando:
        //   estado == error && !reintentoEnProgreso && !bloqueado
        expect(vm.reintentoEnProgreso, isFalse);
        expect(vm.bloqueado, isFalse);

        vm.dispose();
      },
    );

    // ── Test 2 ────────────────────────────────────────────────────────────────
    test(
      '2. Al pulsar Reintentar se inicia exactamente una nueva petición',
      () async {
        final repo = _RepoSiempreFalla();
        final vm = IncidenciasViewModel(repo);

        await vm.cargarIncidencias(); // 1 llamada (no cuenta como reintento)
        final llamadasTrasInicial = repo.llamadas; // = 1

        // Dispara dos pulsaciones simultáneas; la segunda debe ignorarse
        final f1 = vm.reintentar();
        final f2 = vm.reintentar(); // guard: reintentoEnProgreso == true
        await Future.wait([f1, f2]);

        expect(repo.llamadas, llamadasTrasInicial + 1,
            reason: 'Exactamente una petición adicional (la segunda es ignorada)');

        vm.dispose();
      },
    );

    // ── Test 3 ────────────────────────────────────────────────────────────────
    test(
      '3. Durante el reintento el botón queda deshabilitado y hay indicador de carga',
      () async {
        final repo = _RepoSiempreFalla();
        final vm = IncidenciasViewModel(repo);
        await vm.cargarIncidencias();

        bool capturadoEnProgreso = false;

        vm.addListener(() {
          // Capturamos el estado justo cuando empieza el reintento
          if (vm.reintentoEnProgreso) {
            capturadoEnProgreso = true;
          }
        });

        await vm.reintentar();

        expect(capturadoEnProgreso, isTrue,
            reason: 'reintentoEnProgreso debió ser true durante la petición');
        // Al terminar la petición (fallida), vuelve a false
        expect(vm.reintentoEnProgreso, isFalse);

        vm.dispose();
      },
    );

    // ── Test 4 ────────────────────────────────────────────────────────────────
    test(
      '4. Si el reintento tiene éxito, aparecen los datos y el contador se reinicia',
      () async {
        // Falla 1 vez (carga inicial), luego acierta en el primer reintento
        final repo = _RepoFallaLuegoExito(1);
        final vm = IncidenciasViewModel(repo);

        await vm.cargarIncidencias(); // falla → estado error
        expect(vm.estado, IncidenciasEstado.error);

        await vm.reintentar(); // tiene éxito

        expect(vm.estado, IncidenciasEstado.exito,
            reason: 'Tras reintento exitoso debe quedar en estado exito');
        expect(vm.incidencias, isNotEmpty,
            reason: 'Debe haber incidencias cargadas');
        expect(vm.fallosConsecutivos, 0,
            reason: 'El contador se reinicia tras el éxito');

        vm.dispose();
      },
    );

    // ── Test 5 ────────────────────────────────────────────────────────────────
    test(
      '5. Después de tres reintentos manuales fallidos se activa el bloqueo',
      () async {
        final vm = IncidenciasViewModel(_RepoSiempreFalla());

        await vm.cargarIncidencias(); // NO cuenta como reintento manual
        expect(vm.fallosConsecutivos, 0);

        await vm.reintentar(); // fallo 1
        expect(vm.fallosConsecutivos, 1);
        expect(vm.bloqueado, isFalse);

        await vm.reintentar(); // fallo 2
        expect(vm.fallosConsecutivos, 2);
        expect(vm.bloqueado, isFalse);

        await vm.reintentar(); // fallo 3 → bloqueo
        expect(vm.fallosConsecutivos, 3);
        expect(vm.bloqueado, isTrue,
            reason: 'Tras 3 fallos consecutivos debe activarse el bloqueo');
        expect(vm.segundosRestantes, greaterThan(0));

        vm.dispose();
      },
    );

    // ── Test 6 ────────────────────────────────────────────────────────────────
    test(
      '6. Durante el bloqueo no se permiten nuevas peticiones',
      () async {
        final repo = _RepoSiempreFalla();
        final vm = IncidenciasViewModel(repo);

        await _generarTresFallos(vm);
        expect(vm.bloqueado, isTrue);

        final llamadasAntes = repo.llamadas;
        await vm.reintentar(); // debe ser ignorado
        await vm.reintentar(); // debe ser ignorado

        expect(repo.llamadas, llamadasAntes,
            reason: 'Ninguna petición adicional durante el bloqueo');

        vm.dispose();
      },
    );

    // ── Test 7 ────────────────────────────────────────────────────────────────
    test(
      '7. Transcurridos 10 segundos el bloqueo se libera y el contador se reinicia',
      () {
        // fakeAsync controla el reloj interno de Timer sin esperar realmente
        fakeAsync((fake) {
          final vm = IncidenciasViewModel(_RepoSiempreFalla());

          // Genera los 3 fallos de reintento usando microtasks simuladas
          vm.cargarIncidencias();
          fake.flushMicrotasks();

          vm.reintentar();
          fake.flushMicrotasks();

          vm.reintentar();
          fake.flushMicrotasks();

          vm.reintentar(); // tercer fallo → bloqueo
          fake.flushMicrotasks();

          expect(vm.bloqueado, isTrue,
              reason: 'Debe estar bloqueado tras el tercer fallo');
          expect(vm.segundosRestantes, 10);

          // Avanzar 9 segundos: aún bloqueado
          fake.elapse(const Duration(seconds: 9));
          expect(vm.bloqueado, isTrue,
              reason: 'Después de 9 s todavía debe estar bloqueado');

          // Avanzar el segundo restante: bloqueo expira
          fake.elapse(const Duration(seconds: 1));
          expect(vm.bloqueado, isFalse,
              reason: 'Tras 10 s el bloqueo debe haber expirado');
          expect(vm.fallosConsecutivos, 0,
              reason: 'El contador se reinicia al expirar el bloqueo');

          vm.dispose();
        });
      },
    );
  });
}
