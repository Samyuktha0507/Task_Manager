import 'package:flutter/foundation.dart';

class CategoryProvider extends ChangeNotifier {
  final List<String> _categories = [
    'General',
    'Work',
    'Personal',
    'Health',
    'Finance',
    'Learning',
    'Home',
    'Others',
  ];

  List<String> get categories => List.unmodifiable(_categories);

  void addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final exists = _categories.any(
      (c) => c.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return;
    _categories.add(trimmed);
    notifyListeners();
  }

  void removeCategory(String name) {
    if (name == 'General' || name == 'Others') return;
    _categories.removeWhere((c) => c.toLowerCase() == name.toLowerCase());
    notifyListeners();
  }
}
