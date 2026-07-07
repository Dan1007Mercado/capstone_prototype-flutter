import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class OnlineFormsQuestionnairePage extends StatefulWidget {
  const OnlineFormsQuestionnairePage({
    super.key,
    required this.survey,
  });

  final SurveyRecord survey;

  @override
  State<OnlineFormsQuestionnairePage> createState() =>
      _OnlineFormsQuestionnairePageState();
}

class _OnlineFormsQuestionnairePageState
    extends State<OnlineFormsQuestionnairePage> {
  final _responses = <int, dynamic>{};
  late final List<_SurveyQuestion> _questions;
  int _currentIndex = 0;
  bool _submitted = false;
  bool _showRequiredError = false;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
  }

  static const _likertOptions = [
    'Strongly disagree',
    'Disagree',
    'Neutral',
    'Agree',
    'Strongly agree',
  ];

  List<_SurveyQuestion> _buildQuestions() {
    final allQuestions = <_SurveyQuestion>[
      _SurveyQuestion(
        number: 1,
        prompt: 'The application is easy to use.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 2,
        prompt: 'The interface is visually appealing.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 3,
        prompt: 'The system responds quickly to my actions.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 4,
        prompt: 'Navigation within the application is simple.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 5,
        prompt: 'The features meet my needs.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 6,
        prompt: 'I can complete my tasks efficiently using the application.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 7,
        prompt: 'The instructions provided are clear and understandable.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 8,
        prompt: 'The application performs reliably without errors.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 9,
        prompt: 'I feel comfortable using this application.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 10,
        prompt: 'The application saves me time.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 11,
        prompt: 'The information presented is accurate.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 12,
        prompt: 'The system loads pages quickly.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 13,
        prompt: 'The application improves my productivity.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 14,
        prompt: 'I trust the accuracy of the information provided.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 15,
        prompt: 'The application’s design is organized and professional.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 16,
        prompt: 'The available features are useful.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 17,
        prompt: 'The application is easy to learn even for first-time users.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 18,
        prompt: 'Overall, I am satisfied with this application.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 19,
        prompt: 'I would recommend this application to others.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 20,
        prompt: 'I intend to continue using this application in the future.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 21,
        prompt: 'The application meets my expectations.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 22,
        prompt: 'Overall, this application provides a positive user experience.',
        type: _QuestionType.radio,
        options: _likertOptions,
      ),
      _SurveyQuestion(
        number: 23,
        prompt: 'How often do you use the application?',
        type: _QuestionType.multipleChoice,
        options: [
          'Daily',
          'Several times a week',
          'Weekly',
          'Monthly',
          'Rarely',
        ],
      ),
      _SurveyQuestion(
        number: 24,
        prompt: 'Which device do you primarily use to access the application?',
        type: _QuestionType.multipleChoice,
        options: [
          'Desktop Computer',
          'Laptop',
          'Android Phone',
          'iPhone',
          'Tablet',
        ],
      ),
      _SurveyQuestion(
        number: 25,
        prompt: 'Which feature do you use most often?',
        type: _QuestionType.multipleChoice,
        options: [
          'Dashboard',
          'Survey Templates',
          'Survey Builder',
          'Reports',
          'Analytics',
        ],
      ),
      _SurveyQuestion(
        number: 26,
        prompt: 'How did you first learn about this application?',
        type: _QuestionType.multipleChoice,
        options: [
          'Teacher/Instructor',
          'Friend/Classmate',
          'Social Media',
          'School',
          'Other',
        ],
      ),
      _SurveyQuestion(
        number: 27,
        prompt: 'Overall, how would you rate this application?',
        type: _QuestionType.multipleChoice,
        options: [
          'Excellent',
          'Very Good',
          'Good',
          'Fair',
          'Poor',
        ],
      ),
      _SurveyQuestion(
        number: 28,
        prompt: 'What feature of the application do you find most useful?',
        type: _QuestionType.shortText,
        options: const [],
      ),
      _SurveyQuestion(
        number: 29,
        prompt: 'What improvements would you recommend for the application?',
        type: _QuestionType.longText,
        options: const [],
      ),
      _SurveyQuestion(
        number: 30,
        prompt:
            'Please provide any additional comments or suggestions regarding your experience using the application.',
        type: _QuestionType.longText,
        options: const [],
      ),
    ];

    final random = Random(widget.survey.id.hashCode ^ DateTime.now().millisecondsSinceEpoch);
    allQuestions.shuffle(random);
    return allQuestions.take(15).toList();
  }

  void _saveAnswer(dynamic value) {
    setState(() {
      _responses[_questions[_currentIndex].number] = value;
      _showRequiredError = false;
    });
  }

  void _goNext() {
    final answered = _responses.containsKey(_questions[_currentIndex].number);
    if (!answered) {
      setState(() => _showRequiredError = true);
      return;
    }

    setState(() {
      _showRequiredError = false;
      if (_currentIndex < _questions.length - 1) {
        _currentIndex += 1;
      } else {
        _submitResponses();
      }
    });
  }

  void _goBack() {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex -= 1);
  }

  void _submitResponses() {
    if (_submitted) return;
    setState(() => _submitted = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.lg),
          ),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline,
                  color: AppPalette.teal700, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Thank you for answering!')),
            ],
          ),
          content: const Text('We appreciate your response.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.teal700,
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    final answered = _responses.containsKey(current.number);
    final canContinue = answered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Online Forms', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: const Color.fromARGB(255, 43, 215, 203),
        elevation: 0,
      ),
      body: Container(
        color: AppPalette.teal50,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 760 ? 780.0 : double.infinity;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.survey.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Answer a randomized subset of 15 questions.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.slate600,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Question ${_currentIndex + 1} of ${_questions.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Text(
                                  'Survey: ${widget.survey.name}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppPalette.slate500,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            LinearProgressIndicator(
                              value: (_currentIndex + 1) / _questions.length,
                              color: AppPalette.teal700,
                              backgroundColor: AppPalette.teal100,
                              minHeight: 6,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              current.prompt,
                              style:
                                  Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            const SizedBox(height: 10),
                            if (current.type == _QuestionType.shortText ||
                                current.type == _QuestionType.longText)
                              _TextAnswerField(
                                value: _responses[current.number] as String? ?? '',
                                multiline: current.type == _QuestionType.longText,
                                onChanged: _saveAnswer,
                              )
                            else
                              _OptionList(
                                question: current,
                                selectedValue: _responses[current.number],
                                onSelected: _saveAnswer,
                              ),
                            if (_showRequiredError &&
                                !_responses.containsKey(current.number)) ...[
                              const SizedBox(height: 10),
                              Text(
                                'This question is required.',
                                style: TextStyle(
                                  color: AppPalette.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _currentIndex > 0 ? _goBack : null,
                            child: const Text('Back'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: canContinue ? _goNext : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: canContinue
                                  ? AppPalette.teal700
                                  : AppPalette.slate300,
                            ),
                            child: Text(
                              _currentIndex == _questions.length - 1
                                  ? 'Submit'
                                  : 'Next',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({
    required this.question,
    required this.selectedValue,
    required this.onSelected,
  });

  final _SurveyQuestion question;
  final dynamic selectedValue;
  final ValueChanged<dynamic> onSelected;

  @override
  Widget build(BuildContext context) {
    if (question.type == _QuestionType.multipleChoice) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: question.options.map((option) {
          final selected = selectedValue == option;
          return ChoiceChip(
            label: Text(option),
            selected: selected,
            onSelected: (_) => onSelected(option),
            selectedColor: AppPalette.teal700,
            backgroundColor: AppPalette.slate100,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppPalette.slate800,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: question.options.map((option) {
        return RadioListTile<String>(
          value: option,
          groupValue: selectedValue as String?,
          onChanged: (value) {
            if (value != null) onSelected(value);
          },
          title: Text(option),
          activeColor: AppPalette.teal700,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}

class _TextAnswerField extends StatelessWidget {
  const _TextAnswerField({
    required this.value,
    required this.onChanged,
    this.multiline = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      maxLines: multiline ? 5 : 1,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: multiline ? 'Enter your detailed answer...' : 'Type your answer here',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
          borderSide: BorderSide(color: AppPalette.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
          borderSide: BorderSide(color: AppPalette.teal700),
        ),
      ),
    );
  }
}

enum _QuestionType { multipleChoice, radio, shortText, longText }

class _SurveyQuestion {
  _SurveyQuestion({
    required this.number,
    required this.prompt,
    required this.type,
    required this.options,
  });

  final int number;
  final String prompt;
  final _QuestionType type;
  final List<String> options;
}
