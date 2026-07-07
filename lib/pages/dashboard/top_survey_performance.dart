import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chart_widgets.dart';
import '../../widgets/common_widgets.dart';

class TopSurveyPerformance extends StatelessWidget {
  const TopSurveyPerformance({
    super.key,
    required this.onViewAnalytics,
  });

  final VoidCallback onViewAnalytics;

  static const List<SurveyPerformance> _performanceData = [
    SurveyPerformance(title: 'Employee Satisfaction', responses: 1245, trend: 12),
    SurveyPerformance(title: 'Customer Feedback', responses: 930, trend: 8),
    SurveyPerformance(title: 'Faculty Evaluation', responses: 811, trend: 5),
    SurveyPerformance(title: 'Course Evaluation', responses: 745, trend: -2),
    SurveyPerformance(title: 'Student Exit Survey', responses: 688, trend: 3),
  ];

  @override
  Widget build(BuildContext context) {
    
    final chartPoints = _performanceData
        .map((item) => ChartPoint(item.title, item.responses.toDouble()))
        .toList();

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionHeader(
                  title: 'Top Survey Performance',
                  subtitle: 'Most answered surveys based on total submitted responses.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _PerformanceTable(data: _performanceData)),
                        const SizedBox(width: 18),
                        SizedBox(
                          width: 380,
                          child: TopSurveyBarChart(
                            title: 'Responses',
                            subtitle: 'Survey responses by top performing questionnaire.',
                            points: chartPoints,
                            accent: AppPalette.teal700,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PerformanceTable(data: _performanceData),
                        const SizedBox(height: 18),
                        TopSurveyBarChart(
                          title: 'Responses',
                          subtitle: 'Survey responses by top performing questionnaire.',
                          points: chartPoints,
                          accent: AppPalette.teal700,
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _PerformanceTable extends StatelessWidget {
  const _PerformanceTable({required this.data});

  final List<SurveyPerformance> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < data.length; index++) ...[
          _PerformanceRow(
            rank: index + 1,
            survey: data[index],
          ),
          if (index < data.length - 1) const Divider(height: 0),
        ],
      ],
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({
    required this.rank,
    required this.survey,
  });

  final int rank;
  final SurveyPerformance survey;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final trendPositive = survey.trend >= 0;
    final trendColor = trendPositive ? AppColors.success : AppColors.error;
    final trendIcon = trendPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppPalette.teal100,
              borderRadius: BorderRadius.circular(RadiusTokens.xl),
            ),
            alignment: Alignment.center,
            child: Text(
              '🥇' == '' ? '$rank' : '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppPalette.teal800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppPalette.teal300.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(RadiusTokens.lg),
            ),
            child: const Icon(Icons.poll_outlined, color: AppPalette.teal700, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  survey.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${survey.responses} responses',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(RadiusTokens.xl),
            ),
            child: Row(
              children: [
                Icon(trendIcon, size: 18, color: trendColor),
                const SizedBox(width: 4),
                Text(
                  '${trendPositive ? '+' : ''}${survey.trend}%',
                  style: TextStyle(
                    color: trendColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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

class SurveyPerformance {
  const SurveyPerformance({
    required this.title,
    required this.responses,
    required this.trend,
  });

  final String title;
  final int responses;
  final int trend;
}
