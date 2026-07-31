import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

import '../../mock/mock_data.dart' as mock_data;
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'deploy_survey_page.dart';

/// Shared helper (used by both the mobile and web layouts) to determine
/// whether a survey has responses that should be flagged for review.
bool _surveyHasFlaggedResponses(SurveyRecord survey) {
  final responses = mock_data.buildMockResponses(survey);
  final flaggedCount = responses.where((resp) {
    // Flag responses with 2+ low scores
    final lowScores = resp.answers.where((a) => a.score < 2).length;
    return lowScores > 1;
  }).length;
  return flaggedCount > 0;
}

class SurveysPage extends StatefulWidget {
  const SurveysPage({
    super.key,
    required this.onOpenAnalytics,
    this.onOpenResponses,
    this.onNotifications,
    this.onSettings,
    this.unreadNotifications = 0,
  });

  final void Function([String? surveyName]) onOpenAnalytics;
  final void Function(SurveyRecord survey)? onOpenResponses;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final int unreadNotifications;

  @override
  State<SurveysPage> createState() => _SurveysPageState();
}

class _SurveysPageState extends State<SurveysPage> {
  final _searchController = TextEditingController();
  String _query = '';
  SurveyStatus? _statusFilter;
  int _page = 0;

  static const int _surveysPerPage = 10;

  static const Color _tealDark = Color.fromARGB(255, 13, 232, 232);
  static const Color _tealLight = Color(0xFF2DD4CF);
  static const Color _iconTeal = Color(0xFF14B8A6);
  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _headingText = Colors.black;
  static const Color _bodyText = Colors.black;
  static const Color _successGreen = Color(0xFF16A34A);
  static const Color _dangerRed = Color(0xFFE11D48);
  static const Color _infoBlue = Color(0xFF2563EB);
  static const Color _border = Color(0xFFDDECEF);

  static final _boldFont = pw.Font.courierBold();
  static final _regularFont = pw.Font.courier();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final query = _query.trim().toLowerCase();
    final surveys = appState.surveys.where((survey) {
      if (_statusFilter != null && survey.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return survey.name.toLowerCase().contains(query) ||
          survey.templateUsed.toLowerCase().contains(query) ||
          survey.id.toLowerCase().contains(query);
    }).toList();
    final totalPages = _totalPages(surveys.length);
    final currentPage = _currentPage(surveys.length);
    final pagedSurveys = _pageItems(surveys, currentPage);

    final allSurveys = appState.surveys;
    final totalCount = allSurveys.length;
    final activeCount =
        allSurveys.where((s) => s.status == SurveyStatus.active).length;
    final totalResponses = allSurveys.fold<int>(
      0,
      (sum, s) => sum + s.responses,
    );
    final flaggedCount = allSurveys.where(_surveyHasFlaggedResponses).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return _buildMobileLayout(
            context,
            surveys: surveys,
            pagedSurveys: pagedSurveys,
            currentPage: currentPage,
            totalPages: totalPages,
          );
        }
        return _buildWebLayout(
          context,
          surveys: surveys,
          pagedSurveys: pagedSurveys,
          currentPage: currentPage,
          totalPages: totalPages,
          totalCount: totalCount,
          activeCount: activeCount,
          totalResponses: totalResponses,
          flaggedCount: flaggedCount,
        );
      },
    );
  }

  int _totalPages(int itemCount) {
    if (itemCount == 0) return 1;
    return (itemCount / _surveysPerPage).ceil();
  }

  int _currentPage(int itemCount) {
    final maxPage = _totalPages(itemCount) - 1;
    return _page.clamp(0, maxPage).toInt();
  }

  List<SurveyRecord> _pageItems(List<SurveyRecord> surveys, int page) {
    if (surveys.isEmpty) return const [];
    final start = page * _surveysPerPage;
    final end = start + _surveysPerPage > surveys.length
        ? surveys.length
        : start + _surveysPerPage;
    return surveys.sublist(start, end);
  }

  void _updateQuery(String value) {
    setState(() {
      _query = value;
      _page = 0;
    });
  }

  void _updateStatusFilter(SurveyStatus? status) {
    setState(() {
      _statusFilter = status;
      _page = 0;
    });
  }

  void _previousPage() {
    if (_page == 0) return;
    setState(() => _page -= 1);
  }

  void _nextPage(int itemCount) {
    final maxPage = _totalPages(itemCount) - 1;
    if (_page >= maxPage) return;
    setState(() => _page += 1);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT (preserved from original — do not modify)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(
    BuildContext context, {
    required List<SurveyRecord> surveys,
    required List<SurveyRecord> pagedSurveys,
    required int currentPage,
    required int totalPages,
  }) {
    return Container(
      color: AppPalette.teal50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 720 ? 960.0 : 560.0;
          final horizontalPadding = constraints.maxWidth >= 720 ? 28.0 : 16.0;

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
                        title: 'Surveys',
                        onNotifications: widget.onNotifications,
                        onSettings: widget.onSettings,
                        unreadNotifications: widget.unreadNotifications,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _SurveysHero(
                        totalCount: surveys.length,
                        statusFilter: _statusFilter,
                        searchController: _searchController,
                        onSearchChanged: _updateQuery,
                        onStatusFilterChanged: _updateStatusFilter,
                        onBack: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                          return;
                        }
                        _snack(context, 'Back is unavailable on this tab');
                      },
                      onNew: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const DeploySurveyPage(),
                        ),
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
                      child: _SurveysPanel(
                        surveys: pagedSurveys,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onPreviousPage: _previousPage,
                        onNextPage: () => _nextPage(surveys.length),
                        onOpenResponses: widget.onOpenResponses,
                        onOpenAnalytics: widget.onOpenAnalytics,
                        onDownloadOmr: (survey) =>
                            _downloadOmrTemplate(context, survey),
                        onMockAction: (value, survey) => _snack(
                          context,
                          '$value is a mock action for ${survey.name}',
                        ),
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

  // ═══════════════════════════════════════════════════════════════════════
  // WEB LAYOUT (modern design, matching the mobile teal palette)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(
    BuildContext context, {
    required List<SurveyRecord> surveys,
    required List<SurveyRecord> pagedSurveys,
    required int currentPage,
    required int totalPages,
    required int totalCount,
    required int activeCount,
    required int totalResponses,
    required int flaggedCount,
  }) {
    return Container(
      color: _pageBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.xxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WebSurveysHeader(
                  totalCount: totalCount,
                  searchController: _searchController,
                  onSearchChanged: _updateQuery,
                  onNew: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const DeploySurveyPage(),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxl),
                _WebSurveysStatsRow(
                  totalCount: totalCount,
                  activeCount: activeCount,
                  totalResponses: totalResponses,
                  flaggedCount: flaggedCount,
                ),
                const SizedBox(height: SpacingTokens.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: _WebSurveysFilterBar(
                    statusFilter: _statusFilter,
                    onStatusFilterChanged: _updateStatusFilter,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxl),
                _WebSurveysTable(
                  surveys: pagedSurveys,
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPreviousPage: _previousPage,
                  onNextPage: () => _nextPage(surveys.length),
                  onOpenResponses: widget.onOpenResponses,
                  onOpenAnalytics: widget.onOpenAnalytics,
                  onDownloadOmr: (survey) =>
                      _downloadOmrTemplate(context, survey),
                  onMockAction: (value, survey) => _snack(
                    context,
                    '$value is a mock action for ${survey.name}',
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SurveyStatus status) {
    return switch (status) {
      SurveyStatus.active => _successGreen,
      SurveyStatus.closed => _bodyText,
      SurveyStatus.inactive => _dangerRed,
    };
  }

  String _getStatusLabel(SurveyStatus status) {
    return switch (status) {
      SurveyStatus.active => 'Active',
      SurveyStatus.closed => 'Closed',
      SurveyStatus.inactive => 'Inactive',
    };
  }

  String _displayDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day.toString().padLeft(2, '0')}, ${parsed.year}';
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _downloadOmrTemplate(BuildContext context, SurveyRecord survey) async {
    final fileName = '${survey.name.replaceAll(' ', '_')}_OMR_Template.pdf';
    final surveyCode = survey.id.substring(0, 8).toUpperCase();

    final document = pw.Document();

    // OMR margins (17mm = ~48pt for professional OMR scanning)
    const double marginTop = 48;
    const double marginBottom = 48;
    const double marginLeft = 48;
    const double marginRight = 48;
    const double contentHeight = 792 - marginTop - marginBottom; // ~696pt available

    final sections = _generateSurveySections();

    // Build all content with height tracking for dynamic pagination
    List<List<pw.Widget>> pages = [];
    List<pw.Widget> currentPage = [];
    double currentPageHeight = 0;

    // Estimate heights (in points)
    const double sectionHeaderHeight = 14 + 2; // ~16pt per section
    const double questionRowHeight = 11; // ~11pt per question
    const double spacingHeight = 6; // ~6pt spacing between sections
    const double commentsHeight = 50;

    // Add header to first page
    currentPageHeight = 0;

    void addToCurrentPage(pw.Widget widget, double estimatedHeight) {
      if (currentPageHeight + estimatedHeight > contentHeight) {
        // Page is full, save it and start new
        if (currentPage.isNotEmpty) {
          pages.add(currentPage);
        }
        currentPage = [];
        currentPageHeight = 0;
      }
      currentPage.add(widget);
      currentPageHeight += estimatedHeight;
    }

    // Add survey header
    addToCurrentPage(
      pw.Text('Survey: ${survey.name}', style: pw.TextStyle(font: _boldFont, fontSize: 12)),
      12,
    );
    addToCurrentPage(pw.SizedBox(height: 6), 6);

    // Respondent info row
    addToCurrentPage(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildCompactInfoField('Code', '□ □ □ □ □'),
          _buildCompactInfoField('Date', '□□/□□/□□'),
          _buildCompactInfoField('Location', '□ □ □'),
          _buildCompactInfoField('Gender', 'M ○ F ○'),
        ],
      ),
      24,
    );
    addToCurrentPage(pw.SizedBox(height: 6), 6);

    // Instructions box
    addToCurrentPage(
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8, color: PdfColors.grey600), color: PdfColors.grey100),
        child: pw.Text(
          'Instructions: Fill the circle (●) completely. 1=Strongly Disagree | 2=Disagree | 3=Neutral | 4=Agree | 5=Strongly Agree',
          style: pw.TextStyle(font: _regularFont, fontSize: 7.5),
        ),
      ),
      18,
    );
    addToCurrentPage(pw.SizedBox(height: 8), 8);

    // Add sections with questions
    for (final section in sections) {
      final title = section['title'] as String;
      final questions = section['questions'] as List<String>;
      final startNum = section['startNumber'] as int;

      // Add section header
      addToCurrentPage(_buildSectionHeader(title), sectionHeaderHeight);
      addToCurrentPage(pw.SizedBox(height: 2), 2);

      // Add questions in two-column layout
      addToCurrentPage(_buildDynamicSectionQuestions(questions, startNum), questions.length * questionRowHeight);
      addToCurrentPage(pw.SizedBox(height: spacingHeight), spacingHeight);
    }

    // Add comments section
    addToCurrentPage(
      pw.Container(
        width: double.infinity,
        height: commentsHeight,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8, color: PdfColors.grey600)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Additional comments or feedback:', style: pw.TextStyle(font: _boldFont, fontSize: 8)),
            pw.SizedBox(height: 2),
            pw.Text('_' * 90, style: pw.TextStyle(font: _regularFont, fontSize: 8)),
            pw.SizedBox(height: 2),
            pw.Text('_' * 90, style: pw.TextStyle(font: _regularFont, fontSize: 8)),
            pw.SizedBox(height: 2),
            pw.Text('_' * 90, style: pw.TextStyle(font: _regularFont, fontSize: 8)),
          ],
        ),
      ),
      commentsHeight,
    );

    // Save final page
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    // Now generate PDF pages
    for (var pageNum = 0; pageNum < pages.length; pageNum++) {
      final pageContent = pages[pageNum];
      final pageIndex = pageNum + 1;
      final totalPages = pages.length;

      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context pageContext) {
            return pw.Stack(
              children: [
                // Background
                pw.Positioned.fill(
                  child: pw.Container(color: PdfColors.white),
                ),

                // Outer border
                pw.Positioned.fill(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 2.0, color: PdfColors.black),
                    ),
                  ),
                ),

                // Corner L-guides
                pw.Positioned(
                  left: 16,
                  top: 16,
                  child: pw.Column(children: [pw.Container(width: 32, height: 4, color: PdfColors.black), pw.Container(width: 4, height: 32, color: PdfColors.black)]),
                ),
                pw.Positioned(
                  right: 16,
                  top: 16,
                  child: pw.Column(children: [pw.Container(width: 32, height: 4, color: PdfColors.black), pw.SizedBox(height: 28), pw.Container(width: 4, height: 4, color: PdfColors.black)]),
                ),
                pw.Positioned(
                  left: 16,
                  bottom: 16,
                  child: pw.Column(children: [pw.Container(width: 4, height: 32, color: PdfColors.black), pw.Container(width: 32, height: 4, color: PdfColors.black)]),
                ),
                pw.Positioned(
                  right: 16,
                  bottom: 16,
                  child: pw.Column(children: [pw.Container(width: 4, height: 32, color: PdfColors.black), pw.Container(width: 32, height: 4, color: PdfColors.black)]),
                ),

                // Registration marks (distributed along page height)
                pw.Positioned(left: 20, top: 120, child: pw.Container(width: 10, height: 10, color: PdfColors.black)),
                pw.Positioned(left: 20, top: 330, child: pw.Container(width: 10, height: 10, color: PdfColors.black)),
                pw.Positioned(left: 20, top: 540, child: pw.Container(width: 10, height: 10, color: PdfColors.black)),
                pw.Positioned(left: 20, top: 680, child: pw.Container(width: 10, height: 10, color: PdfColors.black)),

                // Main content area
                pw.Positioned(
                  left: marginLeft,
                  right: marginRight,
                  top: marginTop,
                  bottom: marginBottom + 24,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: pageContent,
                  ),
                ),

                // Footer
                pw.Positioned(
                  left: marginLeft,
                  right: marginRight,
                  bottom: 16,
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 14, height: 14, color: PdfColors.black),
                      pw.SizedBox(width: 4),
                      pw.Container(width: 4, height: 14, color: PdfColors.grey500),
                      pw.Spacer(),
                      pw.SizedBox(
                        width: 60,
                        height: 14,
                        child: pw.BarcodeWidget(barcode: pw.Barcode.code128(), data: surveyCode, drawText: false),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'Page $pageIndex of $totalPages | Code: $surveyCode',
                        style: pw.TextStyle(font: _regularFont, fontSize: 7),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final pdfBytes = await document.save();

    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      anchor.remove();
      return;
    }

    await FilePicker.platform.saveFile(
      dialogTitle: 'Save OMR Template PDF',
      fileName: fileName,
      bytes: pdfBytes,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
  }

  pw.Widget _buildCompactInfoField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(font: _boldFont, fontSize: 8)),
        pw.SizedBox(height: 1),
        pw.Text(value, style: pw.TextStyle(font: _regularFont, fontSize: 8)),
      ],
    );
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 1, color: PdfColors.black),
          top: pw.BorderSide(width: 1, color: PdfColors.black),
        ),
        color: PdfColors.grey200,
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: _boldFont, fontSize: 10),
      ),
    );
  }

  pw.Widget _buildQuestionRow(String question, int questionNumber) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 16,
            child: pw.Text(
              question.split(':').first,
              style: pw.TextStyle(font: _regularFont, fontSize: 8),
            ),
          ),
          pw.SizedBox(width: 3),
          pw.Expanded(
            child: pw.Text(
              question.split(':').length > 1 ? question.split(':')[1].trim() : '',
              style: pw.TextStyle(font: _regularFont, fontSize: 8),
              maxLines: 1,
              overflow: pw.TextOverflow.clip,
            ),
          ),
          pw.SizedBox(width: 3),
          pw.Row(
            children: [
              for (var j = 0; j < 5; j++) ...[
                pw.Container(
                  width: 14,
                  height: 14,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.7, color: PdfColors.black),
                    shape: pw.BoxShape.circle,
                  ),
                ),
                if (j < 4) pw.SizedBox(width: 2),
              ]
            ],
          ),
        ],
      ),
    );
  }

  /// Generate survey sections dynamically based on available content
  List<Map<String, dynamic>> _generateSurveySections() {
    return [
      {
        'title': 'PART 1: General Satisfaction',
        'startNumber': 1,
        'questions': [
          'Q1: Overall satisfaction with the service',
          'Q2: Quality of information provided',
          'Q3: Staff professionalism and courtesy',
          'Q4: Responsiveness to your needs',
          'Q5: Value for money',
          'Q6: Would you recommend this service?',
        ],
      },
      {
        'title': 'PART 2: Communication & Support',
        'startNumber': 7,
        'questions': [
          'Q7: Clarity of communication',
          'Q8: Accessibility of support channels',
          'Q9: Response time to inquiries',
          'Q10: Helpfulness of support staff',
          'Q11: Adequacy of information materials',
          'Q12: Follow-up after service',
        ],
      },
      {
        'title': 'PART 3: Experience & Future',
        'startNumber': 13,
        'questions': [
          'Q13: Overall experience compared to expectations',
          'Q14: Likelihood of using service again',
          'Q15: Value of service for the price',
          'Q16: Service innovation and modernization',
          'Q17: Comparison with competitors',
          'Q18: Overall satisfaction rating',
        ],
      },
      {
        'title': 'PART 4: Improvements & Feedback',
        'startNumber': 19,
        'questions': [
          'Q19: Facility cleanliness and maintenance',
          'Q20: Convenience of location and hours',
          'Q21: User-friendliness of processes',
          'Q22: Overall likelihood of recommendation',
          'Q23: Willingness to refer to others',
          'Q24: Timeliness of service delivery',
        ],
      },
      {
        'title': 'PART 5: Additional Questions',
        'startNumber': 25,
        'questions': [
          'Q25: Transparency in pricing',
          'Q26: Professional appearance of staff',
          'Q27: Effectiveness of follow-up',
          'Q28: Value versus competitors',
          'Q29: Likelihood to revisit',
          'Q30: Overall rating of service',
        ],
      },
    ];
  }

  /// Build two-column question layout
  pw.Widget _buildDynamicSectionQuestions(List<String> questions, int startNumber) {
    final midpoint = (questions.length / 2).ceil();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < midpoint; i++)
                _buildQuestionRow(questions[i], startNumber + i),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (var i = midpoint; i < questions.length; i++)
                _buildQuestionRow(questions[i], startNumber + i),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOBILE WIDGETS (preserved from original — do not modify)
// ═══════════════════════════════════════════════════════════════════════════

class _SurveysHero extends StatelessWidget {
  const _SurveysHero({
    required this.totalCount,
    required this.statusFilter,
    required this.searchController,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onBack,
    required this.onNew,
  });

  final int totalCount;
  final SurveyStatus? statusFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SurveyStatus?> onStatusFilterChanged;
  final VoidCallback onBack;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: width * 0.9,
      constraints: BoxConstraints(
        maxWidth: width * 0.9,
      ),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _SurveysPageState._tealLight,
            _SurveysPageState._tealDark,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(20),
        ),
        border: Border.all(
          color: const Color.fromARGB(255, 92, 5, 5).withValues(alpha: 0.16),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -70,
            top: -96,
            child: _HeroCircle(size: 100, opacity: 0.17),
          ),
          Positioned(
            left: -92,
            bottom: -112,
            child: _HeroCircle(size: 150, opacity: 0.13),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 1),
              const SizedBox(height: 18),
          const SizedBox(height: 12),
          Row(
            children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        cursorColor: Colors.black,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search surveys',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: Colors.black,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.18),
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.34),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 38,
                    child: FilledButton.icon(
                      onPressed: onNew,
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('New'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _SurveysPageState._headingText,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebSurveysFilterBar extends StatelessWidget {
  const _WebSurveysFilterBar({
    required this.statusFilter,
    required this.onStatusFilterChanged,
  });

  final SurveyStatus? statusFilter;
  final ValueChanged<SurveyStatus?> onStatusFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Filter by status',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _SurveysPageState._bodyText,
            letterSpacing: 0.2,
          ),
        ),
        _SurveyFilterChip(
          label: 'All',
          selected: statusFilter == null,
          onSelected: () => onStatusFilterChanged(null),
        ),
        _SurveyFilterChip(
          label: 'Active',
          selected: statusFilter == SurveyStatus.active,
          onSelected: () => onStatusFilterChanged(SurveyStatus.active),
        ),
      ],
    );
  }
}

class _SurveyFilterChip extends StatelessWidget {
  const _SurveyFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: Colors.white,
      backgroundColor: _SurveysPageState._mintChipBg.withValues(alpha: 0.65),
      side: BorderSide(
        color: selected
            ? _SurveysPageState._border
            : _SurveysPageState._border.withValues(alpha: 0.9),
      ),
      labelStyle: TextStyle(
        color: selected
            ? _SurveysPageState._headingText
            : _SurveysPageState._bodyText,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 13),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurveysPanel extends StatelessWidget {
  const _SurveysPanel({
    required this.surveys,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onOpenResponses,
    required this.onOpenAnalytics,
    required this.onDownloadOmr,
    required this.onMockAction,
  });

  final List<SurveyRecord> surveys;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final void Function(SurveyRecord survey)? onOpenResponses;
  final void Function([String? surveyName]) onOpenAnalytics;
  final ValueChanged<SurveyRecord> onDownloadOmr;
  final void Function(String value, SurveyRecord survey) onMockAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _SurveysPageState._cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _SurveysPageState._border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (surveys.isEmpty)
            const _EmptySurveys()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 2 : 1;
                return GridView.builder(
                  itemCount: surveys.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: 94,
                  ),
                  itemBuilder: (context, index) {
                    final survey = surveys[index];
                    return _SurveyCard(
                      survey: survey,
                      onOpenResponses: onOpenResponses,
                      onOpenAnalytics: onOpenAnalytics,
                      onDownloadOmr: onDownloadOmr,
                      onMockAction: onMockAction,
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: _PaginationControls(
              currentPage: currentPage,
              totalPages: totalPages,
              onPreviousPage: onPreviousPage,
              onNextPage: onNextPage,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySurveys extends StatelessWidget {
  const _EmptySurveys();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 42),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 42,
              color: _SurveysPageState._bodyText,
            ),
            SizedBox(height: 10),
            Text(
              'No surveys found.',
              style: TextStyle(
                color: _SurveysPageState._bodyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  @override
  Widget build(BuildContext context) {
    final isFirstPage = currentPage == 0;
    final isLastPage = currentPage >= totalPages - 1;

    return Row(
      children: [
        Text(
          'Page ${currentPage + 1} of $totalPages',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _SurveysPageState._bodyText,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: isFirstPage ? null : onPreviousPage,
          icon: const Icon(Icons.chevron_left, size: 18),
          label: const Text('Previous'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: isLastPage ? null : onNextPage,
          icon: const Icon(Icons.chevron_right, size: 18),
          label: const Text('Next'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({
    required this.survey,
    required this.onOpenResponses,
    required this.onOpenAnalytics,
    required this.onDownloadOmr,
    required this.onMockAction,
  });

  final SurveyRecord survey;
  final void Function(SurveyRecord survey)? onOpenResponses;
  final void Function([String? surveyName]) onOpenAnalytics;
  final ValueChanged<SurveyRecord> onDownloadOmr;
  final void Function(String value, SurveyRecord survey) onMockAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFD),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _SurveysPageState._border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        survey.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _SurveysPageState._headingText,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _StatusBadge(status: survey.status),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  survey.templateUsed,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _SurveysPageState._bodyText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${survey.responses}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _SurveysPageState._headingText,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'responses',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _SurveysPageState._bodyText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _formatDate(survey.createdDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              color: _SurveysPageState._bodyText,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Responses icon - red glow only if responses need review
                _ResponsiveResponsesIcon(
                  survey: survey,
                  onOpenResponses: onOpenResponses,
                ),
                const SizedBox(width: 4),
                _CircleAction(
                  tooltip: 'Analytics',
                  icon: Icons.bar_chart_outlined,
                  color: _SurveysPageState._infoBlue,
                  onPressed: () => onOpenAnalytics(survey.name),
                ),
                const SizedBox(width: 4),
                _MoreSurveyAction(
                  survey: survey,
                  onDownloadOmr: onDownloadOmr,
                  onMockAction: onMockAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day.toString().padLeft(2, '0')}, ${parsed.year}';
  }
}

class _ResponsiveResponsesIcon extends StatelessWidget {
  const _ResponsiveResponsesIcon({
    required this.survey,
    required this.onOpenResponses,
  });

  final SurveyRecord survey;
  final void Function(SurveyRecord survey)? onOpenResponses;

  @override
  Widget build(BuildContext context) {
    final hasFlagged = _surveyHasFlaggedResponses(survey);

    return _CircleAction(
      tooltip: 'Responses',
      icon: Icons.assignment_outlined,
      color: _SurveysPageState._bodyText,
      hasAttention: hasFlagged,
      onPressed: () => onOpenResponses?.call(survey),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SurveyStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SurveyStatus.active => _SurveysPageState._successGreen,
      SurveyStatus.closed => _SurveysPageState._bodyText,
      SurveyStatus.inactive => _SurveysPageState._dangerRed,
    };
    final label = switch (status) {
      SurveyStatus.active => 'Active',
      SurveyStatus.closed => 'Closed',
      SurveyStatus.inactive => 'Inactive',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status == SurveyStatus.active
            ? _SurveysPageState._mintChipBg
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.hasAttention = false,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool hasAttention;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF3FAFB),
        shape: const CircleBorder(
          side: BorderSide(color: _SurveysPageState._border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(icon, size: 16, color: color),
              ),
            ),
            if (hasAttention)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoreSurveyAction extends StatelessWidget {
  const _MoreSurveyAction({
    required this.survey,
    required this.onDownloadOmr,
    required this.onMockAction,
  });

  final SurveyRecord survey;
  final ValueChanged<SurveyRecord> onDownloadOmr;
  final void Function(String value, SurveyRecord survey) onMockAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      onSelected: (value) {
        if (value == 'download_omr') {
          onDownloadOmr(survey);
          return;
        }
        if (value == 'share') {
          _showShareDialog(context);
          return;
        }
        onMockAction(value, survey);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'download_omr', child: Text('Download OMR Sheet')),
        PopupMenuItem(value: 'share', child: Text('Share')),
        PopupMenuItem(value: 'archive', child: Text('Archive')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      icon: const Icon(
        Icons.more_vert,
        size: 16,
        color: _SurveysPageState._headingText,
      ),
      iconSize: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: null,
    );
  }

  void _showShareDialog(BuildContext context) {
    final shareLink = 'https://surveys.example.com/survey/${survey.id}';
    
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          constraints: const BoxConstraints(maxWidth: 420),
          title: const Text('Share Survey'),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: _SurveysPageState._border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/qr.png',
                      width: 112,
                      height: 112,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 112,
                          height: 112,
                          color: _SurveysPageState._mintChipBg,
                          child: const Icon(
                            Icons.qr_code_2,
                            size: 48,
                            color: _SurveysPageState._bodyText,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _SurveysPageState._mintChipBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _SurveysPageState._border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            shareLink,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _SurveysPageState._headingText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Copy link',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link copied to clipboard')),
                                );
                              },
                              child: Icon(
                                Icons.copy,
                                size: 18,
                                color: _SurveysPageState._iconTeal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Share via',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _SurveysPageState._headingText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _ShareButton(
                        icon: Icons.mail,
                        label: 'Gmail',
                        color: const Color(0xFFEA4335),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share via Gmail')),
                          );
                        },
                      ),
                      _ShareButton(
                        icon: Icons.chat,
                        label: 'Messenger',
                        color: const Color(0xFF0084FF),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share via Messenger')),
                          );
                        },
                      ),
                      _ShareButton(
                        icon: Icons.phone_android,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share via WhatsApp')),
                          );
                        },
                      ),
                      _ShareButton(
                        icon: Icons.share,
                        label: 'X',
                        color: const Color(0xFF000000),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share via X')),
                          );
                        },
                      ),
                      _ShareButton(
                        icon: Icons.link,
                        label: 'Copy Link',
                        color: _SurveysPageState._iconTeal,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _SurveysPageState._headingText,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB WIDGETS (modern design, matching the mobile teal palette)
// ═══════════════════════════════════════════════════════════════════════════

class _WebSurveysHeader extends StatelessWidget {
  const _WebSurveysHeader({
    required this.totalCount,
    required this.searchController,
    required this.onSearchChanged,
    required this.onNew,
  });

  final int totalCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _SurveysPageState._tealLight,
            _SurveysPageState._tealDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _SurveysPageState._tealDark.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Surveys',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount surveys in the system',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 300,
            height: 44,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              cursorColor: Colors.black,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search surveys',
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.16),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Survey'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _SurveysPageState._headingText,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSurveysStatsRow extends StatelessWidget {
  const _WebSurveysStatsRow({
    required this.totalCount,
    required this.activeCount,
    required this.totalResponses,
    required this.flaggedCount,
  });

  final int totalCount;
  final int activeCount;
  final int totalResponses;
  final int flaggedCount;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _WebSurveyStat(
        label: 'Total Surveys',
        value: totalCount.toString(),
        icon: Icons.table_chart_outlined,
        iconBg: _SurveysPageState._mintChipBg,
        iconColor: _SurveysPageState._iconTeal,
      ),
      _WebSurveyStat(
        label: 'Active Surveys',
        value: activeCount.toString(),
        icon: Icons.assignment_turned_in_outlined,
        iconBg: _SurveysPageState._successGreen.withValues(alpha: 0.12),
        iconColor: _SurveysPageState._successGreen,
      ),
      _WebSurveyStat(
        label: 'Total Responses',
        value: _formatNumber(totalResponses),
        icon: Icons.groups_outlined,
        iconBg: _SurveysPageState._infoBlue.withValues(alpha: 0.12),
        iconColor: _SurveysPageState._infoBlue,
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final isLast = entry.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : SpacingTokens.lg),
            child: _WebSurveyStatCard(stat: entry.value),
          ),
        );
      }).toList(),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final s = (n / 1000).toStringAsFixed(1);
      return '${s.replaceAll('.0', '')},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return n.toString();
  }
}

class _WebSurveyStat {
  const _WebSurveyStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}

class _WebSurveyStatCard extends StatelessWidget {
  const _WebSurveyStatCard({required this.stat});

  final _WebSurveyStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: _SurveysPageState._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _SurveysPageState._border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: stat.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 22),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _SurveysPageState._bodyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _SurveysPageState._headingText,
                    letterSpacing: -0.4,
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

class _WebSurveysTable extends StatelessWidget {
  const _WebSurveysTable({
    required this.surveys,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onOpenResponses,
    required this.onOpenAnalytics,
    required this.onDownloadOmr,
    required this.onMockAction,
  });

  final List<SurveyRecord> surveys;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final void Function(SurveyRecord survey)? onOpenResponses;
  final void Function([String? surveyName]) onOpenAnalytics;
  final ValueChanged<SurveyRecord> onDownloadOmr;
  final void Function(String value, SurveyRecord survey) onMockAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _SurveysPageState._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _SurveysPageState._border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Text(
              'All Surveys',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _SurveysPageState._headingText,
              ),
            ),
          ),
          const Divider(height: 1, color: _SurveysPageState._border),
          if (surveys.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 56),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      size: 42,
                      color: _SurveysPageState._bodyText,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No surveys found.',
                      style: TextStyle(
                        color: _SurveysPageState._bodyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.md,
              ),
              color: _SurveysPageState._mintChipBg.withValues(alpha: 0.4),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _headerLabel('SURVEY NAME')),
                  Expanded(flex: 2, child: _headerLabel('TEMPLATE')),
                  Expanded(child: _headerLabel('STATUS')),
                  Expanded(child: _headerLabel('RESPONSES')),
                  Expanded(child: _headerLabel('CREATED')),
                  const SizedBox(width: 120),
                ],
              ),
            ),
            const Divider(height: 1, color: _SurveysPageState._border),
            ...surveys.asMap().entries.map((entry) {
              final survey = entry.value;
              final isLast = entry.key == surveys.length - 1;
              return Column(
                children: [
                  _WebSurveyRow(
                    survey: survey,
                    onOpenResponses: onOpenResponses,
                    onOpenAnalytics: onOpenAnalytics,
                    onDownloadOmr: onDownloadOmr,
                    onMockAction: onMockAction,
                  ),
                  if (!isLast) const Divider(height: 1, color: _SurveysPageState._border),
                ],
              );
            }),
          ],
          const Divider(height: 1, color: _SurveysPageState._border),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: _PaginationControls(
              currentPage: currentPage,
              totalPages: totalPages,
              onPreviousPage: onPreviousPage,
              onNextPage: onNextPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _SurveysPageState._bodyText,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _WebSurveyRow extends StatelessWidget {
  const _WebSurveyRow({
    required this.survey,
    required this.onOpenResponses,
    required this.onOpenAnalytics,
    required this.onDownloadOmr,
    required this.onMockAction,
  });

  final SurveyRecord survey;
  final void Function(SurveyRecord survey)? onOpenResponses;
  final void Function([String? surveyName]) onOpenAnalytics;
  final ValueChanged<SurveyRecord> onDownloadOmr;
  final void Function(String value, SurveyRecord survey) onMockAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              survey.name,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _SurveysPageState._headingText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              survey.templateUsed,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: _SurveysPageState._bodyText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: survey.status),
            ),
          ),
          Expanded(
            child: Text(
              '${survey.responses}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _SurveysPageState._headingText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(survey.createdDate),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _SurveysPageState._bodyText,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ResponsiveResponsesIcon(
                  survey: survey,
                  onOpenResponses: onOpenResponses,
                ),
                const SizedBox(width: 4),
                _CircleAction(
                  tooltip: 'Analytics',
                  icon: Icons.bar_chart_outlined,
                  color: _SurveysPageState._infoBlue,
                  onPressed: () => onOpenAnalytics(survey.name),
                ),
                const SizedBox(width: 4),
                _MoreSurveyAction(
                  survey: survey,
                  onDownloadOmr: onDownloadOmr,
                  onMockAction: onMockAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day.toString().padLeft(2, '0')}, ${parsed.year}';
  }
}
