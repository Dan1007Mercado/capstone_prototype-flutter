import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/paginated_table_card.dart';

class ResponsesPage extends StatefulWidget {
  const ResponsesPage({
    super.key,
    required this.survey,
    required this.responses,
  });

  final SurveyRecord survey;
  final List<ResponseRecord> responses;

  @override
  State<ResponsesPage> createState() => _ResponsesPageState();
}

class _ResponsesPageState extends State<ResponsesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ResponseRecord> get _filteredResponses {
    if (_query.trim().isEmpty) {
      return widget.responses;
    }
    final lower = _query.toLowerCase();
    return widget.responses
        .where((response) => response.responseId.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResponses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Responses · ${widget.survey.name}'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 700;
          final isTablet = width >= 700 && width < 1100;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Survey Responses',
                      subtitle: 'Search by Response ID using frontend-only mock filtering.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        labelText: 'Search by Response ID',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isMobile)
                _ResponsesMobileList(
                  survey: widget.survey,
                  responses: filtered,
                  onView: _openDetails,
                )
              else if (isTablet)
                _ResponsesTabletTable(
                  survey: widget.survey,
                  responses: filtered,
                  onView: _openDetails,
                )
              else
                _ResponsesDesktopTable(
                  survey: widget.survey,
                  responses: filtered,
                  onView: _openDetails,
                ),
            ],
          );
        },
      ),
    );
  }

  void _openDetails(ResponseRecord response) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResponseDetailsPage(response: response),
      ),
    );
  }
}

class _ResponsesDesktopTable extends StatelessWidget {
  const _ResponsesDesktopTable({
    required this.survey,
    required this.responses,
    required this.onView,
  });

  final SurveyRecord survey;
  final List<ResponseRecord> responses;
  final void Function(ResponseRecord response) onView;

  @override
  Widget build(BuildContext context) {
    return PaginatedTableCard(
      title: 'Responses for ${survey.name}',
      subtitle: 'Desktop table view with mock pagination.',
      rowsPerPage: 8,
      columns: const [
        DataColumn(label: Text('Response ID')),
        DataColumn(label: Text('Survey Name')),
        DataColumn(label: Text('Respondent Name')),
        DataColumn(label: Text('Sync Date')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: responses
          .map(
            (response) => DataRow(
              cells: [
                DataCell(Text(response.responseId)),
                DataCell(Text(response.surveyName)),
                DataCell(Text(response.respondentName)),
                DataCell(Text(response.syncDate)),
                DataCell(StatusBadge(
                  label: responseStatusLabel(response.status),
                  color: responseStatusColor(response.status),
                )),
                DataCell(
                  TextButton.icon(
                    onPressed: () => onView(response),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _ResponsesTabletTable extends StatelessWidget {
  const _ResponsesTabletTable({
    required this.survey,
    required this.responses,
    required this.onView,
  });

  final SurveyRecord survey;
  final List<ResponseRecord> responses;
  final void Function(ResponseRecord response) onView;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Responses for ${survey.name}',
            subtitle: 'Tablet view using PaginatedDataTable.',
          ),
          const SizedBox(height: 16),
          PaginatedDataTable(
            header: const Text('Responses'),
            rowsPerPage: responses.isEmpty ? 1 : math.min(8, responses.length).toInt(),
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Response ID')),
              DataColumn(label: Text('Respondent Name')),
              DataColumn(label: Text('Sync Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            source: _ResponsesDataSource(
              responses: responses,
              onView: onView,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsesMobileList extends StatelessWidget {
  const _ResponsesMobileList({
    required this.survey,
    required this.responses,
    required this.onView,
  });

  final SurveyRecord survey;
  final List<ResponseRecord> responses;
  final void Function(ResponseRecord response) onView;

  @override
  Widget build(BuildContext context) {
    if (responses.isEmpty) {
      return const SurfaceCard(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No responses found.'),
        ),
      );
    }

    return Column(
      children: [
        for (final response in responses) ...[
          _ResponseCard(
            response: response,
            onView: () => onView(response),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ResponsesDataSource extends DataTableSource {
  _ResponsesDataSource({
    required this.responses,
    required this.onView,
  });

  final List<ResponseRecord> responses;
  final void Function(ResponseRecord response) onView;

  @override
  DataRow? getRow(int index) {
    if (index >= responses.length) return null;
    final response = responses[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(response.responseId)),
        DataCell(Text(response.respondentName)),
        DataCell(Text(response.syncDate)),
        DataCell(StatusBadge(
          label: responseStatusLabel(response.status),
          color: responseStatusColor(response.status),
        )),
        DataCell(
          TextButton.icon(
            onPressed: () => onView(response),
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('View'),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => responses.length;

  @override
  int get selectedRowCount => 0;
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({
    required this.response,
    required this.onView,
  });

  final ResponseRecord response;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.responseId,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response.respondentName,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: responseStatusLabel(response.status),
                color: responseStatusColor(response.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DetailRow(label: 'Survey', value: response.surveyName),
          const SizedBox(height: 6),
          DetailRow(label: 'Sync Date', value: response.syncDate),
          const SizedBox(height: 6),
          DetailRow(label: 'Submitted', value: response.dateSubmitted),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onView,
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponseDetailsPage extends StatelessWidget {
  const ResponseDetailsPage({super.key, required this.response});

  final ResponseRecord response;

  @override
  Widget build(BuildContext context) {
    final averageScore =
        response.answers.fold<int>(0, (sum, answer) => sum + answer.score) / response.answers.length;
    final stats = [
      StatItem(
        label: 'Average Score',
        value: averageScore.toStringAsFixed(1),
        icon: Icons.star_outline,
        accent: AppColors.primary,
        delta: '1-5 scale',
      ),
      StatItem(
        label: 'Completion Rate',
        value: '${response.completionRate.toStringAsFixed(0)}%',
        icon: Icons.checklist_outlined,
        accent: AppColors.success,
        delta: 'Answered',
      ),
      StatItem(
        label: 'Submission Time',
        value: response.dateSubmitted,
        icon: Icons.schedule_outlined,
        accent: AppColors.info,
        delta: 'Mock timestamp',
      ),
      StatItem(
        label: 'Survey Category',
        value: response.surveyCategory,
        icon: Icons.category_outlined,
        accent: AppColors.warning,
        delta: 'Assigned',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(response.responseId)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Respondent Information',
                  subtitle: 'Mock completed questionnaire preview.',
                ),
                const SizedBox(height: 16),
                _InfoGrid(response: response),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Questionnaire Content',
            subtitle: 'Twenty unique quantitative answers on a 1-5 Likert scale.',
          ),
          const SizedBox(height: 16),
          for (final answer in response.answers) ...[
            _QuestionAnswerCard(answer: answer),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final stat in stats)
                    SizedBox(
                      width: wide ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth,
                      child: StatCard(
                        label: stat.label,
                        value: stat.value,
                        icon: stat.icon,
                        accent: stat.accent,
                        delta: stat.delta,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Interpretation',
                  subtitle: 'Mock respondent summary based on the generated answers.',
                ),
                const SizedBox(height: 12),
                Text(
                  response.interpretation,
                  style: const TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.response});

  final ResponseRecord response;

  @override
  Widget build(BuildContext context) {
    final items = [
      ['Response ID', response.responseId],
      ['Survey Name', response.surveyName],
      ['Respondent Name', response.respondentName],
      ['Age', '${response.age}'],
      ['Gender', response.gender],
      ['Civil Status', response.civilStatus],
      ['Occupation', response.occupation],
      ['Educational Level', response.educationalLevel],
      ['Location', response.location],
      ['Date Submitted', response.dateSubmitted],
      ['Sync Date', response.syncDate],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900 ? 2 : 1;
        return Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            for (final item in items)
              SizedBox(
                width: columns == 2 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                child: DetailRow(label: item[0], value: item[1]),
              ),
          ],
        );
      },
    );
  }
}

class _QuestionAnswerCard extends StatelessWidget {
  const _QuestionAnswerCard({required this.answer});

  final ResponseQuestionAnswer answer;

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(
      5,
      (index) => Icon(
        index < answer.score ? Icons.star_rounded : Icons.star_border_rounded,
        color: index < answer.score ? AppColors.warning : AppColors.textDisabled,
        size: 18,
      ),
    );

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${answer.questionNumber}. ${answer.questionText}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(children: stars),
              const SizedBox(width: 12),
              Text('${answer.score} / 5'),
              const SizedBox(width: 12),
              AccentChip(
                label: answer.answerLabel,
                color: answer.score >= 4
                    ? AppColors.success
                    : answer.score == 3
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            answer.score >= 4
                ? 'Good Accessibility'
                : answer.score == 3
                    ? 'Moderate perception'
                    : 'Needs attention',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
