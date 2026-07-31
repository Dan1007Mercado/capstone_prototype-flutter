// pages/dashboard/dashboard_page.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mock/mock_data.dart' as mock;
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../surveys/deploy_survey_page.dart';
import '../templates/create_template_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.onOpenAnalytics,
    this.onNotifications,
    this.onSettings,
    this.onCreateSurvey,
    this.onCreateTemplate,
    this.unreadNotifications = 0,
  });

  final void Function([String? surveyName]) onOpenAnalytics;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final VoidCallback? onCreateSurvey;
  final VoidCallback? onCreateTemplate;
  final int unreadNotifications;

  // ── TalaanScan brand colors (preserved from original) ────────────────────
  static const Color _heroStart = Color.fromARGB(255, 130, 225, 230);
  static const Color _heroEnd = Color.fromARGB(255, 31, 185, 193);
  static const Color _brandDeep = Color.fromARGB(255, 36, 240, 203);
  static const Color _mutedText = Colors.black;
  static const Color _border = Color.fromARGB(255, 230, 237, 240);
  static const Color _panelTint = Color.fromARGB(255, 246, 250, 251);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ── Web + Mobile shared state ────────────────────────────────────────────
  int _surveyTablePage = 0;
  static const int _rowsPerPage = 5;
  SurveyRecord? _selectedChartSurvey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedChartSurvey == null && mock.surveys.isNotEmpty) {
        setState(() => _selectedChartSurvey = mock.surveys.first);
      }
    });
  }

  List<ChartPoint> _generateSurveyTrendData(SurveyRecord survey) {
    final seed = survey.id.hashCode.abs();
    final base = survey.responses > 0 ? survey.responses / 7.0 : 12.0;
    return [
      ChartPoint('Mon', (base * 0.8 + (seed % 10)).clamp(1.0, 999.0)),
      ChartPoint('Tue', (base * 1.0 + (seed % 8)).clamp(1.0, 999.0)),
      ChartPoint('Wed', (base * 0.9 + (seed % 12)).clamp(1.0, 999.0)),
      ChartPoint('Thu', (base * 1.1 + (seed % 6)).clamp(1.0, 999.0)),
      ChartPoint('Fri', (base * 1.2 + (seed % 9)).clamp(1.0, 999.0)),
      ChartPoint('Sat', (base * 0.7 + (seed % 5)).clamp(1.0, 999.0)),
      ChartPoint('Sun', (base * 0.6 + (seed % 7)).clamp(1.0, 999.0)),
    ];
  }

  void _handleCreateSurvey() {
    if (widget.onCreateSurvey != null) {
      widget.onCreateSurvey!();
    } else {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const DeploySurveyPage()),
      );
    }
  }

  void _handleCreateTemplate() {
    if (widget.onCreateTemplate != null) {
      widget.onCreateTemplate!();
    } else {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const CreateTemplatePage()),
      );
    }
  }

  void _onSurveyChanged(SurveyRecord survey) {
    setState(() => _selectedChartSurvey = survey);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return _buildMobileLayout(context);
        }
        return _buildWebLayout(context);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT (preserved + Response Overview added)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    final chartData = _selectedChartSurvey != null
        ? _generateSurveyTrendData(_selectedChartSurvey!)
        : const <ChartPoint>[];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 147, 219, 219),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
          final maxContentWidth = constraints.maxWidth >= 900 ? 1080.0 : 560.0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      child: PageHeader(
                        title: 'Home',
                        onNotifications: widget.onNotifications,
                        onSettings: widget.onSettings,
                        unreadNotifications: widget.unreadNotifications,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      child: Column(
                        children: [
                          _MobileStatsGrid(onOpenAnalytics: widget.onOpenAnalytics),
                          const SizedBox(height: 16),
                          _MobileResponseOverview(
                            surveys: mock.surveys,
                            selectedSurvey: _selectedChartSurvey,
                            chartData: chartData,
                            onSurveyChanged: _onSurveyChanged,
                          ),
                          const SizedBox(height: 8),
                          const _MobileActivityPanel(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 56)),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEB LAYOUT (enhanced SaaS dashboard)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context) {
    final theme = context.appTheme;
    final appState = AppStateScope.of(context);
    final surveys = appState.surveys;

    final chartData = _selectedChartSurvey != null
        ? _generateSurveyTrendData(_selectedChartSurvey!)
        : const <ChartPoint>[];

    return Scaffold(
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.xxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Dashboard Header ──────────────────────────────────────
                _WebDashboardHeader(onNewSurvey: _handleCreateSurvey),
                const SizedBox(height: SpacingTokens.xxl),

                // ── Stats Row ───────────────────────────────────────────────
                const _WebStatsRow(),
                const SizedBox(height: SpacingTokens.xxl),

                // ── Response Overview + Quick Actions ─────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _WebResponseOverview(
                        surveys: surveys,
                        selectedSurvey: _selectedChartSurvey,
                        chartData: chartData,
                        onSurveyChanged: _onSurveyChanged,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.xxl),
                    Expanded(
                      flex: 2,
                      child: _WebQuickActions(
                        onCreateSurvey: _handleCreateSurvey,
                        onCreateTemplate: _handleCreateTemplate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xxl),

                // ── Recent Surveys + Recent Activity ────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _WebRecentSurveysTable(
                        page: _surveyTablePage,
                        rowsPerPage: _rowsPerPage,
                        onPageChanged: (page) {
                          setState(() => _surveyTablePage = page);
                        },
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.xxl),
                    const Expanded(
                      flex: 2,
                      child: _WebRecentActivityPanel(),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE WIDGETS (preserved from original)
// ═════════════════════════════════════════════════════════════════════════════

class _MobileStatsGrid extends StatelessWidget {
  const _MobileStatsGrid({required this.onOpenAnalytics});

  final void Function([String? surveyName]) onOpenAnalytics;

  @override
  Widget build(BuildContext context) {
    final stats = <_DashboardMetric>[
      const _DashboardMetric(
        label: 'Total responses',
        value: '12,483',
        delta: '+8.2%',
        icon: Icons.groups_outlined,
      ),
      const _DashboardMetric(
        label: 'Scans today',
        value: '1,204',
        delta: '-1.4%',
        icon: Icons.document_scanner_outlined,
        isNegative: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth >= 760;

        return Row(
          children: [
            Expanded(
              child: _MetricCard(
                metric: stats[0],
                onTap: stats[0].label == 'AI conversion'
                    ? () => onOpenAnalytics()
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                metric: stats[1],
                onTap: stats[1].label == 'AI conversion'
                    ? () => onOpenAnalytics()
                    : null,
              ),
            ),
            if (isLarge) ...[
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ],
        );
      },
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    this.isNegative = false,
  });

  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final bool isNegative;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, this.onTap});

  final _DashboardMetric metric;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = metric.isNegative ? context.error : DashboardPage._heroEnd;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.shadowMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: DashboardPage._heroEnd.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      metric.icon,
                      color: DashboardPage._heroEnd,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      metric.delta,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                metric.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: DashboardPage._mutedText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                metric.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: DashboardPage._brandDeep,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileResponseOverview extends StatelessWidget {
  const _MobileResponseOverview({
    required this.surveys,
    required this.selectedSurvey,
    required this.chartData,
    required this.onSurveyChanged,
  });

  final List<SurveyRecord> surveys;
  final SurveyRecord? selectedSurvey;
  final List<ChartPoint> chartData;
  final ValueChanged<SurveyRecord> onSurveyChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DashboardPage._border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Response Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                ),
              ),
              if (surveys.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: DashboardPage._panelTint,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: DashboardPage._border.withValues(alpha: 0.75),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SurveyRecord>(
                      value: selectedSurvey,
                      isDense: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: DashboardPage._brandDeep,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      items: surveys.map((survey) {
                        return DropdownMenuItem<SurveyRecord>(
                          value: survey,
                          child: Text(
                            survey.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) onSurveyChanged(value);
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _TrendChart(points: chartData),
          ),
        ],
      ),
    );
  }
}

class _MobileActivityPanel extends StatelessWidget {
  const _MobileActivityPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DashboardPage._border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color.fromARGB(255, 0, 5, 4),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest survey, template, and conversion events.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DashboardPage._mutedText,
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: DashboardPage._panelTint,
                  foregroundColor: DashboardPage._brandDeep,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            itemCount: mock.recentActivities.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = mock.recentActivities[index];
              return _MobileActivityTile(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                time: _shortTime(item.time),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _shortTime(String time) {
    if (time.startsWith('2 mins')) return '2m';
    if (time.startsWith('18 mins')) return '18m';
    if (time.startsWith('42 mins')) return '42m';
    if (time.startsWith('1 hour')) return '1h';
    if (time.startsWith('3 hours')) return '3h';
    return time;
  }
}

class _MobileActivityTile extends StatelessWidget {
  const _MobileActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardPage._panelTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DashboardPage._border.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardPage._heroEnd.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: DashboardPage._heroEnd, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DashboardPage._mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: DashboardPage._mutedText,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: DashboardPage._mutedText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WEB WIDGETS (enhanced SaaS dashboard)
// ═════════════════════════════════════════════════════════════════════════════

class _WebDashboardHeader extends StatelessWidget {
  const _WebDashboardHeader({required this.onNewSurvey});

  final VoidCallback onNewSurvey;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back to TalaanScan',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your surveys, templates, and responses from one place.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SpacingTokens.lg),
        FilledButton.icon(
          onPressed: onNewSurvey,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            'New Survey',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 28, 196, 202),
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.md),
            ),
          ),
        ),
      ],
    );
  }
}

class _WebStatsRow extends StatelessWidget {
  const _WebStatsRow();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final activeSurveys = mock.surveys
        .where((s) => s.status == SurveyStatus.active)
        .length;
    final totalResponses = mock.surveys.fold<int>(
      0,
      (sum, s) => sum + s.responses,
    );
    final templateCount = mock.templates.length;

    final stats = [
      _WebStat(
        label: 'Active Surveys',
        value: activeSurveys.toString(),
        icon: Icons.assignment_turned_in_outlined,
        iconBg: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4361EE),
      ),
      _WebStat(
        label: 'Total Responses',
        value: _formatNumber(totalResponses),
        icon: Icons.groups_outlined,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF22C55E),
      ),
      _WebStat(
        label: 'OMR Templates',
        value: templateCount.toString(),
        icon: Icons.view_agenda_outlined,
        iconBg: const Color(0xFFFEF9C3),
        iconColor: const Color(0xFFEAB308),
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final isLast = entry.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : SpacingTokens.lg),
            child: _WebStatCard(stat: entry.value),
          ),
        );
      }).toList(),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final s = (n / 1000).toStringAsFixed(1);
      return '${s.replaceAll('.0', '')}k';
    }
    return n.toString();
  }
}

class _WebStat {
  const _WebStat({
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

class _WebStatCard extends StatelessWidget {
  const _WebStatCard({required this.stat});

  final _WebStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: theme.outlineVariant, width: 0.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: stat.iconBg,
              borderRadius: BorderRadius.circular(RadiusTokens.sm),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 24),
          ),
          const SizedBox(width: SpacingTokens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: theme.onSurface,
                    letterSpacing: -0.5,
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

class _WebResponseOverview extends StatelessWidget {
  const _WebResponseOverview({
    required this.surveys,
    required this.selectedSurvey,
    required this.chartData,
    required this.onSurveyChanged,
  });

  final List<SurveyRecord> surveys;
  final SurveyRecord? selectedSurvey;
  final List<ChartPoint> chartData;
  final ValueChanged<SurveyRecord> onSurveyChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: theme.outlineVariant, width: 0.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Response Overview',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.onSurface,
                    ),
                  ),
                ),
                if (surveys.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(RadiusTokens.sm),
                      border: Border.all(color: theme.outline),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SurveyRecord>(
                        value: selectedSurvey,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.onSurface,
                        ),
                        dropdownColor: theme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        items: surveys.map((survey) {
                          return DropdownMenuItem<SurveyRecord>(
                            value: survey,
                            child: Text(
                              survey.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) onSurveyChanged(value);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: SizedBox(
              height: 240,
              child: _TrendChart(points: chartData),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    if (points.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: theme.onSurfaceVariant,
          ),
        ),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 240),
      painter: _TrendPainter(
        points: points,
        accent: AppPalette.primary500,
        gridColor: theme.outlineVariant,
        labelColor: theme.onSurfaceVariant,
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.accent,
    required this.gridColor,
    required this.labelColor,
  });

  final List<ChartPoint> points;
  final Color accent;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const padding = 28.0;
    final plotWidth = size.width - padding * 2;
    final plotHeight = size.height - padding * 2 - 20;
    final maxVal = points.map((e) => e.value).reduce(math.max);
    final max = maxVal <= 0 ? 1.0 : maxVal;
    final minVal = points.map((e) => e.value).reduce(math.min);
    final min = minVal;
    final range = (max - min).abs() < 0.001 ? 1.0 : max - min;

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = padding + plotHeight * (i / 3);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Compute point offsets
    final pointOffsets = <Offset>[];
    final stepDiv = points.length > 1 ? (points.length - 1) : 1;
    for (var i = 0; i < points.length; i++) {
      final x = padding + plotWidth * (i / stepDiv);
      final y = padding + plotHeight * (1 - ((points[i].value - min) / range));
      pointOffsets.add(Offset(x, y));
    }

    // Fill path
    final fillPath = Path();
    fillPath.moveTo(pointOffsets.first.dx, size.height - padding - 20);
    for (var i = 0; i < pointOffsets.length; i++) {
      fillPath.lineTo(pointOffsets[i].dx, pointOffsets[i].dy);
    }
    fillPath.lineTo(pointOffsets.last.dx, size.height - padding - 20);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.25),
            accent.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line path
    final linePath = Path();
    linePath.moveTo(pointOffsets.first.dx, pointOffsets.first.dy);
    for (var i = 1; i < pointOffsets.length; i++) {
      linePath.lineTo(pointOffsets[i].dx, pointOffsets[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw points
    for (final offset in pointOffsets) {
      canvas.drawCircle(offset, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        offset,
        5.5,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Labels
    final labelStyle = TextStyle(
      color: labelColor,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    for (var i = 0; i < points.length; i++) {
      final x = padding + plotWidth * (i / stepDiv);
      final textPainter = TextPainter(
        text: TextSpan(text: points[i].label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelX = (x - textPainter.width / 2)
          .clamp(0.0, size.width - textPainter.width);
      textPainter.paint(
        canvas,
        Offset(labelX, size.height - padding - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.points != points || old.accent != accent;
}

class _WebQuickActions extends StatelessWidget {
  const _WebQuickActions({
    required this.onCreateSurvey,
    required this.onCreateTemplate,
  });

  final VoidCallback onCreateSurvey;
  final VoidCallback onCreateTemplate;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: theme.outlineVariant, width: 0.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Text(
              'Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.onSurface,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              children: [
                _QuickActionTile(
                  icon: Icons.campaign_outlined,
                  label: 'Create Survey',
                  color: AppPalette.primary500,
                  onTap: onCreateSurvey,
                ),
                const SizedBox(height: SpacingTokens.md),
                _QuickActionTile(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Create Template',
                  color: AppPalette.teal500,
                  onTap: onCreateTemplate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Material(
      color: theme.surfaceContainer,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadiusTokens.xs),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebRecentSurveysTable extends StatelessWidget {
  const _WebRecentSurveysTable({
    required this.page,
    required this.rowsPerPage,
    required this.onPageChanged,
  });

  final int page;
  final int rowsPerPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allSurveys = mock.surveys;
    final totalPages = math.max(1, (allSurveys.length / rowsPerPage).ceil());
    final safePage = page.clamp(0, totalPages - 1);
    final startIndex = safePage * rowsPerPage;
    final endIndex = math.min(startIndex + rowsPerPage, allSurveys.length);
    final pageSurveys = allSurveys.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: theme.outlineVariant, width: 0.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Surveys',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.onSurface,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.onSurfaceVariant,
                    side: BorderSide(color: theme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.md,
            ),
            color: theme.surfaceContainer,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'SURVEY NAME',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'STATUS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'RESPONSES',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CREATED',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Rows
          ...pageSurveys.asMap().entries.map((entry) {
            final survey = entry.value;
            final isLast = entry.key == pageSurveys.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          survey.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: _StatusBadgeWeb(
                          label: shortStatusLabel(survey.status),
                          color: statusColor(survey.status),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          survey.responses.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          survey.createdDate,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, indent: SpacingTokens.lg),
              ],
            );
          }),
          if (allSurveys.isEmpty)
            const Padding(
              padding: EdgeInsets.all(SpacingTokens.xl),
              child: Center(child: Text('No surveys found.')),
            ),
          const Divider(height: 1),
          // Pagination
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: safePage > 0 ? () => onPageChanged(safePage - 1) : null,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: Text(
                    'Previous',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.onSurface,
                    disabledForegroundColor: theme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: SpacingTokens.lg),
                Text(
                  'Page ${safePage + 1} of $totalPages',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: SpacingTokens.lg),
                TextButton.icon(
                  onPressed: safePage < totalPages - 1
                      ? () => onPageChanged(safePage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: Text(
                    'Next',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.onSurface,
                    disabledForegroundColor: theme.onSurfaceVariant,
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

class _StatusBadgeWeb extends StatelessWidget {
  const _StatusBadgeWeb({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(RadiusTokens.xs),
        ),
        child: Text(
          label.toLowerCase(),
          style: GoogleFonts.inter(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _WebRecentActivityPanel extends StatelessWidget {
  const _WebRecentActivityPanel();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: theme.outlineVariant, width: 0.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Activity',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.onSurface,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.onSurfaceVariant,
                    side: BorderSide(color: theme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Activity List
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              children: mock.recentActivities.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == mock.recentActivities.length - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : SpacingTokens.md,
                  ),
                  child: _WebActivityItem(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebActivityItem extends StatelessWidget {
  const _WebActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        border: Border.all(
          color: theme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppPalette.primary500.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadiusTokens.xs),
            ),
            child: Icon(icon, color: AppPalette.primary500, size: 18),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
