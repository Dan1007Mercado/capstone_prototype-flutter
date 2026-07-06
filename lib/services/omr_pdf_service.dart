import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

import '../models/app_models.dart';

/// Service responsible for generating OMR (Optical Mark Recognition) survey
/// template PDFs with proper scanning margins, registration marks, and
/// dynamic pagination.
class OmrPdfService {
  OmrPdfService();

  static final pw.Font _boldFont = pw.Font.courierBold();
  static final pw.Font _regularFont = pw.Font.courier();

  // OMR margins (17mm = ~48pt for professional OMR scanning)
  static const double _marginTop = 48;
  static const double _marginBottom = 48;
  static const double _marginLeft = 48;
  static const double _marginRight = 48;
  static const double _contentHeight = 792 - _marginTop - _marginBottom;

  // Estimated heights (in points) for pagination
  static const double _sectionHeaderHeight = 16;
  static const double _questionRowHeight = 11;
  static const double _spacingHeight = 6;
  static const double _commentsHeight = 50;

  /// Generates an OMR template PDF for the given [survey].
  Future<Uint8List> generatePdf(SurveyRecord survey) async {
    final surveyCode = survey.id.substring(0, 8).toUpperCase();
    final document = pw.Document();
    final sections = _generateSurveySections();

    final pages = _buildPages(survey, surveyCode, sections);

    for (var pageNum = 0; pageNum < pages.length; pageNum++) {
      document.addPage(
        _buildPage(pages[pageNum], pageNum + 1, pages.length, surveyCode),
      );
    }

    return document.save();
  }

  /// Saves the PDF bytes to a file (platform-aware: web vs native).
  Future<void> savePdf(Uint8List pdfBytes, String fileName) async {
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

  /// Generates and downloads an OMR template for the given [survey].
  Future<void> downloadOmrTemplate(SurveyRecord survey) async {
    final fileName = '${survey.name.replaceAll(' ', '_')}_OMR_Template.pdf';
    final pdfBytes = await generatePdf(survey);
    await savePdf(pdfBytes, fileName);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  List<List<pw.Widget>> _buildPages(
    SurveyRecord survey,
    String surveyCode,
    List<SurveySection> sections,
  ) {
    final List<List<pw.Widget>> pages = [];
    final List<pw.Widget> currentPage = [];
    double currentPageHeight = 0;

    void addToCurrentPage(pw.Widget widget, double estimatedHeight) {
      if (currentPageHeight + estimatedHeight > _contentHeight) {
        if (currentPage.isNotEmpty) {
          pages.add(currentPage);
        }
        currentPage.clear();
        currentPageHeight = 0;
      }
      currentPage.add(widget);
      currentPageHeight += estimatedHeight;
    }

    // Survey header
    addToCurrentPage(
      pw.Text(
        'Survey: ${survey.name}',
        style: pw.TextStyle(font: _boldFont, fontSize: 12),
      ),
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
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.8, color: PdfColors.grey600),
          color: PdfColors.grey100,
        ),
        child: pw.Text(
          'Instructions: Fill the circle (●) completely. '
          '1=Strongly Disagree | 2=Disagree | 3=Neutral | '
          '4=Agree | 5=Strongly Agree',
          style: pw.TextStyle(font: _regularFont, fontSize: 7.5),
        ),
      ),
      18,
    );
    addToCurrentPage(pw.SizedBox(height: 8), 8);

    // Sections with questions
    for (final section in sections) {
      addToCurrentPage(
        _buildSectionHeader(section.title),
        _sectionHeaderHeight,
      );
      addToCurrentPage(pw.SizedBox(height: 2), 2);

      addToCurrentPage(
        _buildDynamicSectionQuestions(
          section.questions,
          section.startNumber,
        ),
        section.questions.length * _questionRowHeight,
      );
      addToCurrentPage(pw.SizedBox(height: _spacingHeight), _spacingHeight);
    }

    // Comments section
    addToCurrentPage(
      pw.Container(
        width: double.infinity,
        height: _commentsHeight,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.8, color: PdfColors.grey600),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Additional comments or feedback:',
              style: pw.TextStyle(font: _boldFont, fontSize: 8),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              '_' * 90,
              style: pw.TextStyle(font: _regularFont, fontSize: 8),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              '_' * 90,
              style: pw.TextStyle(font: _regularFont, fontSize: 8),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              '_' * 90,
              style: pw.TextStyle(font: _regularFont, fontSize: 8),
            ),
          ],
        ),
      ),
      _commentsHeight,
    );

    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    return pages;
  }

  pw.Page _buildPage(
    List<pw.Widget> pageContent,
    int pageIndex,
    int totalPages,
    String surveyCode,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: pw.EdgeInsets.zero,
      build: (_) {
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
            _cornerLGuide(16, 16, false, false),
            _cornerLGuide(null, 16, true, false),
            _cornerLGuide(16, null, false, true),
            _cornerLGuide(null, null, true, true),

            // Registration marks
            _registrationMark(20, 120),
            _registrationMark(20, 330),
            _registrationMark(20, 540),
            _registrationMark(20, 680),

            // Main content area
            pw.Positioned(
              left: _marginLeft,
              right: _marginRight,
              top: _marginTop,
              bottom: _marginBottom + 24,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: pageContent,
              ),
            ),

            // Footer
            pw.Positioned(
              left: _marginLeft,
              right: _marginRight,
              bottom: 16,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 14,
                    height: 14,
                    color: PdfColors.black,
                  ),
                  pw.SizedBox(width: 4),
                  pw.Container(
                    width: 4,
                    height: 14,
                    color: PdfColors.grey500,
                  ),
                  pw.Spacer(),
                  pw.SizedBox(
                    width: 60,
                    height: 14,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: surveyCode,
                      drawText: false,
                    ),
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
    );
  }

  pw.Widget _cornerLGuide(double? left, double? top, bool isRight, bool isBottom) {
    return pw.Positioned(
      left: isRight ? null : left,
      right: isRight ? 16 : null,
      top: isBottom ? null : top,
      bottom: isBottom ? 16 : null,
      child: pw.Column(
        children: [
          if (!isBottom) ...[
            pw.Container(width: 32, height: 4, color: PdfColors.black),
            if (isRight) pw.SizedBox(height: 28),
          ],
          if (isBottom) pw.Container(width: 4, height: 32, color: PdfColors.black),
          if (isBottom) pw.Container(width: 32, height: 4, color: PdfColors.black),
          if (!isBottom && !isRight)
            pw.Container(width: 4, height: 32, color: PdfColors.black),
          if (isRight && !isBottom)
            pw.Container(width: 4, height: 4, color: PdfColors.black),
        ],
      ),
    );
  }

  pw.Widget _registrationMark(double left, double top) {
    return pw.Positioned(
      left: left,
      top: top,
      child: pw.Container(
        width: 10,
        height: 10,
        color: PdfColors.black,
      ),
    );
  }

  pw.Widget _buildCompactInfoField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: _boldFont, fontSize: 8),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          value,
          style: pw.TextStyle(font: _regularFont, fontSize: 8),
        ),
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
    final parts = question.split(':');
    final number = parts.first;
    final text = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 16,
            child: pw.Text(
              number,
              style: pw.TextStyle(font: _regularFont, fontSize: 8),
            ),
          ),
          pw.SizedBox(width: 3),
          pw.Expanded(
            child: pw.Text(
              text,
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

  pw.Widget _buildDynamicSectionQuestions(
    List<String> questions,
    int startNumber,
  ) {
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

  /// Generates the default survey sections for the OMR template.
  static List<SurveySection> _generateSurveySections() {
    return const [
      SurveySection(
        title: 'PART 1: General Satisfaction',
        startNumber: 1,
        questions: [
          'Q1: Overall satisfaction with the service',
          'Q2: Quality of information provided',
          'Q3: Staff professionalism and courtesy',
          'Q4: Responsiveness to your needs',
          'Q5: Value for money',
          'Q6: Would you recommend this service?',
        ],
      ),
      SurveySection(
        title: 'PART 2: Communication & Support',
        startNumber: 7,
        questions: [
          'Q7: Clarity of communication',
          'Q8: Accessibility of support channels',
          'Q9: Response time to inquiries',
          'Q10: Helpfulness of support staff',
          'Q11: Adequacy of information materials',
          'Q12: Follow-up after service',
        ],
      ),
      SurveySection(
        title: 'PART 3: Experience & Future',
        startNumber: 13,
        questions: [
          'Q13: Overall experience compared to expectations',
          'Q14: Likelihood of using service again',
          'Q15: Value of service for the price',
          'Q16: Service innovation and modernization',
          'Q17: Comparison with competitors',
          'Q18: Overall satisfaction rating',
        ],
      ),
      SurveySection(
        title: 'PART 4: Improvements & Feedback',
        startNumber: 19,
        questions: [
          'Q19: Facility cleanliness and maintenance',
          'Q20: Convenience of location and hours',
          'Q21: User-friendliness of processes',
          'Q22: Overall likelihood of recommendation',
          'Q23: Willingness to refer to others',
          'Q24: Timeliness of service delivery',
        ],
      ),
      SurveySection(
        title: 'PART 5: Additional Questions',
        startNumber: 25,
        questions: [
          'Q25: Transparency in pricing',
          'Q26: Professional appearance of staff',
          'Q27: Effectiveness of follow-up',
          'Q28: Value versus competitors',
          'Q29: Likelihood to revisit',
          'Q30: Overall rating of service',
        ],
      ),
    ];
  }
}