import 'package:flutter/material.dart';

class DashboardBackground extends StatelessWidget {
  const DashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      colorScheme.surface,
                      colorScheme.surfaceContainer,
                      colorScheme.surfaceContainerHigh,
                      colorScheme.surface,
                    ]
                  : const [
                      Color(0xFFF5FBF3),
                      Color(0xFFE8F6E5),
                      Color(0xFFD3EFD8),
                      Color(0xFFF0F9EE),
                    ],
              stops: [0.0, 0.35, 0.72, 1.0],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned(
          top: -70,
          left: -60,
          child: _SoftOrb(
            size: 220,
            colors: [
              Colors.white.withValues(alpha: 0.35),
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
        Positioned(
          top: 120,
          right: -40,
          child: _SoftOrb(
            size: 170,
            colors: [
              const Color(0xFFB7E4C7).withValues(alpha: 0.22),
              const Color(0xFFB7E4C7).withValues(alpha: 0.0),
            ],
          ),
        ),
        Positioned(
          bottom: -70,
          left: -30,
          child: _SoftOrb(
            size: 190,
            colors: [
              const Color(0xFF8BC34A).withValues(alpha: 0.14),
              const Color(0xFF8BC34A).withValues(alpha: 0.0),
            ],
          ),
        ),
        Positioned(
          bottom: 140,
          right: 20,
          child: _LeafAccent(
            icon: Icons.eco_rounded,
            size: 44,
            color: const Color(0xFF76B77A).withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          top: 170,
          left: 24,
          child: _LeafAccent(
            icon: Icons.spa_rounded,
            size: 36,
            color: const Color(0xFF6AAE72).withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _LeafAccent extends StatelessWidget {
  const _LeafAccent({
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
