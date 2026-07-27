import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../mock/mock_data.dart' as mock_data;
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
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

  // ─────────────────────────────────────────────────────────────────────
  // Web palette (mirrors Surveys / Analytics / Online Forms / Settings)
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
  static const Color _pink = Color(0xFFDB2777);
  static const Color _border = Color(0xFFDDECEF);

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
                                        label: const Text('New'),
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
                                  delta: 'Library',
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
                          const SizedBox(height: 10),
                          SurfaceCard(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Column(
                                  children: List.generate(templateRows.length, (index) {
                                    final template = templateRows[index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                                                      fontSize: 21,
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
                                                      fontSize: 16,
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
                                                    SizedBox(width: double.infinity, child: titleBlock),
                                                    const SizedBox(height: 12),
                                                    Align(alignment: Alignment.centerRight, child: actionsRow),
                                                  ],
                                                );
                                              }

                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(child: titleBlock),
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

  // ═══════════════════════════════════════════════════════════════════════
  // WEB LAYOUT (modern dashboard — no sidebar, matches other web pages)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context) {
    final appState = AppStateScope.of(context);
    final templateRows = appState.templates;

    return Container(
      color: _pageBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.xxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WebTemplatesHeader(
                  totalCount: templateRows.length,
                  onNotifications: onNotifications,
                  onSettings: onSettings,
                  unreadNotifications: unreadNotifications,
                  onNew: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const CreateTemplatePage(),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxl),
                _WebTemplatesStatsRow(totalCount: templateRows.length),
                const SizedBox(height: SpacingTokens.xxl),
                _WebTemplatesTable(
                  templates: templateRows,
                  onPreview: (template) => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => TemplateBuilderPage(
                        style: TemplateStyle.traditional,
                        mode: TemplateBuilderMode.preview,
                        template: template,
                      ),
                    ),
                  ),
                  onEdit: (template) => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => TemplateBuilderPage(
                        style: TemplateStyle.traditional,
                        mode: TemplateBuilderMode.edit,
                        template: template,
                      ),
                    ),
                  ),
                  onDuplicate: (template) {
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
                  onDelete: (template) async {
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
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOBILE WIDGETS (preserved from original — do not modify)
// ═══════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════
// WEB WIDGETS (mirrors the visual language of the other web pages)
// ═══════════════════════════════════════════════════════════════════════════

class _WebTemplatesHeader extends StatelessWidget {
  const _WebTemplatesHeader({
    required this.totalCount,
    required this.onNotifications,
    required this.onSettings,
    required this.unreadNotifications,
    required this.onNew,
  });

  final int totalCount;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final int unreadNotifications;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TemplatesPage._tealLight,
            TemplatesPage._tealDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TemplatesPage._tealDark.withValues(alpha: 0.25),
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
                  'Templates',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount reusable templates',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            height: 44,
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
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.16),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Template'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TemplatesPage._headingText,
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
          if (onNotifications != null) ...[
            const SizedBox(width: 10),
            _WebHeaderIconButton(
              icon: Icons.notifications_outlined,
              onPressed: onNotifications,
              badgeCount: unreadNotifications,
            ),
          ],
          if (onSettings != null) ...[
            const SizedBox(width: 10),
            _WebHeaderIconButton(
              icon: Icons.settings_outlined,
              onPressed: onSettings,
            ),
          ],
        ],
      ),
    );
  }
}

class _WebHeaderIconButton extends StatelessWidget {
  const _WebHeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WebTemplatesStatsRow extends StatelessWidget {
  const _WebTemplatesStatsRow({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _WebTemplatesStat(
        label: 'Templates',
        value: totalCount.toString(),
        icon: Icons.grid_view_rounded,
        iconBg: TemplatesPage._mintChipBg,
        iconColor: TemplatesPage._iconTeal,
      ),
      _WebTemplatesStat(
        label: 'High Usage',
        value: '9',
        icon: Icons.show_chart_rounded,
        iconBg: TemplatesPage._successGreen.withValues(alpha: 0.12),
        iconColor: TemplatesPage._successGreen,
      ),
      _WebTemplatesStat(
        label: 'Recently Updated',
        value: '4',
        icon: Icons.refresh_rounded,
        iconBg: TemplatesPage._infoBlue.withValues(alpha: 0.12),
        iconColor: TemplatesPage._infoBlue,
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final isLast = entry.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : SpacingTokens.lg),
            child: _WebTemplatesStatCard(stat: entry.value),
          ),
        );
      }).toList(),
    );
  }
}

class _WebTemplatesStat {
  const _WebTemplatesStat({
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

class _WebTemplatesStatCard extends StatelessWidget {
  const _WebTemplatesStatCard({required this.stat});

  final _WebTemplatesStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: TemplatesPage._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TemplatesPage._border, width: 0.5),
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
                    color: TemplatesPage._bodyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: TemplatesPage._headingText,
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

class _WebTemplatesTable extends StatelessWidget {
  const _WebTemplatesTable({
    required this.templates,
    required this.onPreview,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  // NOTE: typed as `dynamic` because the concrete template model class
  // (from app_models.dart) wasn't available when generating this file.
  // Swap `dynamic` for your actual template model type, e.g. TemplateModel.
  final List<dynamic> templates;
  final ValueChanged<dynamic> onPreview;
  final ValueChanged<dynamic> onEdit;
  final ValueChanged<dynamic> onDuplicate;
  final ValueChanged<dynamic> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TemplatesPage._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TemplatesPage._border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Text(
              'All Templates',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TemplatesPage._headingText,
              ),
            ),
          ),
          const Divider(height: 1, color: TemplatesPage._border),
          if (templates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 56),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 42,
                      color: TemplatesPage._bodyText,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No templates found.',
                      style: TextStyle(
                        color: TemplatesPage._bodyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.md,
              ),
              color: TemplatesPage._mintChipBg.withValues(alpha: 0.4),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _headerLabel('TEMPLATE NAME')),
                  Expanded(flex: 2, child: _headerLabel('CATEGORY')),
                  Expanded(child: _headerLabel('USAGE')),
                  Expanded(flex: 2, child: _headerLabel('LAST UPDATED')),
                  const SizedBox(width: 168),
                ],
              ),
            ),
            const Divider(height: 1, color: TemplatesPage._border),
            ...templates.asMap().entries.map((entry) {
              final template = entry.value;
              final isLast = entry.key == templates.length - 1;
              return Column(
                children: [
                  _WebTemplateRow(
                    template: template,
                    onPreview: () => onPreview(template),
                    onEdit: () => onEdit(template),
                    onDuplicate: () => onDuplicate(template),
                    onDelete: () => onDelete(template),
                  ),
                  if (!isLast) const Divider(height: 1, color: TemplatesPage._border),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _headerLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: TemplatesPage._bodyText,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _WebTemplateRow extends StatelessWidget {
  const _WebTemplateRow({
    required this.template,
    required this.onPreview,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final dynamic template;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: TemplatesPage._mintChipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.description_outlined,
                    color: TemplatesPage._iconTeal,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    template.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: TemplatesPage._headingText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TemplatesPage._mintChipBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  template.category,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TemplatesPage._iconTeal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${template.usage}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TemplatesPage._headingText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              template.lastUpdated,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: TemplatesPage._bodyText,
              ),
            ),
          ),
          SizedBox(
            width: 168,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _WebRowAction(
                  tooltip: 'Preview',
                  icon: Icons.visibility_rounded,
                  color: TemplatesPage._iconTeal,
                  onPressed: onPreview,
                ),
                const SizedBox(width: 4),
                _WebRowAction(
                  tooltip: 'Edit',
                  icon: Icons.edit_rounded,
                  color: TemplatesPage._infoBlue,
                  onPressed: onEdit,
                ),
                const SizedBox(width: 4),
                _WebRowAction(
                  tooltip: 'Duplicate',
                  icon: Icons.copy_rounded,
                  color: TemplatesPage._bodyText,
                  onPressed: onDuplicate,
                ),
                const SizedBox(width: 4),
                _WebRowAction(
                  tooltip: 'Delete',
                  icon: Icons.delete_rounded,
                  color: TemplatesPage._pink,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebRowAction extends StatelessWidget {
  const _WebRowAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF3FAFB),
        shape: const CircleBorder(
          side: BorderSide(color: TemplatesPage._border),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }
}