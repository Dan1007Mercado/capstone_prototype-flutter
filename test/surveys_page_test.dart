import 'package:capstone_prototype/pages/surveys/responses_page.dart';
import 'package:capstone_prototype/pages/surveys/surveys_page.dart';
import 'package:capstone_prototype/state/app_state.dart';
import 'package:capstone_prototype/widgets/app_shell.dart';
import 'package:capstone_prototype/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a shared page header for surveys', (tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStateScope(
            notifier: appState,
            child: const SurveysPage(
              onOpenAnalytics: _noop,
              onNotifications: _noop,
              onSettings: _noop,
              unreadNotifications: 0,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(PageHeader), findsOneWidget);
  });

  testWidgets('shows the download OMR template action for surveys', (tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStateScope(
            notifier: appState,
            child: const SurveysPage(
              onOpenAnalytics: _noop,
              onNotifications: _noop,
              onSettings: _noop,
              unreadNotifications: 0,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Search surveys'), findsOneWidget);
    expect(find.text('Quarterly Satisfaction Survey'), findsOneWidget);
    expect(find.text('Healthcare Feedback A'), findsOneWidget);
  });

  testWidgets('opens the responses page when the responses icon is tapped', (tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(
          notifier: appState,
          child: const AppShell(initialIndex: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Responses').first);
    await tester.pumpAndSettle();

    expect(find.byType(ResponsesPage), findsOneWidget);
  });
}

void _noop([String? _]) {}
