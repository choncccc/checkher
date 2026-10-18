import 'package:flutter/material.dart';

import '../widgets/logo.dart';

/// Stand-in for screens whose layouts aren't built yet, such as the Menu
/// sidebar destinations.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const LogoHeader(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PillTitle(title, fontSize: 22),
            ),
            const Expanded(child: Center(child: Text('Coming soon'))),
          ],
        ),
        if (onBack != null)
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
          ),
      ],
    );
  }
}
