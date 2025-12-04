// Uygulama durumu: rutin listesini tutar, CRUD işlemlerini sağlar ve ilerleme hesaplar.
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

    // Load dark mode setting
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

  // Routines
  Future<void> addRoutine(Routine r) async {
    _routines.add(r);
    // ignore: avoid_print
    print('AppState.addRoutine: adding id=${r.id} title=${r.title}');
    await StorageService.saveRoutines(_routines);
    // ignore: avoid_print
    print('AppState.addRoutine: saved, notifying listeners');
    notifyListeners();
  }

  Future<void> updateRoutine(Routine r) async {
    final idx = _routines.indexWhere((x) => x.id == r.id);
    if (idx != -1) {
      _routines[idx] = r;
      // ignore: avoid_print
      print('AppState.updateRoutine: updating id=${r.id}');
      await StorageService.saveRoutines(_routines);
      // ignore: avoid_print
      print('AppState.updateRoutine: saved');
      notifyListeners();
    }
  }

  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((x) => x.id == id);
    // ignore: avoid_print
    print('AppState.deleteRoutine: deleting id=$id');
    await StorageService.saveRoutines(_routines);
    // ignore: avoid_print
    print('AppState.deleteRoutine: deleted and saved');
    notifyListeners();
  }

  double progress() {
    if (_routines.isEmpty) return 0.0;
    final done = _routines.where((r) => r.completed).length;
    return done / _routines.length;
  }

  // Tasks
  Future<void> addTask(Task t) async {
    _tasks.add(t);
    // ignore: avoid_print
    print('AppState.addTask: id=${t.id} title=${t.title}');
    await StorageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task t) async {
    final idx = _tasks.indexWhere((x) => x.id == t.id);
    if (idx != -1) {
      _tasks[idx] = t;
      // ignore: avoid_print
      print('AppState.updateTask: id=${t.id}');
      await StorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((x) => x.id == id);
    // ignore: avoid_print
    print('AppState.deleteTask: id=$id');
    await StorageService.saveTasks(_tasks);
    notifyListeners();
  }

  // Blocks
  Future<void> addBlock(Block b) async {
    _blocks.add(b);
    // ignore: avoid_print
    print('AppState.addBlock: id=${b.id} title=${b.title}');
    await StorageService.saveBlocks(_blocks);
    notifyListeners();
  }

  Future<void> updateBlock(Block b) async {
    final idx = _blocks.indexWhere((x) => x.id == b.id);
    if (idx != -1) {
      _blocks[idx] = b;
      // ignore: avoid_print
      print('AppState.updateBlock: id=${b.id}');
      await StorageService.saveBlocks(_blocks);
      notifyListeners();
    }
  }

  Future<void> deleteBlock(String id) async {
    _blocks.removeWhere((x) => x.id == id);
    // ignore: avoid_print
    print('AppState.deleteBlock: id=$id');
    await StorageService.saveBlocks(_blocks);
    notifyListeners();
  }

  // Helper: tasks for a specific date (by dueDateMillis), excluding completed tasks
  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((t) {
      if (t.dueDateMillis == null) return false;
      if (t.completed) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(t.dueDateMillis!);
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  // Attach a block to a task
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
