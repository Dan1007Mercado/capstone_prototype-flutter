import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

class SurveysPage extends StatelessWidget {
  const SurveysPage({
    super.key,
    required this.onOpenAnalytics,
    this.onOpenResponses,
  });

  final void Function([String? surveyName]) onOpenAnalytics;
  final void Function(SurveyRecord survey)? onOpenResponses;

  static final _boldFont = pw.Font.courierBold();
  static final _regularFont = pw.Font.courier();

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final surveys = appState.surveys;

    // Build table columns
    const columns = [
      DataColumn(label: Text('Survey Name')),
      DataColumn(label: Text('Template Used')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Responses')),
      DataColumn(label: Text('Date Created')),
      DataColumn(label: Text('Actions')),
    ];

    // Build table rows
    final rows = surveys.map((survey) {
      final statusColor = _getStatusColor(survey.status);
      final statusLabel = _getStatusLabel(survey.status);

      return DataRow(cells: [
        DataCell(Text(survey.name)),
        DataCell(Text(survey.templateUsed, style: const TextStyle(fontSize: 12))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text('${survey.responses}')),
        DataCell(Text(survey.createdDate, style: const TextStyle(fontSize: 11))),
        DataCell(
          Wrap(
            spacing: 2,
            children: [
              IconButton(
                iconSize: 18,
                onPressed: () => onOpenResponses?.call(survey),
                icon: const Icon(Icons.assignment_outlined),
                tooltip: 'Responses',
              ),
              IconButton(
                iconSize: 18,
                onPressed: () => onOpenAnalytics(survey.name),
                icon: const Icon(Icons.analytics_outlined),
                tooltip: 'Analytics',
              ),
              PopupMenuButton<String>(
                iconSize: 18,
                tooltip: 'More',
                onSelected: (value) {
                  if (value == 'download_omr') {
                    _downloadOmrTemplate(context, survey);
                  } else {
                    _snack(context, '$value is a mock action for ${survey.name}');
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'download_omr', child: Text('Download OMR')),
                  PopupMenuItem(value: 'archive', child: Text('Archive')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ]);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Surveys',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns,
                rows: rows,
                columnSpacing: 16,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                headingRowHeight: 56,
                showCheckboxColumn: false,
                dividerThickness: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SurveyStatus status) {
    return switch (status) {
      SurveyStatus.active => const Color(0xFF22C55E),
      SurveyStatus.closed => const Color(0xFF6B7280),
      SurveyStatus.inactive => const Color(0xFFEF4444),
    };
  }

  String _getStatusLabel(SurveyStatus status) {
    return switch (status) {
      SurveyStatus.active => 'Active',
      SurveyStatus.closed => 'Closed',
      SurveyStatus.inactive => 'Inactive',
    };
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

