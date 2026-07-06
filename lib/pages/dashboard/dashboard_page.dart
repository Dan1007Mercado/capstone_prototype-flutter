import 'dart:async';

import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.onOpenAnalytics,
    this.onNotifications,
    this.onSettings,
    this.unreadNotifications = 0,
  });

  final void Function([String? surveyName]) onOpenAnalytics;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final int unreadNotifications;

  static const Color _heroStart = Color.fromARGB(255, 130, 225, 230);
  static const Color _heroEnd = Color.fromARGB(255, 31, 185, 193);
  static const Color _brandDeep = Color.fromARGB(255, 36, 240, 203);
  static const Color _mutedText = Color.fromARGB(255, 125, 135, 144);
  static const Color _border = Color.fromARGB(255, 230, 237, 240);
  static const Color _panelTint = Color.fromARGB(255, 246, 250, 251);
  static const double _heroOverlap = 28;

  @override
  Widget build(BuildContext context) {
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
                        title: 'Dashboard',
                        onNotifications: onNotifications,
                        onSettings: onSettings,
                        unreadNotifications: unreadNotifications,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _DashboardHero(
                  horizontalPadding: horizontalPadding,
                  maxContentWidth: maxContentWidth,
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    // shift the content up so it visually overlaps the hero
                    child: Transform.translate(
                      offset: const Offset(0, -DashboardPage._heroOverlap),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          children: [
                            _StatsGrid(onOpenAnalytics: onOpenAnalytics),
                            const SizedBox(height: 12),
                            const _ActivityPanel(),
                          ],
                        ),
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
}

// The hero and the stats-grid overlap are now built together inside a
// single Stack, so the overlap amount is always relative to the hero's
// real rendered height — it can never "leave a hole" behind if the hero
// changes size or disappears, unlike the old Transform.translate(-64)
// approach which assumed the hero was permanently a fixed height.
class _DashboardHero extends StatefulWidget {
  const _DashboardHero({
    required this.horizontalPadding,
    required this.maxContentWidth,
  });

  final double horizontalPadding;
  final double maxContentWidth;

  @override
  State<_DashboardHero> createState() => _DashboardHeroState();
}

class _DashboardHeroState extends State<_DashboardHero> {
  // use DashboardPage._heroOverlap so overlap is consistent across widgets
  bool _visible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: _buildHero(context),
      secondChild: const SizedBox.shrink(),
      crossFadeState:
          _visible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 450),
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeIn,
      sizeCurve: Curves.easeInOut,
    );
  }

  Widget _buildHero(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            widget.horizontalPadding,
            36,
            widget.horizontalPadding,
            64,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [DashboardPage._heroStart, DashboardPage._heroEnd],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -72,
                    top: -84,
                    child: _HeroGlow(size: 224, opacity: 0.15),
                  ),
                  Positioned(
                    left: -68,
                    bottom: -104,
                    child: _HeroGlow(size: 256, opacity: 0.10),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Text(
                          'Command center for surveys, conversion & analytics.',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 610),
                        child: Text(
                          'Monitor response flow, template usage, AI conversion, and scanner activity from one workspace.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.86),
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _HealthCard(),
                      // Reserve the overlap space inside the hero's own
                      // layout so the sliver below can visually overlap.
                      SizedBox(height: DashboardPage._heroOverlap),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroGlow extends StatelessWidget {
  const _HeroGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '87%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    'survey completion health',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_outward_rounded,
              color: Colors.white.withValues(alpha: 0.92),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.onOpenAnalytics});

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
        label: 'Templates used',
        value: '42',
        delta: '+3',
        icon: Icons.description_outlined,
      ),
      const _DashboardMetric(
        label: 'AI conversion',
        value: '87%',
        delta: '+2.1%',
        icon: Icons.auto_awesome_outlined,
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
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.builder(
          itemCount: stats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 4 ? 0.95 : 0.9,
          ),
          itemBuilder: (context, index) {
            final metric = stats[index];
            return _MetricCard(
              metric: metric,
              onTap: metric.label == 'AI conversion'
                  ? () => onOpenAnalytics()
                  : null,
            );
          },
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

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel();

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
                        color: DashboardPage._brandDeep,
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
            itemCount: recentActivities.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = recentActivities[index];
              return _ActivityTile(
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
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