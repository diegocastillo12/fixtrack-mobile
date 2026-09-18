# fixtrack-mobile

## Examen práctico Unidad I — Tipo 1

- `app/lib/features/auth/presentation/login_page.dart`: valida correo y contraseña antes del envío, muestra errores en la vista y deshabilita el botón con spinner durante la solicitud.
- `app/lib/features/auth/domain/login_controller.dart`: cuenta fallos consecutivos y bloquea el cuarto intento durante 30 segundos sin llamar al servicio.
- `app/lib/features/auth/data/supabase_auth_gateway.dart`: conecta el caso de uso con Supabase y almacena el token localmente.
- `app/lib/core/network/dio_client.dart`: detecta HTTP 401 en una petición autenticada, ejecuta el cierre de sesión y no reintenta la solicitud.
- `app/lib/features/incidencias/data/incidencia_repository_impl.dart`, `app/lib/core/navigation/app_navigator.dart` y `app/lib/main.dart`: eliminan el token, cierran la sesión Supabase y vuelven a login al recibir 401.
- `app/test/examen_tipo1_test.dart`: cinco pruebas unitarias sin emulador ni red: estado inicial, éxito, rechazo, bloqueo y 401.

Comando de pruebas: `cd app` y `flutter test test/examen_tipo1_test.dart`.

### Demostración del HTTP 401 en el emulador

En una terminal dentro de `app`, ejecutar `python tools/mock_401_server.py`. El servidor local responde 401 a `GET /incidencias` y muestra el número de solicitud y si llegó el encabezado `Authorization`, sin revelar el token. En otra terminal, iniciar la app en el emulador con `C:\flutter\bin\flutter.bat run -d emulator-5554`. Tras iniciar sesión con una cuenta válida de Supabase, la pantalla de incidencias solicita el recurso en `http://10.0.2.2:4010`; el 401 limpia el token, cierra la sesión y regresa al login. La autorización de HTTP local se limita al manifest de depuración `app/android/app/src/debug/AndroidManifest.xml`. La prueba unitaria `e` demuestra además que solo se envía una petición.
Aplicación móvil para la gestión de activos y seguimiento de incidencias mediante códigos QR.
