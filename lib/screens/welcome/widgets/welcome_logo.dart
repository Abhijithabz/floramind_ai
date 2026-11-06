import 'package:flutter/material.dart';

class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key, this.size = 156});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.08),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF7FBF7).withValues(alpha: 0.84),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.42),
            width: 1.4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD8F0DB),
          ),
          child: Icon(
            Icons.spa_rounded,
            size: size * 0.38,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ),
    );
  }
}
