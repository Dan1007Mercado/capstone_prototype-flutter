import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../models/app_models.dart';

class CsvExporter {
  static Future<String> export(List<ResponseRecord> responses, SurveyRecord survey) async {
    final dir = Directory.systemTemp.createTempSync('capstone_exports_');
    final file = File(p.join(dir.path, '${survey.id}_${DateTime.now().millisecondsSinceEpoch}.csv'));

    final rows = <List<String>>[];
    rows.add([
      'Survey Name',
      'Question',
      'Average',
      'Frequency',
      'Likert Counts',
      'Percentage',
      'Respondent Type',
      'Submission Date',
    ]);

    for (final r in responses) {
      for (final a in r.answers) {
        rows.add([
          r.surveyName,
          a.questionText,
          (a.score).toString(),
          '1',
          a.answerLabel,
          '${(a.score / 5 * 100).toStringAsFixed(0)}%',
          r.occupation,
          r.dateSubmitted,
        ]);
      }
    }

    final sink = file.openWrite();
    for (final row in rows) {
      sink.writeln(_toCsvRow(row));
    }
    await sink.flush();
    await sink.close();
    return file.path;
  }

  static String _toCsvRow(List<String> cols) => cols.map(_escape).join(',');

  static String _escape(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"' + v.replaceAll('"', '""') + '"';
    }
    return v;
  }
}
