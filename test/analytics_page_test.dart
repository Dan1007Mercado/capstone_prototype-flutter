import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_prototype/pages/analytics/analytics_page.dart';
import 'package:capstone_prototype/services/firebase_analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Analytics Page & Firebase Service Tests', () {
    test('FirebaseAnalyticsService initializes and processes metrics safely', () async {
      final service = FirebaseAnalyticsService();
      await service.initialize();

      final surveys = await service.getSurveys();
      expect(surveys, isNotEmpty);

      final responses = await service.getResponses(surveyName: 'All Surveys');
      expect(responses, isNotEmpty);

      final weekly = service.processWeeklySeries(responses);
      expect(weekly.length, equals(4));

      final status = service.processStatusSummary(responses);
      expect(status.length, equals(2));

      final questions = service.processQuestionInsights(responses);
      expect(questions, isNotEmpty);
    });

    testWidgets('Renders AnalyticsPage with toolbar and metric cards without throwing exceptions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: AnalyticsPage(surveyName: 'All Surveys'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2000));

      expect(find.byType(AnalyticsPage), findsOneWidget);
      expect(find.text('Analytics Workspace'), findsOneWidget);
      expect(find.text('Overall Survey Analytics'), findsOneWidget);
    });
  });
}
