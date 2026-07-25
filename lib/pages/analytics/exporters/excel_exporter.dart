import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;

import '../../../models/app_models.dart';

/// ExcelExporter
/// Generates an .xlsx workbook for survey analytics using `excel: ^4.x`.
class ExcelExporter {
  /// Export the given responses for [survey] and return the saved file path.
  static Future<String> export(List<ResponseRecord> responses, SurveyRecord survey) async {
    final excel = Excel.createExcel();

    // Reusable helper: convert Dart values into the package's CellValue types.
    CellValue? toCellValue(Object? v) {
      if (v == null) return null;
      if (v is CellValue) return v;
      if (v is String) return TextCellValue(v);
      if (v is int) return IntCellValue(v);
      if (v is double) return DoubleCellValue(v);
      if (v is bool) return BoolCellValue(v);
      if (v is DateTime) return DateTimeCellValue.fromDateTime(v);
      if (v is num) {
        return v is int ? IntCellValue(v) : DoubleCellValue(v.toDouble());
      }
      return TextCellValue(v.toString());
    }

    // Reusable helper: write a list of Dart values into a given row.
    void writeRow(Sheet sheet, int rowIndex, List<Object?> values) {
      for (var c = 0; c < values.length; c++) {
        final idx = CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIndex);
        final cell = sheet.cell(idx);
        cell.value = toCellValue(values[c]);
      }
    }

    // Compute question-level statistics if there are responses.
    final questionAverages = <int, double>{};
    final questionWeighted = <int, double>{};
    final questionInterpretation = <int, String>{};
    if (responses.isNotEmpty) {
      final maxQ = responses.map((r) => r.answers.length).reduce(max);
      for (var qi = 0; qi < maxQ; qi++) {
        final scores = <int>[];
        double weightedSum = 0;
        double weightTotal = 0;
        for (final rr in responses) {
          if (qi < rr.answers.length) {
            final ans = rr.answers[qi];
            scores.add(ans.score);
            final w = rr.completionRate > 0 ? rr.completionRate : 1.0;
            weightedSum += ans.score * w;
            weightTotal += w;
            questionInterpretation[qi] = ans.interpretation;
          }
        }
        if (scores.isNotEmpty) {
          final avg = scores.reduce((a, b) => a + b) / scores.length;
          questionAverages[qi] = avg;
          questionWeighted[qi] = weightTotal > 0 ? (weightedSum / weightTotal) : avg;
        }
      }
    }

    // ------------------ Summary Sheet ------------------
    final sheetSummary = excel['Summary'];
    var r = 0;
    writeRow(sheetSummary, r++, ['Survey Name', survey.name]);
    writeRow(sheetSummary, r++, ['Category', survey.category]);
    final generated = DateTime.now();
    writeRow(sheetSummary, r++, ['Generated', generated.toIso8601String()]);
    writeRow(sheetSummary, r++, ['Total Responses', responses.length]);

    // Overall average across all question averages
    final overallAvg = questionAverages.isNotEmpty
        ? questionAverages.values.reduce((a, b) => a + b) / questionAverages.length
        : 0.0;
    writeRow(sheetSummary, r++, ['Average Score', overallAvg.toStringAsFixed(2)]);

    // Highest / lowest rated questions
    if (questionAverages.isNotEmpty) {
      final best = questionAverages.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final worst = questionAverages.entries.reduce((a, b) => a.value <= b.value ? a : b);
      writeRow(sheetSummary, r++, ['Highest Rated Question', 'Q${best.key + 1}']);
      writeRow(sheetSummary, r++, ['Lowest Rated Question', 'Q${worst.key + 1}']);
    } else {
      writeRow(sheetSummary, r++, ['Highest Rated Question', 'N/A']);
      writeRow(sheetSummary, r++, ['Lowest Rated Question', 'N/A']);
    }

    // ------------------ Questions Sheet ------------------
    final sheetQuestions = excel['Questions'];
    var q = 0;
    writeRow(sheetQuestions, q++, ['Question', 'Average Score', 'Weighted Mean', 'Interpretation']);
    if (questionAverages.isNotEmpty) {
      questionAverages.forEach((qi, avg) {
        final weighted = questionWeighted[qi] ?? avg;
        final interp = questionInterpretation[qi] ?? '';
        writeRow(sheetQuestions, q++, ['Q${qi + 1}', avg.toStringAsFixed(2), weighted.toStringAsFixed(2), interp]);
      });
    }

    // ------------------ Responses Sheet ------------------
    final sheetResponses = excel['Responses'];
    var s = 0;
    writeRow(sheetResponses, s++, ['Response ID', 'Respondent', 'Age', 'Gender', 'Occupation', 'Date Submitted']);
    for (final rr in responses) {
      // attempt to parse date string to DateTime; if not possible leave as string
      DateTime? parsed;
      try {
        parsed = DateTime.parse(rr.dateSubmitted);
      } catch (_) {
        parsed = null;
      }
      writeRow(sheetResponses, s++, [rr.responseId, rr.respondentName, rr.age, rr.gender, rr.occupation, parsed ?? rr.dateSubmitted]);
    }

    // ------------------ Charts Data Sheet ------------------
    final sheetData = excel['Charts Data'];
    var d = 0;
    writeRow(sheetData, d++, ['Metric', 'Value']);
    writeRow(sheetData, d++, ['Total Responses', responses.length]);
    // Average completion rate
    final avgCompletion = responses.isNotEmpty
        ? responses.map((r) => r.completionRate).reduce((a, b) => a + b) / responses.length
        : 0.0;
    writeRow(sheetData, d++, ['Avg Completion Rate', (avgCompletion * 100).toStringAsFixed(1)]);

    // Likert/Question averages block
    writeRow(sheetData, d++, ['Question Averages', '']);
    questionAverages.forEach((qi, avg) {
      writeRow(sheetData, d++, ['Q${qi + 1}', avg.toStringAsFixed(2)]);
    });

    // Response trend: simple counts per submission date (day)
    final trend = <String, int>{};
    for (final rr in responses) {
      final dateKey = rr.dateSubmitted.split('T').first;
      trend[dateKey] = (trend[dateKey] ?? 0) + 1;
    }
    if (trend.isNotEmpty) {
      writeRow(sheetData, d++, ['Response Trend', '']);
      final sorted = trend.keys.toList()..sort();
      for (final k in sorted) {
        writeRow(sheetData, d++, [k, trend[k]]);
      }
    }

    // ------------------ Save workbook ------------------
    final bytes = excel.encode();
    final dir = Directory.systemTemp.createTempSync('capstone_exports_');
    final safeName = survey.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final filename = '${safeName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes ?? <int>[], flush: true);
    return file.path;
  }
}
