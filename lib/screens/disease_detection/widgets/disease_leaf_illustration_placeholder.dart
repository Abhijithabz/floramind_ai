import 'package:flutter/material.dart';

class DiseaseLeafIllustrationPlaceholder extends StatelessWidget {
  const DiseaseLeafIllustrationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1.24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.88),
              colorScheme.secondaryContainer.withValues(alpha: 0.82),
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
              child: _FloatingBubble(
                icon: Icons.bug_report_rounded,
                iconColor: const Color(0xFF8D6E63),
                backgroundColor: Colors.white.withValues(alpha: 0.50),
              ),
            ),
            Positioned(
              top: 28,
              right: 26,
              child: _FloatingBubble(
                icon: Icons.local_florist_rounded,
                iconColor: const Color(0xFF2D6A4F),
                backgroundColor: Colors.white.withValues(alpha: 0.42),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              child: _FloatingBubble(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF1B4332),
                backgroundColor: Colors.white.withValues(alpha: 0.44),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 156,
                  height: 156,
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
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 132,
                      height: 106,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A4E2D),
                        borderRadius: BorderRadius.circular(28),
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
                      bottom: 0,
                      child: SizedBox(
                        width: 112,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 22,
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
                              left: 8,
                              bottom: 46,
                              child: Transform.rotate(
                                angle: -0.52,
                                child: _Leaf(
                                  color: const Color(0xFF52B788),
                                  size: 30,
                                  spots: true,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 52,
                              child: Transform.rotate(
                                angle: 0.46,
                                child: _Leaf(
                                  color: const Color(0xFF74C69D),
                                  size: 34,
                                  spots: false,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 34,
                              bottom: 68,
                              child: Transform.rotate(
                                angle: -0.10,
                                child: _Leaf(
                                  color: const Color(0xFF40916C),
                                  size: 38,
                                  spots: true,
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
          ],
        ),
      ),
    );
  }
}

class _FloatingBubble extends StatelessWidget {
  const _FloatingBubble({
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
    required this.spots,
  });

  final Color color;
  final double size;
  final bool spots;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
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
        ),
        if (spots)
          Positioned(
            top: size * 0.18,
            left: size * 0.16,
            child: Container(
              width: size * 0.18,
              height: size * 0.18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.brown.withValues(alpha: 0.28),
              ),
            ),
          ),
      ],
    );
  }
}
