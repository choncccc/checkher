import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/logo.dart';

/// Shared white/aqua-swirl backdrop for the login, sign-up and reset screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.showBack = false,
    this.logoHeight = 130,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBack;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(
            child: ClipRect(child: CustomPaint(painter: _SwirlPainter())),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CheckHerLogo(
                        height: logoHeight,
                        showTagline: false,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: displayStyle.copyWith(
                        fontSize: 34,
                        color: const Color(0xFF3A3A3A),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
          if (showBack)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Soft translucent aqua ribbons sweeping across the upper part of the screen,
/// echoing the swirl artwork on the layout's login page.
class _SwirlPainter extends CustomPainter {
  const _SwirlPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    void ribbon(double y0, double y1, double amp, double thickness, int alpha) {
      final path = Path()
        ..moveTo(-20, h * y0)
        ..cubicTo(
          w * 0.3,
          h * (y0 - amp),
          w * 0.6,
          h * (y1 + amp),
          w + 20,
          h * y1,
        )
        ..lineTo(w + 20, h * y1 + thickness)
        ..cubicTo(
          w * 0.6,
          h * (y1 + amp) + thickness,
          w * 0.3,
          h * (y0 - amp) + thickness,
          -20,
          h * y0 + thickness,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.aqua.withAlpha(alpha),
              AppColors.aqua.withAlpha(alpha ~/ 4),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
    }

    ribbon(0.36, 0.14, 0.10, 46, 70);
    ribbon(0.42, 0.22, 0.12, 22, 55);
    ribbon(0.30, 0.08, 0.06, 14, 45);
    // Faint matching ribbon near the bottom for balance.
    ribbon(0.98, 0.86, 0.05, 30, 35);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Aqua gradient pill button from the layout ("Login", "Sign Up").
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: softShadow,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.deepTeal.withAlpha(90)),
            gradient: const LinearGradient(
              colors: [Color(0xFF7FF0DD), Color(0xFFD9FFF8), Color(0xFF7FF0DD)],
            ),
          ),
          child: InkWell(
            onTap: busy ? null : onPressed,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepTeal,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.hint = 'Password',
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.lock_outline),
        // Keep the eye toggle out of focus traversal so the keyboard's
        // "next" action jumps to the following field, not this button.
        suffixIcon: ExcludeFocus(
          child: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }
}

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(error.toString())));
}
