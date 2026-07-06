import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../mock/mock_data.dart' as mock_data;
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/paginated_table_card.dart';
import 'create_template_page.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({
    super.key,
    this.onNotifications,
    this.onSettings,
    this.unreadNotifications = 0,
  });

  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final templateRows = appState.templates;

    return Container(
      color: AppPalette.teal50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 920 ? 1080.0 : 560.0;
          final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      child: PageHeader(
                        title: 'Templates',
                        onNotifications: onNotifications,
                        onSettings: onSettings,
                        unreadNotifications: unreadNotifications,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero header (matches Surveys/Dashboard style)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppPalette.teal300, AppPalette.teal600],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(18)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const _HeaderPill(
                                      icon: Icons.arrow_back,
                                      label: 'Back',
                                    ),
                                    const Spacer(),
                                    const _HeaderPill(
                                      icon: Icons.view_agenda_rounded,
                                      label: 'Templates',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Templates',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${templateRows.length} reusable templates',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 42,
                                        child: TextField(
                                          onChanged: (_) {},
                                          cursorColor: Colors.white,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Search templates',
                                            hintStyle: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.78),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.search,
                                              size: 18,
                                              color: Colors.white.withValues(alpha: 0.82),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withValues(alpha: 0.18),
                                            contentPadding: EdgeInsets.zero,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(999),
                                              borderSide: BorderSide(
                                                color: Colors.white.withValues(alpha: 0.12),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(999),
                                              borderSide: BorderSide(
                                                color: Colors.white.withValues(alpha: 0.12),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(999),
                                              borderSide: BorderSide(
                                                color: Colors.white.withValues(alpha: 0.34),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 38,
                                      child: FilledButton.icon(
                                        onPressed: () => Navigator.of(context).push<void>(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const CreateTemplatePage(),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add, size: 17),
                                        label: const Text('+ New'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppPalette.teal800,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Summary cards (stacked white cards with left icon and right meta)
                          LayoutBuilder(
                            builder: (context, inner) {
                              final summary = [
                                StatItem(
                                  label: 'Templates',
                                  value: '${templateRows.length}',
                                  icon: Icons.grid_view_rounded,
                                  accent: AppColors.primary,
                                  delta: 'Mock library',
                                ),
                                StatItem(
                                  label: 'High Usage',
                                  value: '9',
                                  icon: Icons.show_chart_rounded,
                                  accent: AppColors.success,
                                  delta: 'Active templates',
                                ),
                                StatItem(
                                  label: 'Recently Updated',
                                  value: '4',
                                  icon: Icons.refresh_rounded,
                                  accent: AppColors.info,
                                  delta: 'This week',
                                ),
                              ];
                              return Column(
                                children: summary
                                    .map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _SummaryCard(item: item),
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          SurfaceCard(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: 'Templates',
                                  subtitle: 'Reusable mock templates with pagination and compact metadata.',
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: List.generate(templateRows.length, (index) {
                                    final template = templateRows[index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          child: LayoutBuilder(
                                            builder: (context, rowConstraints) {
                                              final isNarrow = rowConstraints.maxWidth < 380;

                                              final titleBlock = Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    template.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                      color: AppPalette.teal800,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      AccentChip(label: template.category, color: AppColors.accentTeal),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '${template.usage} uses',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: AppColors.textSecondary,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    template.lastUpdated,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              );

                                              final actionsRow = Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _ActionCircle(
                                                    icon: Icons.visibility_rounded,
                                                    color: AppPalette.teal600,
                                                    onTap: () => Navigator.of(context).push<void>(
                                                      MaterialPageRoute<void>(
                                                        builder: (_) => TemplateBuilderPage(
                                                          style: TemplateStyle.traditional,
                                                          mode: TemplateBuilderMode.preview,
                                                          template: template,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _ActionCircle(
                                                    icon: Icons.edit_rounded,
                                                    color: AppPalette.teal600,
                                                    onTap: () => Navigator.of(context).push<void>(
                                                      MaterialPageRoute<void>(
                                                        builder: (_) => TemplateBuilderPage(
                                                          style: TemplateStyle.traditional,
                                                          mode: TemplateBuilderMode.edit,
                                                          template: template,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _ActionCircle(
                                                    icon: Icons.copy_rounded,
                                                    color: AppPalette.teal600,
                                                    onTap: () {
                                                      final copiedName = '${template.name} - Copy';
                                                      appState.addTemplate(
                                                        name: copiedName,
                                                        category: template.category,
                                                        usage: template.usage,
                                                        lastUpdated: mock_data.formatDateLabel(DateTime.now()),
                                                        components: template.components,
                                                      );
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Template duplicated successfully')),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _ActionCircle(
                                                    icon: Icons.delete_rounded,
                                                    color: AppPalette.pink,
                                                    onTap: () async {
                                                      final templateId = template.id;
                                                      final messenger = ScaffoldMessenger.of(context);
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (dialogContext) {
                                                          return AlertDialog(
                                                            title: const Text('Delete Template'),
                                                            content: const Text('Are you sure you want to delete this template?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(dialogContext, false),
                                                                child: const Text('Cancel'),
                                                              ),
                                                              FilledButton(
                                                                onPressed: () => Navigator.pop(dialogContext, true),
                                                                child: const Text('Delete'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      if (confirm == true) {
                                                        appState.deleteTemplate(templateId);
                                                        messenger.showSnackBar(
                                                          const SnackBar(content: Text('Template deleted successfully')),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );

                                              if (isNarrow) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    titleBlock,
                                                    const SizedBox(height: 12),
                                                    actionsRow,
                                                  ],
                                                );
                                              }

                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(child: titleBlock),
                                                  const SizedBox(width: 12),
                                                  actionsRow,
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        if (index != templateRows.length - 1)
                                          Divider(height: 1, color: AppColors.divider),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 13),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.14)),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppPalette.teal800,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
          Text(
            item.delta,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}