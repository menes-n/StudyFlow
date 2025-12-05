import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/app_state.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final bool autoStart;
  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.autoStart = false,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  Task? _task;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = Provider.of<AppState>(context, listen: false);
    if (_task == null) {
      final found = app.tasks.where((t) => t.id == widget.taskId).toList();
      if (found.isNotEmpty) _task = found.first;
    }
    if (widget.autoStart && !_isRunning && _task != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startTimer(app);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(AppState app) {
    if (_task == null) return;
    setState(() {
      if (_remainingSeconds <= 0) {
        _remainingSeconds = _task!.pomodoroMinutes * 60;
      }
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, 999999);
        if (_remainingSeconds == 0) {
          _completeSession(app);
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _completeSession(AppState app) async {
    _stopTimer();
    if (_task == null) return;
    _task!.pomodoroSessionsCompleted += 1;
    _task!.lastSessionMillis = DateTime.now().millisecondsSinceEpoch;
    final messenger = ScaffoldMessenger.of(context);
    await app.updateTask(_task!);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Pomodoro tamamlandı')),
    );
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Görev')),
        body: const Center(child: Text('Görev bulunamadı')),
      );
    }

    final totalSessions = _task!.pomodoroSessionsCompleted;

    return Scaffold(
      appBar: AppBar(title: Text(_task!.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_task!.notes != null) Text(_task!.notes!),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'Oturum süresi: ${_task!.pomodoroMinutes} dk',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _format(_remainingSeconds),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Duraklat' : 'Başlat'),
                        onPressed: () {
                          if (_isRunning) {
                            _stopTimer();
                          } else {
                            _startTimer(app);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.stop),
                        label: const Text('Sıfırla'),
                        onPressed: () {
                          _stopTimer();
                          setState(() {
                            _remainingSeconds = _task!.pomodoroMinutes * 60;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Tamamlanan oturumlar: $totalSessions'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            Text('Detaylar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Priority: ${_task!.priority.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text(
              'Due: ${_task!.dueDateMillis != null ? DateTime.fromMillisecondsSinceEpoch(_task!.dueDateMillis!).toLocal().toString() : "—"}',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  _task!.completed = true;
                  await app.updateTask(_task!);
                  if (!mounted) return;
                  navigator.pop();
                },
                child: const Text('İşi Tamamla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
