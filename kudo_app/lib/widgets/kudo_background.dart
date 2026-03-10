import 'dart:math';
import 'package:flutter/material.dart';

/// Fondo animado con orbes de gradiente que imita el efecto visual de la web
/// (la web usa imágenes/videos de fondo; aquí usamos gradientes animados)
class KudoBackground extends StatefulWidget {
  final Widget child;
  const KudoBackground({super.key, required this.child});

  @override
  State<KudoBackground> createState() => _KudoBackgroundState();
}

class _KudoBackgroundState extends State<KudoBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo base oscuro #020205
        Container(color: const Color(0xFF020205)),

        // Orbe azul (arriba izquierda) — imita el glow de la web
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _controller.value;
            return Positioned(
              top: -80 + 30 * sin(t * pi),
              left: -60 + 20 * cos(t * pi),
              child: _GradientOrb(
                size: 320,
                color: const Color(0xFF3B82F6).withAlpha(55), // azul
              ),
            );
          },
        ),

        // Orbe morado (centro derecha)
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _controller.value;
            return Positioned(
              top: 200 + 40 * cos(t * pi),
              right: -80 + 25 * sin(t * pi),
              child: _GradientOrb(
                size: 260,
                color: const Color(0xFF7C3AED).withAlpha(40), // violeta
              ),
            );
          },
        ),

        // Orbe sutil azul (abajo)
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _controller.value;
            return Positioned(
              bottom: 80 + 20 * sin(t * pi * 1.5),
              left: 60 + 30 * cos(t * pi),
              child: _GradientOrb(
                size: 200,
                color: const Color(0xFF2563EB).withAlpha(30), // azul oscuro
              ),
            );
          },
        ),

        // Contenido encima
        widget.child,
      ],
    );
  }
}

class _GradientOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GradientOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
