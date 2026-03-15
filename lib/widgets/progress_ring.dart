import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress;   // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final String centerText;
  final Color? color;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size        = 80,
    this.strokeWidth = 8,
    this.centerText  = '',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width:  size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween:    Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve:    Curves.easeOutCubic,
            builder: (_, value, __) => CircularProgressIndicator(
              value:           value,
              strokeWidth:     strokeWidth,
              strokeCap:       StrokeCap.round,
              color:           color ?? colors.primary,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          if (centerText.isNotEmpty)
            Text(
              centerText,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize:   size * 0.18,
                color:      color ?? colors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
