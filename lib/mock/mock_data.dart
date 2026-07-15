import 'package:flutter/material.dart';

import '../models/app_models.dart';

const dashboardStats = <StatItem>[
  StatItem(
    label: 'Active Surveys',
    value: '18',
    icon: Icons.assignment_turned_in_outlined,
    accent: Color(0xFF4361EE),
    delta: '+4 this week',
  ),
  StatItem(
    label: 'Total Responses',
    value: '1,240',
    icon: Icons.groups_outlined,
    accent: Color(0xFF22C55E),
    delta: '+12% vs last week',
  ),
  StatItem(
    label: 'Templates',
    value: '12',
    icon: Icons.view_agenda_outlined,
    accent: Color(0xFFF59E0B),
    delta: '3 recently updated',
  ),
];

const recentActivities = <ActivityItem>[
  ActivityItem(
    title: 'Template Generated',
    subtitle: 'Community Health Survey Template A',
    time: '2 mins ago',
    icon: Icons.auto_awesome_outlined,
  ),
  ActivityItem(
    title: 'Survey Published',
    subtitle: 'Quarterly Satisfaction Survey',
    time: '18 mins ago',
    icon: Icons.campaign_outlined,
  ),
  ActivityItem(
    title: 'Conversion Completed',
    subtitle: 'Uploaded questionnaire converted',
    time: '42 mins ago',
    icon: Icons.swap_horiz_outlined,
  ),
  ActivityItem(
    title: 'Export Downloaded',
    subtitle: 'Survey results exported as XLSX',
    time: '1 hour ago',
    icon: Icons.file_download_outlined,
  ),
  ActivityItem(
    title: 'Questionnaire Uploaded',
    subtitle: 'Baseline assessment file received',
    time: '3 hours ago',
    icon: Icons.upload_file_outlined,
  ),
];

const notifications = <NotificationItem>[
  NotificationItem(
    title: 'Conversion Completed',
    subtitle: 'The latest questionnaire was converted successfully.',
    time: 'Just now',
    icon: Icons.swap_horiz_outlined,
  ),
  NotificationItem(
    title: 'Template Generated',
    subtitle: 'A new template was created from the uploaded survey.',
    time: '12 mins ago',
    icon: Icons.auto_awesome_outlined,
  ),
  NotificationItem(
    title: 'Export Finished',
    subtitle: 'CSV export is ready for download.',
    time: '34 mins ago',
    icon: Icons.file_download_done_outlined,
  ),
  NotificationItem(
    title: 'Survey Closed',
    subtitle: 'Field data collection ended for Survey A.',
    time: '2 hours ago',
    icon: Icons.lock_outline,
  ),
];

const surveys = <SurveyRecord>[
  SurveyRecord(
    id: 'SUR-2026-001',
    name: 'Quarterly Satisfaction Survey',
    templateUsed: 'Healthcare Feedback A',
    category: 'Health',
    status: SurveyStatus.active,
    createdDate: '2026-06-29',
    responses: 248,
  ),
  SurveyRecord(
    id: 'SUR-2026-002',
    name: 'Patient Intake Review',
    templateUsed: 'Intake Form Standard',
    category: 'Health',
    status: SurveyStatus.closed,
    createdDate: '2026-06-22',
    responses: 156,
  ),
  SurveyRecord(
    id: 'SUR-2026-003',
    name: 'Community Outreach Check-in',
    templateUsed: 'Outreach Survey B',
    category: 'Community Services',
    status: SurveyStatus.inactive,
    createdDate: '2026-06-18',
    responses: 0,
  ),
  SurveyRecord(
    id: 'SUR-2026-004',
    name: 'Service Quality Pulse',
    templateUsed: 'Quality Tracker',
    category: 'General',
    status: SurveyStatus.active,
    createdDate: '2026-06-16',
    responses: 342,
  ),
  SurveyRecord(
    id: 'SUR-2026-005',
    name: 'Accessibility Audit',
    templateUsed: 'Access Review Set',
    category: 'Education',
    status: SurveyStatus.active,
    createdDate: '2026-06-15',
    responses: 89,
  ),
  SurveyRecord(
    id: 'SUR-2026-006',
    name: 'Feedback Round 2',
    templateUsed: 'Satisfaction Lite',
    category: 'General',
    status: SurveyStatus.closed,
    createdDate: '2026-06-10',
    responses: 203,
  ),
  SurveyRecord(
    id: 'SUR-2026-007',
    name: 'Post Visit Survey',
    templateUsed: 'Follow-up Template',
    category: 'Health',
    status: SurveyStatus.inactive,
    createdDate: '2026-06-06',
    responses: 0,
  ),
  SurveyRecord(
    id: 'SUR-2026-008',
    name: 'Training Evaluation',
    templateUsed: 'Learning Review',
    category: 'Education',
    status: SurveyStatus.active,
    createdDate: '2026-06-02',
    responses: 127,
  ),
  SurveyRecord(
    id: 'SUR-2026-009',
    name: 'Baseline Research Form',
    templateUsed: 'Research Intake',
    category: 'Research',
    status: SurveyStatus.closed,
    createdDate: '2026-05-28',
    responses: 412,
  ),
  SurveyRecord(
    id: 'SUR-2026-010',
    name: 'Monthly Service Audit',
    templateUsed: 'Operations Audit',
    category: 'Community Services',
    status: SurveyStatus.active,
    createdDate: '2026-05-24',
    responses: 175,
  ),
];

const templates = <TemplateRecord>[
  TemplateRecord(
    id: 'TMP-001',
    name: 'Healthcare Feedback A',
    category: 'Survey',
    usage: '9 surveys',
    lastUpdated: '2026-06-30',
  ),
  TemplateRecord(
    id: 'TMP-002',
    name: 'Quality Tracker',
    category: 'Analytics',
    usage: '6 surveys',
    lastUpdated: '2026-06-29',
  ),
  TemplateRecord(
    id: 'TMP-003',
    name: 'Intake Form Standard',
    category: 'Workflow',
    usage: '11 surveys',
    lastUpdated: '2026-06-27',
  ),
  TemplateRecord(
    id: 'TMP-004',
    name: 'Outreach Survey B',
    category: 'Field Work',
    usage: '4 surveys',
    lastUpdated: '2026-06-23',
  ),
  TemplateRecord(
    id: 'TMP-005',
    name: 'Satisfaction Lite',
    category: 'Survey',
    usage: '8 surveys',
    lastUpdated: '2026-06-21',
  ),
  TemplateRecord(
    id: 'TMP-006',
    name: 'Operations Audit',
    category: 'Audit',
    usage: '3 surveys',
    lastUpdated: '2026-06-20',
  ),
  TemplateRecord(
    id: 'TMP-007',
    name: 'Learning Review',
    category: 'Training',
    usage: '5 surveys',
    lastUpdated: '2026-06-18',
  ),
  TemplateRecord(
    id: 'TMP-008',
    name: 'Research Intake',
    category: 'Research',
    usage: '2 surveys',
    lastUpdated: '2026-06-14',
  ),
];

const conversions = <ConversionRecord>[
  ConversionRecord(
    fileName: 'baseline_assessment.pdf',
    source: 'Uploaded questionnaire',
    status: 'Completed',
    updatedAt: '2026-07-03 08:15',
  ),
  ConversionRecord(
    fileName: 'community_form.docx',
    source: 'OCR scanned form',
    status: 'Completed',
    updatedAt: '2026-07-03 07:42',
  ),
  ConversionRecord(
    fileName: 'service_review.jpg',
    source: 'Image capture',
    status: 'Queued',
    updatedAt: '2026-07-03 07:10',
  ),
  ConversionRecord(
    fileName: 'training_eval.pdf',
    source: 'Bulk upload',
    status: 'Processing',
    updatedAt: '2026-07-02 22:01',
  ),
  ConversionRecord(
    fileName: 'feedback_sheet.png',
    source: 'Camera scan',
    status: 'Completed',
    updatedAt: '2026-07-02 18:24',
  ),
  ConversionRecord(
    fileName: 'audit_packet.pdf',
    source: 'Manual import',
    status: 'Archived',
    updatedAt: '2026-07-01 14:09',
  ),
];

const weeklyResponses = <ChartPoint>[
  ChartPoint('Week 1', 44),
  ChartPoint('Week 2', 61),
  ChartPoint('Week 3', 55),
  ChartPoint('Week 4', 73),
  ChartPoint('Week 5', 69),
  ChartPoint('Week 6', 92),
];

const responseStatusSummary = <ChartPoint>[
  ChartPoint('Completed', 68),
  ChartPoint('In Progress', 32),
];

List<QuestionInsight> buildQuestionInsights() {
  final titles = <String>[
    'Q1 Satisfaction',
    'Q2 Accessibility',
    'Q3 Healthcare Status',
    'Q4 Service Quality',
    'Q5 Response Time',
    'Q6 Communication Clarity',
    'Q7 Staff Support',
    'Q8 Facility Cleanliness',
    'Q9 Appointment Ease',
    'Q10 Follow-up Quality',
    'Q11 Wait Time',
    'Q12 Information Accuracy',
    'Q13 Confidence Level',
    'Q14 Recommendation Likelihood',
    'Q15 User Experience',
    'Q16 Issue Resolution',
    'Q17 Safety Perception',
    'Q18 Digital Comfort',
    'Q19 Overall Trust',
    'Q20 Final Rating',
  ];
  final chartTypes = ChartType.values;

  return List.generate(titles.length, (index) {
    final seed = index + 1;
    final points = <ChartPoint>[
      ChartPoint('Strongly Disagree', 6 + seed % 5),
      ChartPoint('Disagree', 10 + (seed * 2) % 8),
      ChartPoint('Neutral', 18 + (seed * 3) % 12),
      ChartPoint('Agree', 26 + (seed * 4) % 16),
      ChartPoint('Strongly Agree', 34 + (seed * 5) % 20),
    ];
    return QuestionInsight(
      title: titles[index],
      chartType: chartTypes[index % chartTypes.length],
      points: points,
      interpretation:
          'Majority of respondents for ${titles[index]} reported positive outcomes, suggesting strong satisfaction and minimal friction.',
    );
  });
}

String formatDateLabel(DateTime date) {
  const months = <String>[
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
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatDateTimeLabel(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
          ? date.hour - 12
          : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '${formatDateLabel(date)} $hour:$minute $suffix';
}

List<ResponseQuestionAnswer> buildQuestionAnswers(int seed, {bool review = false}) {
  const answerLabels = ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'];
  const questionText = <String>[
    'How would you rate your overall health?',
    'How often do you exercise?',
    'How accessible are healthcare services?',
    'How satisfied are you with public clinics?',
    'Quality of learning materials',
    'Availability of educational support',
    'Internet accessibility',
    'Road maintenance satisfaction',
    'Waste management effectiveness',
    'Safety within your community',
    'Stress Level',
    'Financial Stability',
    'Work Satisfaction',
    'Life Satisfaction',
    'Access to community programs',
    'Confidence in local services',
    'Satisfaction with communication',
    'Digital service usability',
    'Trust in local initiatives',
    'Overall service rating',
  ];

  return List.generate(questionText.length, (index) {
    var score = ((seed * 3 + index * 2) % 5) + 1;

    if (!review && score == 1) {
      // Keep at most one low-scoring answer for good responses.
      score = index % 5 == 0 ? 1 : 2;
    }

    return ResponseQuestionAnswer(
      questionNumber: index + 1,
      questionText: questionText[index],
      answerLabel: answerLabels[score - 1],
      score: score,
      interpretation: score >= 4
          ? 'Positive'
          : score == 3
              ? 'Neutral'
              : 'Needs Improvement',
    );
  });
}

List<ResponseRecord> buildMockResponses(SurveyRecord survey) {
  const firstNames = [
    'Juan',
    'Maria',
    'Carlos',
    'Anna',
    'Jocelyn',
    'Michael',
    'Grace',
    'Ramon',
    'Isabel',
    'Paolo',
  ];
  const lastNames = [
    'Dela Cruz',
    'Reyes',
    'Santos',
    'Garcia',
    'Mendoza',
    'Torres',
    'Lopez',
    'Navarro',
    'Ramos',
    'Flores',
  ];
  const genders = ['Male', 'Female'];
  const civilStatuses = ['Single', 'Married', 'Widowed', 'Separated'];
  const occupations = [
    'Teacher',
    'Nurse',
    'Office Staff',
    'Vendor',
    'Farmer',
    'Driver',
    'Student',
    'Engineer',
    'Caregiver',
    'Community Worker',
  ];
  const educationLevels = [
    'Elementary Graduate',
    'High School Graduate',
    'College Level',
    'College Graduate',
    'Postgraduate',
  ];
  const locations = [
    'Quezon City',
    'Makati',
    'Pasig',
    'Cebu City',
    'Davao City',
    'Baguio City',
    'Iloilo City',
    'Cagayan de Oro',
    'Taguig',
    'Muntinlupa',
  ];
  const statuses = [
    ResponseStatus.synced,
    ResponseStatus.pending,
    ResponseStatus.exported,
  ];

  return List.generate(50, (index) {
    final seed = index + 1;
    final responseId = 'RSP-2026-${(index + 1).toString().padLeft(4, '0')}';
    final submitted = DateTime(2026, 7, 1 + (index % 3), 8 + (index % 10), (index * 7) % 60);
    final sync = submitted.add(Duration(hours: 1 + (index % 5), minutes: (index * 4) % 50));
    final isReviewResponse = index >= 46;
    final answers = buildQuestionAnswers(seed, review: isReviewResponse);
    final averageScore = answers.fold<double>(0, (sum, answer) => sum + answer.score) / answers.length;
    return ResponseRecord(
      responseId: responseId,
      surveyId: survey.id,
      surveyName: survey.name,
      respondentName: '${firstNames[index % firstNames.length]} ${lastNames[(index + 3) % lastNames.length]}',
      age: 21 + (index * 3) % 39,
      gender: genders[index % genders.length],
      civilStatus: civilStatuses[index % civilStatuses.length],
      occupation: occupations[index % occupations.length],
      educationalLevel: educationLevels[index % educationLevels.length],
      location: locations[index % locations.length],
      dateSubmitted: formatDateTimeLabel(submitted),
      syncDate: formatDateTimeLabel(sync),
      status: statuses[index % statuses.length],
      completionRate: 70 + (averageScore * 6),
      answers: answers,
      interpretation:
          'The respondent generally demonstrated ${averageScore >= 4 ? 'positive perceptions' : averageScore >= 3 ? 'balanced perceptions' : 'mixed perceptions'} regarding healthcare accessibility and community services. Most responses fall within the ${averageScore >= 4 ? 'Agree to Strongly Agree' : averageScore >= 3 ? 'Neutral to Agree' : 'Disagree to Neutral'} range, indicating ${averageScore >= 4 ? 'favorable satisfaction levels' : averageScore >= 3 ? 'moderate satisfaction levels' : 'areas that need further attention'}.',
      surveyCategory: survey.category,
    );
  });
}
