import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = true;

  TaskProvider({TaskRepository? repository})
      : _repository = repository ?? TaskRepository() {
    _loadTasks();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
  List<Task> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();
  bool get isLoading => _isLoading;

  Future<void> _loadTasks() async {
    _tasks = await _repository.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? notes,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      notes: notes,
      dueDate: dueDate,
      priority: priority,
    );
    _tasks.add(task);
    notifyListeners();
    await _repository.saveTasks(_tasks);
  }

  Future<void> toggleComplete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] =
        _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    notifyListeners();
    await _repository.saveTasks(_tasks);
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _repository.saveTasks(_tasks);
  }

  Future<void> updateTask(Task updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _tasks[index] = updated;
    notifyListeners();
    await _repository.saveTasks(_tasks);
  }
}
