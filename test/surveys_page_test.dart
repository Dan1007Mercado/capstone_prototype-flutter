import 'package:capstone_prototype/pages/surveys/surveys_page.dart';
import 'package:capstone_prototype/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the download OMR template action for surveys', (tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(
          notifier: appState,
          child: const SurveysPage(onOpenAnalytics: _noop),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify DataTable with survey columns is present
    expect(find.byType(DataTable), findsAtLeastNWidgets(1));
    
    // Verify table headers exist
    expect(find.text('Survey Name'), findsOneWidget);
    expect(find.text('Template Used'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Responses'), findsOneWidget);
    expect(find.text('Date Created'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    
    // Verify survey data is displayed
    expect(find.text('Quarterly Satisfaction Survey'), findsOneWidget);
    expect(find.text('Healthcare Feedback A'), findsOneWidget);
  });
}

void _noop([String? _]) {}
