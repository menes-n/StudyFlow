// Basit kalıcı depolama servisi.
// `SharedPreferences` kullanarak rutin listesini JSON olarak saklar ve yükler.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../models/task.dart';
import '../models/block.dart';

class StorageService {
  static const _routinesKey = 'studyflow_routines_v1';
  static const _tasksKey = 'studyflow_tasks_v1';
  static const _blocksKey = 'studyflow_blocks_v1';

  // Routines
  static Future<List<Routine>> loadRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_routinesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      // ignore: avoid_print
      print('StorageService.loadRoutines: raw length=${raw.length}');
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => Routine.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // ignore: avoid_print
      print('StorageService.loadRoutines: failed to decode stored data');
      return [];
    }
  }

  static Future<void> saveRoutines(List<Routine> routines) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(routines.map((r) => r.toJson()).toList());
    try {
      // ignore: avoid_print
      print('StorageService.saveRoutines: saving ${encoded.length} bytes');
      await prefs.setString(_routinesKey, encoded);
      // ignore: avoid_print
      print('StorageService.saveRoutines: saved successfully');
    } catch (e, st) {
      // ignore: avoid_print
      print('StorageService.saveRoutines: error saving -> $e\n$st');
      rethrow;
    }
  }

  // Tasks
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      // ignore: avoid_print
      print('StorageService.loadTasks: raw length=${raw.length}');
      return Task.decodeList(raw);
    } catch (e, st) {
      // ignore: avoid_print
      print('StorageService.loadTasks: failed -> $e\n$st');
      return [];
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = Task.encodeList(tasks);
    try {
      // ignore: avoid_print
      print('StorageService.saveTasks: saving ${encoded.length} bytes');
      await prefs.setString(_tasksKey, encoded);
      // ignore: avoid_print
      print('StorageService.saveTasks: saved successfully');
    } catch (e, st) {
      // ignore: avoid_print
      print('StorageService.saveTasks: error saving -> $e\n$st');
      rethrow;
    }
  }

  // Blocks
  static Future<List<Block>> loadBlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_blocksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      // ignore: avoid_print
      print('StorageService.loadBlocks: raw length=${raw.length}');
      return Block.decodeList(raw);
    } catch (e, st) {
      // ignore: avoid_print
      print('StorageService.loadBlocks: failed -> $e\n$st');
      return [];
    }
  }

  static Future<void> saveBlocks(List<Block> blocks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = Block.encodeList(blocks);
    try {
      // ignore: avoid_print
      print('StorageService.saveBlocks: saving ${encoded.length} bytes');
      await prefs.setString(_blocksKey, encoded);
      // ignore: avoid_print
      print('StorageService.saveBlocks: saved successfully');
    } catch (e, st) {
      // ignore: avoid_print
      print('StorageService.saveBlocks: error saving -> $e\n$st');
      rethrow;
    }
  }
}
