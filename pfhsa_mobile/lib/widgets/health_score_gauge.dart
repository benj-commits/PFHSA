import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A hand-drawn-dial-style gauge for the 0-100 Financial Health Score.
/// Deliberately not a stock progress ring: it has tick marks like a
/// physical meter, and the arc color shifts with the rating so the
/// verdict is legible at a glance.
class HealthScoreGauge extends StatelessWidget {
  final int score;
  final String rating;
  final String emoji;

  const HealthScoreGauge({
    super.key,
    required this.score,
    required this.rating,
    required this.emoji,
  });

  Color get _arcColor {
    if (score >= 80) return AppColors.pine;
    if (score >= 60) return AppColors.pine;
    if (score >= 40) return AppColors.brass;
    return AppColors.clay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _GaugePainter(score: score, color: _arcColor),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$score', style: AppTextStyles.display(56, color: AppColors.ink)),
                  Text('/ 100', style: AppTextStyles.mono(13, color: AppColors.mutedInk)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('$emoji  $rating', style: AppTextStyles.body(16, weight: FontWeight.w600, color: _arcColor)),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;
  _GaugePainter({required this.score, required this.color});

  static const double _startAngle = math.pi * 0.75; // 135deg
  static const double _sweepAngle = math.pi * 1.5; // 270deg total

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), _startAngle, _sweepAngle, false, trackPaint);

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final scoreSweep = _sweepAngle * (score.clamp(0, 100) / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), _startAngle, scoreSweep, false, scorePaint);

    // Tick marks every 10 points, like a dial gauge
    final tickPaint = Paint()
      ..color = AppColors.mutedInk.withOpacity(0.5)
      ..strokeWidth = 1.5;
    for (int i = 0; i <= 10; i++) {
      final angle = _startAngle + _sweepAngle * (i / 10);
      final outer = Offset(center.dx + (radius + 10) * math.cos(angle), center.dy + (radius + 10) * math.sin(angle));
      final inner = Offset(center.dx + (radius + 3) * math.cos(angle), center.dy + (radius + 3) * math.sin(angle));
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
