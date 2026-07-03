import 'package:capstone_prototype/models/app_models.dart';
import 'package:capstone_prototype/pages/conversion/conversion_page.dart';
import 'package:capstone_prototype/pages/templates/create_template_page.dart';
import 'package:capstone_prototype/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the survey converter empty state', (tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(
          notifier: appState,
          child: const SurveyConverterPage(),
        ),
      ),
    );

    expect(find.text('Upload questionnaire images or PDFs and start AI-powered extraction.'), findsOneWidget);
    expect(find.text('Upload Images'), findsOneWidget);
    expect(find.text('Upload PDF'), findsOneWidget);
    expect(find.text('0 selected items'), findsOneWidget);
  });

  testWidgets('hides scale fields for choice components and shows placeholder for text components in preview mode', (tester) async {
    final appState = AppState();
    final choiceTemplate = TemplateRecord(
      id: 'TMP-1',
      name: 'Sample',
      category: 'Survey',
      usage: '1 component',
      lastUpdated: 'Today',
      components: [
        const TemplateComponent(
          type: 'Multiple Choice',
          label: 'Favorite language',
          description: 'Pick one',
          category: 'Quantitative Components',
          isRequired: true,
          choices: ['Hello', 'Konichiwa'],
        ),
      ],
    );
    final textTemplate = TemplateRecord(
      id: 'TMP-2',
      name: 'Text Sample',
      category: 'Survey',
      usage: '1 component',
      lastUpdated: 'Today',
      components: [
        const TemplateComponent(
          type: 'Textbox',
          label: 'Comments',
          description: 'Tell us more',
          category: 'Qualitative Components',
          placeholder: 'Type here',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(
          notifier: appState,
          child: TemplateBuilderPage(
            key: ValueKey(choiceTemplate.id),
            style: TemplateStyle.traditional,
            mode: TemplateBuilderMode.preview,
            template: choiceTemplate,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
    expect(find.textContaining('Hello'), findsOneWidget);
    expect(find.textContaining('Konichiwa'), findsOneWidget);
    expect(find.text('Add Choice'), findsNothing);
    expect(
      tester.widgetList(find.byType(TextField)).any((widget) => (widget as TextField).decoration?.labelText == 'Scale Values'),
      isFalse,
    );
    expect(
      tester.widgetList(find.byType(TextField)).any((widget) => (widget as TextField).decoration?.labelText == 'Placeholder'),
      isFalse,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(
          notifier: appState,
          child: TemplateBuilderPage(
            key: ValueKey(textTemplate.id),
            style: TemplateStyle.traditional,
            mode: TemplateBuilderMode.preview,
            template: textTemplate,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      tester.widgetList(find.byType(TextField)).any((widget) => (widget as TextField).decoration?.labelText == 'Placeholder'),
      isTrue,
    );
    expect(
      tester.widgetList(find.byType(TextField)).any((widget) => (widget as TextField).decoration?.labelText == 'Scale Values'),
      isFalse,
    );
    expect(find.text('Add Choice'), findsNothing);
  });
}
