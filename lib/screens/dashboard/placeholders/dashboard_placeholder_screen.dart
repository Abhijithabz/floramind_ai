import 'package:flutter/material.dart';

import '../widgets/dashboard_background.dart';
import '../widgets/dashboard_placeholder_body.dart';

class DashboardPlaceholderScreen extends StatelessWidget {
  const DashboardPlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: DashboardPlaceholderBody(
              title: title,
              description: description,
              icon: icon,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
