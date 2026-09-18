import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../incidencias/presentation/incidencias_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const IncidenciasPage(),
        ),
        (_) => false,
      );
    } on AuthException catch (error) {
      _mostrarError(_mensajeDeAuth(error));
    } catch (_) {
      _mostrarError('No pudimos iniciar sesión. Inténtalo de nuevo.');
    }
  }

  Future<void> _iniciarSesionConGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final redirectUrl = Uri.base.origin;

      final iniciado = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );

      if (!iniciado && mounted) {
        _mostrarError('No se pudo abrir el inicio de sesión con Google.');
      }
    } on AuthException catch (error) {
      _mostrarError(error.message);
    } catch (_) {
      _mostrarError('No se pudo iniciar sesión con Google.');
    }
  }

  void _mostrarError(String message) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  String _mensajeDeAuth(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'El correo o la contraseña no son correctos.';
    }

    if (message.contains('email not confirmed')) {
      return 'Confirma tu correo electrónico para continuar.';
    }

    return 'No pudimos validar tus datos. Inténtalo de nuevo.';
  }

  String? _validarCorreo(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Escribe tu correo electrónico';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Escribe un correo válido';
    }

    return null;
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Escribe tu contraseña';
    }

    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }

    return null;
  }

  InputDecoration _decoracionCampo({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Encabezado(theme: theme),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE4E9EE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F172A),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Inicia sesión',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF14213D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Accede a tu panel de incidencias.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            decoration: _decoracionCampo(
                              label: 'Correo electrónico',
                              icon: Icons.alternate_email_rounded,
                            ),
                            validator: _validarCorreo,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _iniciarSesion(),
                            decoration: _decoracionCampo(
                              label: 'Contraseña',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                tooltip: _passwordVisible
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: _validarPassword,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _MensajeError(message: _errorMessage!),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _iniciarSesion,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                disabledBackgroundColor:
                                    const Color(0xFF94A3B8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('O continúa con'),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _iniciarSesionConGoogle,
                              icon: const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                              label: const Text('Continuar con Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF14213D),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                            child: const Text('Crear una cuenta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'FixTrack · Gestión de incidencias',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.handyman_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FixTrack',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF14213D),
              ),
            ),
            Text(
              'Todo bajo control',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F766E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB91C1C),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}