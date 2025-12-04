import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../state/app_state.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;
  late TextEditingController _notesCtl;
  late Priority _priority;
  late DateTime? _due;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.task.title);
    _notesCtl = TextEditingController(text: widget.task.notes ?? '');
    _priority = widget.task.priority;
    _due = widget.task.dueDateMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.task.dueDateMillis!)
        : null;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final app = Provider.of<AppState>(context, listen: false);
    final updatedTask = Task(
      id: widget.task.id,
      title: _titleCtl.text.trim(),
      notes: _notesCtl.text.trim().isEmpty ? null : _notesCtl.text.trim(),
      completed: widget.task.completed,
      dueDateMillis: _due?.millisecondsSinceEpoch,
      priority: _priority,
      blockIds: widget.task.blockIds,
      pomodoroMinutes: widget.task.pomodoroMinutes,
      pomodoroSessionsCompleted: widget.task.pomodoroSessionsCompleted,
      lastSessionMillis: widget.task.lastSessionMillis,
    );
    // ignore: avoid_print
    print('EditTaskScreen._submit: updating ${updatedTask.title}');
    await app.updateTask(updatedTask);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görevi Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Başlık gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtl,
                decoration: const InputDecoration(labelText: 'Notlar'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Priority>(
                initialValue: _priority,
                items: const [
                  DropdownMenuItem(value: Priority.high, child: Text('Yüksek')),
                  DropdownMenuItem(value: Priority.medium, child: Text('Orta')),
                  DropdownMenuItem(value: Priority.low, child: Text('Düşük')),
                ],
                onChanged: (v) =>
                    setState(() => _priority = v ?? Priority.medium),
                decoration: const InputDecoration(labelText: 'Öncelik'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _due == null
                          ? 'Bitiş tarihi yok'
                          : '${_due!.day}/${_due!.month}/${_due!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      // ensure initialDate is within allowed range
                      DateTime initial = _due ?? today;
                      if (initial.isBefore(today)) initial = today;
                      final d = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: today,
                        lastDate: DateTime(
                          now.year,
                          now.month,
                          now.day,
                        ).add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _due = d);
                    },
                    child: const Text('Tarih seç'),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
