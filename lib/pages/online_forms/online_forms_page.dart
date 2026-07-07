import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'online_forms_questionnaire_page.dart';

class OnlineFormsPage extends StatelessWidget {
  const OnlineFormsPage({
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
    final theme = context.appTheme;
    final activeSurveys = appState.surveys
        .where((survey) => survey.status == SurveyStatus.active)
        .toList();

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
                          
                          SurfaceCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppPalette.teal50,
                                    borderRadius:
                                        BorderRadius.circular(RadiusTokens.lg),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.assignment_outlined,
                                    color: AppPalette.teal700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Active forms',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: theme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${activeSurveys.length}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppPalette.teal700,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Mock library',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: theme.onSurfaceVariant,
                                      ),
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
                      child: activeSurveys.isEmpty
                          ? const _EmptyOnlineForms()
                          : Column(
                              children: [
                                for (final survey in activeSurveys) ...[
                                  _OnlineFormsSurveyCard(
                                    survey: survey,
                                    onAnswer: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            OnlineFormsQuestionnairePage(
                                          survey: survey,
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
}

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

class _OnlineFormsSurveyCard extends StatelessWidget {
  const _OnlineFormsSurveyCard({
    required this.survey,
    required this.onAnswer,
  });

  final SurveyRecord survey;
  final VoidCallback onAnswer;

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
                label: 'Open now',
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
                  child: const Text('Answer'),
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
  const _EmptyOnlineForms();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return SurfaceCard(
      child: Column(
        children: [
          Icon(Icons.assignment_late_outlined,
              size: 52, color: theme.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          Text(
            'No active forms yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no open surveys available to answer at this time.',
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
