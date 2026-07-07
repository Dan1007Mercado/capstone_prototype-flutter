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
    final theme = context.appTheme;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(RadiusTokens.lg),
              border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) {
                return SizedBox(
                  height: 240,
                  child: CustomPaint(
                    painter: _LinePainter(
                      points: points,
                      progress: progress,
                      gridColor: theme.outlineVariant,
                      labelColor: theme.onSurfaceVariant,
                    ),
                    child: child,
                  ),
                );
              },
              child: const SizedBox.expand(),
            ),
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
    final theme = context.appTheme;
    final colors = _chartColors(points.length);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(RadiusTokens.lg),
              border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
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
                          surfaceColor: theme.surface,
                          outlineColor: theme.outlineVariant,
                        ),
                        child: child,
                      );
                    },
                    child: const SizedBox.expand(),
                  ),
                Column(
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
                      style: TextStyle(
                        color: theme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
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
    final palette = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
    ];
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
              StatusBadge(
                label: widget.type.name.toUpperCase(),
                color: widget.accent,
              ),
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
        return _SmallDonutChart(
          points: widget.points,
          accent: widget.accent,
          hole: 0.66,
        );
      case ChartType.pie:
        // A true pie hole (0.30) is too small to fit the center label
        // without it spilling onto the colored ring, so we keep enough
        // room for the text while still reading visibly thicker than
        // the donut variant.
        return _SmallDonutChart(
          points: widget.points,
          accent: widget.accent,
          hole: 0.52,
        );
      case ChartType.horizontalBar:
        return _HorizontalBarChart(
          points: widget.points,
          accent: widget.accent,
        );
    }
  }
}
 

class _InterpretationBody extends StatelessWidget {
  const _InterpretationBody({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        border: Border.all(color: theme.outlineVariant),
      ),
      child: Text(
        text,
        style: TextStyle(height: 1.6, fontSize: 13, color: theme.onSurface),
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
    final theme = context.appTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 13, color: theme.onSurface),
        ),
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
    final theme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: CustomPaint(
          painter: _LinePainter(
            points: points,
            progress: 1,
            accent: accent,
            gridColor: theme.outlineVariant,
            labelColor: theme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Returns one distinct color per segment so a multi-category ring is
/// actually readable and comparable, instead of collapsing into one solid
/// color. Five-point Likert data gets a deliberate red→green diverging
/// scale (bad sentiment to good sentiment); anything else cycles through
/// the standard chart palette.
List<Color> _segmentColors(int count) {
  if (count == 5) {
    return const [
      AppColors.error, // Strongly Disagree
      AppColors.warning, // Disagree
      AppPalette.slate400, // Neutral
      AppColors.info, // Agree
      AppColors.success, // Strongly Agree
    ];
  }
  final palette = [
    AppColors.primary,
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    AppColors.accentPink,
  ];
  return List.generate(count, (i) => palette[i % palette.length]);
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
    final theme = context.appTheme;
    final colors = _segmentColors(points.length);
    // Highlight whichever category actually has the most responses —
    // that's the useful, comparable takeaway, not just "whatever the
    // first category happens to be".
    var dominantIndex = 0;
    for (var i = 1; i < points.length; i++) {
      if (points[i].value > points[dominantIndex].value) dominantIndex = i;
    }
    final dominant = points[dominantIndex];
    final dominantColor = colors[dominantIndex % colors.length];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(RadiusTokens.lg),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _DonutPainter(
                    points: points,
                    progress: 1,
                    colors: colors,
                    holeFraction: hole,
                    surfaceColor: theme.surface,
                    outlineColor: theme.outlineVariant,
                  ),
                ),
                // Constrain + scale the label to the actual hole diameter so it
                // can never overflow onto the colored ring and overlap itself.
                SizedBox(
                  width: 180 * hole - 16,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${dominant.value.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: dominantColor,
                              ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dominant.label,
                          style: TextStyle(
                            color: theme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            for (var i = 0; i < points.length; i++)
              _MiniLegendDot(
                label: points[i].label,
                color: colors[i % colors.length],
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniLegendDot extends StatelessWidget {
  const _MiniLegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: theme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _HorizontalBarChart extends StatelessWidget {
  const _HorizontalBarChart({required this.points, required this.accent});

  final List<ChartPoint> points;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final max = points.map((e) => e.value).reduce(math.max);
    final theme = context.appTheme;
    // Give this chart an explicit height (matching its sibling chart
    // builders, which all use a fixed SizedBox) so AnimatedSwitcher never
    // has to guess its size and every row is guaranteed to lay out fully.
    return SizedBox(
      height: points.length * 36.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: points
            .map(
              (point) => Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      point.label,
                      style: TextStyle(fontSize: 12, color: theme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : point.value / max,
                        minHeight: 12,
                        backgroundColor: theme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text(
                      point.value.toStringAsFixed(0),
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 12, color: theme.onSurface),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class TopSurveyBarChart extends StatelessWidget {
  const TopSurveyBarChart({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final List<ChartPoint> points;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(RadiusTokens.lg),
              border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _BarChart(points: points, accent: accent),
            ),
          ),
        ],
      ),
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
    final theme = context.appTheme;
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
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 130 * (point.value / max),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    point.label.split(' ').first,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: theme.onSurface),
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
    this.gridColor = AppColors.inputBorder,
    this.labelColor = AppColors.textSecondary,
  });

  final List<ChartPoint> points;
  final double progress;
  final Color accent;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const padding = 24.0;
    final plotWidth = size.width - padding * 2;
    final plotHeight = size.height - padding * 2;
    final max = points.map((e) => e.value).reduce(math.max);
    final min = points.map((e) => e.value).reduce(math.min);
    final range = (max - min).abs() < 0.001 ? 1.0 : max - min;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.7)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = padding + plotHeight * (i / 3);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
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
      canvas.drawCircle(offset, 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        offset,
        6.5,
        Paint()
          ..color = accent.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final labelStyle = TextStyle(
      color: labelColor,
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
        ellipsis: '…',
      )..layout(maxWidth: 48);

      final labelX = (x - textPainter.width / 2)
          .clamp(padding, size.width - padding - textPainter.width);
      final labelY = size.height - padding + (padding - textPainter.height - 4) / 2;

      textPainter.paint(
        canvas,
        Offset(labelX, labelY),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.points,
    required this.progress,
    required this.colors,
    this.holeFraction = 0.62,
    this.surfaceColor = AppColors.card,
    this.outlineColor = AppColors.inputBorder,
  });

  final List<ChartPoint> points;
  final double progress;
  final List<Color> colors;
  final double holeFraction;
  final Color surfaceColor;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final total = points.fold<double>(0, (sum, point) => sum + point.value);
    final center = size.center(Offset.zero);
    final baseRadius = math.min(size.width, size.height) / 2 - 12;
    final strokeWidth = baseRadius * (1 - holeFraction);
    final ringRadius = baseRadius - strokeWidth / 2;
    final holeRadius = baseRadius - strokeWidth;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    var start = -math.pi / 2;

    for (var i = 0; i < points.length; i++) {
      final sweep = (points[i].value / total) * math.pi * 2 * progress;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }

    canvas.drawCircle(
      center,
      holeRadius,
      Paint()..color = surfaceColor,
    );
    canvas.drawCircle(
      center,
      holeRadius,
      Paint()
        ..color = outlineColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.holeFraction != holeFraction ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.outlineColor != outlineColor;
  }
}