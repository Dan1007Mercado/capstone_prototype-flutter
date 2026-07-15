import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/paginated_table_card.dart';

const Color _responsesTealDark = Color.fromARGB(255, 13, 232, 232);
const Color _responsesTealLight = Color(0xFF2DD4CF);
const Color _responsesHeadingText = Color(0xFF0E2A2E);
const Color _responsesBodyText = Color(0xFF7C8A90);
const Color _responsesCardWhite = Color(0xFFFFFFFF);
const Color _responsesBorder = Color(0xFFDDECEF);
const Color _responsesMintChipBg = Color(0xFFDFF5F3);

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
  String _filterType = 'all'; // 'all', 'needs_review', 'good'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ResponseRecord> get _filteredResponses {
    var responses = widget.responses;
    
    // Filter by type (needs review or good)
    if (_filterType == 'needs_review') {
      responses = responses.where(_responseNeedsReview).toList();
    } else if (_filterType == 'good') {
      responses = responses.where((response) => !_responseNeedsReview(response)).toList();
    }
    
    // Filter by search query
    if (_query.trim().isEmpty) {
      return responses;
    }
    final lower = _query.toLowerCase();
    return responses
        .where((response) => response.responseId.toLowerCase().contains(lower))
        .toList();
  }

  bool _responseNeedsReview(ResponseRecord response) {
    return response.answers.where((a) => a.score < 2).length > 1;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResponses;
    final reviewResponses = filtered.where(_responseNeedsReview).toList();
    final goodResponses = filtered.where((response) => !_responseNeedsReview(response)).toList();
    final reviewDisplay = reviewResponses.take(5).toList();

    return Scaffold(
      backgroundColor: AppPalette.teal50,
      appBar: AppBar(
        backgroundColor: AppPalette.teal50,
        foregroundColor: _responsesHeadingText,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          'Responses · ${widget.survey.name}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 700;
          final isTablet = width >= 700 && width < 1100;
          final maxWidth = width >= 960 ? 960.0 : width.clamp(320.0, 900.0);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_responsesTealLight, _responsesTealDark],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Survey responses',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.survey.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by response ID',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.82), size: 18),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.34)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PanelCard(
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
                                    '${filtered.length} responses shown',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: _responsesHeadingText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Frontend-only sample responses for this survey.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _responsesBodyText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _StatusPill(
                              label: widget.survey.status.name.toUpperCase(),
                              color: widget.survey.status == SurveyStatus.active ? AppPalette.success : AppPalette.primary500,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FilterChip(
                              label: 'All Responses (${widget.responses.length})',
                              isSelected: _filterType == 'all',
                              onPressed: () => setState(() => _filterType = 'all'),
                              color: Colors.blue,
                            ),
                            _FilterChip(
                              label: 'Needs Review (${reviewResponses.length})',
                              isSelected: _filterType == 'needs_review',
                              onPressed: () => setState(() => _filterType = 'needs_review'),
                              color: Colors.orange,
                            ),
                            _FilterChip(
                              label: 'Good (${goodResponses.length})',
                              isSelected: _filterType == 'good',
                              onPressed: () => setState(() => _filterType = 'good'),
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isNotEmpty)
                    _PanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 4, 6, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _filterType == 'needs_review'
                                      ? 'Needs Review'
                                      : _filterType == 'good'
                                          ? 'Good Responses'
                                          : 'All Responses',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: _responsesHeadingText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _filterType == 'needs_review'
                                      ? 'Showing ${filtered.length} responses flagged for review.'
                                      : _filterType == 'good'
                                          ? 'Showing ${filtered.length} high-quality responses.'
                                          : 'Showing ${filtered.length} total responses.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _responsesBodyText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                      ),
                    )
                  else
                    _PanelCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 42,
                              color: _responsesBodyText,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No responses found.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _responsesBodyText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
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

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _responsesCardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _responsesBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.20) : color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.5) : color.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
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
      return _PanelCard(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: const [
            Icon(Icons.inbox_outlined, color: Color.fromARGB(255, 0, 0, 0)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No responses found.',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w600),
              ),
            ),
          ],
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
    // Flag responses only if they have multiple low scores (quality control)
    final lowScoreCount = response.answers.where((a) => a.score < 2).length;
    final needsReview = lowScoreCount > 1; // Only flag if 2+ low scores

    return _PanelCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (needsReview)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border(
                  bottom: BorderSide(color: Colors.orange[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Needs Review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[900],
                    ),
                  ),
                ],
              ),
            ),
          Padding(
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
                            style: const TextStyle(fontWeight: FontWeight.w800, color: _responsesHeadingText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            response.respondentName,
                            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(
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
                  child: FilledButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.primary600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
              ],
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
      backgroundColor: AppPalette.teal50,
      appBar: AppBar(
        backgroundColor: AppPalette.teal50,
        foregroundColor: _responsesHeadingText,
        elevation: 0,
        title: Text(response.responseId, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_responsesTealLight, _responsesTealDark],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.white, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            response.respondentName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            response.surveyName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Respondent information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _responsesHeadingText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mock completed questionnaire preview.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _responsesBodyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoGrid(response: response),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Questionnaire content',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _responsesHeadingText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
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
              _PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interpretation',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _responsesHeadingText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      response.interpretation,
                      style: const TextStyle(height: 1.6, color: _responsesBodyText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
