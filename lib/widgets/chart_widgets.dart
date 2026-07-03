import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class LineChartCard extends StatelessWidget {
  const LineChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  final String title;
  final String subtitle;
  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return SizedBox(
                height: 240,
                child: CustomPaint(
                  painter: _LinePainter(points: points, progress: progress),
                  child: child,
                ),
              );
            },
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }
}

class DonutChartCard extends StatelessWidget {
  const DonutChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    this.holeFraction = 0.62,
  });

  final String title;
  final String subtitle;
  final List<ChartPoint> points;
  final double holeFraction;

  @override
  Widget build(BuildContext context) {
    final colors = _chartColors(points.length);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) {
                return CustomPaint(
                  painter: _DonutPainter(
                    points: points,
                    progress: progress,
                    colors: colors,
                    holeFraction: holeFraction,
                  ),
                  child: child,
                );
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${points.first.value.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      points.first.label,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (var i = 0; i < points.length; i++)
                _LegendDot(
                  label: points[i].label,
                  value: '${points[i].value.toStringAsFixed(0)}%',
                  color: colors[i],
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _chartColors(int count) {
    final palette = [AppColors.primary, AppColors.info, AppColors.success, AppColors.warning];
    return List.generate(count, (index) => palette[index % palette.length]);
  }
}

class MiniChartCard extends StatelessWidget {
  const MiniChartCard({
    super.key,
    required this.title,
    required this.type,
    required this.points,
    required this.interpretation,
    required this.accent,
  });

  final String title;
  final ChartType type;
  final List<ChartPoint> points;
  final String interpretation;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _MiniChartBody(
      title: title,
      type: type,
      points: points,
      interpretation: interpretation,
      accent: accent,
    );
  }
}

class _MiniChartBody extends StatefulWidget {
  const _MiniChartBody({
    required this.title,
    required this.type,
    required this.points,
    required this.interpretation,
    required this.accent,
  });

  final String title;
  final ChartType type;
  final List<ChartPoint> points;
  final String interpretation;
  final Color accent;

  @override
  State<_MiniChartBody> createState() => _MiniChartBodyState();
}

class _MiniChartBodyState extends State<_MiniChartBody> {
  bool _showInterpretation = false;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              StatusBadge(label: widget.type.name.toUpperCase(), color: widget.accent),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChartToggle(
                label: 'Chart',
                selected: !_showInterpretation,
                onTap: () => setState(() => _showInterpretation = false),
              ),
              ChartToggle(
                label: 'Interpretation',
                selected: _showInterpretation,
                onTap: () => setState(() => _showInterpretation = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _showInterpretation
                ? _InterpretationBody(
                    key: const ValueKey('interpretation'),
                    text: widget.interpretation,
                  )
                : _buildChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (widget.type) {
      case ChartType.bar:
        return _BarChart(points: widget.points, accent: widget.accent);
      case ChartType.line:
        return _SmallLineChart(points: widget.points, accent: widget.accent);
      case ChartType.donut:
        return _SmallDonutChart(points: widget.points, accent: widget.accent, hole: 0.66);
      case ChartType.pie:
        return _SmallDonutChart(points: widget.points, accent: widget.accent, hole: 0.30);
      case ChartType.horizontalBar:
        return _HorizontalBarChart(points: widget.points, accent: widget.accent);
    }
  }
}

class _InterpretationBody extends StatelessWidget {
  const _InterpretationBody({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(height: 1.5),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }
}

class _SmallLineChart extends StatelessWidget {
  const _SmallLineChart({required this.points, required this.accent});

  final List<ChartPoint> points;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _LinePainter(points: points, progress: 1, accent: accent),
      ),
    );
  }
}

class _SmallDonutChart extends StatelessWidget {
  const _SmallDonutChart({
    required this.points,
    required this.accent,
    required this.hole,
  });

  final List<ChartPoint> points;
  final Color accent;
  final double hole;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: _DonutPainter(
              points: points,
              progress: 1,
              colors: [accent],
              holeFraction: hole,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${points.first.value.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Text(
                'Completed',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HorizontalBarChart extends StatelessWidget {
  const _HorizontalBarChart({
    required this.points,
    required this.accent,
  });

  final List<ChartPoint> points;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final max = points.map((e) => e.value).reduce(math.max);
    return Column(
      children: points
          .map(
            (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      point.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: point.value / max,
                        minHeight: 14,
                        backgroundColor: AppColors.inputBg,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 28,
                    child: Text(
                      point.value.toStringAsFixed(0),
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.points, required this.accent});

  final List<ChartPoint> points;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final max = points.map((e) => e.value).reduce(math.max);
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in points) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    point.value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 130 * (point.value / max),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    point.label.split(' ').first,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (point != points.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.points,
    required this.progress,
    this.accent = AppColors.primary,
  });

  final List<ChartPoint> points;
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const padding = 18.0;
    final plotWidth = size.width - padding * 2;
    final plotHeight = size.height - padding * 2;
    final max = points.map((e) => e.value).reduce(math.max);
    final min = points.map((e) => e.value).reduce(math.min);
    final range = (max - min).abs() < 0.001 ? 1.0 : max - min;

    final gridPaint = Paint()
      ..color = AppColors.inputBorder.withValues(alpha: 0.7)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = padding + plotHeight * (i / 3);
      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    final pointsPath = Path();
    final fillPath = Path();
    final pointOffsets = <Offset>[];

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = padding + plotWidth * (i / (points.length - 1));
      final y = padding + plotHeight * (1 - ((point.value - min) / range));
      final offset = Offset(x, y);
      pointOffsets.add(offset);
    }

    for (var i = 0; i < pointOffsets.length; i++) {
      final offset = pointOffsets[i];
      final target = i == 0
          ? offset
          : Offset.lerp(pointOffsets[i - 1], offset, progress.clamp(0, 1))!;
      if (i == 0) {
        pointsPath.moveTo(target.dx, target.dy);
        fillPath.moveTo(target.dx, size.height - padding);
        fillPath.lineTo(target.dx, target.dy);
      } else {
        pointsPath.lineTo(target.dx, target.dy);
        fillPath.lineTo(target.dx, target.dy);
      }
    }

    fillPath.lineTo(pointOffsets.last.dx, size.height - padding);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.28),
            accent.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      pointsPath,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final offset in pointOffsets) {
      canvas.drawCircle(
        offset,
        4.5,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        offset,
        6.5,
        Paint()
          ..color = accent.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final labelStyle = const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = padding + plotWidth * (i / (points.length - 1));
      final textPainter = TextPainter(
        text: TextSpan(text: point.label, style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: 48);
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 12));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.progress != progress ||
        oldDelegate.accent != accent;
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.points,
    required this.progress,
    required this.colors,
    this.holeFraction = 0.62,
  });

  final List<ChartPoint> points;
  final double progress;
  final List<Color> colors;
  final double holeFraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final total = points.fold<double>(0, (sum, point) => sum + point.value);
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 12;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = radius * (1 - holeFraction);
    final rect = Rect.fromCircle(center: center, radius: radius);
    var start = -math.pi / 2;

    for (var i = 0; i < points.length; i++) {
      final sweep = (points[i].value / total) * math.pi * 2 * progress;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }

    canvas.drawCircle(
      center,
      radius * holeFraction,
      Paint()..color = AppColors.card,
    );
    canvas.drawCircle(
      center,
      radius * holeFraction,
      Paint()
        ..color = AppColors.inputBorder.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.holeFraction != holeFraction;
  }
}
