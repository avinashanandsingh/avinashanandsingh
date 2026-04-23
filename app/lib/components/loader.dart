import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Loader extends StatelessWidget {
  final String? message;

  const Loader({super.key, this.message});

  /// Shows the loading overlay.
  /// Use [message] to display a custom text below the spinner.
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(80),
      builder: (context) => Loader(message: message),
    );
  }

  /// Hides the loading overlay.
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surface.withAlpha(160)
                      : Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(40)
                        : colorScheme.primary.withAlpha(30),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(isDark ? 40 : 20),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PremiumSpinner(color: colorScheme.primary),
                    if (message != null) ...[
                      const SizedBox(height: 28),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumSpinner extends StatefulWidget {
  final Color color;

  const _PremiumSpinner({required this.color});

  @override
  State<_PremiumSpinner> createState() => _PremiumSpinnerState();
}

class _PremiumSpinnerState extends State<_PremiumSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withAlpha(20),
                    width: 4,
                  ),
                ),
                child: CircularProgressIndicator(
                  value: 0.25,
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  backgroundColor: Colors.transparent,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            // Inner pulsing glow
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withAlpha(
                  (15 *
                          (1 +
                              (0.5 *
                                  (1 - (2 * (_controller.value - 0.5)).abs()))))
                      .toInt(),
                ),
              ),
            ),
            // Center Icon
            Icon(Icons.auto_awesome, color: widget.color, size: 24),
            // Expanding pulse ring
            Opacity(
              opacity: 1 - _controller.value,
              child: Container(
                width: 44 + (40 * _controller.value),
                height: 44 + (40 * _controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withAlpha(100),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
