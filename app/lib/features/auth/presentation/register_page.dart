import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../incidencias/presentation/incidencias_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrarse() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'nombre': _nameController.text.trim()},
      );

      if (!mounted) return;

      if (response.session != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const IncidenciasPage(),
          ),
          (_) => false,
        );
        return;
      }

      setState(() {
        _isLoading = false;
        _successMessage =
            'Cuenta creada. Revisa tu correo para confirmar tu cuenta.';
      });
    } on AuthException catch (error) {
      _mostrarError(_mensajeDeAuth(error));
    } catch (_) {
      _mostrarError('No pudimos crear tu cuenta. Inténtalo de nuevo.');
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

    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'Ya existe una cuenta con este correo.';
    }

    if (message.contains('password')) {
      return 'La contraseña no cumple los requisitos.';
    }

    return 'Error de Supabase: ${error.message}';
  }

  String? _validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escribe tu nombre';
    }

    return null;
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
      return 'Escribe una contraseña';
    }

    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }

    return null;
  }

  String? _validarConfirmacion(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
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
                  const _RegisterHeader(),
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
                            'Crea tu cuenta',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF14213D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Empieza a gestionar tus incidencias.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: _decoracionCampo(
                              label: 'Nombre',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: _validarNombre,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
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
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_confirmPasswordVisible,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onFieldSubmitted: (_) => _registrarse(),
                            decoration: _decoracionCampo(
                              label: 'Confirmar contraseña',
                              icon: Icons.lock_reset_outlined,
                              suffixIcon: IconButton(
                                tooltip: _confirmPasswordVisible
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _confirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: _validarConfirmacion,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _RegisterMessage(
                              message: _errorMessage!,
                              isSuccess: false,
                            ),
                          ],
                          if (_successMessage != null) ...[
                            const SizedBox(height: 16),
                            _RegisterMessage(
                              message: _successMessage!,
                              isSuccess: true,
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _registrarse,
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
                                      'Crear cuenta',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Ya tengo una cuenta · Iniciar sesión'),
                  ),
                  const SizedBox(height: 8),
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

class _RegisterMessage extends StatelessWidget {
  const _RegisterMessage({required this.message, required this.isSuccess});

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSuccess
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF1F2);
    final borderColor = isSuccess
        ? const Color(0xFFA7F3D0)
        : const Color(0xFFFECACA);
    final textColor = isSuccess
        ? const Color(0xFF047857)
        : const Color(0xFF991B1B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
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
