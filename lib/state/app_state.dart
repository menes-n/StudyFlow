import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../models/task.dart';
import '../models/block.dart';
import '../services/storage.dart';

class AppState extends ChangeNotifier {
  List<Routine> _routines = [];
  List<Task> _tasks = [];
  List<Block> _blocks = [];
  bool loading = true;
  bool _darkModeEnabled = false;

  List<Routine> get routines => List.unmodifiable(_routines);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Block> get blocks => List.unmodifiable(_blocks);
  bool get darkModeEnabled => _darkModeEnabled;

  Future<void> init() async {
    loading = true;
    notifyListeners();
    _routines = await StorageService.loadRoutines();
    _tasks = await StorageService.loadTasks();
    _blocks = await StorageService.loadBlocks();

    final prefs = await SharedPreferences.getInstance();
    _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;

    loading = false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkModeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', enabled);
    notifyListeners();
  }

  Future<void> addRoutine(Routine r) async {
    _routines.add(r);
    await StorageService.saveRoutines(_routines);

    notifyListeners();
  }

  Future<void> updateRoutine(Routine r) async {
    final idx = _routines.indexWhere((x) => x.id == r.id);
    if (idx != -1) {
      _routines[idx] = r;

      await StorageService.saveRoutines(_routines);

      notifyListeners();
    }
  }

  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((x) => x.id == id);

    await StorageService.saveRoutines(_routines);

    notifyListeners();
  }

  double progress() {
    if (_routines.isEmpty) return 0.0;
    final done = _routines.where((r) => r.completed).length;
    return done / _routines.length;
  }

  Future<void> addTask(Task t) async {
    _tasks.add(t);

    await StorageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task t) async {
    final idx = _tasks.indexWhere((x) => x.id == t.id);
    if (idx != -1) {
      _tasks[idx] = t;

      await StorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((x) => x.id == id);

    await StorageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> addBlock(Block b) async {
    _blocks.add(b);

    await StorageService.saveBlocks(_blocks);
    notifyListeners();
  }

  Future<void> updateBlock(Block b) async {
    final idx = _blocks.indexWhere((x) => x.id == b.id);
    if (idx != -1) {
      _blocks[idx] = b;

      await StorageService.saveBlocks(_blocks);
      notifyListeners();
    }
  }

  Future<void> deleteBlock(String id) async {
    _blocks.removeWhere((x) => x.id == id);

    await StorageService.saveBlocks(_blocks);
    notifyListeners();
  }

  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((t) {
      if (t.dueDateMillis == null) return false;
      if (t.completed) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(t.dueDateMillis!);
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  Future<void> addBlockToTask(String taskId, String blockId) async {
    final tIdx = _tasks.indexWhere((t) => t.id == taskId);
    if (tIdx == -1) return;
    final t = _tasks[tIdx];
    if (!t.blockIds.contains(blockId)) {
      t.blockIds.add(blockId);
      await updateTask(t);
    }
  }
}
