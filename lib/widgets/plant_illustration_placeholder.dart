import 'package:flutter/material.dart';

class PlantIllustrationPlaceholder extends StatelessWidget {
  const PlantIllustrationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.90),
              colorScheme.secondaryContainer.withValues(alpha: 0.85),
            ],
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 22,
              left: 22,
              child: _LeafBubble(
                icon: Icons.spa_rounded,
                iconColor: const Color(0xFF2D6A4F),
                backgroundColor: Colors.white.withValues(alpha: 0.50),
              ),
            ),
            Positioned(
              top: 28,
              right: 26,
              child: _LeafBubble(
                icon: Icons.bubble_chart_rounded,
                iconColor: const Color(0xFF40916C),
                backgroundColor: Colors.white.withValues(alpha: 0.40),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              child: _LeafBubble(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF1B4332),
                backgroundColor: Colors.white.withValues(alpha: 0.44),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.90),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 108,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A4E2D),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 2,
                      child: Container(
                        width: 128,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB08968),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 36,
                      child: SizedBox(
                        width: 100,
                        height: 110,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 20,
                              child: Container(
                                width: 4,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D6A4F),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              bottom: 42,
                              child: Transform.rotate(
                                angle: -0.55,
                                child: _Leaf(
                                  color: const Color(0xFF52B788),
                                  size: 30,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 48,
                              child: Transform.rotate(
                                angle: 0.45,
                                child: _Leaf(
                                  color: const Color(0xFF74C69D),
                                  size: 34,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 38,
                              bottom: 68,
                              child: Transform.rotate(
                                angle: -0.12,
                                child: _Leaf(
                                  color: const Color(0xFF40916C),
                                  size: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeafBubble extends StatelessWidget {
  const _LeafBubble({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size),
          topRight: Radius.circular(size),
          bottomLeft: Radius.circular(size * 0.35),
          bottomRight: Radius.circular(size * 0.35),
        ),
      ),
    );
  }
}
