import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/category_provider.dart';

class TaskEditArgs {
  final TaskModel task;
  final bool isNew;

  const TaskEditArgs({required this.task, required this.isNew});
}

/// Add/Edit task screen (local-only fields).
class TaskEditScreen extends StatefulWidget {
  const TaskEditScreen({super.key});

  static const String routeName = '/task/edit';

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TaskModel _task;
  late bool _isNew;
  DateTime? _deadline;
  bool _repeatDaily = false;
  String _category = 'General';
  int _colorValue = 0xFF7C4DFF;
  String? _coverImagePath;
  Uint8List? _coverImageBytes;

  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments as TaskEditArgs?;
    _task = args?.task ??
        const TaskModel(
          id: 0,
          userId: 0,
          title: '',
          completed: false,
        );
    _isNew = args?.isNew ?? true;

    _titleController.text = _task.title;
    _descriptionController.text = _task.description;
    _deadline = _task.deadline;
    _repeatDaily = _task.repeatDaily;
    _category = _task.category;
    _colorValue = _task.colorValue;
    _coverImagePath = _task.coverImagePath;

    _initialized = true;
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _coverImagePath = image.path;
      _coverImageBytes = bytes;
    });
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initial = _deadline ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (selected == null) return;
    setState(() => _deadline = selected);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updated = _task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      coverImagePath: _coverImagePath,
      deadline: _deadline,
      repeatDaily: _repeatDaily,
      category: _category,
      colorValue: _colorValue,
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _deadline == null
        ? 'No deadline'
        : MaterialLocalizations.of(context).formatMediumDate(_deadline!);
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add Task' : 'Edit Task'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(_colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _category,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      prefixIcon: Icon(Icons.title_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.image_outlined),
                              const SizedBox(width: 10),
                              Text(
                                'Cover image (optional)',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _pickCoverImage,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Pick'),
                              ),
                              const SizedBox(width: 6),
                              TextButton(
                                onPressed: _coverImagePath == null
                                    ? null
                                    : () => setState(() {
                                          _coverImagePath = null;
                                          _coverImageBytes = null;
                                        }),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_coverImageBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.memory(
                                  _coverImageBytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Could not load image',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'No cover selected',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.event_outlined),
                          title: const Text('Deadline'),
                          subtitle: Text(dateLabel),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                tooltip: 'Pick date',
                                onPressed: _pickDeadline,
                                icon: const Icon(Icons.calendar_month_outlined),
                              ),
                              IconButton(
                                tooltip: 'Clear',
                                onPressed: _deadline == null
                                    ? null
                                    : () => setState(() => _deadline = null),
                                icon: const Icon(Icons.clear),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: _repeatDaily,
                          onChanged: (v) => setState(() => _repeatDaily = v),
                          title: const Text('Repeat every day'),
                          secondary: const Icon(Icons.repeat),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _category,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon:
                                      Icon(Icons.category_outlined),
                                ),
                                items: categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => _category = v);
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _colorValue,
                                decoration: const InputDecoration(
                                  labelText: 'Color',
                                  prefixIcon: Icon(Icons.palette_outlined),
                                ),
                                items: const [
                                  _ColorOption('Purple', 0xFF7C4DFF),
                                  _ColorOption('Cyan', 0xFF00ACC1),
                                  _ColorOption('Amber', 0xFFFFB300),
                                  _ColorOption('Green', 0xFF43A047),
                                  _ColorOption('Red', 0xFFEF5350),
                                  _ColorOption('Blue', 0xFF1E88E5),
                                ].map((o) {
                                  return DropdownMenuItem<int>(
                                    value: o.value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Color(o.value),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(o.label),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => _colorValue = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorOption {
  final String label;
  final int value;
  const _ColorOption(this.label, this.value);
}
