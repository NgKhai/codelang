// lib/presentation/widgets/alc/score_indicator.dart
// Circular score indicator widget with animations

import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScoreIndicator extends StatefulWidget {
  final int score;
  final String label;
  final double size;
  final Color? color;

  const ScoreIndicator({
    super.key,
    required this.score,
    required this.label,
    this.size = 80,
    this.color,
  });

  @override
  State<ScoreIndicator> createState() => _ScoreIndicatorState();
}

class _ScoreIndicatorState extends State<ScoreIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(ScoreIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score / 100,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(BuildContext context, int score) {
    if (widget.color != null) return widget.color!;
    final colorScheme = Theme.of(context).colorScheme;
    
    if (score >= 70) return colorScheme.primary;
    if (score >= 40) return colorScheme.tertiary;
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scoreColor = _getScoreColor(context, widget.score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 5,
                      backgroundColor: colorScheme.outlineVariant.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // Animated progress circle
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: _animation.value,
                        color: scoreColor,
                        strokeWidth: 5,
                      ),
                    ),
                  ),
                  // Score text
                  Text(
                    '${(_animation.value * 100).round()}',
                    style: TextStyle(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
