import 'package:flutter/material.dart';

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

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  final _titles = const <String>[
    'Dashboard',
    'Surveys',
    'Templates',
    'Survey Converter',
  ];

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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CreateTemplatePage(),
      ),
    );
  }

  void _openSurveyConverter() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SurveyConverterPage(),
      ),
    );
  }

  void _openDeploySurvey() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DeploySurveyPage(),
      ),
    );
  }

  void _showNotifications(AppState appState) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
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
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                for (final item in appState.notifications) ...[
                  SurfaceNotificationTile(item: item),
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  Future<void> _showScanner() async {
    final appState = AppStateScope.of(context);
    if (appState.surveys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create or deploy a survey before opening the scanner.')),
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
              backgroundColor: AppColors.card,
              title: const Text('Select Survey'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose the survey that will be used for OMR scanning.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SurveyRecord>(
                    initialValue: selected,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Survey',
                    ),
                    items: [
                      for (final survey in appState.surveys)
                        DropdownMenuItem<SurveyRecord>(
                          value: survey,
                          child: Text(survey.name),
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
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, selected),
                  child: const Text('Continue'),
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
          appBar: AppBar(
            title: Text(_titles[_index]),
            actions: [
              _IconBadgeButton(
                icon: Icons.notifications_outlined,
                tooltip: 'Notifications',
                badgeCount: appState.unreadNotifications,
                onPressed: () {
                  appState.markNotificationsRead();
                  _showNotifications(appState);
                },
              ),
              IconButton(
                onPressed: _showSettings,
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 104),
            child: IndexedStack(
              index: _index,
              children: [
                DashboardPage(onOpenAnalytics: _openAnalytics),
                SurveysPage(onOpenAnalytics: _openAnalytics),
                const TemplatesPage(),
                const SurveyConverterPage(),
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
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.inputBorder),
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
                            colors: [AppColors.primary, AppColors.primaryHover],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.document_scanner_outlined, size: 28, color: Colors.white),
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
    final color = selected ? AppColors.textPrimary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
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

class SurfaceNotificationTile extends StatelessWidget {
  const SurfaceNotificationTile({super.key, required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
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
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
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
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
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
  State<GlobalFloatingActionMenu> createState() => _GlobalFloatingActionMenuState();
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
      width: 236,
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.inputBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 18, color: AppColors.primaryHover),
              const SizedBox(width: 10),
              Text(
                action.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
