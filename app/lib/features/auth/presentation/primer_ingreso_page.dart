import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/navigation/dark_route.dart';
import '../../incidencias/presentation/incidencias_page.dart';

// Paleta
const _kNavy     = Color(0xFF0D1B3E);
const _kNavyMid  = Color(0xFF0F2347);
const _kNavyCard = Color(0xFF162852);
const _kBlue     = Color(0xFF2563EB);
const _kBlueLight = Color(0xFF3B82F6);
const _kWhite    = Colors.white;
const _kWhite70  = Color(0xB3FFFFFF);
const _kWhite40  = Color(0x66FFFFFF);
const _kWhite15  = Color(0x26FFFFFF);

class PrimerIngresoPage extends StatefulWidget {
  const PrimerIngresoPage({super.key});

  @override
  State<PrimerIngresoPage> createState() => _PrimerIngresoPageState();
}

class _PrimerIngresoPageState extends State<PrimerIngresoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _irAIncidencias() {
    Navigator.of(context).pushAndRemoveUntil(
      darkRoute(page: const IncidenciasPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // ── Fondo decorativo ────────────────────────────────────
          Positioned(
            top: -size.height * 0.12,
            right: -size.width * 0.2,
            child: _Glow(size: size.width * 0.7, color: _kBlue.withAlpha(38)),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: _Glow(size: size.width * 0.75, color: _kBlue.withAlpha(28)),
          ),

          // ── Contenido ───────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Logo + Bienvenido ──────────────────────
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kBlue.withAlpha(70),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '¡Bienvenido!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: _kWhite,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Para comenzar, selecciona\nuna opción:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: _kWhite70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // ── Tarjeta: Crear empresa ─────────────────
                        _OpcionCard(
                          imagePath: 'assets/images/empresa.png',
                          titulo: 'Crear nueva empresa',
                          descripcion:
                              'Registra tu facultad, sede\no dependencia.',
                          color: _kBlue,
                          onTap: _irAIncidencias, // por ahora va a incidencias
                        ),

                        const SizedBox(height: 16),

                        // ── Tarjeta: Unirme ────────────────────────
                        _OpcionCard(
                          imagePath: 'assets/images/unirme.png',
                          titulo: 'Unirme a una empresa',
                          descripcion:
                              'Ingresa el código de invitación\nque te proporcionaron.',
                          color: _kBlueLight,
                          onTap: _irAIncidencias, // por ahora va a incidencias
                        ),

                        const SizedBox(height: 28),

                        // ── Más información ────────────────────────
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) => const _InfoDialog(),
                              );
                            },
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: _kBlueLight,
                            ),
                            label: const Text(
                              'Más información',
                              style: TextStyle(
                                color: _kBlueLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ── Tarjeta de opción ─────────────────────────────────────────────────────────

class _OpcionCard extends StatefulWidget {
  const _OpcionCard({
    required this.imagePath,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  final String imagePath;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_OpcionCard> createState() => _OpcionCardState();
}

class _OpcionCardState extends State<_OpcionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kNavyCard.withAlpha(220),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.color.withAlpha(80),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withAlpha(25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Ícono en círculo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.color.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        widget.imagePath,
                        color: widget.color,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _kWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.descripcion,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _kWhite70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Flecha
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: widget.color,
                      size: 14,
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

// ── Diálogo de info ───────────────────────────────────────────────────────────

class _InfoDialog extends StatelessWidget {
  const _InfoDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF162852),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '¿Cómo funciona?',
        style: TextStyle(color: _kWhite, fontWeight: FontWeight.w700),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoItem(
            icon: Icons.business_rounded,
            color: _kBlue,
            texto: 'Crear empresa: ideal si eres administrador y quieres registrar tu institución.',
          ),
          SizedBox(height: 12),
          _InfoItem(
            icon: Icons.group_add_rounded,
            color: _kBlueLight,
            texto: 'Unirme: úsalo si ya tienes un código de invitación de tu organización.',
          ),
        ],
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _kBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.color, required this.texto});
  final IconData icon;
  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(color: _kWhite70, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// ── Widget auxiliar ───────────────────────────────────────────────────────────

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
