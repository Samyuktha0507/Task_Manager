import 'package:flutter/material.dart';

import '../providers/task_provider.dart';

/// Filter chips for All / Completed / Pending.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FilterChip(
            label: 'Show All',
            selected: currentFilter == TaskFilter.all,
            onTap: () => onFilterChanged(TaskFilter.all),
          ),
          _FilterChip(
            label: 'Completed',
            selected: currentFilter == TaskFilter.completed,
            onTap: () => onFilterChanged(TaskFilter.completed),
          ),
          _FilterChip(
            label: 'Pending',
            selected: currentFilter == TaskFilter.pending,
            onTap: () => onFilterChanged(TaskFilter.pending),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
