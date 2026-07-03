import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onOpenAnalytics});

  final void Function([String? surveyName]) onOpenAnalytics;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _scrollOffset = 0;

  double get _shrinkFactor {
    final t = (_scrollOffset / 260).clamp(0.0, 0.10).toDouble();
    return (1.0 - t).clamp(0.9, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          setState(() {
            _scrollOffset = notification.metrics.pixels;
          });
        }
        return false;
      },
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                sliver: SliverToBoxAdapter(child: _buildHero()),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 160,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = dashboardStats[index];
                      return StatCard(
                        label: item.label,
                        value: item.value,
                        icon: item.icon,
                        accent: item.accent,
                        delta: item.delta,
                        scale: _shrinkFactor,
                      );
                    },
                    childCount: dashboardStats.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Recent Activities',
                          subtitle: 'A scrollable activity feed built from mock records.',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: ListView.separated(
                            itemCount: recentActivities.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = recentActivities[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(item.icon, color: AppColors.primary, size: 18),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                          const SizedBox(height: 3),
                                          Text(item.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      item.time,
                                      style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SurfaceCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AccentChip(label: 'Modern SaaS Dashboard', color: AppColors.primary),
                const SizedBox(height: 14),
                Text(
                  'Command center for surveys, conversion, and analytics.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This screen uses mock data only and keeps the visual system dark, compact, and responsive.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.dashboard_customize_outlined, size: 48, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}