import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;

import '../../../models/app_models.dart';
import '../../../mock/mock_data.dart';
import '../interpretation_engine.dart';

class PdfExporter {
  static Future<String> export(List<ResponseRecord> responses, SurveyRecord survey) async {
    final doc = pw.Document();

    // Cover page
    doc.addPage(pw.Page(build: (c) {
      return pw.Column(children: [
        pw.Spacer(),
        pw.Text(survey.name, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Category: ${survey.category}'),
        pw.SizedBox(height: 8),
        pw.Text('Generated: ${DateTime.now().toIso8601String()}'),
        pw.SizedBox(height: 8),
        pw.Text('Responses: ${responses.length}'),
        pw.Spacer(),
      ]);
    }));

    // Executive summary + quick metrics
    final exec = InterpretationEngine.executiveSummary(responses, survey);
    doc.addPage(pw.Page(build: (c) {
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Executive Summary', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(exec),
        pw.SizedBox(height: 12),
        pw.Text('Quick Metrics', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Bullet(text: 'Total Responses: ${responses.length}'),
        pw.Bullet(text: 'Average Score: ${_avgScore(responses).toStringAsFixed(2)}'),
        pw.Bullet(text: 'Completion Rate (avg): ${_avgCompletion(responses).toStringAsFixed(0)}%'),
      ]);
    }));

    // Charts placeholder: draw a simple bar for overall distribution
    doc.addPage(pw.Page(build: (c) {
      final counts = <int>[0, 0, 0, 0, 0];
      for (final r in responses) {
        for (final a in r.answers) {
          final idx = (a.score - 1).clamp(0, 4);
          counts[idx]++;
        }
      }
      return pw.Column(children: [
        pw.Text('Overall Score Distribution', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Row(children: counts.map((c) => pw.Expanded(child: pw.Container(height: 120, color: pdf.PdfColors.grey300, child: pw.Center(child: pw.Text(c.toString()))))).toList()),
      ]);
    }));

    // Append interpretations per question
    final questions = buildQuestionInsights();
    doc.addPage(pw.MultiPage(build: (c) {
      return [
        pw.Text('Question Interpretations', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Column(children: questions.map((q) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(q.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(q.interpretation)]))).toList()),
        pw.SizedBox(height: 12),
        pw.Text('Appendix: Responses', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(headerCount: 1, data: [
          ['ResponseId', 'Respondent', 'Submitted', 'AvgScore']
        ]..addAll(responses.map((r) => [r.responseId, r.respondentName, r.dateSubmitted, (r.answers.map((a) => a.score).reduce((v, e) => v + e) / r.answers.length).toStringAsFixed(2)]).toList())),
      ];
    }));

    final bytes = await doc.save();
    final dir = Directory.systemTemp.createTempSync('capstone_exports_');
    final file = File(p.join(dir.path, '${survey.id}_${DateTime.now().millisecondsSinceEpoch}.pdf'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static double _avgScore(List<ResponseRecord> responses) {
    if (responses.isEmpty) return 0;
    double total = 0;
    int count = 0;
    for (final r in responses) {
      for (final a in r.answers) {
        total += a.score;
        count++;
      }
    }
    return total / (count == 0 ? 1 : count);
  }

  static double _avgCompletion(List<ResponseRecord> responses) {
    if (responses.isEmpty) return 0;
    final sum = responses.map((r) => r.completionRate).reduce((a, b) => a + b);
    return sum / responses.length;
  }
}
