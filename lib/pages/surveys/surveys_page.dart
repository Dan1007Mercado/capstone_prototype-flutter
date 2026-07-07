import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'deploy_survey_page.dart';

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

  static const Color _tealDark = Color.fromARGB(255, 13, 232, 232);
  static const Color _tealLight = Color(0xFF2DD4CF);
  static const Color _iconTeal = Color(0xFF14B8A6);
  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _headingText = Color(0xFF0E2A2E);
  static const Color _bodyText = Color(0xFF7C8A90);
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
    final query = _searchController.text.trim().toLowerCase();
    final surveys = appState.surveys.where((survey) {
      if (query.isEmpty) return true;
      return survey.name.toLowerCase().contains(query) ||
          survey.templateUsed.toLowerCase().contains(query) ||
          survey.id.toLowerCase().contains(query);
    }).toList();

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
                      totalCount: appState.surveys.length,
                      searchController: _searchController,
                      onSearchChanged: (_) => setState(() {}),
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
                        surveys: surveys,
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

class _SurveysHero extends StatelessWidget {
  const _SurveysHero({
    required this.totalCount,
    required this.searchController,
    required this.onSearchChanged,
    required this.onBack,
    required this.onNew,
  });

  final int totalCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
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
          color: const Color.fromARGB(255, 92, 5, 5).withOpacity(0.16),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              const SizedBox(height: 2),
              Text(
                '$totalCount surveys in the system',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search surveys',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.82),
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
    required this.onOpenResponses,
    required this.onOpenAnalytics,
    required this.onDownloadOmr,
    required this.onMockAction,
  });

  final List<SurveyRecord> surveys;
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
      child: surveys.isEmpty
          ? const _EmptySurveys()
          : LayoutBuilder(
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
                _CircleAction(
                  tooltip: 'Responses',
                  icon: Icons.assignment_outlined,
                  color: _SurveysPageState._bodyText,
                  onPressed: () => onOpenResponses?.call(survey),
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
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF3FAFB),
        shape: const CircleBorder(
          side: BorderSide(color: _SurveysPageState._border),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 16, color: color),
          ),
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
        onMockAction(value, survey);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'download_omr', child: Text('Download OMR')),
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
}