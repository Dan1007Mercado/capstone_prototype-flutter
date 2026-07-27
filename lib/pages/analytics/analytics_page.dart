import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../services/firebase_analytics_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chart_widgets.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/web_sidebar.dart';
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

  // ─────────────────────────────────────────────────────────────────────
  // Web palette (mirrors the SurveysPage web layout for visual consistency)
  // ─────────────────────────────────────────────────────────────────────
  static const Color _tealLight = Color(0xFF2DD4CF);
  static const Color _tealDark = Color.fromARGB(255, 13, 232, 232);
  static const Color _iconTeal = Color(0xFF14B8A6);
  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _headingText = Color(0xFF0E2A2E);
  static const Color _bodyText = Color(0xFF7C8A90);
  static const Color _successGreen = Color(0xFF16A34A);
  static const Color _infoBlue = Color(0xFF2563EB);
  static const Color _warningAmber = Color(0xFFD97706);
  static const Color _border = Color(0xFFDDECEF);

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildWebLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT (preserved from original — do not modify)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
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

  // ═══════════════════════════════════════════════════════════════════════
  // WEB LAYOUT (modern dashboard, matches the SurveysPage web design)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Row(
        children: [
          WebSidebar(
            // Analytics is reached from the Surveys section, so that tab
            // stays highlighted while viewing this page.
            currentIndex: 1,
            onNavigate: (index) {
              if (index == 1) {
                Navigator.of(context).maybePop();
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            onLogout: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SpacingTokens.xxl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WebAnalyticsHeader(
                        title: _activeSurveyName == 'All Surveys'
                            ? 'Overall Survey Analytics'
                            : _activeSurveyName,
                        onExport: _onExport,
                        onInterpret: () => _showOverallInterpretation(context, _questions),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Container(
                        padding: const EdgeInsets.all(SpacingTokens.lg),
                        decoration: BoxDecoration(
                          color: _cardWhite,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _border, width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AnalyticsToolbar(
                          onFilterChanged: _onFilterChanged,
                          onExport: _onExport,
                          initialSurvey: _activeSurveyName,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xxl),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Center(child: CircularProgressIndicator(color: _iconTeal)),
                        )
                      else ...[
                        _WebAnalyticsStatsRow(
                          totalResponses: _responses.length,
                          questionsAnalyzed: _questions.length,
                          responseRate: '${(_responses.length / 10).toStringAsFixed(0)}%',
                        ),
                        const SizedBox(height: SpacingTokens.xxl),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth > 900;
                            return Wrap(
                              spacing: SpacingTokens.lg,
                              runSpacing: SpacingTokens.lg,
                              children: [
                                SizedBox(
                                  width: wide
                                      ? (constraints.maxWidth - SpacingTokens.lg) / 2
                                      : constraints.maxWidth,
                                  child: _WebChartPanel(
                                    child: LineChartCard(
                                      title: 'Responses Over Time',
                                      subtitle: 'Weekly submissions breakdown.',
                                      points: _weekly,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: wide
                                      ? (constraints.maxWidth - SpacingTokens.lg) / 2
                                      : constraints.maxWidth,
                                  child: _WebChartPanel(
                                    child: DonutChartCard(
                                      title: 'Response Status Summary',
                                      subtitle: 'Completed vs In Progress',
                                      points: _statusSummary,
                                      holeFraction: 0.70,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: SpacingTokens.xxl),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _cardWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _border, width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(SpacingTokens.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question Analytics',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _headingText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quantitative survey questions with interactive chart analysis.',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: _bodyText,
                                ),
                              ),
                              const SizedBox(height: SpacingTokens.lg),
                              if (_questions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      'No question data available.',
                                      style: TextStyle(color: _bodyText, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              else
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final wide = constraints.maxWidth > 900;
                                    final cardWidth = wide
                                        ? (constraints.maxWidth - SpacingTokens.lg) / 2
                                        : constraints.maxWidth;
                                    return Wrap(
                                      spacing: SpacingTokens.lg,
                                      runSpacing: SpacingTokens.lg,
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
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xxl),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB WIDGETS (mirrors the visual language of the Surveys web layout)
// ═══════════════════════════════════════════════════════════════════════════

class _WebAnalyticsHeader extends StatelessWidget {
  const _WebAnalyticsHeader({
    required this.title,
    required this.onExport,
    required this.onInterpret,
  });

  final String title;
  final VoidCallback onExport;
  final VoidCallback onInterpret;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _AnalyticsPageState._tealLight,
            _AnalyticsPageState._tealDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _AnalyticsPageState._tealDark.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live insights and processed quantitative survey metrics from Firebase.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: onInterpret,
              icon: const Icon(Icons.insights_outlined, size: 18),
              label: const Text('Overall Interpretation'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _AnalyticsPageState._headingText,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebAnalyticsStatsRow extends StatelessWidget {
  const _WebAnalyticsStatsRow({
    required this.totalResponses,
    required this.questionsAnalyzed,
    required this.responseRate,
  });

  final int totalResponses;
  final int questionsAnalyzed;
  final String responseRate;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _WebAnalyticsStat(
        label: 'Total Responses',
        value: totalResponses.toString(),
        icon: Icons.groups_outlined,
        iconBg: _AnalyticsPageState._mintChipBg,
        iconColor: _AnalyticsPageState._iconTeal,
      ),
      _WebAnalyticsStat(
        label: 'Questions Analyzed',
        value: questionsAnalyzed.toString(),
        icon: Icons.document_scanner_outlined,
        iconBg: _AnalyticsPageState._infoBlue.withValues(alpha: 0.12),
        iconColor: _AnalyticsPageState._infoBlue,
      ),
      _WebAnalyticsStat(
        label: 'Response Rate',
        value: responseRate,
        icon: Icons.trending_up_outlined,
        iconBg: _AnalyticsPageState._successGreen.withValues(alpha: 0.12),
        iconColor: _AnalyticsPageState._successGreen,
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final isLast = entry.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : SpacingTokens.lg),
            child: _WebAnalyticsStatCard(stat: entry.value),
          ),
        );
      }).toList(),
    );
  }
}

class _WebAnalyticsStat {
  const _WebAnalyticsStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}

class _WebAnalyticsStatCard extends StatelessWidget {
  const _WebAnalyticsStatCard({required this.stat});

  final _WebAnalyticsStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: _AnalyticsPageState._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AnalyticsPageState._border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: stat.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 22),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _AnalyticsPageState._bodyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _AnalyticsPageState._headingText,
                    letterSpacing: -0.4,
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

/// Wraps a chart card (LineChartCard / DonutChartCard) in the same
/// bordered white panel style used across the web dashboard.
class _WebChartPanel extends StatelessWidget {
  const _WebChartPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _AnalyticsPageState._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AnalyticsPageState._border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: child,
    );
  }
}