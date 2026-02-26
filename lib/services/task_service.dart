import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task_model.dart';

/// Service for fetching task data from JSONPlaceholder API.
class TaskService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Fetches all todos from the API.
  /// Throws [TaskServiceException] on network or parsing errors.
  Future<List<TaskModel>> fetchTasks() async {
    final uri = Uri.parse('$_baseUrl/todos');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw TaskServiceException(
        'Failed to load tasks (${response.statusCode})',
      );
    }

    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList.map((e) {
      final raw = TaskModel.fromJson(e as Map<String, dynamic>);
      return raw.copyWith(
        title: _friendlyTitle(raw.id),
        description: _friendlyDescription(raw.id),
        category: _friendlyCategory(raw.id),
        colorValue: _friendlyColor(raw.id),
        deadline: _friendlyDeadline(raw.id),
        repeatDaily: _friendlyRepeatDaily(raw.id),
      );
    }).toList();
  }
}

String _friendlyTitle(int id) {
  const titles = [
    'Review today’s priorities',
    'Reply to important emails',
    '30-minute workout',
    'Plan meals for the week',
    'Read 10 pages of a book',
    'Team stand-up prep',
    'Pay utility bills',
    'Clean up photo gallery',
    'Meditation session',
    'Update resume/portfolio',
    'Water the plants',
    'Grocery run essentials',
    'Call family member',
    'Write weekly journal',
    'Organize desk and files',
    'Learn something new (15 min)',
    'Schedule doctor appointment',
    'Backup laptop files',
    'Refill prescriptions',
    'Practice a hobby',
    'Prepare for tomorrow',
  ];
  return titles[(id - 1) % titles.length];
}

String _friendlyDescription(int id) {
  const descriptions = [
    'Pick the top 3 tasks that will make today a win.',
    'Clear quick replies first; flag items needing more time.',
    'Keep it simple: warm-up, strength, stretch.',
    'Choose easy meals; add items to your shopping list.',
    'No pressure—just consistent progress.',
    'Skim notes and list blockers before the meeting.',
    'Check due dates and confirm payments are successful.',
    'Delete duplicates and favorites; free some space.',
    'A short reset for focus and calm.',
    'Refresh summary, projects, and one key achievement.',
    'Quick check: soil, sunlight, and water as needed.',
    'Buy only what you need; avoid impulse items.',
    'A small check-in goes a long way.',
    'Write one highlight and one lesson learned.',
    'Tidy workspace; your future self will thank you.',
    'Watch/read one short resource and take notes.',
    'Pick a time slot and set a reminder.',
    'Run a quick backup to your preferred drive/cloud.',
    'Confirm stock and set a pickup reminder if needed.',
    'Spend 20 minutes—enjoy the process.',
    'Lay out clothes, schedule, and your first task.',
  ];
  return descriptions[(id - 1) % descriptions.length];
}

String _friendlyCategory(int id) {
  const categories = [
    'Work',
    'Personal',
    'Health',
    'Finance',
    'Learning',
    'Home',
    'Others',
  ];
  return categories[(id - 1) % categories.length];
}

int _friendlyColor(int id) {
  const colors = [
    0xFF7C4DFF, // purple
    0xFF00ACC1, // cyan
    0xFFFFB300, // amber
    0xFF43A047, // green
    0xFFEF5350, // red
    0xFF1E88E5, // blue
  ];
  return colors[(id - 1) % colors.length];
}

DateTime? _friendlyDeadline(int id) {
  final today = DateTime.now();
  final base = DateTime(today.year, today.month, today.day);

  // Spread API tasks across upcoming dates so calendar selection
  // consistently shows matching tasks below the calendar.
  final offsetDays = (id - 1) % 180; // next ~6 months
  return base.add(Duration(days: offsetDays));
}

bool _friendlyRepeatDaily(int id) => id % 17 == 0;

/// Exception thrown when task service operations fail.
class TaskServiceException implements Exception {
  final String message;

  TaskServiceException(this.message);

  @override
  String toString() => 'TaskServiceException: $message';
}
