import 'package:flutter/material.dart';

class AnalyticsToolbar extends StatelessWidget {
  const AnalyticsToolbar({
    super.key,
    required this.onFilterChanged,
    required this.onExport,
    this.initialSurvey = 'All Surveys',
  });

  final void Function(Map<String, String>) onFilterChanged;
  final VoidCallback onExport;
  final String initialSurvey;

  @override
  Widget build(BuildContext context) {
    final surveys = [
      'All Surveys',
      'Student Satisfaction',
      'Faculty Evaluation',
      'Customer Feedback',
      'Course Evaluation',
    ];
    final dateOptions = ['Last 7 Days', 'Last 30 Days', 'This Month', 'Last Semester', 'Custom Range'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          
          if (isMobile) {
            // Mobile: Survey + Date + Export
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: surveys.contains(initialSurvey) ? initialSurvey : surveys.first,
                        items: surveys.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => onFilterChanged({'survey': v ?? 'All Surveys'}),
                        decoration: const InputDecoration(labelText: 'Survey', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: dateOptions.first,
                        items: dateOptions.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => onFilterChanged({'date': v ?? dateOptions.first}),
                        decoration: const InputDecoration(labelText: 'Date', isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onExport,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Export'),
                  ),
                ),
              ],
            );
          } else {
            // Desktop: single row with Survey, Date, Export
            return Row(
              children: [
                Flexible(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: surveys.contains(initialSurvey) ? initialSurvey : surveys.first,
                    items: surveys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => onFilterChanged({'survey': v ?? 'All Surveys'}),
                    decoration: const InputDecoration(labelText: 'Survey'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: dateOptions.first,
                    items: dateOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => onFilterChanged({'date': v ?? dateOptions.first}),
                    decoration: const InputDecoration(labelText: 'Date Range'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export'),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
