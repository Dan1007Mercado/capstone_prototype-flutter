import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../services/firebase_analytics_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chart_widgets.dart';
import '../../widgets/common_widgets.dart';
import 'analytics_toolbar.dart';
import 'export_dialog.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key, this.surveyName});

  final String? surveyName;

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirebaseAnalyticsService _firebaseService = FirebaseAnalyticsService();
  late SurveyRecord _selectedSurvey;
  List<ResponseRecord> _responses = [];
  List<QuestionInsight> _questions = [];
  List<ChartPoint> _weekly = weeklyResponses;
  List<ChartPoint> _statusSummary = responseStatusSummary;
  bool _isLoading = true;
  String _activeSurveyName = 'All Surveys';

  @override
  void initState() {
    super.initState();
    _activeSurveyName = widget.surveyName ?? 'All Surveys';
    _selectedSurvey = _resolveSurvey(_activeSurveyName);
    _loadAnalytics();
  }

  SurveyRecord _resolveSurvey(String? surveyName) {
    if (surveyName == null || surveyName.isEmpty || surveyName == 'All Surveys') {
      return surveys.first;
    }
    return surveys.firstWhere((s) => s.name == surveyName, orElse: () => surveys.first);
  }

  Future<void> _loadAnalytics({Map<String, String>? filters}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final surveyName = filters?['survey'] ?? _activeSurveyName;
    _activeSurveyName = surveyName;
    _selectedSurvey = _resolveSurvey(surveyName);

    final respondentFilter = filters?['respondent'] ?? 'All Respondents';
    final categoryFilter = filters?['category'];

    final responses = await _firebaseService.getResponses(
      surveyName: surveyName,
      respondentFilter: respondentFilter,
      categoryFilter: categoryFilter,
    );

    final weekly = _firebaseService.processWeeklySeries(responses);
    final status = _firebaseService.processStatusSummary(responses);
    final questions = _firebaseService.processQuestionInsights(responses);

    if (!mounted) return;

    setState(() {
      _responses = responses;
      _weekly = weekly;
      _statusSummary = status;
      _questions = questions;
      _isLoading = false;
    });
  }

  void _onFilterChanged(Map<String, String> payload) {
    if (payload.containsKey('survey')) {
      _activeSurveyName = payload['survey']!;
      _selectedSurvey = _resolveSurvey(_activeSurveyName);
    }
    _loadAnalytics(filters: payload);
  }

  void _onExport() async {
    if (_responses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No responses available to export.')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => ExportDialog(responses: _responses, survey: _selectedSurvey),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String number,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 123, 194),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 130, 225, 230),
        surfaceTintColor: const Color.fromARGB(255, 130, 225, 230),
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 15, 61, 74),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color.fromARGB(255, 15, 61, 74),
              fontWeight: FontWeight.w700,
            ),
        title: Text(_activeSurveyName == 'All Surveys' ? 'Analytics Workspace' : _activeSurveyName),
      ),
      body: Container(
        color: const Color.fromARGB(255, 130, 225, 230),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnalyticsToolbar(
                      onFilterChanged: _onFilterChanged,
                      onExport: _onExport,
                      initialSurvey: _activeSurveyName,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppPalette.teal300, AppPalette.teal600],
                        ),
                        borderRadius: BorderRadius.circular(RadiusTokens.xl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeSurveyName == 'All Surveys'
                                ? 'Overall Survey Analytics'
                                : _activeSurveyName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Live insights and processed quantitative survey metrics from Firebase.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 46,
                            child: FilledButton(
                              onPressed: () => _showOverallInterpretation(context, _questions),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppPalette.teal700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(RadiusTokens.lg),
                                ),
                              ),
                              child: const Text('Overall Interpretation'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Metrics',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cardWidth = constraints.maxWidth;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: cardWidth,
                                    child: _buildMetricCard(
                                      icon: Icons.groups_outlined,
                                      number: _responses.length.toString(),
                                      title: 'Total Responses',
                                      subtitle: 'All surveys',
                                      accent: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _buildMetricCard(
                                      icon: Icons.document_scanner_outlined,
                                      number: _questions.length.toString(),
                                      title: 'Questions Analyzed',
                                      subtitle: 'Quantitative',
                                      accent: AppColors.info,
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _buildMetricCard(
                                      icon: Icons.trending_up_outlined,
                                      number: '${((_responses.length / 10).toStringAsFixed(0))}%',
                                      title: 'Response Rate',
                                      subtitle: 'Growth trend',
                                      accent: AppColors.success,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
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
                                width: wide
                                    ? (constraints.maxWidth - 16) / 2
                                    : constraints.maxWidth,
                                child: LineChartCard(
                                  title: 'Responses Over Time',
                                  subtitle: 'Weekly submissions breakdown.',
                                  points: _weekly,
                                ),
                              ),
                              SizedBox(
                                width: wide
                                    ? (constraints.maxWidth - 16) / 2
                                    : constraints.maxWidth,
                                child: DonutChartCard(
                                  title: 'Response Status Summary',
                                  subtitle: 'Completed vs In Progress',
                                  points: _statusSummary,
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
                        subtitle: 'Quantitative survey questions with interactive chart analysis.',
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 1100;
                          final cardWidth =
                              wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              for (var i = 0; i < _questions.length; i++)
                                SizedBox(
                                  width: cardWidth,
                                  child: MiniChartCard(
                                    title: _questions[i].title,
                                    type: _questions[i].chartType,
                                    points: _questions[i].points,
                                    interpretation: _questions[i].interpretation,
                                    accent: _accentForIndex(i),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
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
    final text = questions.isEmpty
        ? 'No questions to summarize.'
        : questions.map((q) => '• ${q.title}: ${q.interpretation}').join('\n\n');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overall Interpretation'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Text(text, style: const TextStyle(height: 1.5)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
