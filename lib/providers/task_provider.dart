import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api;

  List<TaskModel> _tasks        = [];
  final List<String>    _categories   = List.from(kDefaultCategories);
  bool            _isLoading    = false;
  String?         _error;
  Map<String, dynamic>? _stats;

  List<TaskModel> get tasks      => _tasks;
  List<String>    get categories => _categories;
  bool            get isLoading  => _isLoading;
  String?         get error      => _error;
  Map<String, dynamic>? get stats => _stats;

  TaskProvider({required ApiService api}) : _api = api;

  // ── Computed getters ──────────────────────────────────────

  List<TaskModel> get todayTasks    =>
      _tasks.where((t) => t.isDueToday && t.isPending).toList();

  List<TaskModel> get pendingTasks  =>
      _tasks.where((t) => t.isPending).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  List<TaskModel> get overdueTasks  =>
      _tasks.where((t) => t.isOverdue).toList();

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    return _tasks
        .where((t) => t.isPending && t.deadline != null && t.deadline!.isAfter(now))
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
  }

  double get completionRate {
    if (_tasks.isEmpty) return 0;
    return completedTasks.length / _tasks.length;
  }

  // ── Data fetching ─────────────────────────────────────────

  Future<void> loadTasks() async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      _tasks = await _api.getTasks();
      _syncCustomCategories();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _api.getStats();
      notifyListeners();
    } catch (_) {}
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> addTask(TaskModel task) async {
    try {
      final created = await _api.createTask(task);
      _tasks.insert(0, created);
      _syncCustomCategories();
      // Schedule reminder notification at deadline time
      if (created.deadline != null) {
        await NotificationService().scheduleTaskReminder(
          id:       created.id ?? 0,
          title:    created.title,
          deadline: created.deadline!,
        );
      }
      await loadStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final updated = await _api.updateTask(task);
      final idx = _tasks.indexWhere((t) => t.id == updated.id);
      if (idx >= 0) _tasks[idx] = updated;
      _syncCustomCategories();
      // Update reminder: cancel if no deadline or task completed; else schedule at new deadline
      final taskId = updated.id ?? 0;
      if (updated.deadline == null || updated.status == 'completed') {
        await NotificationService().cancelNotification(taskId);
      } else if (updated.deadline != null) {
        await NotificationService().scheduleTaskReminder(
          id: taskId,
          title: updated.title,
          deadline: updated.deadline!,
        );
      }
      await loadStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleComplete(TaskModel task) async {
    final newStatus = task.isCompleted ? 'pending' : 'completed';
    await updateTask(task.copyWith(status: newStatus));
  }

  Future<void> deleteTask(int id) async {
    try {
      await _api.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      await NotificationService().cancelNotification(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // ── Categories ────────────────────────────────────────────

  void addCategory(String name) {
    if (!_categories.contains(name)) {
      _categories.add(name);
      notifyListeners();
    }
  }

  void _syncCustomCategories() {
    for (final t in _tasks) {
      if (!_categories.contains(t.category)) {
        _categories.add(t.category);
      }
    }
  }

  // ── Filtering ─────────────────────────────────────────────

  List<TaskModel> filterTasks({
    String? status,
    String? priority,
    String? category,
    String? searchQuery,
  }) {
    return _tasks.where((t) {
      if (status   != null && t.status   != status)   return false;
      if (priority != null && t.priority != priority) return false;
      if (category != null && t.category != category) return false;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !(t.description?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
