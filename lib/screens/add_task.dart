import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../state/app_state.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _notesCtl = TextEditingController();
  Priority _priority = Priority.medium;
  DateTime? _due;

  @override
  void dispose() {
    _titleCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final app = Provider.of<AppState>(context, listen: false);
    final t = Task.create(
      title: _titleCtl.text.trim(),
      notes: _notesCtl.text.trim().isEmpty ? null : _notesCtl.text.trim(),
      dueDateMillis: _due?.millisecondsSinceEpoch,
      priority: _priority,
    );
    // ignore: avoid_print
    print('AddTaskScreen._submit: creating ${t.title}');
    await app.addTask(t);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Görev')),
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
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _due = d);
                    },
                    child: const Text('Tarih seç'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(onPressed: _submit, child: const Text('Kaydet')),
            ],
          ),
        ),
      ),
    );
  }
}
