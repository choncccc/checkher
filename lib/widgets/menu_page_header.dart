import 'package:flutter/material.dart';

import '../screens/assessment/assessment_widgets.dart';
import 'logo.dart';

/// Top of the Menu feature pages (page 20 on): back button, stacked logo and a
/// spaced-out title.
class MenuPageHeader extends StatelessWidget {
  const MenuPageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 6,
        16,
        10,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 8,
            child: RoundBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const CheckHerLogo(height: 52, showTagline: false),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
