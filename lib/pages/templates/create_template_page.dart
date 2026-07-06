import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

class CreateTemplatePage extends StatefulWidget {
  const CreateTemplatePage({super.key});

  @override
  State<CreateTemplatePage> createState() => _CreateTemplatePageState();
}

enum TemplateBuilderMode { create, edit, preview }

class _CreateTemplatePageState extends State<CreateTemplatePage> {
  TemplateStyle _style = TemplateStyle.traditional;

  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFDDECEF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        title: const Text('Create Template'),
        backgroundColor: _cardWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStyleSelectionCard(),
        ],
      ),
    );
  }

  Widget _buildStyleSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Step 1',
            subtitle: 'Select template style before entering the builder.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;
              final children = [
                _StyleOptionCard(
                  title: 'Traditional Form',
                  subtitle: 'Question 1, Question 2, Question 3, Question 4',
                  selected: _style == TemplateStyle.traditional,
                  onTap: () => setState(() => _style = TemplateStyle.traditional),
                ),
                _StyleOptionCard(
                  title: 'Card Per Page',
                  subtitle: 'One Question per screen',
                  selected: _style == TemplateStyle.cardPerPage,
                  onTap: () => setState(() => _style = TemplateStyle.cardPerPage),
                ),
              ];

              if (wide) {
                return Row(
                  children: [
                    Expanded(child: children[0]),
                    const SizedBox(width: 16),
                    Expanded(child: children[1]),
                  ],
                );
              }

              return Column(
                children: [
                  children[0],
                  const SizedBox(height: 16),
                  children[1],
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TemplateBuilderPage(style: _style),
                  ),
                );
              },
              child: const Text('Proceed to Template Builder'),
            ),
          ),
        ],
      ),
    );
  }
}

enum TemplateStyle { traditional, cardPerPage }

class TemplateBuilderPage extends StatefulWidget {
  const TemplateBuilderPage({
    super.key,
    required this.style,
    this.mode = TemplateBuilderMode.create,
    this.template,
  });

  final TemplateStyle style;
  final TemplateBuilderMode mode;
  final TemplateRecord? template;

  @override
  State<TemplateBuilderPage> createState() => _TemplateBuilderPageState();
}

class _TemplateBuilderPageState extends State<TemplateBuilderPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _labelController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _placeholderController;
  late final TextEditingController _scaleValuesController;
  final _components = <TemplateComponent>[];
  int _selectedIndex = 0;

  static const Color _tealDark = Color(0xFF0F9B9B);
  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _headingText = Color(0xFF0E2A2E);
  static const Color _bodyText = Color(0xFF7C8A90);
  static const Color _border = Color(0xFFDDECEF);

  bool get _canEdit => widget.mode != TemplateBuilderMode.preview;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.template?.name ?? 'Community Health Survey',
    );
    _labelController = TextEditingController();
    _descriptionController = TextEditingController();
    _placeholderController = TextEditingController();
    _scaleValuesController = TextEditingController();
    if (widget.template != null) {
      _components.addAll(widget.template!.components);
    }
    // Ensure there's always at least one component to avoid index errors
    if (_components.isEmpty) {
      _components.add(TemplateComponent.empty());
    } else {
      _components.addAll([
        TemplateComponent(
          type: 'Section Header',
          label: 'Survey Introduction',
          description: 'Explain the survey purpose and estimated completion time.',
          category: 'OMR Components',
        ),
        TemplateComponent(
          type: 'Likert Scale',
          label: 'Satisfaction Questions',
          description: 'Five-point satisfaction rating.',
          category: 'Quantitative Components',
        ),
        TemplateComponent(
          type: 'Instruction Block',
          label: 'Response Guidelines',
          description: 'Use one mark per item and avoid skipping questions.',
          category: 'OMR Components',
        ),
      ]);
    }
    _syncControllersWithSelection();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _descriptionController.dispose();
    _placeholderController.dispose();
    _scaleValuesController.dispose();
    super.dispose();
  }

  TemplateComponent get _selectedComponent => _components[_selectedIndex];

  void _syncControllersWithSelection() {
    final component = _selectedComponent;
    _labelController.text = component.label;
    _descriptionController.text = component.description;
    _placeholderController.text = component.placeholder ?? '';
    _scaleValuesController.text = component.scaleValues.join(', ');
  }

  void _selectComponent(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _syncControllersWithSelection();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final title = widget.mode == TemplateBuilderMode.edit
        ? 'Edit Template'
        : widget.mode == TemplateBuilderMode.preview
            ? 'Preview Template'
            : 'Template Builder';

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: _cardWhite,
      ),
      floatingActionButton: widget.mode == TemplateBuilderMode.preview
          ? null
          : FloatingActionButton.extended(
              backgroundColor: _tealDark,
              foregroundColor: Colors.white,
              onPressed: _showAddComponentSheet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Component'),
            ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTemplateNameCard(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 1100;
              final builderPane = _buildComponentList(context);
              final propsPane = _buildPropertiesPane(context);

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: builderPane),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: propsPane),
                  ],
                );
              }

              return Column(
                children: [
                  builderPane,
                  const SizedBox(height: 16),
                  propsPane,
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _canEdit
                  ? () {
                      final template = TemplateRecord(
                        id: widget.template?.id ?? 'TMP-${DateTime.now().millisecondsSinceEpoch}',
                        name: _nameController.text.trim().isEmpty
                            ? 'Untitled Template'
                            : _nameController.text.trim(),
                        category: 'Survey',
                        usage: '${_components.length} components',
                        lastUpdated: formatDateLabel(DateTime.now()),
                        components: List.unmodifiable(_components),
                      );
                      if (widget.mode == TemplateBuilderMode.edit && widget.template != null) {
                        appState.updateTemplate(template);
                      } else {
                        appState.addTemplate(
                          name: template.name,
                          category: template.category,
                          usage: template.usage,
                          lastUpdated: template.lastUpdated,
                          components: template.components,
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.mode == TemplateBuilderMode.edit
                              ? 'Template updated successfully'
                              : 'Template saved to mock library'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(widget.mode == TemplateBuilderMode.edit ? 'Save Changes' : 'Save Template'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateNameCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Builder',
            subtitle: widget.style == TemplateStyle.traditional
                ? 'Traditional Form layout with grouped components.'
                : 'Card Per Page layout with one question per screen.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Template Name',
              prefixIcon: Icon(Icons.edit_outlined, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Components',
            subtitle: 'Drag to reorder. Select a card to edit its properties.',
          ),
          const SizedBox(height: 16),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _components.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _components.removeAt(oldIndex);
                _components.insert(newIndex, item);
                _selectedIndex = newIndex;
              });
            },
            itemBuilder: (context, index) {
              final component = _components[index];
              final selected = index == _selectedIndex;
              return Padding(
                key: ValueKey(component.label + index.toString()),
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _selectComponent(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFF8FCFD) : _pageBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? _tealDark : _border,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: Icon(Icons.drag_indicator, color: _bodyText),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                component.label,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _headingText),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                component.type,
                                style: const TextStyle(color: _bodyText, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(label: component.category),
                        const SizedBox(width: 8),
                        if (_canEdit)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _components.removeAt(index);
                                if (_components.isEmpty) {
                                  _components.add(TemplateComponent.empty());
                                  _selectedIndex = 0;
                                } else {
                                  _selectedIndex = _selectedIndex.clamp(0, _components.length - 1);
                                }
                              });
                            },
                            icon: const Icon(Icons.delete_outline, size: 18, color: _bodyText),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesPane(BuildContext context) {
    final component = _selectedComponent;
    final showChoices = _isChoiceType(component.type);
    final showScaleValues = _isLikertType(component.type);
    final showPlaceholder = _isTextInputType(component.type);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Properties',
            subtitle: 'Mock editing panel for questionnaire components.',
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Label',
              prefixIcon: Icon(Icons.label_outline, size: 20),
            ),
            controller: _labelController,
            readOnly: !_canEdit,
            onChanged: _canEdit
                ? (value) => _updateSelectedComponent((current) => current.copyWith(label: value))
                : null,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description_outlined, size: 20),
              alignLabelWithHint: true,
            ),
            controller: _descriptionController,
            maxLines: 2,
            readOnly: !_canEdit,
            onChanged: _canEdit
                ? (value) => _updateSelectedComponent((current) => current.copyWith(description: value))
                : null,
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Required'),
            value: component.isRequired,
            activeThumbColor: _tealDark,
            onChanged: _canEdit
                ? (value) => _updateSelectedComponent((current) => current.copyWith(isRequired: value))
                : null,
          ),
          if (showChoices) ...[
            const SizedBox(height: 12),
            const Text('Choices', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _headingText)),
            const SizedBox(height: 8),
            if (component.choices.isEmpty)
              Text(
                _canEdit ? 'No choices added yet.' : 'No choices defined.',
                style: const TextStyle(color: _bodyText, fontSize: 13),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: component.choices
                    .asMap()
                    .entries
                    .map(
                      (entry) => Chip(
                        label: Text('${entry.key + 1}. ${entry.value}'),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: _mintChipBg,
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 8),
            if (_canEdit)
              OutlinedButton.icon(
                onPressed: _showAddChoiceDialog,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Choice'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _tealDark,
                  side: BorderSide(color: _tealDark.withValues(alpha: 0.3)),
                ),
              ),
          ],
          if (showScaleValues) ...[
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Scale Values',
                prefixIcon: Icon(Icons.tune_outlined, size: 20),
              ),
              controller: _scaleValuesController,
              readOnly: !_canEdit,
              onChanged: _canEdit
                  ? (value) => _updateSelectedComponent(
                        (current) => current.copyWith(
                          scaleValues: value
                              .split(',')
                              .map((entry) => entry.trim())
                              .where((entry) => entry.isNotEmpty)
                              .toList(),
                        ),
                      )
                  : null,
            ),
          ],
          if (showPlaceholder) ...[
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Placeholder',
                prefixIcon: Icon(Icons.text_fields_outlined, size: 20),
              ),
              controller: _placeholderController,
              readOnly: !_canEdit,
              onChanged: _canEdit
                  ? (value) => _updateSelectedComponent((current) => current.copyWith(placeholder: value))
                  : null,
            ),
          ],
          if (!showChoices && !showScaleValues && !showPlaceholder) ...[
            const SizedBox(height: 12),
            Text(
              'This component has no additional configuration fields.',
              style: const TextStyle(color: _bodyText, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  void _updateSelectedComponent(TemplateComponent Function(TemplateComponent) updater) {
    setState(() {
      _components[_selectedIndex] = updater(_components[_selectedIndex]);
    });
    _syncControllersWithSelection();
  }

  Future<void> _showAddChoiceDialog() async {
    final controller = TextEditingController();
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Choice'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Type a choice'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  Navigator.pop(dialogContext);
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (!mounted || choice == null || choice.isEmpty) return;

    _updateSelectedComponent(
      (current) => current.copyWith(choices: [...current.choices, choice]),
    );
  }

  bool _isChoiceType(String type) {
    final normalized = type.toLowerCase();
    return normalized.contains('choice') || normalized.contains('dropdown') || normalized.contains('checkbox');
  }

  bool _isLikertType(String type) {
    final normalized = type.toLowerCase();
    return normalized.contains('likert') || normalized.contains('rating') || normalized.contains('semantic');
  }

  bool _isTextInputType(String type) {
    final normalized = type.toLowerCase();
    return normalized.contains('text') || normalized.contains('paragraph') || normalized.contains('comment') || normalized.contains('open-ended') || normalized.contains('numeric');
  }

  void _showAddComponentSheet() {
    final groupedComponents = <String, List<String>>{
      'Demographics': [
        'First Name',
        'Middle Name',
        'Last Name',
        'Age',
        'Birthdate',
        'Gender',
        'Civil Status',
        'Occupation',
        'Educational Level',
        'Email',
        'Phone Number',
      ],
      'Location Components': [
        'Region',
        'Province',
        'Municipality',
        'Barangay',
        'Address',
      ],
      'Quantitative Components': [
        'Likert Scale',
        'Semantic Differential Scale',
        'Multiple Choice',
        'Single Choice',
        'Checkbox Group',
        'Rating Scale',
        'Matrix Question',
        'Dropdown',
        'Numeric Input',
      ],
      'Qualitative Components': [
        'Textbox',
        'Long Text',
        'Paragraph',
        'Comment Box',
        'Open-ended Question',
      ],
      'OMR Components': [
        'Bubble Grid',
        'Answer Sheet',
        'Section Header',
        'Instruction Block',
      ],
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _cardWhite,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          minChildSize: 0.65,
          maxChildSize: 0.96,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Add Component',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _headingText,
                      ),
                ),
                const SizedBox(height: 16),
                for (final entry in groupedComponents.entries) ...[
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _bodyText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: entry.value
                        .map(
                          (componentName) => ActionChip(
                            label: Text(componentName),
                            backgroundColor: _mintChipBg,
                            side: BorderSide.none,
                            onPressed: () {
                              setState(() {
                                _components.add(
                                  TemplateComponent(
                                    type: componentName,
                                    label: componentName,
                                    description: 'Mock $componentName component.',
                                    category: entry.key,
                                  ),
                                );
                                _selectedIndex = _components.length - 1;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _StyleOptionCard extends StatelessWidget {
  const _StyleOptionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  static const Color _tealDark = Color(0xFF0F9B9B);
  static const Color _border = Color(0xFFDDECEF);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _headingText = Color(0xFF0E2A2E);
  static const Color _bodyText = Color(0xFF7C8A90);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8FCFD) : _pageBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _tealDark : _border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _headingText),
                  ),
                ),
                if (selected) const Icon(Icons.check_circle, color: _tealDark, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: _bodyText, height: 1.5, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _iconTeal = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _mintChipBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _iconTeal,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}