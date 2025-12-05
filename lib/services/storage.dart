import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../models/task.dart';
import '../models/block.dart';

// SharedPreferences kullanarak verileri depola ve yükle
class StorageService {
  // Depolama anahtarları
  static const _routinesKey = 'studyflow_routines_v1';
  static const _tasksKey = 'studyflow_tasks_v1';
  static const _blocksKey = 'studyflow_blocks_v1';

  // Rutinleri depolamadan yükle
  static Future<List<Routine>> loadRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_routinesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => Routine.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Rutinleri depolamaya kaydet
  static Future<void> saveRoutines(List<Routine> routines) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(routines.map((r) => r.toJson()).toList());
    try {
      await prefs.setString(_routinesKey, encoded);
    } catch (_) {
      rethrow;
    }
  }

  // Görevleri depolamadan yükle
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Task.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  // Görevleri depolamaya kaydet
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = Task.encodeList(tasks);
    try {
      await prefs.setString(_tasksKey, encoded);
    } catch (_) {
      rethrow;
    }
  }

  // Blokları depolamadan yükle
  static Future<List<Block>> loadBlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_blocksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Block.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  // Blokları depolamaya kaydet
  static Future<void> saveBlocks(List<Block> blocks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = Block.encodeList(blocks);
    try {
      await prefs.setString(_blocksKey, encoded);
    } catch (_) {
      rethrow;
    }
  }
}
