import 'dart:async';

import 'package:flutter/material.dart';

import '../mock/mock_data.dart' as mock_data;
import '../models/app_models.dart';

class AppState extends ChangeNotifier {
  AppState()
      : _surveys = List<SurveyRecord>.from(mock_data.surveys),
        _templates = List<TemplateRecord>.from(mock_data.templates),
        _notifications = List<NotificationItem>.from(mock_data.notifications);

  final List<SurveyRecord> _surveys;
  final List<TemplateRecord> _templates;
  final List<NotificationItem> _notifications;
  final List<ConversionFileItem> _uploadedConversionFiles = [];
  final List<ExtractedComponent> _extractedComponents = [];
  int _unreadNotifications = 0;
  bool _backgroundConversionRunning = false;
  Timer? _backgroundConversionTimer;
  bool _surveyExtractionRunning = false;
  String _surveyExtractionStatus = 'Idle';
  String? _lastSurveyExtractionMessage;
  Timer? _surveyExtractionTimer;
  Completer<void>? _surveyExtractionCompleter;

  List<SurveyRecord> get surveys => List.unmodifiable(_surveys);
  List<TemplateRecord> get templates => List.unmodifiable(_templates);
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  List<ConversionFileItem> get uploadedConversionFiles => List.unmodifiable(_uploadedConversionFiles);
  List<ExtractedComponent> get extractedComponents => List.unmodifiable(_extractedComponents);
  int get unreadNotifications => _unreadNotifications;
  bool get backgroundConversionRunning => _backgroundConversionRunning;
  bool get surveyExtractionRunning => _surveyExtractionRunning;
  String get surveyExtractionStatus => _surveyExtractionStatus;
  String? get lastSurveyExtractionMessage => _lastSurveyExtractionMessage;

  SurveyRecord deploySurvey({
    required String title,
    required String description,
    required String templateName,
    required String targetResponses,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final nextId = 'SUR-2026-${(_surveys.length + 1).toString().padLeft(3, '0')}';
    final survey = SurveyRecord(
      id: nextId,
      name: title,
      templateUsed: templateName,
      category: 'General',
      status: SurveyStatus.active,
      createdDate: mock_data.formatDateLabel(DateTime.now()),
      responses: 0,
    );
    _surveys.insert(0, survey);
    addNotification(
      title: 'Survey Successfully Deployed',
      subtitle: '$title is now active for $targetResponses responses.',
      icon: Icons.campaign_outlined,
    );
    notifyListeners();
    return survey;
  }

  TemplateRecord addTemplate({
    required String name,
    required String category,
    required String usage,
    required String lastUpdated,
    List<TemplateComponent> components = const [],
  }) {
    final template = TemplateRecord(
      id: 'TMP-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      usage: usage,
      lastUpdated: lastUpdated,
      components: components,
    );
    _templates.insert(0, template);
    addNotification(
      title: 'Template Generated',
      subtitle: '$name was saved to your template library.',
      icon: Icons.auto_awesome_outlined,
    );
    notifyListeners();
    return template;
  }

  void updateTemplate(TemplateRecord updated) {
    final index = _templates.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    _templates[index] = updated;
    addNotification(
      title: 'Template Updated',
      subtitle: '${updated.name} was updated successfully.',
      icon: Icons.edit_outlined,
    );
    notifyListeners();
  }

  void deleteTemplate(String id) {
    _templates.removeWhere((template) => template.id == id);
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    _notifications.insert(
      0,
      NotificationItem(
        title: title,
        subtitle: subtitle,
        time: 'Just now',
        icon: icon,
      ),
    );
    _unreadNotifications += 1;
    notifyListeners();
  }

  void markNotificationsRead() {
    if (_unreadNotifications == 0) return;
    _unreadNotifications = 0;
    notifyListeners();
  }

  void addUploadedConversionFiles(List<ConversionFileItem> files) {
    for (final file in files) {
      final alreadyExists = _uploadedConversionFiles.any((item) => item.id == file.id);
      if (!alreadyExists) {
        _uploadedConversionFiles.add(file);
      }
    }
    notifyListeners();
  }

  void removeUploadedConversionFile(String id) {
    _uploadedConversionFiles.removeWhere((file) => file.id == id);
    notifyListeners();
  }

  void clearUploadedConversionFiles() {
    if (_uploadedConversionFiles.isEmpty) return;
    _uploadedConversionFiles.clear();
    notifyListeners();
  }

  void setExtractedComponents(List<ExtractedComponent> components) {
    _extractedComponents
      ..clear()
      ..addAll(components);
    notifyListeners();
  }

  void addExtractedComponent(ExtractedComponent component) {
    _extractedComponents.add(component);
    notifyListeners();
  }

  void updateExtractedComponent(ExtractedComponent updated) {
    final index = _extractedComponents.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    _extractedComponents[index] = updated;
    notifyListeners();
  }

  void removeExtractedComponent(String id) {
    _extractedComponents.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearExtractedComponents() {
    if (_extractedComponents.isEmpty) return;
    _extractedComponents.clear();
    notifyListeners();
  }

  void addTemplateFromExtraction({
    required String name,
    required String category,
    required String usage,
    required String lastUpdated,
    required List<TemplateComponent> components,
  }) {
    final template = TemplateRecord(
      id: 'TMP-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      usage: usage,
      lastUpdated: lastUpdated,
      components: components,
    );
    _templates.insert(0, template);
    addNotification(
      title: 'Template Generated',
      subtitle: '$name was saved to your template library.',
      icon: Icons.auto_awesome_outlined,
    );
    notifyListeners();
  }

  Future<void> startSurveyExtraction({required int fileCount}) async {
    if (_surveyExtractionRunning) return;

    _surveyExtractionRunning = true;
    _surveyExtractionStatus = 'Preparing extraction for $fileCount file(s)...';
    _lastSurveyExtractionMessage = null;
    notifyListeners();

    final completer = Completer<void>();
    _surveyExtractionCompleter = completer;
    _surveyExtractionTimer?.cancel();

    var step = 0;
    _surveyExtractionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      step += 1;
      switch (step) {
        case 1:
          _surveyExtractionStatus = 'Analyzing uploaded questionnaire sources...';
          break;
        case 2:
          _surveyExtractionStatus = 'Detecting question blocks and scales...';
          break;
        case 3:
          _surveyExtractionStatus = 'Generating survey structure...';
          break;
        case 4:
          _surveyExtractionStatus = 'Extraction completed';
          _surveyExtractionRunning = false;
          _lastSurveyExtractionMessage = 'Extraction completed successfully.';
          _setMockExtractedComponents();
          addNotification(
            title: 'Survey extraction complete',
            subtitle: 'Extraction finished. Review the detected components before saving.',
            icon: Icons.fact_check_outlined,
          );
          timer.cancel();
          _surveyExtractionTimer = null;
          _surveyExtractionCompleter?.complete();
          _surveyExtractionCompleter = null;
          notifyListeners();
          break;
      }
      notifyListeners();
    });

    return completer.future;
  }

  void _setMockExtractedComponents() {
    _extractedComponents
      ..clear()
      ..addAll([
        const ExtractedComponent(
          id: 'comp-001',
          type: 'Section title',
          label: 'Customer Satisfaction',
          description: 'Section heading for the survey introduction.',
          questionNumber: null,
          alignment: 'Left aligned',
        ),
        const ExtractedComponent(
          id: 'comp-002',
          type: 'Question',
          label: 'How satisfied are you with the service?',
          description: 'Five-point satisfaction rating.',
          questionNumber: 1,
          alignment: 'Left aligned',
        ),
        const ExtractedComponent(
          id: 'comp-003',
          type: 'Checkbox',
          label: 'Service factors',
          description: 'Checkbox items for service attributes.',
          questionNumber: 2,
          alignment: 'Top aligned',
        ),
        const ExtractedComponent(
          id: 'comp-004',
          type: 'OMR bubble',
          label: 'Choose one option',
          description: 'Detected OMR bubble group.',
          questionNumber: 3,
          alignment: 'Centered',
        ),
        const ExtractedComponent(
          id: 'comp-005',
          type: 'Label',
          label: 'Please mark only one answer.',
          description: 'Instruction label for the OMR block.',
          questionNumber: null,
          alignment: 'Left aligned',
        ),
      ]);
  }

  void cancelSurveyExtraction() {
    _surveyExtractionTimer?.cancel();
    _surveyExtractionTimer = null;
    _surveyExtractionRunning = false;
    _surveyExtractionStatus = 'Cancelled';
    _surveyExtractionCompleter?.completeError(StateError('Cancelled'));
    _surveyExtractionCompleter = null;
    notifyListeners();
  }

  void startBackgroundConversion() {
    if (_backgroundConversionRunning) return;
    _backgroundConversionRunning = true;
    notifyListeners();

    var step = 0;
    _backgroundConversionTimer?.cancel();
    _backgroundConversionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      step += 1;
      if (step == 2) {
        addNotification(
          title: 'Review Ready',
          subtitle: 'A questionnaire review is ready in the background.',
          icon: Icons.fact_check_outlined,
        );
      }
      if (step == 4) {
        addNotification(
          title: 'Conversion Completed',
          subtitle: 'Questionnaire conversion has finished.',
          icon: Icons.swap_horiz_outlined,
        );
      }
      if (step >= 5) {
        addNotification(
          title: 'Export Available',
          subtitle: 'Converted output files are now available.',
          icon: Icons.file_download_done_outlined,
        );
        _backgroundConversionTimer?.cancel();
        _backgroundConversionTimer = null;
        _backgroundConversionRunning = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _backgroundConversionTimer?.cancel();
    _surveyExtractionTimer?.cancel();
    super.dispose();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}
