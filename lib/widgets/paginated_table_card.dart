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
    final compact = MediaQuery.sizeOf(context).width < 640;
    final theme = context.appTheme;

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
                    Icon(
                      Icons.table_rows_outlined,
                      size: 40,
                      color: AppColors.textDisabled,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No records available.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (compact)
            Column(
              children: [
                for (final row in rows) ...[
                  _MobileDataRow(columns: widget.columns, row: row),
                  if (row != rows.last) const SizedBox(height: 10),
                ],
              ],
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
                  style: TextStyle(color: theme.onSurfaceVariant, fontSize: 13),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
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

class _MobileDataRow extends StatelessWidget {
  const _MobileDataRow({required this.columns, required this.row});

  final List<DataColumn> columns;
  final DataRow row;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        border: Border.all(color: theme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < row.cells.length && i < columns.length; i++) ...[
            _MobileDataField(
              label: columns[i].label,
              value: row.cells[i].child,
            ),
            if (i != row.cells.length - 1)
              Divider(height: 18, color: theme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _MobileDataField extends StatelessWidget {
  const _MobileDataField({required this.label, required this.value});

  final Widget label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          child: label,
        ),
        const SizedBox(height: 6),
        DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          child: value,
        ),
      ],
    );
  }
}
