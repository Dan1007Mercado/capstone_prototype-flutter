import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../mock/mock_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ReviewExtractedComponentsPage extends StatefulWidget {
  const ReviewExtractedComponentsPage({super.key});

  @override
  State<ReviewExtractedComponentsPage> createState() => _ReviewExtractedComponentsPageState();
}

class _ReviewExtractedComponentsPageState extends State<ReviewExtractedComponentsPage> {
  final _templateNameController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Converted Survey');
  late List<ExtractedComponent> _components;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final appState = AppStateScope.of(context);
    _components = appState.extractedComponents.map((item) => item.copyWith()).toList();
    _templateNameController.text = 'Converted Template ${appState.templates.length + 1}';
    _initialized = true;
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveTemplate(AppState appState) {
    final name = _templateNameController.text.trim().isEmpty
        ? 'Converted Template ${appState.templates.length + 1}'
        : _templateNameController.text.trim();
    final components = _components
        .map(
          (item) => TemplateComponent(
            type: item.type,
            label: item.label,
            description: item.description,
            category: item.type,
            questionNumber: item.questionNumber,
            alignment: item.alignment,
          ),
        )
        .toList();

    appState.addTemplate(
      name: name,
      category: _categoryController.text.trim().isEmpty ? 'Converted Survey' : _categoryController.text.trim(),
      usage: '${components.length} components',
      lastUpdated: formatDateLabel(DateTime.now()),
      components: components,
    );
    appState.clearExtractedComponents();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Template saved'),
          content: const Text('Your extracted survey template has been saved to the library.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _confirmCancel(AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Discard extraction review?'),
          content: const Text('If you cancel, the extracted components will be discarded and you will return to the Survey Converter.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Reviewing'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      appState.clearExtractedComponents();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _updateComponent(int index, ExtractedComponent updated) {
    setState(() {
      _components[index] = updated;
    });
  }

  void _reorderComponents(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _components.removeAt(oldIndex);
      _components.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Review Extracted Components')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Inspect and validate extraction',
                  subtitle: 'Edit labels, delete incorrect elements, add missing items, and reorder detected components.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _templateNameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    prefixIcon: Icon(Icons.drive_file_rename_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Template Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Detected components',
                  subtitle: 'Review recognition results and fix any issues before saving.',
                ),
                const SizedBox(height: 16),
                if (_components.isEmpty)
                  const Text('No extracted components are available. Return to the converter to start again.')
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: true,
                    itemCount: _components.length,
                    onReorder: _reorderComponents,
                    itemBuilder: (context, index) {
                      final item = _components[index];
                      return Padding(
                        key: ValueKey(item.id),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.type} ${item.questionNumber != null ? '#${item.questionNumber}' : ''}',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _updateComponent(
                                      index,
                                      item.copyWith(
                                        label: item.label,
                                        description: item.description,
                                      ),
                                    ),
                                    icon: const Icon(Icons.drag_indicator),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _components.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete component',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(labelText: 'Label'),
                                controller: TextEditingController(text: item.label),
                                onChanged: (value) => _updateComponent(index, item.copyWith(label: value)),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(labelText: 'Description'),
                                controller: TextEditingController(text: item.description),
                                onChanged: (value) => _updateComponent(index, item.copyWith(description: value)),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(labelText: 'Question Number'),
                                controller: TextEditingController(text: item.questionNumber?.toString() ?? ''),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final parsed = int.tryParse(value);
                                  _updateComponent(index, item.copyWith(questionNumber: parsed));
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(labelText: 'Alignment'),
                                controller: TextEditingController(text: item.alignment ?? ''),
                                onChanged: (value) => _updateComponent(index, item.copyWith(alignment: value.isEmpty ? null : value)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _components.add(
                          ExtractedComponent(
                            id: 'comp-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'Textbox',
                            label: 'New component',
                            description: 'Add the missing component description here.',
                            questionNumber: null,
                            alignment: 'Left aligned',
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Missing Component'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _confirmCancel(appState),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _components.isEmpty ? null : () => _saveTemplate(appState),
                  child: const Text('Save Template'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
