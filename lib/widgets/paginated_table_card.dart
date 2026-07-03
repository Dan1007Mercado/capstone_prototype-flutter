import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common_widgets.dart';

class PaginatedTableCard extends StatefulWidget {
  const PaginatedTableCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.columns,
    required this.rows,
    this.rowsPerPage = 5,
  });

  final String title;
  final String subtitle;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int rowsPerPage;

  @override
  State<PaginatedTableCard> createState() => _PaginatedTableCardState();
}

class _PaginatedTableCardState extends State<PaginatedTableCard> {
  int _page = 0;

  int get _totalPages {
    if (widget.rows.isEmpty) {
      return 1;
    }
    return (widget.rows.length / widget.rowsPerPage).ceil();
  }

  List<DataRow> get _visibleRows {
    final start = _page * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  void _previousPage() {
    if (_page == 0) return;
    setState(() => _page -= 1);
  }

  void _nextPage() {
    if (_page >= _totalPages - 1) return;
    setState(() => _page += 1);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: widget.title, subtitle: widget.subtitle),
          const SizedBox(height: 16),
          if (widget.rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.table_rows_outlined, size: 40, color: AppColors.textDisabled),
                    SizedBox(height: 12),
                    Text(
                      'No records available.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 820),
                child: DataTable(
                  columns: widget.columns,
                  rows: rows,
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  headingRowHeight: 52,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 88,
                ),
              ),
            ),
          if (widget.rows.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Page ${_page + 1} of $_totalPages',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Next'),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}