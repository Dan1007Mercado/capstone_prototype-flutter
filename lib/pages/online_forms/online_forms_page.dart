import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'online_forms_questionnaire_page.dart';

class OnlineFormsPage extends StatefulWidget {
  const OnlineFormsPage({
    super.key,
    this.onNotifications,
    this.onSettings,
    this.unreadNotifications = 0,
  });

  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final int unreadNotifications;

  // ─────────────────────────────────────────────────────────────────────
  // Web palette (mirrors SurveysPage / AnalyticsPage web layouts)
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
  static const Color _border = Color(0xFFDDECEF);

  @override
  State<OnlineFormsPage> createState() => _OnlineFormsPageState();
}

class _OnlineFormsPageState extends State<OnlineFormsPage> {
  static const Color _pageBg = OnlineFormsPage._pageBg;
  static const Color _headingText = OnlineFormsPage._headingText;
  static const Color _bodyText = OnlineFormsPage._bodyText;

  SurveyStatus _selectedStatus = SurveyStatus.active;

  void _selectStatus(SurveyStatus status) {
    setState(() => _selectedStatus = status);
  }

  String get _selectedStatusTitle {
    return switch (_selectedStatus) {
      SurveyStatus.active => 'Available Forms',
      SurveyStatus.closed => 'Closed Forms',
      SurveyStatus.inactive => 'Inactive Forms',
    };
  }

  String get _selectedStatusDescription {
    return switch (_selectedStatus) {
      SurveyStatus.active => 'Pick an open survey to answer and submit your responses.',
      SurveyStatus.closed => 'Review closed form contents. Closed forms cannot be edited or answered.',
      SurveyStatus.inactive => 'Review inactive form contents.',
    };
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
    final appState = AppStateScope.of(context);
    final visibleSurveys = appState.surveys
        .where((survey) => survey.status == _selectedStatus)
        .toList();
    final activeCount = appState.surveys
        .where((survey) => survey.status == SurveyStatus.active)
        .length;
    final closedCount = appState.surveys
        .where((survey) => survey.status == SurveyStatus.closed)
        .length;

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
                        title: 'Online Forms',
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
                          
                          Row(
                            children: [
                              Expanded(
                                child: _MobileFormsStatusCard(
                                  label: 'Active forms',
                                  value: activeCount.toString(),
                                  icon: Icons.assignment_turned_in_outlined,
                                  selected:
                                      _selectedStatus == SurveyStatus.active,
                                  onTap: () =>
                                      _selectStatus(SurveyStatus.active),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MobileFormsStatusCard(
                                  label: 'Closed forms',
                                  value: closedCount.toString(),
                                  icon: Icons.assignment_late_outlined,
                                  selected:
                                      _selectedStatus == SurveyStatus.closed,
                                  onTap: () =>
                                      _selectStatus(SurveyStatus.closed),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  32,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth - 24),
                      child: visibleSurveys.isEmpty
                          ? _EmptyOnlineForms(status: _selectedStatus)
                          : Column(
                              children: [
                                for (final survey in visibleSurveys) ...[
                                  _OnlineFormsSurveyCard(
                                    survey: survey,
                                    readOnly:
                                        survey.status != SurveyStatus.active,
                                    onAnswer: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            OnlineFormsQuestionnairePage(
                                          survey: survey,
                                          readOnly: survey.status !=
                                              SurveyStatus.active,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
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
  // WEB LAYOUT (modern dashboard, matches Surveys/Analytics web design)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context) {
    final appState = AppStateScope.of(context);
    final allSurveys = appState.surveys;
    final visibleSurveys = allSurveys
        .where((survey) => survey.status == _selectedStatus)
        .toList();
    final activeCount =
        allSurveys.where((survey) => survey.status == SurveyStatus.active).length;
    final closedCount =
        allSurveys.where((survey) => survey.status == SurveyStatus.closed).length;

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
                _WebOnlineFormsHeader(
                  activeCount: activeCount,
                  onNotifications: widget.onNotifications,
                  onSettings: widget.onSettings,
                  unreadNotifications: widget.unreadNotifications,
                ),
                const SizedBox(height: SpacingTokens.xxl),
                _WebOnlineFormsStatsRow(
                  activeCount: activeCount,
                  closedCount: closedCount,
                  totalCount: allSurveys.length,
                  selectedStatus: _selectedStatus,
                  onStatusSelected: _selectStatus,
                ),
                const SizedBox(height: SpacingTokens.xxl),
                Text(
                  _selectedStatusTitle,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _headingText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedStatusDescription,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: _bodyText,
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                if (visibleSurveys.isEmpty)
                  _WebEmptyOnlineForms(status: _selectedStatus)
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1100
                          ? 3
                          : (constraints.maxWidth >= 700 ? 2 : 1);
                      final spacing = SpacingTokens.lg;
                      final cardWidth =
                          (constraints.maxWidth - spacing * (columns - 1)) / columns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final survey in visibleSurveys)
                            SizedBox(
                              width: cardWidth,
                              child: _WebOnlineFormCard(
                                survey: survey,
                                readOnly:
                                    survey.status != SurveyStatus.active,
                                onAnswer: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        OnlineFormsQuestionnairePage(
                                      survey: survey,
                                      readOnly: survey.status !=
                                          SurveyStatus.active,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
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
// SHARED WIDGETS (used by mobile layout — do not modify)
// ═══════════════════════════════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: theme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppPalette.teal700),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: theme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _MobileFormsStatusCard extends StatelessWidget {
  const _MobileFormsStatusCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Material(
      color: theme.surface,
      borderRadius: BorderRadius.circular(RadiusTokens.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            border: Border.all(
              color: selected ? AppPalette.teal700 : theme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? AppPalette.teal100
                      : theme.surfaceContainer,
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? AppPalette.teal700
                      : theme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: theme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: selected
                                ? AppPalette.teal700
                                : theme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineFormsSurveyCard extends StatelessWidget {
  const _OnlineFormsSurveyCard({
    required this.survey,
    required this.onAnswer,
    this.readOnly = false,
  });

  final SurveyRecord survey;
  final VoidCallback onAnswer;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppPalette.teal100,
                  borderRadius: BorderRadius.circular(RadiusTokens.xl),
                ),
                child: Text(
                  _statusLabel(survey.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.teal800,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            survey.templateUsed.isNotEmpty
                ? 'Category: ${survey.templateUsed}'
                : 'Answer this survey to share your responses.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _DetailPill(
                icon: Icons.category_outlined,
                label: survey.category,
              ),
              _DetailPill(
                icon: Icons.help_outline,
                label: '30 Questions',
              ),
              _DetailPill(
                icon: Icons.access_time_outlined,
                label: readOnly ? 'Closed' : 'Open now',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAnswer,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.teal700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.xl),
                    ),
                  ),
                  child: Text(readOnly ? 'View contents' : 'Answer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(SurveyStatus status) {
    return switch (status) {
      SurveyStatus.active => 'Active',
      SurveyStatus.closed => 'Closed',
      SurveyStatus.inactive => 'Inactive',
    };
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        border: Border.all(color: theme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: theme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOnlineForms extends StatelessWidget {
  const _EmptyOnlineForms({required this.status});

  final SurveyStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isClosed = status == SurveyStatus.closed;
    return SurfaceCard(
      child: Column(
        children: [
          Icon(Icons.assignment_late_outlined,
              size: 52, color: theme.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          Text(
            isClosed ? 'No closed forms yet' : 'No active forms yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isClosed
                ? 'Closed forms will appear here once a survey is closed.'
                : 'There are no open surveys available to answer at this time.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB WIDGETS (mirrors the visual language of Surveys/Analytics web layouts)
// ═══════════════════════════════════════════════════════════════════════════

class _WebOnlineFormsHeader extends StatelessWidget {
  const _WebOnlineFormsHeader({
    required this.activeCount,
    required this.onNotifications,
    required this.onSettings,
    required this.unreadNotifications,
  });

  final int activeCount;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OnlineFormsPage._tealLight,
            OnlineFormsPage._tealDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: OnlineFormsPage._tealDark.withValues(alpha: 0.25),
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
                  'Online Forms',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$activeCount open surveys ready to answer.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (onNotifications != null) ...[
            _WebHeaderIconButton(
              icon: Icons.notifications_outlined,
              onPressed: onNotifications,
              badgeCount: unreadNotifications,
            ),
            const SizedBox(width: 10),
          ],
          if (onSettings != null)
            _WebHeaderIconButton(
              icon: Icons.settings_outlined,
              onPressed: onSettings,
            ),
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

class _WebOnlineFormsStatsRow extends StatelessWidget {
  const _WebOnlineFormsStatsRow({
    required this.activeCount,
    required this.closedCount,
    required this.totalCount,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final int activeCount;
  final int closedCount;
  final int totalCount;
  final SurveyStatus selectedStatus;
  final ValueChanged<SurveyStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _WebOnlineFormsStat(
        label: 'Active Forms',
        value: activeCount.toString(),
        icon: Icons.assignment_turned_in_outlined,
        iconBg: OnlineFormsPage._mintChipBg,
        iconColor: OnlineFormsPage._iconTeal,
        status: SurveyStatus.active,
      ),
      _WebOnlineFormsStat(
        label: 'Closed Forms',
        value: closedCount.toString(),
        icon: Icons.assignment_late_outlined,
        iconBg: OnlineFormsPage._bodyText.withValues(alpha: 0.12),
        iconColor: OnlineFormsPage._bodyText,
        status: SurveyStatus.closed,
      ),
      _WebOnlineFormsStat(
        label: 'Total Surveys',
        value: totalCount.toString(),
        icon: Icons.table_chart_outlined,
        iconBg: OnlineFormsPage._successGreen.withValues(alpha: 0.12),
        iconColor: OnlineFormsPage._successGreen,
        status: null,
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final isLast = entry.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : SpacingTokens.lg),
            child: _WebOnlineFormsStatCard(
              stat: entry.value,
              selected: entry.value.status == selectedStatus,
              onTap: entry.value.status == null
                  ? null
                  : () => onStatusSelected(entry.value.status!),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WebOnlineFormsStat {
  const _WebOnlineFormsStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.status,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final SurveyStatus? status;
}

class _WebOnlineFormsStatCard extends StatelessWidget {
  const _WebOnlineFormsStatCard({
    required this.stat,
    required this.selected,
    required this.onTap,
  });

  final _WebOnlineFormsStat stat;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OnlineFormsPage._cardWhite,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? OnlineFormsPage._iconTeal
                  : OnlineFormsPage._border,
              width: selected ? 1.5 : 0.5,
            ),
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
                        color: OnlineFormsPage._bodyText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.value,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: OnlineFormsPage._headingText,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebOnlineFormCard extends StatelessWidget {
  const _WebOnlineFormCard({
    required this.survey,
    required this.onAnswer,
    this.readOnly = false,
  });

  final SurveyRecord survey;
  final VoidCallback onAnswer;
  final bool readOnly;

  String _statusLabel(SurveyStatus status) {
    return switch (status) {
      SurveyStatus.active => 'Active',
      SurveyStatus.closed => 'Closed',
      SurveyStatus.inactive => 'Inactive',
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = survey.status == SurveyStatus.active
        ? OnlineFormsPage._successGreen
        : OnlineFormsPage._bodyText;
    final statusBg = survey.status == SurveyStatus.active
        ? OnlineFormsPage._mintChipBg
        : OnlineFormsPage._bodyText.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: OnlineFormsPage._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OnlineFormsPage._border, width: 0.5),
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: OnlineFormsPage._mintChipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.assignment_outlined,
                  color: OnlineFormsPage._iconTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  survey.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: OnlineFormsPage._headingText,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  _statusLabel(survey.status),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            survey.templateUsed.isNotEmpty
                ? 'Category: ${survey.templateUsed}'
                : 'Answer this survey to share your responses.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: OnlineFormsPage._bodyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _WebDetailPill(icon: Icons.category_outlined, label: survey.category),
              const _WebDetailPill(icon: Icons.help_outline, label: '30 Questions'),
              _WebDetailPill(
                icon: Icons.access_time_outlined,
                label: readOnly ? 'Closed' : 'Open now',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton(
              onPressed: onAnswer,
              style: FilledButton.styleFrom(
                backgroundColor: OnlineFormsPage._iconTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(readOnly ? 'View contents' : 'Answer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebDetailPill extends StatelessWidget {
  const _WebDetailPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFD),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: OnlineFormsPage._border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: OnlineFormsPage._bodyText),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: OnlineFormsPage._bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebEmptyOnlineForms extends StatelessWidget {
  const _WebEmptyOnlineForms({required this.status});

  final SurveyStatus status;

  @override
  Widget build(BuildContext context) {
    final isClosed = status == SurveyStatus.closed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56),
      decoration: BoxDecoration(
        color: OnlineFormsPage._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OnlineFormsPage._border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 46,
            color: OnlineFormsPage._bodyText.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 14),
          Text(
            isClosed ? 'No closed forms yet' : 'No active forms yet',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OnlineFormsPage._headingText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isClosed
                ? 'Closed forms will appear here once a survey is closed.'
                : 'There are no open surveys available to answer at this time.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: OnlineFormsPage._bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
