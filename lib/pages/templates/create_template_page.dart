import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/web_sidebar.dart';
import '../../widgets/web_topbar.dart';
import '../auth/login.dart';
import '../settings/settings_page.dart';

class CreateTemplatePage extends StatelessWidget {
  const CreateTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TemplateBuilderPage(style: TemplateStyle.traditional);
  }
}

enum TemplateBuilderMode { create, edit, preview }
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

  // ── Design tokens (kept in sync with SurveysPage's web palette) ──────────
  static const Color _tealDark = Color(0xFF0F9B9B);
  static const Color _tealLight = Color(0xFF2DD4CF);
  static const Color _iconTeal = Color(0xFF14B8A6);
  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _headingText = Colors.black;
  static const Color _bodyText = Colors.black;
  static const Color _border = Color(0xFFDDECEF);
  static const Color _infoBlue = Color(0xFF2563EB);
  static const Color _successGreen = Color(0xFF16A34A);

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

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildWebLayout(context, appState, title);
        }
        return _buildMobileLayout(context, appState, title);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT — no sidebar, matches SurveysPage mobile behavior
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(
    BuildContext context,
    AppState appState,
    String title,
  ) {
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
      body: _buildEditorContent(context, appState),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // WEB LAYOUT — sidebar + topbar shell, matching SurveysPage's web design
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(
    BuildContext context,
    AppState appState,
    String title,
  ) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Row(
        children: [
          WebSidebar(
            currentIndex: 2,
            onNavigate: (index) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => ResponsiveShell(initialIndex: index),
                ),
                (route) => false,
              );
            },
            onLogout: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          Expanded(
            child: Column(
              children: [
                WebTopbar(
                  onSettings: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsPage(),
                    ),
                  ),
                  unreadNotifications: appState.unreadNotifications,
                ),
                Expanded(
                  child: _buildEditorContent(
                    context,
                    appState,
                    padding: const EdgeInsets.all(SpacingTokens.xxl),
                    header: _buildWebHeader(context, title),
                    isWeb: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorContent(
    BuildContext context,
    AppState appState, {
    EdgeInsets padding = const EdgeInsets.all(20),
    Widget? header,
    bool isWeb = false,
  }) {
    return ListView(
      padding: padding,
      children: [
        if (header != null) ...[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: header,
            ),
          ),
          const SizedBox(height: SpacingTokens.xxl),
        ],
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWeb) ...[
                  _WebTemplateStatsRow(
                    totalComponents: _components.length,
                    requiredCount:
                        _components.where((c) => c.isRequired).length,
                    categoryCount:
                        _components.map((c) => c.category).toSet().length,
                    styleLabel: widget.style == TemplateStyle.traditional
                        ? 'Traditional'
                        : 'Card / Page',
                  ),
                  const SizedBox(height: SpacingTokens.xxl),
                ],
                _buildTemplateNameCard(isWeb: isWeb),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 1100;
                    final builderPane = _buildComponentList(context, isWeb: isWeb);
                    final propsPane = _buildPropertiesPane(context, isWeb: isWeb);

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
                  child: isWeb
                      ? FilledButton.icon(
                          onPressed: _canEdit
                              ? () => _saveTemplate(context, appState)
                              : null,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(widget.mode == TemplateBuilderMode.edit
                              ? 'Save Changes'
                              : 'Save Template'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _tealDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : FilledButton(
                          onPressed: _canEdit
                              ? () => _saveTemplate(context, appState)
                              : null,
                          child: Text(widget.mode == TemplateBuilderMode.edit
                              ? 'Save Changes'
                              : 'Save Template'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_tealLight, _tealDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _tealDark.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.style == TemplateStyle.traditional
                      ? 'Traditional form layout with grouped components.'
                      : 'Card per page layout with one question per screen.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (_canEdit)
            FilledButton.icon(
              onPressed: _showAddComponentSheet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Component'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _headingText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _saveTemplate(BuildContext context, AppState appState) {
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

  Widget _buildTemplateNameCard({bool isWeb = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(isWeb ? 18 : 20),
        border: Border.all(color: _border, width: isWeb ? 0.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isWeb ? 0.03 : 0.04),
            blurRadius: isWeb ? 14 : 18,
            offset: Offset(0, isWeb ? 6 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWeb
              ? _WebSectionHeading(
                  title: 'Builder',
                  subtitle: widget.style == TemplateStyle.traditional
                      ? 'Traditional Form layout with grouped components.'
                      : 'Card Per Page layout with one question per screen.',
                )
              : SectionHeader(
                  title: 'Builder',
                  subtitle: widget.style == TemplateStyle.traditional
                      ? 'Traditional Form layout with grouped components.'
                      : 'Card Per Page layout with one question per screen.',
                ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: isWeb ? GoogleFonts.inter(fontSize: 14) : null,
            decoration: const InputDecoration(
              labelText: 'Template Name',
              prefixIcon: Icon(Icons.edit_outlined, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList(BuildContext context, {bool isWeb = false}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(isWeb ? 18 : 20),
        border: Border.all(color: _border, width: isWeb ? 0.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isWeb ? 0.03 : 0.04),
            blurRadius: isWeb ? 14 : 18,
            offset: Offset(0, isWeb ? 6 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: isWeb
                ? const _WebSectionHeading(
                    title: 'Components',
                    subtitle: 'Drag to reorder. Select a card to edit its properties.',
                  )
                : const SectionHeader(
                    title: 'Components',
                    subtitle: 'Drag to reorder. Select a card to edit its properties.',
                  ),
          ),
          if (isWeb) ...[
            Divider(height: 1, color: _border),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: SpacingTokens.md,
              ),
              color: _mintChipBg.withValues(alpha: 0.4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _columnLabel('COMPONENT'),
                  ),
                  Expanded(child: _columnLabel('CATEGORY')),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Divider(height: 1, color: _border),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(
              isWeb ? 0 : 20,
              isWeb ? 0 : 0,
              isWeb ? 0 : 20,
              20,
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _components.length,
              buildDefaultDragHandles: false,
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
                return isWeb
                    ? _WebComponentRow(
                        key: ValueKey(component.label + index.toString()),
                        index: index,
                        component: component,
                        selected: selected,
                        canEdit: _canEdit,
                        onTap: () => _selectComponent(index),
                        onDelete: () => _removeComponent(index),
                      )
                    : Padding(
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
                                    onPressed: () => _removeComponent(index),
                                    icon: const Icon(Icons.delete_outline, size: 18, color: _bodyText),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _columnLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _bodyText,
        letterSpacing: 0.5,
      ),
    );
  }

  void _removeComponent(int index) {
    setState(() {
      _components.removeAt(index);
      if (_components.isEmpty) {
        _components.add(TemplateComponent.empty());
        _selectedIndex = 0;
      } else {
        _selectedIndex = _selectedIndex.clamp(0, _components.length - 1);
      }
    });
    _syncControllersWithSelection();
  }

  Widget _buildPropertiesPane(BuildContext context, {bool isWeb = false}) {
    final component = _selectedComponent;
    final showChoices = _isChoiceType(component.type);
    final showScaleValues = _isLikertType(component.type);
    final showPlaceholder = _isTextInputType(component.type);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(isWeb ? 18 : 20),
        border: Border.all(color: _border, width: isWeb ? 0.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isWeb ? 0.03 : 0.04),
            blurRadius: isWeb ? 14 : 18,
            offset: Offset(0, isWeb ? 6 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWeb
              ? const _WebSectionHeading(
                  title: 'Properties',
                  subtitle: 'Mock editing panel for questionnaire components.',
                )
              : const SectionHeader(
                  title: 'Properties',
                  subtitle: 'Mock editing panel for questionnaire components.',
                ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Component Name',
              prefixIcon: Icon(Icons.label_outline, size: 20),
            ),
            style: isWeb ? GoogleFonts.inter(fontSize: 14) : null,
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
            style: isWeb ? GoogleFonts.inter(fontSize: 14) : null,
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
            title: Text(
              'Required',
              style: isWeb
                  ? GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _headingText)
                  : null,
            ),
            value: component.isRequired,
            activeThumbColor: _tealDark,
            onChanged: _canEdit
                ? (value) => _updateSelectedComponent((current) => current.copyWith(isRequired: value))
                : null,
          ),
          if (showChoices) ...[
            const SizedBox(height: 12),
            Text(
              'Choices',
              style: isWeb
                  ? GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: _headingText)
                  : const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _headingText),
            ),
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
              style: isWeb ? GoogleFonts.inter(fontSize: 14) : null,
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
              style: isWeb ? GoogleFonts.inter(fontSize: 14) : null,
              controller: _placeholderController,
              readOnly: !_canEdit,
              onChanged: _canEdit
                  ? (value) => _updateSelectedComponent((current) => current.copyWith(placeholder: value))
                  : null,
            ),
          ],
          if (!showChoices && !showScaleValues && !showPlaceholder) ...[
            const SizedBox(height: 12),
            const Text(
              'This component has no additional configuration fields.',
              style: TextStyle(color: _bodyText, fontSize: 13),
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

// ═══════════════════════════════════════════════════════════════════════════
// WEB-STYLE SECTION HEADING — mirrors card headings used across the web app
// ═══════════════════════════════════════════════════════════════════════════
class _WebSectionHeading extends StatelessWidget {
  const _WebSectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _TemplateBuilderPageState._headingText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: _TemplateBuilderPageState._bodyText,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB STATS ROW — same card pattern as _WebSurveysStatsRow in SurveysPage
// ═══════════════════════════════════════════════════════════════════════════
class _WebTemplateStatsRow extends StatelessWidget {
  const _WebTemplateStatsRow({
    required this.totalComponents,
    required this.requiredCount,
    required this.categoryCount,
    required this.styleLabel,
  });

  final int totalComponents;
  final int requiredCount;
  final int categoryCount;
  final String styleLabel;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _WebTemplateStat(
        label: 'Components',
        value: totalComponents.toString(),
        icon: Icons.widgets_outlined,
        iconBg: _TemplateBuilderPageState._mintChipBg,
        iconColor: _TemplateBuilderPageState._iconTeal,
      ),
      _WebTemplateStat(
        label: 'Required Fields',
        value: requiredCount.toString(),
        icon: Icons.check_circle_outline,
        iconBg: _TemplateBuilderPageState._successGreen.withValues(alpha: 0.12),
        iconColor: _TemplateBuilderPageState._successGreen,
      ),
      _WebTemplateStat(
        label: 'Categories Used',
        value: categoryCount.toString(),
        icon: Icons.category_outlined,
        iconBg: _TemplateBuilderPageState._infoBlue.withValues(alpha: 0.12),
        iconColor: _TemplateBuilderPageState._infoBlue,
      ),
      _WebTemplateStat(
        label: 'Layout Style',
        value: styleLabel,
        icon: Icons.dashboard_customize_outlined,
        iconBg: _TemplateBuilderPageState._tealDark.withValues(alpha: 0.12),
        iconColor: _TemplateBuilderPageState._tealDark,
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final isLast = entry.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : SpacingTokens.lg),
            child: _WebTemplateStatCard(stat: entry.value),
          ),
        );
      }).toList(),
    );
  }
}

class _WebTemplateStat {
  const _WebTemplateStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}

class _WebTemplateStatCard extends StatelessWidget {
  const _WebTemplateStatCard({required this.stat});

  final _WebTemplateStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: _TemplateBuilderPageState._cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _TemplateBuilderPageState._border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: stat.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 22),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _TemplateBuilderPageState._bodyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _TemplateBuilderPageState._headingText,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB COMPONENT ROW — table-row styled item, echoing _WebSurveyRow
// ═══════════════════════════════════════════════════════════════════════════
class _WebComponentRow extends StatelessWidget {
  const _WebComponentRow({
    super.key,
    required this.index,
    required this.component,
    required this.selected,
    required this.canEdit,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final TemplateComponent component;
  final bool selected;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? _TemplateBuilderPageState._mintChipBg.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _TemplateBuilderPageState._border),
              left: BorderSide(
                color: selected ? _TemplateBuilderPageState._tealDark : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: _TemplateBuilderPageState._bodyText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _TemplateBuilderPageState._headingText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      component.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _TemplateBuilderPageState._bodyText,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CategoryChip(label: component.category),
              ),
              SizedBox(
                width: 40,
                child: canEdit
                    ? IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: _TemplateBuilderPageState._bodyText,
                        tooltip: 'Remove',
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
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
  static const Color _headingText = Colors.black;
  static const Color _bodyText = Colors.black;

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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
