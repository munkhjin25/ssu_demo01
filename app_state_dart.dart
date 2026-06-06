import 'package:flutter/material.dart';

// --- DATA MODELS ---

class Task {
  final String id;
  String title;
  bool isCompleted;
  String category;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'Study',
  });
}

class FocusSession {
  final DateTime timestamp;
  final int durationMinutes;

  FocusSession({
    required this.timestamp,
    required this.durationMinutes,
  });
}

class AppPreferences {
  int defaultPomodoroDuration;
  bool notificationsEnabled;
  bool strictMode;

  AppPreferences({
    this.defaultPomodoroDuration = 25,
    this.notificationsEnabled = true,
    this.strictMode = false,
  });
}

// --- CENTRAL STATE MANAGER ---

class AppStateManager extends ChangeNotifier {
  final List<Task> _tasks = [
    Task(id: '1', title: 'Complete VFX Sand Simulation Analysis Paper', category: 'Academic'),
    Task(id: '2', title: 'Debug Flutter Navigation Stack State Issues', category: 'Coding'),
    Task(id: '3', title: 'Refactor OpenCV Bilateral Matrix Node Logic', category: 'Research'),
    Task(id: '4', title: 'Review Material 3 Design Guidelines', category: 'Design'),
  ];

  final List<FocusSession> _sessions = [
    FocusSession(timestamp: DateTime.now().subtract(const Duration(days: 2)), durationMinutes: 25),
    FocusSession(timestamp: DateTime.now().subtract(const Duration(days: 2)), durationMinutes: 25),
    FocusSession(timestamp: DateTime.now().subtract(const Duration(days: 1)), durationMinutes: 50),
    FocusSession(timestamp: DateTime.now(), durationMinutes: 25),
  ];

  final AppPreferences _preferences = AppPreferences();

  List<Task> get tasks => _tasks;
  List<FocusSession> get sessions => _sessions;
  AppPreferences get preferences => _preferences;

  int get totalFocusTime => _sessions.fold(0, (sum, item) => sum + item.durationMinutes);
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;

  void addTask(String title, String category) {
    _tasks.insert(0, Task(id: DateTime.now().toString(), title: title, category: category));
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void editTask(String id, String newTitle) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].title = newTitle;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void logCompletedSession(int minutes) {
    _sessions.add(FocusSession(timestamp: DateTime.now(), durationMinutes: minutes));
    notifyListeners();
  }

  void updatePreferences({int? duration, bool? notify, bool? strict}) {
    if (duration != null) _preferences.defaultPomodoroDuration = duration;
    if (notify != null) _preferences.notificationsEnabled = notify;
    if (strict != null) _preferences.strictMode = strict;
    notifyListeners();
  }
}