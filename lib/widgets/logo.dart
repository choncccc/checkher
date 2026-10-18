import 'package:flutter/material.dart';

import '../theme.dart';

/// CheckHER logo. `assets/logo_transparent.png` is `assets/logo.png` cropped
/// with its white background made transparent.
class CheckHerLogo extends StatelessWidget {
  const CheckHerLogo({super.key, this.height = 80, this.showTagline = true});

  final double height;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo_transparent.png',
          height: height,
          semanticLabel: 'CheckHER',
        ),
        if (showTagline)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Blooms Through Every Season of Her Cycle',
              style: TextStyle(
                fontSize: (height * 0.14).clamp(9, 16),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Rounded white header bar with the logo, used at the top of inner screens.
class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: const Center(child: CheckHerLogo(height: 64)),
    );
  }
}

/// Aqua pill title, e.g. "Guided Self-Care".
class PillTitle extends StatelessWidget {
  const PillTitle(this.text, {super.key, this.fontSize = 24});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.aqua,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: displayStyle.copyWith(fontSize: fontSize),
      ),
    );
  }
}
