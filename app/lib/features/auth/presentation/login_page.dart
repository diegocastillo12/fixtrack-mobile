import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/dark_route.dart';
import 'primer_ingreso_page.dart';
import 'register_page.dart';

// Paleta del logo de FixTrack
const _kNavy = Color(0xFF0D1B3E);      // azul marino oscuro (fondo)
const _kNavyLight = Color(0xFF162852);  // azul un poco más claro (card)
const _kBlue = Color(0xFF2563EB);       // azul brillante (acento)
const _kBlueLight = Color(0xFF3B82F6);  // azul claro
const _kWhite = Colors.white;
const _kWhite60 = Color(0x99FFFFFF);    // blanco 60%
const _kWhite15 = Color(0x26FFFFFF);    // blanco 15% (bordes glass)
const _kRed = Color(0xFFEF4444);

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
    if (!_formKey.currentState!.validate()) return;

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
        darkRoute(page: const PrimerIngresoPage()),
        (_) => false,
      );
    } on AuthException catch (error) {
      // ignore: avoid_print
      print('[FixTrack] AuthException: ${error.message} | code: ${error.statusCode}');
      _mostrarError(_mensajeDeAuth(error));
    } catch (e) {
      // ignore: avoid_print
      print('[FixTrack] Error inesperado en login: $e');
      _mostrarError('No pudimos iniciar sesión. Inténtalo de nuevo.\n($e)');
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
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'El correo o la contraseña no son correctos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirma tu correo electrónico para continuar.';
    }
    return 'Error: ${error.message}';
  }

  String? _validarCorreo(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Escribe tu correo electrónico';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Escribe un correo válido';
    }
    return null;
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) return 'Escribe tu contraseña';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  InputDecoration _field({required String label, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _kWhite60, fontSize: 14),
      prefixIcon: Icon(icon, color: _kWhite60, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _kWhite15,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kWhite15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kWhite15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kRed, width: 1.5),
      ),
      errorStyle: const TextStyle(color: _kRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // ── Fondo con círculos decorativos ──────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _GlowCircle(size: 260, color: _kBlue.withAlpha(40)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _GlowCircle(size: 300, color: _kBlue.withAlpha(30)),
          ),
          Positioned(
            top: 160,
            left: -40,
            child: _GlowCircle(size: 140, color: _kBlueLight.withAlpha(20)),
          ),

          // ── Contenido ────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo + nombre
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 88,
                              width: 88,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'FixTrack',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: _kWhite,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Todo bajo control',
                            style: TextStyle(
                              fontSize: 14,
                              color: _kWhite60,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // ── Tarjeta glass ──────────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _kNavyLight.withAlpha(200),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _kWhite15, width: 1),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Inicia sesión',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: _kWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Accede a tu panel de incidencias.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _kWhite60,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.username],
                                    style: const TextStyle(color: _kWhite),
                                    decoration: _field(
                                      label: 'Correo electrónico',
                                      icon: Icons.alternate_email_rounded,
                                    ),
                                    validator: _validarCorreo,
                                  ),
                                  const SizedBox(height: 16),

                                  // Contraseña
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_passwordVisible,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [AutofillHints.password],
                                    onFieldSubmitted: (_) => _iniciarSesion(),
                                    style: const TextStyle(color: _kWhite),
                                    decoration: _field(
                                      label: 'Contraseña',
                                      icon: Icons.lock_outline_rounded,
                                      suffix: IconButton(
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
                                          color: _kWhite60,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    validator: _validarPassword,
                                  ),

                                  // Error
                                  if (_errorMessage != null) ...[
                                    const SizedBox(height: 16),
                                    _ErrorBanner(message: _errorMessage!),
                                  ],

                                  const SizedBox(height: 24),

                                  // Botón entrar
                                  SizedBox(
                                    height: 52,
                                    child: FilledButton(
                                      onPressed: _isLoading ? null : _iniciarSesion,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _kBlue,
                                        disabledBackgroundColor: _kBlue.withAlpha(100),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: _kWhite,
                                              ),
                                            )
                                          : const Text(
                                              'Entrar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: _kWhite,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Divisor
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(color: _kWhite15, thickness: 1),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'O continúa con',
                                          style: TextStyle(
                                            color: _kWhite60,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(color: _kWhite15, thickness: 1),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Botón Google
                                  SizedBox(
                                    height: 52,
                                    child: OutlinedButton(
                                      onPressed: _isLoading ? null : _iniciarSesionConGoogle,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: _kWhite15, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        backgroundColor: _kWhite15,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/google.png',
                                            height: 22,
                                            width: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Continuar con Google',
                                            style: TextStyle(
                                              color: _kWhite,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Crear cuenta
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            Navigator.of(context).push(
                                              darkRoute(page: const RegisterPage()),
                                            );
                                          },
                                    child: const Text(
                                      '¿No tienes cuenta? Crear una cuenta',
                                      style: TextStyle(
                                        color: _kBlueLight,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                      const Text(
                        'FixTrack · Gestión de incidencias',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _kWhite60,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kRed.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kRed.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: _kRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _kRed,
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