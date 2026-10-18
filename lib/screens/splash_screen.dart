import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../data/services.dart';
import '../models/user.dart';
import '../theme.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

/// Page 2: the wordmark inside an oblong whose aqua outline doubles as the
/// loading bar. Routes to login, or straight into the app if a session was
/// saved on this device.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // The oblong outline fills as the loading bar.
  late final _loading = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  Future<void> _run() async {
    // Start loading the session right away; the animation only paces it.
    final userFuture = Services.of(context).auth.currentUser();
    await _loading.animateTo(0.85, curve: Curves.easeInOut);
    final user = await userFuture;
    await _loading.animateTo(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (mounted) _go(user);
  }

  void _go(AppUser? user) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) =>
            user == null ? const LoginScreen() : MainShell(user: user),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _LoadingOblong(progress: _loading),
        ),
      ),
    );
  }
}

/// Page 2: wordmark inside an oblong; the outline traces around as [progress]
/// goes from 0 to 1, ending exactly like the layout.
class _LoadingOblong extends StatelessWidget {
  const _LoadingOblong({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading CheckHER',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AspectRatio(
          // Proportions of the oblong in the layout (526 × 150 pt).
          aspectRatio: 526 / 150,
          child: LayoutBuilder(
            builder: (context, c) {
              final stroke = c.maxWidth * 0.026; // 13.4 pt on 526 pt
              return CustomPaint(
                painter: _OblongPainter(progress, stroke),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: stroke * 2.2,
                    vertical: stroke * 1.9,
                  ),
                  child: Image.asset(
                    'assets/wordmark.png',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OblongPainter extends CustomPainter {
  _OblongPainter(this.progress, this.stroke) : super(repaint: progress);

  final Animation<double> progress;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height / 2),
    );

    // Faint track so the bar's full shape is visible while it fills.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.aqua.withAlpha(45),
    );

    // Trace clockwise starting from the middle of the left edge.
    final r = rect.height / 2;
    final path = Path()
      ..moveTo(rect.left, rect.center.dy)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r))
      ..lineTo(rect.right - r, rect.top)
      ..arcToPoint(
        Offset(rect.right - r, rect.bottom),
        radius: Radius.circular(r),
      )
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.center.dy),
        radius: Radius.circular(r),
      );
    final PathMetric metric = path.computeMetrics().first;
    final t = progress.value.clamp(0.0, 1.0);
    if (t == 0) return;
    canvas.drawPath(
      metric.extractPath(0, metric.length * t),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = t < 1 ? StrokeCap.round : StrokeCap.butt
        ..color = AppColors.aqua,
    );
  }

  @override
  bool shouldRepaint(_OblongPainter old) => old.stroke != stroke;
}
