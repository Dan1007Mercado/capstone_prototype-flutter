import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../mock/mock_data.dart' as mock_data;
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/paginated_table_card.dart';
import 'create_template_page.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final templateRows = appState.templates;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            final summary = [
              StatItem(
                label: 'Templates',
                value: '${templateRows.length}',
                icon: Icons.view_agenda_outlined,
                accent: AppColors.primary,
                delta: 'Mock library',
              ),
              StatItem(
                label: 'High Usage',
                value: '9',
                icon: Icons.trending_up_outlined,
                accent: AppColors.success,
                delta: 'Active templates',
              ),
              StatItem(
                label: 'Recently Updated',
                value: '4',
                icon: Icons.update_outlined,
                accent: AppColors.warning,
                delta: 'This week',
              ),
            ];
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: summary
                  .map(
                    (item) => SizedBox(
                      width: wide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      child: StatCard(
                        label: item.label,
                        value: item.value,
                        icon: item.icon,
                        accent: item.accent,
                        delta: item.delta,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        PaginatedTableCard(
          title: 'Templates',
          subtitle: 'Reusable mock templates with pagination and compact metadata.',
          rowsPerPage: 5,
          columns: const [
            DataColumn(label: Text('Template Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Usage')),
            DataColumn(label: Text('Last Updated')),
            DataColumn(label: Text('Actions')),
          ],
          rows: templateRows
              .map(
                (template) => DataRow(
                  cells: [
                    DataCell(Text(template.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(template.category, style: const TextStyle(color: AppColors.textSecondary))),
                    DataCell(Text(template.usage)),
                    DataCell(Text(template.lastUpdated, style: const TextStyle(color: AppColors.textSecondary))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Preview',
                            child: IconButton(
                              onPressed: () => Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => TemplateBuilderPage(
                                    style: TemplateStyle.traditional,
                                    mode: TemplateBuilderMode.preview,
                                    template: template,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.visibility_outlined, size: 18),
                            ),
                          ),
                          Tooltip(
                            message: 'Edit Template',
                            child: IconButton(
                              onPressed: () => Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => TemplateBuilderPage(
                                    style: TemplateStyle.traditional,
                                    mode: TemplateBuilderMode.edit,
                                    template: template,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                            ),
                          ),
                          Tooltip(
                            message: 'Duplicate',
                            child: IconButton(
                              onPressed: () {
                                final copiedName = '${template.name} - Copy';
                                appState.addTemplate(
                                  name: copiedName,
                                  category: template.category,
                                  usage: template.usage,
                                  lastUpdated: mock_data.formatDateLabel(DateTime.now()),
                                  components: template.components,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Template duplicated successfully')),
                                );
                              },
                              icon: const Icon(Icons.copy_outlined, size: 18),
                            ),
                          ),
                          Tooltip(
                            message: 'Delete',
                            child: IconButton(
                              onPressed: () async {
                                final templateId = template.id;
                                final messenger = ScaffoldMessenger.of(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Delete Template'),
                                      content: const Text('Are you sure you want to delete this template?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogContext, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(dialogContext, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  appState.deleteTemplate(templateId);
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Template deleted successfully')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.delete_outline, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}