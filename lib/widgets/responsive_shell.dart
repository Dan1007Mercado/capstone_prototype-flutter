import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_shell.dart';
import 'web_sidebar.dart';
import 'web_topbar.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/surveys/surveys_page.dart';
import '../pages/templates/templates_page.dart';
import '../pages/online_forms/online_forms_page.dart';
import '../pages/analytics/analytics_page.dart';
import '../pages/surveys/responses_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/auth/login.dart'; // Add this import
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../mock/mock_data.dart' as mock_data;

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _onNavigate(int index) {
    setState(() {
      _index = index;
    });
    
    // Handle settings navigation for mobile
    if (index == 4) {
      _showSettings();
    }
  }

  void _openAnalytics([String? surveyName]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnalyticsPage(surveyName: surveyName),
      ),
    );
  }

  void _openResponses(SurveyRecord survey) {
    final responses = mock_data.buildMockResponses(survey);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResponsesPage(survey: survey, responses: responses),
      ),
    );
  }

  void _showSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  void _showNotifications(AppState appState) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              letterSpacing: 0,
                            ),
                      ),
                      const Spacer(),
                      if (appState.notifications.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            appState.markNotificationsRead();
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Mark all read'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (appState.notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_none_outlined,
                            size: 48,
                            color: AppColors.textDisabled,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No notifications yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: appState.notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = appState.notifications[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.divider),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text('${item.subtitle}\n${item.time}'),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNotifications() {
    final appState = AppStateScope.of(context);
    appState.markNotificationsRead();
    _showNotifications(appState);
  }

  void _handleLogout() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with gradient background
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.error, Color(0xFFE74C3C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Confirm Logout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Message
                Text(
                  'Are you sure you want to log out of your account? You will need to sign in again to access your surveys and data.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _performLogout();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildContent(AppState appState) {
    switch (_index) {
      case 0:
        return DashboardPage(
          onOpenAnalytics: _openAnalytics,
          onNotifications: _handleNotifications,
          onSettings: _showSettings,
          unreadNotifications: appState.unreadNotifications,
        );
      case 1:
        return SurveysPage(
          onOpenAnalytics: _openAnalytics,
          onOpenResponses: _openResponses,
          onNotifications: _handleNotifications,
          onSettings: _showSettings,
          unreadNotifications: appState.unreadNotifications,
        );
      case 2:
        return TemplatesPage(
          onNotifications: _handleNotifications,
          onSettings: _showSettings,
          unreadNotifications: appState.unreadNotifications,
        );
      case 3:
        return OnlineFormsPage(
          onNotifications: _handleNotifications,
          onSettings: _showSettings,
          unreadNotifications: appState.unreadNotifications,
        );
      default:
        return DashboardPage(
          onOpenAnalytics: _openAnalytics,
          onNotifications: _handleNotifications,
          onSettings: _showSettings,
          unreadNotifications: appState.unreadNotifications,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return AppShell(initialIndex: _index); // Mobile view
        }

        // Web view
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              WebSidebar(
                currentIndex: _index,
                onNavigate: _onNavigate,
                onLogout: _performLogout,
              ),
              Expanded(
                child: Column(
                  children: [
                    WebTopbar(
                      onNotifications: _handleNotifications,
                      onSettings: _showSettings,
                      unreadNotifications: appState.unreadNotifications,
                    ),
                    Expanded(
                      child: ClipRect(
                        child: _buildContent(appState),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
