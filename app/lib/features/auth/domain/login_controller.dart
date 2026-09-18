/// Lógica de autenticación independiente de Flutter y de la red.
abstract class AuthGateway {
  Future<String> signIn(String email, String password);
}

abstract class TokenStore {
  Future<void> save(String token);
  Future<void> clear();
}

enum LoginStatus { unauthenticated, loading, authenticated, error, blocked }

class LoginController {
  LoginController({
    required this.gateway,
    required this.tokens,
    DateTime Function()? now,
    this.lockDuration = const Duration(seconds: 30),
  }) : _now = now ?? DateTime.now;

  final AuthGateway gateway;
  final TokenStore tokens;
  final DateTime Function() _now;
  final Duration lockDuration;

  LoginStatus status = LoginStatus.unauthenticated;
  String? error;
  int failedAttempts = 0;
  DateTime? lockedUntil;

  /// El cuarto envío no llega al servicio después de tres fallos seguidos.
  Future<bool> signIn(String email, String password) async {
    if (status == LoginStatus.loading) return false;
    if (lockedUntil != null && _now().isBefore(lockedUntil!)) {
      status = LoginStatus.blocked;
      error = 'Demasiados intentos. Espera 30 segundos e inténtalo de nuevo.';
      return false;
    }
    if (lockedUntil != null) {
      lockedUntil = null;
      failedAttempts = 0;
    }
    if (failedAttempts >= 3) {
      lockedUntil = _now().add(lockDuration);
      status = LoginStatus.blocked;
      error = 'Demasiados intentos. Espera 30 segundos e inténtalo de nuevo.';
      return false;
    }
    status = LoginStatus.loading;
    error = null;
    try {
      final token = await gateway.signIn(email.trim(), password);
      await tokens.save(token);
      failedAttempts = 0;
      status = LoginStatus.authenticated;
      return true;
    } catch (_) {
      failedAttempts++;
      status = LoginStatus.error;
      error = 'El correo o la contraseña no son correctos.';
      return false;
    }
  }
}
