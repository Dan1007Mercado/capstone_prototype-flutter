import 'dart:math';

import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../models/app_models.dart';

class MockAnalyticsGenerator {
  MockAnalyticsGenerator();

  /// Generate a list of ResponseRecord using the provided survey and
  /// filters. This is intentionally synthetic and fast.
  List<ResponseRecord> generateResponses({
    required SurveyRecord survey,
    required int minResponses,
    required int maxResponses,
    String respondentFilter = 'All Respondents',
    DateTimeRange? dateRange,
  }) {
    final rng = Random(survey.id.hashCode + DateTime.now().millisecondsSinceEpoch);
    final target = minResponses + rng.nextInt((maxResponses - minResponses).clamp(1, 2000));
    final results = <ResponseRecord>[];

    for (var i = 0; i < target; i++) {
      final idx = i % 50;
      final base = buildMockResponses(survey)[idx];

      // Adjust dateSubmitted within range if provided
      final date = DateTime.now().subtract(Duration(days: rng.nextInt(90)));
      final dateLabel = formatDateTimeLabel(date);

      // Filter by respondent type if requested
      final respondentType = (i % 4 == 0) ? 'Student' : (i % 4 == 1) ? 'Faculty' : (i % 4 == 2) ? 'Staff' : 'Guest';
      if (respondentFilter != 'All Respondents' && respondentFilter != respondentType) continue;

      results.add(ResponseRecord(
        responseId: '${base.responseId}x$i',
        surveyId: survey.id,
        surveyName: survey.name,
        respondentName: base.respondentName,
        age: base.age,
        gender: base.gender,
        civilStatus: base.civilStatus,
        occupation: base.occupation,
        educationalLevel: base.educationalLevel,
        location: base.location,
        dateSubmitted: dateLabel,
        syncDate: dateLabel,
        status: base.status,
        completionRate: base.completionRate,
        answers: base.answers,
        interpretation: base.interpretation,
        surveyCategory: survey.category,
      ));
    }

    return results;
  }

  /// Create aggregated chart points for a weekly line chart from responses.
  List<ChartPoint> buildWeeklySeries(List<ResponseRecord> responses, {int periods = 6}) {
    final rng = Random(responses.length + 7);
    final points = <ChartPoint>[];
    for (var i = 0; i < periods; i++) {
      points.add(ChartPoint('P${i + 1}', (responses.length / periods) * (0.8 + rng.nextDouble() * 0.8)));
    }
    return points;
  }

  /// Build a simple response status summary (completed vs in progress)
  List<ChartPoint> buildStatusSummary(List<ResponseRecord> responses) {
    final completed = responses.where((r) => r.status == ResponseStatus.synced).length;
    final other = (responses.length - completed).toDouble();
    return [ChartPoint('Completed', completed.toDouble()), ChartPoint('In Progress', other)];
  }

  /// Build question insights by reusing existing question templates and
  /// jittering values based on the response set size.
  List<QuestionInsight> buildQuestionInsightsFromResponses(List<ResponseRecord> responses) {
    final base = buildQuestionInsights();
    final rng = Random(responses.length + 13);
    return base.map((q) {
      final modified = q.points.map((p) {
        final jitter = 0.7 + rng.nextDouble() * 1.6;
        return ChartPoint(p.label, (p.value * jitter).clamp(2, 120).toDouble());
      }).toList();
      return QuestionInsight(
        title: q.title,
        chartType: q.chartType,
        points: modified,
        interpretation: q.interpretation,
      );
    }).toList();
  }
}
