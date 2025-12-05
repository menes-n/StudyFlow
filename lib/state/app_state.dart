import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../models/task.dart';
import '../models/block.dart';
import '../services/storage.dart';

// Uygulamanın global durumunu yönet (Rutin, Görev, Blok vb.)
class AppState extends ChangeNotifier {
  // Rutin, Görev ve Blok listeleri
  List<Routine> _routines = [];
  List<Task> _tasks = [];
  List<Block> _blocks = [];
  // Veri yüklenme durumu
  bool loading = true;
  // Koyu mod etkin mi
  bool _darkModeEnabled = false;

  List<Routine> get routines => List.unmodifiable(_routines);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Block> get blocks => List.unmodifiable(_blocks);
  bool get darkModeEnabled => _darkModeEnabled;

  // Verileri depolamadan yükle ve uygulamayı başlat
  Future<void> init() async {
    loading = true;
    notifyListeners();
    // Depolamadan tüm verileri yükle
    _routines = await StorageService.loadRoutines();
    _tasks = await StorageService.loadTasks();
    _blocks = await StorageService.loadBlocks();

    // Koyu mod ayarını yükle
    final prefs = await SharedPreferences.getInstance();
    _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;

    loading = false;
    notifyListeners();
  }

  // Koyu modu aç/kapat
  Future<void> setDarkMode(bool enabled) async {
    _darkModeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', enabled);
    notifyListeners();
  }

  // Yeni rutin ekle
  Future<void> addRoutine(Routine r) async {
    _routines.add(r);
    await StorageService.saveRoutines(_routines);

    notifyListeners();
  }

  // Rutin güncelle
  Future<void> updateRoutine(Routine r) async {
    final idx = _routines.indexWhere((x) => x.id == r.id);
    if (idx != -1) {
      _routines[idx] = r;

      await StorageService.saveRoutines(_routines);

      notifyListeners();
    }
  }

  // Rutin sil
  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((x) => x.id == id);

    await StorageService.saveRoutines(_routines);

    notifyListeners();
  }

  // Rutinlerin tamamlanma oranını hesapla
  double progress() {
    if (_routines.isEmpty) return 0.0;
    final done = _routines.where((r) => r.completed).length;
    return done / _routines.length;
  }

  // Yeni görev ekle
  Future<void> addTask(Task t) async {
    _tasks.add(t);

    await StorageService.saveTasks(_tasks);
    notifyListeners();
  }

  // Görev güncelle
  Future<void> updateTask(Task t) async {
    final idx = _tasks.indexWhere((x) => x.id == t.id);
    if (idx != -1) {
      _tasks[idx] = t;

      await StorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  // Görev sil
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((x) => x.id == id);

    await StorageService.saveTasks(_tasks);
    notifyListeners();
  }

  // Yeni blok ekle
  Future<void> addBlock(Block b) async {
    _blocks.add(b);

    await StorageService.saveBlocks(_blocks);
    notifyListeners();
  }

  // Blok güncelle
  Future<void> updateBlock(Block b) async {
    final idx = _blocks.indexWhere((x) => x.id == b.id);
    if (idx != -1) {
      _blocks[idx] = b;

      await StorageService.saveBlocks(_blocks);
      notifyListeners();
    }
  }

  // Blok sil
  Future<void> deleteBlock(String id) async {
    _blocks.removeWhere((x) => x.id == id);

    await StorageService.saveBlocks(_blocks);
    notifyListeners();
  }

  // Belirli bir tarih için görevleri getir
  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((t) {
      if (t.dueDateMillis == null) return false;
      if (t.completed) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(t.dueDateMillis!);
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  // Göreve blok ekle
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
