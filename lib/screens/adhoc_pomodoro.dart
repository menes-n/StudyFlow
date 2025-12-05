import 'dart:async';

import 'package:flutter/material.dart';
import '../models/task.dart';

class AdHocPomodoroScreen extends StatefulWidget {
  final Task? task;

  const AdHocPomodoroScreen({super.key, this.task});

  @override
  State<AdHocPomodoroScreen> createState() => _AdHocPomodoroScreenState();
}

class _AdHocPomodoroScreenState extends State<AdHocPomodoroScreen> {
  Timer? _timer;
  bool _isRunning = false;
  bool _isWork = true;

  int _workMinutes = 25;
  final int _breakMinutes = 5;
  final int _longBreakMinutes = 15;

  final List<int> _presetWorkMinutes = [15, 20, 25, 30, 45, 60];

  int _remainingSeconds = 0;
  int _completedPomodoros = 0;

  @override
  void initState() {
    super.initState();

    if (widget.task != null && widget.task!.pomodoroMinutes > 0) {
      _workMinutes = widget.task!.pomodoroMinutes;
    }

    _resetToMode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetToMode() {
    _remainingSeconds = (_isWork ? _workMinutes : _breakMinutes) * 60;
    _isRunning = false;
    _timer?.cancel();
    setState(() {});
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds -= 1;
        }
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _isRunning = false;
          if (_isWork) {
            _completedPomodoros++;
          }

          _isWork = !_isWork;
          _remainingSeconds = (_isWork ? _workMinutes : _breakMinutes) * 60;
          _triggerAlert(
            _isWork
                ? 'Mola bitti — Çalışma zamanı'
                : 'Çalışma bitti — Mola zamanı',
          );
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _toggleStartPause() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _resetPressed() {
    _resetToMode();
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _triggerAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _startShortBreak() {
    _timer?.cancel();
    _isWork = false;
    _remainingSeconds = _breakMinutes * 60;
    _isRunning = true;
    _startTimer();
  }

  void _startLongBreak() {
    _timer?.cancel();
    _isWork = false;
    _remainingSeconds = _longBreakMinutes * 60;
    _isRunning = true;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isWork ? 'Çalışma zamanı' : 'Mola zamanı';

    final int totalSeconds = _isWork ? (_workMinutes * 60) : _breakMinutes * 60;
    final double progress = totalSeconds > 0
        ? (1.0 - (_remainingSeconds / totalSeconds).clamp(0.0, 1.0))
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Hızlı Pomodoro')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _completedPomodoros % 4
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 500,
                    height: 500,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 250,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _format(_remainingSeconds),
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_isWork ? _workMinutes : _breakMinutes} dk',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 56,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _presetWorkMinutes.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          ChoiceChip(
                            label: Text(
                              '${_presetWorkMinutes[i]} dk',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: _presetWorkMinutes[i] == _workMinutes,
                            side: BorderSide(
                              color: _presetWorkMinutes[i] == _workMinutes
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            onSelected: (sel) {
                              if (!sel) return;
                              setState(() {
                                _workMinutes = _presetWorkMinutes[i];
                                if (!_isRunning && _isWork) {
                                  _remainingSeconds = _workMinutes * 60;
                                }
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Durdur' : 'Başlat'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _toggleStartPause,
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Sıfırla'),
                    onPressed: _resetPressed,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.coffee),
                    label: const Text('Kısa Mola'),
                    onPressed: _startShortBreak,
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.free_breakfast),
                    label: const Text('Uzun Mola'),
                    onPressed: _startLongBreak,
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
