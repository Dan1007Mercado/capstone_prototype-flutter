import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../mock/mock_data.dart';
import '../models/app_models.dart';

/// Service for handling Firebase Analytics & Firestore operations.
class FirebaseAnalyticsService {
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();
  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();

  bool _initialized = false;
  FirebaseFirestore? _db;

  /// Default fallback options for initializing Firebase when google-services.json is absent.
  static const FirebaseOptions _defaultFirebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyDummyApiKeyForCapstoneAnalytics2026",
    appId: "1:1234567890:android:capstoneprototype2026",
    messagingSenderId: "1234567890",
    projectId: "capstone-prototype-analytics",
    storageBucket: "capstone-prototype-analytics.appspot.com",
  );

  /// Ensure Firebase and Firestore are initialized safely.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: _defaultFirebaseOptions);
      } else {
        await Firebase.initializeApp();
      }

      _db = FirebaseFirestore.instance;
      _db!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _initialized = true;
    } catch (e) {
      debugPrint("Firebase init notice: $e. Falling back to local persistent repository mode.");
      _initialized = false;
    }
  }

  /// Get Firestore database instance if initialized.
  FirebaseFirestore? get db => _db;

  /// Fetch all active surveys from Firestore or fallback mock set.
  Future<List<SurveyRecord>> getSurveys() async {
    await initialize();
    if (_db == null) return surveys;

    try {
      final snapshot = await _db!
          .collection('surveys')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(milliseconds: 1500));

      if (snapshot.docs.isEmpty) {
        return surveys;
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final statusStr = (data['status'] as String?)?.toLowerCase() ?? 'active';
        SurveyStatus status = SurveyStatus.active;
        if (statusStr == 'closed') status = SurveyStatus.closed;
        if (statusStr == 'inactive') status = SurveyStatus.inactive;

        return SurveyRecord(
          id: doc.id,
          name: (data['surveyName'] as String?) ?? 'Unnamed Survey',
          templateUsed: (data['templateName'] as String?) ?? 'Standard Template',
          category: (data['category'] as String?) ?? 'General',
          status: status,
          createdDate: (data['createdAt'] is Timestamp)
              ? formatDateLabel((data['createdAt'] as Timestamp).toDate())
              : 'Jan 2026',
          responses: (data['responsesCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching surveys from Firestore: $e");
      return surveys;
    }
  }

  /// Fetch responses for a given survey name or all surveys.
  Future<List<ResponseRecord>> getResponses({
    String? surveyName,
    String respondentFilter = 'All Respondents',
    String? categoryFilter,
  }) async {
    await initialize();
    List<ResponseRecord> result = [];

    if (_db != null) {
      try {
        Query query = _db!.collection('responses');

        if (surveyName != null && surveyName != 'All Surveys') {
          query = query.where('surveyName', isEqualTo: surveyName);
        }

        final snapshot = await query
            .get(const GetOptions(source: Source.serverAndCache))
            .timeout(const Duration(milliseconds: 1500));

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final respondent = data['respondent'] as Map<String, dynamic>? ?? {};

          final respType = (respondent['occupation'] as String?) ?? 'Student';
          if (respondentFilter != 'All Respondents' &&
              !respondentFilter.toLowerCase().contains(respType.toLowerCase())) {
            continue;
          }

          final statusStr = (data['status'] as String?)?.toLowerCase() ?? 'completed';
          final status = (statusStr == 'synced' || statusStr == 'completed')
              ? ResponseStatus.synced
              : ResponseStatus.pending;

          final answersMap = data['answers'] as Map<String, dynamic>? ?? {};
          final answersList = <ResponseQuestionAnswer>[];

          var qIdx = 1;
          answersMap.forEach((key, val) {
            int score = 3;
            String textVal = val.toString();

            if (val is num) {
              score = val.toInt().clamp(1, 5);
            } else if (textVal.contains('Very Satisfied') || textVal.contains('Strongly Agree')) {
              score = 5;
            } else if (textVal.contains('Satisfied') || textVal.contains('Agree')) {
              score = 4;
            } else if (textVal.contains('Neutral')) {
              score = 3;
            } else if (textVal.contains('Dissatisfied') || textVal.contains('Disagree')) {
              score = 2;
            } else if (textVal.contains('Very Dissatisfied') || textVal.contains('Strongly Disagree')) {
              score = 1;
            }

            answersList.add(ResponseQuestionAnswer(
              questionNumber: qIdx++,
              questionText: 'Question $key',
              answerLabel: textVal,
              score: score,
              interpretation: 'Score $score recorded.',
            ));
          });

          final dateVal = (data['submittedAt'] is Timestamp)
              ? formatDateLabel((data['submittedAt'] as Timestamp).toDate())
              : 'Recent';

          result.add(ResponseRecord(
            responseId: doc.id,
            surveyId: (data['surveyId'] as String?) ?? 'survey001',
            surveyName: (data['surveyName'] as String?) ?? (surveyName ?? 'Survey'),
            respondentName:
                '${respondent['firstName'] ?? 'Anonymous'} ${respondent['lastName'] ?? ''}'.trim(),
            age: (respondent['age'] as num?)?.toInt() ?? 20,
            gender: (respondent['gender'] as String?) ?? 'Unspecified',
            civilStatus: (respondent['civilStatus'] as String?) ?? 'Single',
            occupation: respType,
            educationalLevel: (respondent['educationalLevel'] as String?) ?? 'Undergraduate',
            location: (respondent['location'] as String?) ?? 'Main Campus',
            dateSubmitted: dateVal,
            syncDate: dateVal,
            status: status,
            completionRate: (data['completionRate'] as num?)?.toDouble() ?? 100.0,
            answers: answersList,
            interpretation: 'Completed survey submission.',
            surveyCategory: categoryFilter ?? 'General',
          ));
        }
      } catch (e) {
        debugPrint("Error reading Firestore responses: $e");
      }
    }

    // If Firestore produced no responses, generate a robust fallback response set
    if (result.isEmpty) {
      final selectedSurvey = _resolveSurvey(surveyName);
      result = buildMockResponses(selectedSurvey);
      if (respondentFilter != 'All Respondents') {
        result = result.where((r) => r.occupation.toLowerCase() == respondentFilter.toLowerCase()).toList();
      }
    }

    return result;
  }

  /// Process raw response records into weekly submission series.
  List<ChartPoint> processWeeklySeries(List<ResponseRecord> responses) {
    if (responses.isEmpty) {
      return const [
        ChartPoint('Week 1', 0),
        ChartPoint('Week 2', 0),
        ChartPoint('Week 3', 0),
        ChartPoint('Week 4', 0),
      ];
    }

    final int chunkSize = (responses.length / 4).ceil().clamp(1, 9999);
    final w1 = responses.take(chunkSize).length.toDouble();
    final w2 = responses.skip(chunkSize).take(chunkSize).length.toDouble();
    final w3 = responses.skip(chunkSize * 2).take(chunkSize).length.toDouble();
    final w4 = responses.skip(chunkSize * 3).length.toDouble();

    return [
      ChartPoint('Week 1', w1),
      ChartPoint('Week 2', w2),
      ChartPoint('Week 3', w3),
      ChartPoint('Week 4', w4),
    ];
  }

  /// Process raw response records into completion status breakdown.
  List<ChartPoint> processStatusSummary(List<ResponseRecord> responses) {
    if (responses.isEmpty) {
      return const [
        ChartPoint('Completed', 0),
        ChartPoint('In Progress', 0),
      ];
    }

    int completed = 0;
    int pending = 0;

    for (final r in responses) {
      if (r.status == ResponseStatus.synced || r.completionRate >= 90.0) {
        completed++;
      } else {
        pending++;
      }
    }

    final total = responses.length.toDouble();
    final compPct = (completed / total * 100).roundToDouble();
    final pendPct = (pending / total * 100).roundToDouble();

    return [
      ChartPoint('Completed', compPct),
      ChartPoint('In Progress', pendPct),
    ];
  }

  /// Process question insights dynamically from actual response answers.
  List<QuestionInsight> processQuestionInsights(List<ResponseRecord> responses) {
    if (responses.isEmpty) {
      return buildQuestionInsights();
    }

    final Map<int, List<int>> scoresByQuestion = {};
    for (final r in responses) {
      for (final a in r.answers) {
        scoresByQuestion.putIfAbsent(a.questionNumber, () => []).add(a.score);
      }
    }

    if (scoresByQuestion.isEmpty) {
      return buildQuestionInsights();
    }

    final insights = <QuestionInsight>[];
    const types = [
      ChartType.bar,
      ChartType.donut,
      ChartType.line,
      ChartType.horizontalBar,
      ChartType.pie,
    ];

    var idx = 0;
    scoresByQuestion.forEach((qNum, scores) {
      final total = scores.length;
      final avg = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / total;

      int count1 = scores.where((s) => s == 1).length;
      int count2 = scores.where((s) => s == 2).length;
      int count3 = scores.where((s) => s == 3).length;
      int count4 = scores.where((s) => s == 4).length;
      int count5 = scores.where((s) => s == 5).length;

      final points = [
        ChartPoint('Strongly Disagree', count1.toDouble()),
        ChartPoint('Disagree', count2.toDouble()),
        ChartPoint('Neutral', count3.toDouble()),
        ChartPoint('Agree', count4.toDouble()),
        ChartPoint('Strongly Agree', count5.toDouble()),
      ];

      final chartType = types[idx % types.length];
      final sentiment = avg >= 4.0
          ? 'highly positive'
          : avg >= 3.0
              ? 'neutral to positive'
              : 'needs improvement';

      insights.add(QuestionInsight(
        title: 'Q$qNum: Quantitative Assessment',
        chartType: chartType,
        points: points,
        interpretation:
            'Mean score is ${avg.toStringAsFixed(2)} out of 5 based on $total submissions. Overall sentiment is $sentiment.',
      ));

      idx++;
    });

    return insights.isEmpty ? buildQuestionInsights() : insights;
  }

  SurveyRecord _resolveSurvey(String? surveyName) {
    if (surveyName == null || surveyName.isEmpty || surveyName == 'All Surveys') {
      return surveys.first;
    }
    return surveys.firstWhere((s) => s.name == surveyName, orElse: () => surveys.first);
  }
}
