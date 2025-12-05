// Planlayıcı Ekranı

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/task.dart';
import 'add_task.dart';

// Görevleri tarihe göre planlamak için ekran
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

// Planlayıcı ekranı durum widget'ı
class _PlannerScreenState extends State<PlannerScreen> {
  // Görünüm modu (takvim, liste vb.)
  int _viewMode = 0;
  // Seçilen tarih
  DateTime _selectedDate = DateTime.now();

  // Yeni görev ekleme ekranını aç
  void _openAddTask() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen()));
  }

  // _openAddTask: Yeni görev ekleme akışını başlatır (AddTaskScreen'i açar)

  @override
  Widget build(BuildContext context) {
    // Planner Scaffold: tarih seçimi, görünüm modu ve görev listesi
    final app = context.watch<AppState>();

    final tasksForDate = app.tasksForDate(_selectedDate);

    // Ekranın UI'ı oluştur
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planlayıcı'),
        actions: [
          // Debug alanı: geliştirici modunda görev sayısını gösterir
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(child: Text('tasks=${app.tasks.length}')),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ToggleButtons(
                  isSelected: [_viewMode == 0, _viewMode == 1],
                  onPressed: (idx) => setState(() => _viewMode = idx),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Günlük'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Haftalık'),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _selectedDate = d);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Tarih'),
                ),
              ],
            ),
          ),

          if (_viewMode == 1)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                // Haftalık görünümde gün kartlarını göster
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: 7,
                itemBuilder: (context, idx) {
                  final d = DateTime.now()
                      .subtract(Duration(days: DateTime.now().weekday - 1))
                      .add(Duration(days: idx));
                  final isSelected =
                      d.year == _selectedDate.year &&
                      d.month == _selectedDate.month &&
                      d.day == _selectedDate.day;
                  // Seçilen tarıh için görev sayısını al
                  final count = app.tasksForDate(d).length;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 110,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.04 * 255).round()),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _weekdayName(d.weekday),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${d.day}/${d.month}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$count görev',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          Expanded(
            child: tasksForDate.isEmpty
                ? // Görev yoksa mesaj göster
                  Center(child: Text('Bu tarihte görev yok'))
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasksForDate.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final t = tasksForDate[i];
                      return Card(
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: t.notes == null ? null : Text(t.notes!),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_priorityLabel(t.priority)),
                              const SizedBox(height: 6),
                              Text('${t.blockIds.length} blok'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _weekdayName(int w) {
    const names = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return names[(w - 1) % 7];
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.high:
        return 'Yüksek';
      case Priority.medium:
        return 'Orta';
      case Priority.low:
        return 'Düşük';
    }
  }
}
