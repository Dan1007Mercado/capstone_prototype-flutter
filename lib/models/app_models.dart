import 'dart:typed_data';

import 'package:flutter/material.dart';

enum SurveyStatus { active, closed, inactive }

enum ChartType { bar, line, donut, pie, horizontalBar }

enum ResponseStatus { synced, pending, exported }

class StatItem {
  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.delta,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String delta;
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
}

class NotificationItem {
  const NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
}

class SurveyRecord {
  const SurveyRecord({
    required this.id,
    required this.name,
    required this.templateUsed,
    required this.category,
    required this.status,
    required this.createdDate,
    this.responses = 0,
  });

  final String id;
  final String name;
  final String templateUsed;
  final String category;
  final SurveyStatus status;
  final String createdDate;
  final int responses;
}

class TemplateRecord {
  const TemplateRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.usage,
    required this.lastUpdated,
    this.components = const [],
  });

  final String id;
  final String name;
  final String category;
  final String usage;
  final String lastUpdated;
  final List<TemplateComponent> components;

  TemplateRecord copyWith({
    String? id,
    String? name,
    String? category,
    String? usage,
    String? lastUpdated,
    List<TemplateComponent>? components,
  }) {
    return TemplateRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      usage: usage ?? this.usage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      components: components ?? this.components,
    );
  }
}

class TemplateComponent {
  const TemplateComponent({
    required this.type,
    required this.label,
    required this.description,
    required this.category,
    this.questionNumber,
    this.alignment,
    this.isRequired = false,
    this.choices = const [],
    this.scaleValues = const [],
    this.placeholder,
  });

  factory TemplateComponent.empty() => const TemplateComponent(
        type: 'Textbox',
        label: 'New component',
        description: 'Add details for this component.',
        category: 'General',
      );

  final String type;
  final String label;
  final String description;
  final String category;
  final int? questionNumber;
  final String? alignment;
  final bool isRequired;
  final List<String> choices;
  final List<String> scaleValues;
  final String? placeholder;

  TemplateComponent copyWith({
    String? type,
    String? label,
    String? description,
    String? category,
    int? questionNumber,
    String? alignment,
    bool? isRequired,
    List<String>? choices,
    List<String>? scaleValues,
    String? placeholder,
  }) {
    return TemplateComponent(
      type: type ?? this.type,
      label: label ?? this.label,
      description: description ?? this.description,
      category: category ?? this.category,
      questionNumber: questionNumber ?? this.questionNumber,
      alignment: alignment ?? this.alignment,
      isRequired: isRequired ?? this.isRequired,
      choices: choices ?? this.choices,
      scaleValues: scaleValues ?? this.scaleValues,
      placeholder: placeholder ?? this.placeholder,
    );
  }
}

class ExtractedComponent {
  const ExtractedComponent({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    this.questionNumber,
    this.alignment,
  });

  final String id;
  final String type;
  final String label;
  final String description;
  final int? questionNumber;
  final String? alignment;

  ExtractedComponent copyWith({
    String? type,
    String? label,
    String? description,
    int? questionNumber,
    String? alignment,
  }) {
    return ExtractedComponent(
      id: id,
      type: type ?? this.type,
      label: label ?? this.label,
      description: description ?? this.description,
      questionNumber: questionNumber ?? this.questionNumber,
      alignment: alignment ?? this.alignment,
    );
  }
}

class ConversionRecord {
  const ConversionRecord({
    required this.fileName,
    required this.source,
    required this.status,
    required this.updatedAt,
  });

  final String fileName;
  final String source;
  final String status;
  final String updatedAt;
}

class ConversionFileItem {
  const ConversionFileItem({
    required this.id,
    required this.name,
    required this.type,
    this.path,
    this.bytes,
  });

  final String id;
  final String name;
  final String type;
  final String? path;
  final Uint8List? bytes;

  bool get isPdf => type == 'pdf';
  bool get isImage => type == 'image';
}

class ResponseQuestionAnswer {
  const ResponseQuestionAnswer({
    required this.questionNumber,
    required this.questionText,
    required this.answerLabel,
    required this.score,
    required this.interpretation,
  });

  final int questionNumber;
  final String questionText;
  final String answerLabel;
  final int score;
  final String interpretation;
}

class ResponseRecord {
  const ResponseRecord({
    required this.responseId,
    required this.surveyId,
    required this.surveyName,
    required this.respondentName,
    required this.age,
    required this.gender,
    required this.civilStatus,
    required this.occupation,
    required this.educationalLevel,
    required this.location,
    required this.dateSubmitted,
    required this.syncDate,
    required this.status,
    required this.completionRate,
    required this.answers,
    required this.interpretation,
    required this.surveyCategory,
  });

  final String responseId;
  final String surveyId;
  final String surveyName;
  final String respondentName;
  final int age;
  final String gender;
  final String civilStatus;
  final String occupation;
  final String educationalLevel;
  final String location;
  final String dateSubmitted;
  final String syncDate;
  final ResponseStatus status;
  final double completionRate;
  final List<ResponseQuestionAnswer> answers;
  final String interpretation;
  final String surveyCategory;
}

class ChartPoint {
  const ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

class QuestionInsight {
  const QuestionInsight({
    required this.title,
    required this.chartType,
    required this.points,
    required this.interpretation,
  });

  final String title;
  final ChartType chartType;
  final List<ChartPoint> points;
  final String interpretation;
}

/// A typed model for OMR survey sections used in PDF generation.
class SurveySection {
  const SurveySection({
    required this.title,
    required this.startNumber,
    required this.questions,
  });

  final String title;
  final int startNumber;
  final List<String> questions;
}

String shortStatusLabel(SurveyStatus status) {
  switch (status) {
    case SurveyStatus.active:
      return 'Active';
    case SurveyStatus.closed:
      return 'Closed';
    case SurveyStatus.inactive:
      return 'Inactive';
  }
}

Color statusColor(SurveyStatus status) {
  switch (status) {
    case SurveyStatus.active:
      return const Color(0xFF22C55E);
    case SurveyStatus.closed:
      return const Color(0xFFF59E0B);
    case SurveyStatus.inactive:
      return const Color(0xFF6B7280);
  }
}

Color responseStatusColor(ResponseStatus status) {
  switch (status) {
    case ResponseStatus.synced:
      return const Color(0xFF22C55E);
    case ResponseStatus.pending:
      return const Color(0xFFF59E0B);
    case ResponseStatus.exported:
      return const Color(0xFF3B82F6);
  }
}

String responseStatusLabel(ResponseStatus status) {
  switch (status) {
    case ResponseStatus.synced:
      return 'Synced';
    case ResponseStatus.pending:
      return 'Pending';
    case ResponseStatus.exported:
      return 'Exported';
  }
}