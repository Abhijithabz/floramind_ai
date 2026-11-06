import 'package:flutter/material.dart';

class WelcomeBackground extends StatelessWidget {
  const WelcomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF4FBF3),
            Color(0xFFE3F3E1),
            Color(0xFFEFF8EA),
          ],
          stops: [0.0, 0.52, 1.0],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
