import 'package:flutter/material.dart';

import 'exporters/csv_exporter.dart';
import 'exporters/excel_exporter.dart';
import 'exporters/pdf_exporter.dart';
import '../../models/app_models.dart';

class ExportDialog extends StatelessWidget {
  const ExportDialog({super.key, required this.responses, required this.survey});

  final List<ResponseRecord> responses;
  final SurveyRecord survey;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Report'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('CSV'),
              subtitle: const Text('Comma-separated values file'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);
                final path = await CsvExporter.export(responses, survey);
                if (!context.mounted) return;
                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text('CSV saved: $path')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on_outlined),
              title: const Text('Excel (.xlsx)'),
              subtitle: const Text('Multi-sheet workbook'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);
                final path = await ExcelExporter.export(responses, survey);
                if (!context.mounted) return;
                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text('XLSX saved: $path')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('PDF Report'),
              subtitle: const Text('Print-ready analytics report'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);
                final path = await PdfExporter.export(responses, survey);
                if (!context.mounted) return;
                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text('PDF saved: $path')));
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}
