import '../../models/app_models.dart';

class InterpretationEngine {
  static String executiveSummary(List<ResponseRecord> responses, SurveyRecord survey) {
    final avgScore = _averageScore(responses);
    final respondentText = '${responses.length} responses';
    final overall = avgScore >= 4 ? 'positive' : avgScore >= 3 ? 'mixed' : 'needs improvement';
    return 'The analysis for "${survey.name}" ($respondentText) indicates an overall $overall sentiment with an average score of ${avgScore.toStringAsFixed(2)}. Questions with lower averages may require attention.';
  }

  static double _averageScore(List<ResponseRecord> responses) {
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

  static List<String> questionInterpretations(List<QuestionInsight> questions) {
    return questions.map((q) => '${q.title}: ${q.interpretation}').toList();
  }
}
