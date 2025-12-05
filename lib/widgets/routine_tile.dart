import 'dart:async';

import 'package:flutter/material.dart';
import '../models/routine.dart';
import '../screens/add_routine.dart';

class RoutineTile extends StatefulWidget {
  final Routine routine;
  final ValueChanged<Routine> onUpdate;
  final ValueChanged<String> onDelete;

  const RoutineTile({
    super.key,
    required this.routine,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<RoutineTile> createState() => _RoutineTileState();
}

class _RoutineTileState extends State<RoutineTile> {
  bool _running = false;
  late Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  void _stop() {
    _stopwatch.stop();
    _timer?.cancel();
    final seconds = _stopwatch.elapsed.inSeconds;
    final minutes = (seconds / 60).round();
    final r = widget.routine;
    r.totalMinutes += minutes;
    r.lastSessionMillis = DateTime.now().millisecondsSinceEpoch;
    widget.onUpdate(r);
    _stopwatch.reset();
    setState(() => _running = false);
  }

  Future<void> _confirmDelete() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Rutini silmek istediğinize emin misiniz?'),
          content: const Text('Bu rutin kaldırılacaktır.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Sil'),
            ),
          ],
        ),
      );
      if (ok == true && mounted) widget.onDelete(widget.routine.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.routine;
    final last = r.lastSessionMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(r.lastSessionMillis!)
        : null;

    final double goalProgress = r.durationMinutes > 0
        ? (r.totalMinutes / r.durationMinutes).clamp(0.0, 1.0)
        : 0.0;
    final int runningSeconds = _running ? _stopwatch.elapsed.inSeconds : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(radius: 22, backgroundColor: Color(r.colorValue)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: r.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${r.durationMinutes}m',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: goalProgress,
                        minHeight: 6,
                        valueColor: AlwaysStoppedAnimation(Color(r.colorValue)),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (last != null)
                          Expanded(
                            child: Text(
                              'Son: ${last.toLocal()}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (_running)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Şimdi: ${_formatRunning(runningSeconds)}',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          'Toplam: ${r.totalMinutes}m',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((0.08 * 255).round()),
                    child: IconButton(
                      icon: Icon(
                        _running ? Icons.stop : Icons.play_arrow,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => _running ? _stop() : _start(),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: r.completed,
                        onChanged: (v) {
                          r.completed = v ?? false;
                          widget.onUpdate(r);
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'delete') {
                            _confirmDelete();
                            return;
                          }
                          if (v == 'edit') {
                            WidgetsBinding.instance.addPostFrameCallback((
                              _,
                            ) async {
                              if (!mounted) return;
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddRoutineScreen(routine: widget.routine),
                                ),
                              );
                            });
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Düzenle'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Sil'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRunning(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min > 0) return '${min}m ${sec}s';
    return '${sec}s';
  }
}
