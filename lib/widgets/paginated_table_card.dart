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
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No records available.'),
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
                  horizontalMargin: 12,
                  headingRowHeight: 52,
                  dataRowMinHeight: 88,
                  dataRowMaxHeight: 118,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Page ${_page + 1} of $_totalPages',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              TextButton(
                onPressed: _previousPage,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _nextPage,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
