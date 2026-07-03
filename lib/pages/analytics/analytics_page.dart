import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chart_widgets.dart';
import '../../widgets/common_widgets.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key, this.surveyName});

  final String? surveyName;

  @override
  Widget build(BuildContext context) {
    final questions = buildQuestionInsights();

    return Scaffold(
      appBar: AppBar(
        title: Text(surveyName == null ? 'Analytics' : surveyName!),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surveyName == null ? 'Analytics' : 'Analytics · $surveyName',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mock analytics only. The layout mirrors a modern SaaS reporting workspace.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    child: StatCard(
                      label: 'Total Responses',
                      value: '1,240',
                      icon: Icons.groups_outlined,
                      accent: AppColors.primary,
                      delta: '+12% this week',
                    ),
                  ),
                  SizedBox(
                    width: wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    child: StatCard(
                      label: 'Last Sync Time',
                      value: '07/03/2026 08:15 AM',
                      icon: Icons.schedule_outlined,
                      accent: AppColors.info,
                      delta: 'Live mock feed',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => _showOverallInterpretation(context, questions),
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: const Text('Overall Interpretation'),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 980;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    child: const LineChartCard(
                      title: 'Responses Over Time',
                      subtitle: 'Weekly data across 6 periods.',
                      points: weeklyResponses,
                    ),
                  ),
                  SizedBox(
                    width: wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    child: const DonutChartCard(
                      title: 'Response Status Summary',
                      subtitle: 'Completed vs In Progress with a large center hole.',
                      points: responseStatusSummary,
                      holeFraction: 0.70,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Question Analytics',
            subtitle: 'Twenty mock quantitative questions with toggled chart and interpretation views.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 1100;
              final cardWidth = wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (var i = 0; i < questions.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: MiniChartCard(
                        title: questions[i].title,
                        type: questions[i].chartType,
                        points: questions[i].points,
                        interpretation: questions[i].interpretation,
                        accent: _accentForIndex(i),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _accentForIndex(int index) {
    const accents = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
    ];
    return accents[index % accents.length];
  }

  void _showOverallInterpretation(BuildContext context, List<QuestionInsight> questions) {
    final text = questions
        .map((question) => '• ${question.title}: ${question.interpretation}')
        .join('\n\n');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overall Interpretation'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Text(
              text,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}