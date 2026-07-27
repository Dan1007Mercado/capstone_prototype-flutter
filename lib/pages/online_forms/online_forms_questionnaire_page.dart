import 'dart:math';

import 'package:flutter/material.dart';

import '../../pages/auth/login.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/web_sidebar.dart';

class OnlineFormsQuestionnairePage extends StatefulWidget {
  const OnlineFormsQuestionnairePage({
    super.key,
    required this.survey,
    this.readOnly = false,
  });

  final SurveyRecord survey;
  final bool readOnly;

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

  int get _answeredCount => _responses.length;

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

    final random = Random(widget.survey.id.hashCode);
    allQuestions.shuffle(random);
    return allQuestions.take(15).toList();
  }

  void _saveAnswer(dynamic value) {
    if (widget.readOnly) return;
    setState(() {
      _responses[_questions[_currentIndex].number] = value;
      _showRequiredError = false;
    });
  }

  void _goNext() {
    if (widget.readOnly) {
      setState(() {
        if (_currentIndex < _questions.length - 1) {
          _currentIndex += 1;
        } else {
          Navigator.of(context).pop();
        }
      });
      return;
    }

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

  void _handleSidebarNavigate(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => ResponsiveShell(initialIndex: index),
      ),
      (route) => false,
    );
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    final answered = _responses.containsKey(current.number);
    final canContinue = widget.readOnly || answered;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            backgroundColor: AppPalette.teal50,
            body: Row(
              children: [
                WebSidebar(
                  currentIndex: 3,
                  onNavigate: _handleSidebarNavigate,
                  onLogout: _handleLogout,
                ),
                Expanded(
                  child: _buildQuestionnaireBody(
                    context,
                    current,
                    answered: answered,
                    canContinue: canContinue,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Online Forms',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          body: _buildQuestionnaireBody(
            context,
            current,
            answered: answered,
            canContinue: canContinue,
          ),
        );
      },
    );
  }

  Widget _buildQuestionnaireBody(
    BuildContext context,
    _SurveyQuestion current, {
    required bool answered,
    required bool canContinue,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppPalette.teal50, Colors.white],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          final maxWidth = isWide ? 1180.0 : 780.0;
          final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(context),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 320,
                            child: _buildInfoPanel(context, current),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildQuestionCard(
                              context,
                              current,
                              answered: answered,
                              canContinue: canContinue,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildInfoPanel(context, current),
                      const SizedBox(height: 16),
                      _buildQuestionCard(
                        context,
                        current,
                        answered: answered,
                        canContinue: canContinue,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.teal600, AppPalette.teal400],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        boxShadow: [
          BoxShadow(
            color: AppPalette.teal700.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.survey.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.readOnly
                      ? 'Review the questions for this closed form. Responses are disabled.'
                      : 'Answer a randomized subset of 15 questions in a clean, focused flow.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      icon: widget.readOnly
                          ? Icons.visibility_outlined
                          : Icons.edit_outlined,
                      label: widget.readOnly ? 'Read only' : 'Interactive',
                    ),
                    _StatusPill(
                      icon: Icons.quiz_outlined,
                      label: '${_questions.length} questions',
                    ),
                    _StatusPill(
                      icon: Icons.check_circle_outline,
                      label: '${_answeredCount} answered',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, _SurveyQuestion current) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Survey Overview',
            subtitle: 'Track your progress and current mode.',
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.article_outlined,
            label: 'Mode',
            value: widget.readOnly ? 'Review' : 'Answering',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.bar_chart_outlined,
            label: 'Progress',
            value: '${_currentIndex + 1}/${_questions.length}',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.check_circle_outline,
            label: 'Completed',
            value: '$_answeredCount',
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            color: AppPalette.teal700,
            backgroundColor: AppPalette.teal100,
            minHeight: 6,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPalette.teal50,
              borderRadius: BorderRadius.circular(RadiusTokens.md),
              border: Border.all(color: AppPalette.teal100),
            ),
            child: Text(
              current.prompt,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.slate700,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    _SurveyQuestion current, {
    required bool answered,
    required bool canContinue,
  }) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Question ${_currentIndex + 1} of ${_questions.length}',
            subtitle: widget.readOnly
                ? 'Read-only review mode'
                : 'Answer this item to continue to the next question.',
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            color: AppPalette.teal700,
            backgroundColor: AppPalette.teal100,
            minHeight: 6,
          ),
          const SizedBox(height: 20),
          Text(
            current.prompt,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppPalette.slate900,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 16),
          if (current.type == _QuestionType.shortText ||
              current.type == _QuestionType.longText)
            _TextAnswerField(
              value: _responses[current.number] as String? ?? '',
              multiline: current.type == _QuestionType.longText,
              readOnly: widget.readOnly,
              onChanged: _saveAnswer,
            )
          else
            _OptionList(
              question: current,
              selectedValue: _responses[current.number],
              readOnly: widget.readOnly,
              onSelected: _saveAnswer,
            ),
          if (_showRequiredError && !answered) ...[
            const SizedBox(height: 12),
            Text(
              'This question is required.',
              style: TextStyle(
                color: AppPalette.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton.icon(
                onPressed: _currentIndex > 0 ? _goBack : null,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: canContinue ? _goNext : null,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      canContinue ? AppPalette.teal700 : AppPalette.slate300,
                ),
                icon: Icon(
                  _currentIndex == _questions.length - 1
                      ? (widget.readOnly
                          ? Icons.check
                          : Icons.send_outlined)
                      : Icons.arrow_forward,
                  size: 18,
                ),
                label: Text(
                  _currentIndex == _questions.length - 1
                      ? (widget.readOnly ? 'Done' : 'Submit')
                      : 'Next',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(RadiusTokens.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppPalette.teal50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppPalette.teal700, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.slate500,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppPalette.slate900,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({
    required this.question,
    required this.selectedValue,
    required this.readOnly,
    required this.onSelected,
  });

  final _SurveyQuestion question;
  final dynamic selectedValue;
  final bool readOnly;
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
            onSelected: readOnly ? null : (_) => onSelected(option),
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
          onChanged: readOnly
              ? null
              : (value) {
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
    this.readOnly = false,
    this.multiline = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      maxLines: multiline ? 5 : 1,
      enabled: !readOnly,
      onChanged: readOnly ? null : onChanged,
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
