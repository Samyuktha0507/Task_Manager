import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import 'task_edit_screen.dart';
import '../widgets/filter_chips.dart';
import '../widgets/task_list_item.dart';

/// Home screen: Today tasks (calendar removed).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor({
    required TaskProvider provider,
    required TaskModel task,
    required bool isNew,
  }) async {
    final result = await Navigator.of(context).pushNamed(
      TaskEditScreen.routeName,
      arguments: TaskEditArgs(task: task, isNew: isNew),
    );
    if (!mounted) return;
    if (result is TaskModel) {
      provider.upsertTask(result);
    }
  }

  Future<void> _confirmDelete(TaskProvider provider, TaskModel task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      provider.deleteTask(task.id);
    }
  }

  Future<void> _manageCategories() async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Consumer<CategoryProvider>(
            builder: (context, categories, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Departments / Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.categories.map((c) {
                      final removable = c != 'General' && c != 'Others';
                      return InputChip(
                        label: Text(c),
                        onDeleted: removable
                            ? () => context
                                .read<CategoryProvider>()
                                .removeCategory(c)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Add new category (optional)',
                      prefixIcon: Icon(Icons.add),
                    ),
                    onSubmitted: (v) {
                      context.read<CategoryProvider>().addCategory(v);
                      controller.clear();
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      context
                          .read<CategoryProvider>()
                          .addCategory(controller.text);
                      controller.clear();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    controller.dispose();
  }

  static const _colorOptions = <_ColorOption>[
    _ColorOption('Purple', 0xFF7C4DFF),
    _ColorOption('Cyan', 0xFF00ACC1),
    _ColorOption('Amber', 0xFFFFB300),
    _ColorOption('Green', 0xFF43A047),
    _ColorOption('Red', 0xFFEF5350),
    _ColorOption('Blue', 0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            tooltip: 'Manage categories',
            icon: const Icon(Icons.tune_outlined),
            onPressed: _manageCategories,
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(
              context.watch<ThemeProvider>().isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
        ],
      ),
      floatingActionButton: Consumer<TaskProvider>(
        builder: (context, provider, _) => FloatingActionButton.extended(
          onPressed: () {
            final d = DateTime.now();
            final newTask = TaskModel(
              id: provider.nextTaskId(),
              userId: 0,
              title: '',
              completed: false,
              category: 'General',
              colorValue: 0xFF7C4DFF,
              deadline: DateTime(d.year, d.month, d.day),
            );
            _openEditor(provider: provider, task: newTask, isNew: true);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add task'),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tasks...'),
                ],
              ),
            );
          }

          if (provider.error != null && provider.tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => provider.loadTasks(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final categories = context.watch<CategoryProvider>().categories;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (provider.isLoading && provider.tasks.isNotEmpty)
                const LinearProgressIndicator(minHeight: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search tasks…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              FilterChips(
                currentFilter: provider.filter,
                onFilterChanged: (f) => provider.setFilter(f),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String?>(
                        value: provider.categoryFilter,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem<String?>(
                              value: c,
                              child: Text(c),
                            ),
                          ),
                        ],
                        onChanged: provider.setCategoryFilter,
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      child: DropdownButtonFormField<int?>(
                        value: provider.colorFilter,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          prefixIcon: Icon(Icons.palette_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All'),
                          ),
                          ..._colorOptions.map(
                            (o) => DropdownMenuItem<int?>(
                              value: o.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Color(o.value),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(o.label),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: provider.setColorFilter,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        provider.clearExtraFilters();
                      },
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _TodayTab(
                  provider: provider,
                  date: DateTime.now(),
                  onEdit: (t) => _openEditor(
                    provider: provider,
                    task: t,
                    isNew: false,
                  ),
                  onDelete: (t) => _confirmDelete(provider, t),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Kept for potential future empty states.
}

class _TodayTab extends StatelessWidget {
  const _TodayTab({
    required this.provider,
    required this.date,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskProvider provider;
  final DateTime date;
  final ValueChanged<TaskModel> onEdit;
  final ValueChanged<TaskModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final list = provider.tasksForDate(date);
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No tasks for today',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: provider.loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final task = list[index];
          return TaskListItem(
            task: task,
            onToggleCompleted: (v) => provider.toggleCompleted(task.id, v),
            onEdit: () => onEdit(task),
            onDelete: () => onDelete(task),
          );
        },
      ),
    );
  }
}

class _ColorOption {
  final String label;
  final int value;
  const _ColorOption(this.label, this.value);
}
