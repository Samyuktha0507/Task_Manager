import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

/// Filter options for the task list.
enum TaskFilter {
  all,
  completed,
  pending,
}

/// Provider for task list state: loading, error, data, and filter.
class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;
  TaskFilter _filter = TaskFilter.all;
  String? _categoryFilter;
  int? _colorFilter;
  String _searchQuery = '';

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskFilter get filter => _filter;
  String? get categoryFilter => _categoryFilter;
  int? get colorFilter => _colorFilter;
  String get searchQuery => _searchQuery;

  /// Returns tasks filtered by current [filter].
  List<TaskModel> get filteredTasks {
    Iterable<TaskModel> list = _tasks;

    switch (_filter) {
      case TaskFilter.completed:
        list = list.where((t) => t.completed);
        break;
      case TaskFilter.pending:
        list = list.where((t) => !t.completed);
        break;
      case TaskFilter.all:
        break;
    }

    if (_categoryFilter != null) {
      list = list.where((t) => t.category == _categoryFilter);
    }

    if (_colorFilter != null) {
      list = list.where((t) => t.colorValue == _colorFilter);
    }

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
      });
    }

    return list.toList();
  }

  List<TaskModel> tasksForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return filteredTasks.where((t) {
      if (t.repeatDaily) return true;
      if (t.deadline == null) return false;
      final td = t.deadline!;
      return td.year == d.year && td.month == d.month && td.day == d.day;
    }).toList();
  }

  /// Fetches tasks from API. Sets [isLoading] and [error] accordingly.
  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _service.fetchTasks();
      _error = null;
    } on TaskServiceException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleCompleted(int taskId, bool value) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(completed: value);
    notifyListeners();
  }

  void deleteTask(int taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void upsertTask(TaskModel task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      _tasks = [task, ..._tasks];
    } else {
      _tasks[index] = task;
    }
    notifyListeners();
  }

  int nextTaskId() {
    if (_tasks.isEmpty) return 1;
    final maxId = _tasks.map((e) => e.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  /// Updates the active filter and notifies listeners.
  void setFilter(TaskFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setColorFilter(int? value) {
    _colorFilter = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearExtraFilters() {
    _categoryFilter = null;
    _colorFilter = null;
    _searchQuery = '';
    notifyListeners();
  }
}
