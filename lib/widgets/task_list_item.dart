import 'package:flutter/material.dart';

import '../models/task_model.dart';

/// A single task row showing title, status, and actions.
class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskModel task;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: Color(task.colorValue),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (v) => onToggleCompleted(v ?? false),
                ),
                title: Text(
                  task.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                    color: task.completed
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Pill(
                        icon: task.completed
                            ? Icons.check_circle_outline
                            : Icons.schedule_outlined,
                        label: task.statusLabel,
                        color: task.completed
                            ? theme.colorScheme.primary
                            : theme.colorScheme.tertiary,
                      ),
                      _Pill(
                        icon: Icons.category_outlined,
                        label: task.category,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      if (task.deadline != null)
                        _Pill(
                          icon: Icons.event_outlined,
                          label: MaterialLocalizations.of(context)
                              .formatMediumDate(task.deadline!),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      if (task.repeatDaily)
                        _Pill(
                          icon: Icons.repeat,
                          label: 'Daily',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      if ((task.coverImagePath ?? '').trim().isNotEmpty ||
                          (task.coverImageUrl ?? '').trim().isNotEmpty)
                        _Pill(
                          icon: Icons.image_outlined,
                          label: 'Cover',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
