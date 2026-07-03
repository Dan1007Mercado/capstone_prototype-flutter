import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class DeploySurveyPage extends StatefulWidget {
  const DeploySurveyPage({super.key});

  @override
  State<DeploySurveyPage> createState() => _DeploySurveyPageState();
}

class _DeploySurveyPageState extends State<DeploySurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '250');
  String _template = 'Community Health Survey';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Deploy New Survey')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SurfaceCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Survey Information',
                    subtitle: 'Mock deploy form with frontend-only state updates.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Survey Title'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _template,
                    items: const [
                      DropdownMenuItem(value: 'Community Health Survey', child: Text('Community Health Survey')),
                      DropdownMenuItem(value: 'Educational Satisfaction Survey', child: Text('Educational Satisfaction Survey')),
                      DropdownMenuItem(value: 'Barangay Assessment Form', child: Text('Barangay Assessment Form')),
                      DropdownMenuItem(value: 'Healthcare Access Survey', child: Text('Healthcare Access Survey')),
                    ],
                    onChanged: (value) => setState(() => _template = value ?? _template),
                    decoration: const InputDecoration(labelText: 'Template Selection'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _targetController.text,
                    items: const [
                      DropdownMenuItem(value: '100', child: Text('100')),
                      DropdownMenuItem(value: '250', child: Text('250')),
                      DropdownMenuItem(value: '500', child: Text('500')),
                      DropdownMenuItem(value: '1000', child: Text('1000')),
                    ],
                    onChanged: (value) => setState(() => _targetController.text = value ?? '250'),
                    decoration: const InputDecoration(labelText: 'Target Response Count'),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 760;
                      final fields = [
                        Expanded(
                          child: _DateField(
                            label: 'Start Date',
                            value: _startDate,
                            onTap: () async {
                              final picked = await _pickDate(context, _startDate ?? DateTime.now());
                              if (picked != null) setState(() => _startDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateField(
                            label: 'End Date',
                            value: _endDate,
                            onTap: () async {
                              final picked = await _pickDate(
                                context,
                                _endDate ?? DateTime.now().add(const Duration(days: 7)),
                              );
                              if (picked != null) setState(() => _endDate = picked);
                            },
                          ),
                        ),
                      ];

                      if (wide) {
                        return Row(children: fields);
                      }

                      return Column(
                        children: [
                          fields[0],
                          const SizedBox(height: 12),
                          fields[2],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          final deployed = appState.deploySurvey(
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            templateName: _template,
                            targetResponses: _targetController.text,
                            startDate: _startDate ?? DateTime.now(),
                            endDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${deployed.name} deployed successfully')),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Deploy Survey'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_month_outlined)),
        child: Text(value == null ? 'Select date' : '${value!.year}-${value!.month}-${value!.day}'),
      ),
    );
  }
}
