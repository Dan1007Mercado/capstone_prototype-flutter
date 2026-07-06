import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/app_models.dart';
import '../pages/analytics/analytics_page.dart';
import '../pages/conversion/conversion_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/surveys/deploy_survey_page.dart';
import '../pages/surveys/surveys_page.dart';
import '../pages/scanner/omr_scanner_page.dart';
import '../pages/templates/create_template_page.dart';
import '../pages/templates/templates_page.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

// ── Brand palette (matches login/signup/dashboard) ─────────────────────────
class _ShellColors {
  static const Color tealDark = Color(0xFF0F9B9B);
  static const Color tealLight = Color(0xFF2DD4CF);
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _openAnalytics([String? surveyName]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnalyticsPage(surveyName: surveyName),
      ),
    );
  }

  void _openCreateTemplate() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateTemplatePage()));
  }

  void _openSurveyConverter() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SurveyConverterPage()),
    );
  }

  void _openDeploySurvey() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const DeploySurveyPage()));
  }

  void _showNotifications(AppState appState) {
    final theme = context.appTheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.64,
          minChildSize: 0.42,
          maxChildSize: 0.92,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (appState.notifications.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          appState.markNotificationsRead();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Mark all read',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (appState.notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.notifications_none_outlined,
                            size: 48,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications yet.',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final item in appState.notifications) ...[
                    _NotificationTile(item: item),
                    const SizedBox(height: 12),
                  ],
              ],
            );
          },
        );
      },
    );
  }

  void _showSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  void _handleNotifications() {
    final appState = AppStateScope.of(context);
    appState.markNotificationsRead();
    _showNotifications(appState);
  }

  Future<void> _showScanner() async {
    final appState = AppStateScope.of(context);
    if (appState.surveys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Create or deploy a survey before opening the scanner.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final selectedSurvey = await showDialog<SurveyRecord>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        SurveyRecord selected = appState.surveys.first;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Survey',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose the survey that will be used for OMR scanning.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SurveyRecord>(
                    initialValue: selected,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Survey',
                      labelStyle: GoogleFonts.inter(),
                    ),
                    items: [
                      for (final survey in appState.surveys)
                        DropdownMenuItem<SurveyRecord>(
                          value: survey,
                          child: Text(survey.name, style: GoogleFonts.inter()),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selected = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: GoogleFonts.inter()),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, selected),
                  style: FilledButton.styleFrom(
                    backgroundColor: _ShellColors.tealDark,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || selectedSurvey == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OmrScannerPage(survey: selectedSurvey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: false,
          body: Padding(
            padding: const EdgeInsets.only(bottom: 104),
            child: IndexedStack(
              index: _index,
              children: [
                DashboardPage(
                  onOpenAnalytics: _openAnalytics,
                  onNotifications: _handleNotifications,
                  onSettings: _showSettings,
                  unreadNotifications: appState.unreadNotifications,
                ),
                SurveysPage(
                  onOpenAnalytics: _openAnalytics,
                  onNotifications: _handleNotifications,
                  onSettings: _showSettings,
                  unreadNotifications: appState.unreadNotifications,
                ),
                TemplatesPage(
                  onNotifications: _handleNotifications,
                  onSettings: _showSettings,
                  unreadNotifications: appState.unreadNotifications,
                ),
                SurveyConverterPage(
                  onNotifications: _handleNotifications,
                  onSettings: _showSettings,
                  unreadNotifications: appState.unreadNotifications,
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: SizedBox(
              height: 88,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    top: 18,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(RadiusTokens.lg),
                        border: Border.all(color: context.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: context.appTheme.shadow.withValues(
                              alpha: context.isDark ? 0.28 : 0.10,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _NavItem(
                            label: 'HOME',
                            icon: Icons.home_outlined,
                            selected: _index == 0,
                            onTap: () => setState(() => _index = 0),
                          ),
                          _NavItem(
                            label: 'SURVEYS',
                            icon: Icons.table_chart_outlined,
                            selected: _index == 1,
                            onTap: () => setState(() => _index = 1),
                          ),
                          const SizedBox(width: 76),
                          _NavItem(
                            label: 'TEMPLATES',
                            icon: Icons.view_agenda_outlined,
                            selected: _index == 2,
                            onTap: () => setState(() => _index = 2),
                          ),
                          _NavItem(
                            label: 'CONVERTER',
                            icon: Icons.swap_horiz_outlined,
                            selected: _index == 3,
                            onTap: () => setState(() => _index = 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -22,
                    child: GestureDetector(
                      onTap: _showScanner,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _ShellColors.tealDark,
                              _ShellColors.tealLight,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _ShellColors.tealDark.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.document_scanner_outlined,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 118,
          child: GlobalFloatingActionMenu(
            onDeploySurvey: _openDeploySurvey,
            onCreateTemplate: _openCreateTemplate,
            onConvertQuestionnaire: _openSurveyConverter,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final color = selected ? _ShellColors.tealDark : theme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: theme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _ShellColors.tealDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(RadiusTokens.sm),
            ),
            child: Icon(item.icon, color: _ShellColors.tealDark, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    color: theme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: GoogleFonts.inter(
                    color: theme.onSurfaceVariant.withValues(alpha: 0.72),
                    fontSize: 12,
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

class _IconBadgeButton extends StatelessWidget {
  const _IconBadgeButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.badgeCount,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badgeCount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          tooltip: tooltip,
        ),
        if (badgeCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class GlobalFloatingActionMenu extends StatefulWidget {
  const GlobalFloatingActionMenu({
    super.key,
    required this.onDeploySurvey,
    required this.onCreateTemplate,
    required this.onConvertQuestionnaire,
  });

  final VoidCallback onDeploySurvey;
  final VoidCallback onCreateTemplate;
  final VoidCallback onConvertQuestionnaire;

  @override
  State<GlobalFloatingActionMenu> createState() =>
      _GlobalFloatingActionMenuState();
}

class _GlobalFloatingActionMenuState extends State<GlobalFloatingActionMenu> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  void _run(VoidCallback action) {
    setState(() => _open = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _DialAction(
        label: 'Deploy Survey',
        icon: Icons.campaign_outlined,
        onTap: () => _run(widget.onDeploySurvey),
      ),
      _DialAction(
        label: 'Create Template',
        icon: Icons.add_circle_outline,
        onTap: () => _run(widget.onCreateTemplate),
      ),
      _DialAction(
        label: 'Convert Questionnaire',
        icon: Icons.swap_horiz_outlined,
        onTap: () => _run(widget.onConvertQuestionnaire),
      ),
    ];

    return SizedBox(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: _open ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_open,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final action in actions) ...[
                    _DialActionTile(action: action),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: _ShellColors.tealDark,
            foregroundColor: Colors.white,
            elevation: 4,
            child: AnimatedRotation(
              turns: _open ? 0.125 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(_open ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialAction {
  const _DialAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _DialActionTile extends StatelessWidget {
  const _DialActionTile({required this.action});

  final _DialAction action;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            border: Border.all(color: theme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: theme.shadow.withValues(
                  alpha: context.isDark ? 0.22 : 0.10,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 18, color: _ShellColors.tealDark),
              const SizedBox(width: 10),
              Text(
                action.label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}