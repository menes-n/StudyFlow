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
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _titleCtl.addListener(_onPreviewUpdate);
    _notesCtl.addListener(_onPreviewUpdate);
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen - 1)}…';
  }

  @override
  void dispose() {
    _titleCtl.removeListener(_onPreviewUpdate);
    _notesCtl.removeListener(_onPreviewUpdate);
    _titleCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  void _onPreviewUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _saved = false;
    });

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
    setState(() {
      _isSaving = false;
      _saved = true;
    });

    // show a short success SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Görev kaydedildi'),
        duration: Duration(milliseconds: 900),
      ),
    );

    // brief delay so user can see the success state, then close
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _quickDateButton(String label, int daysOffset) {
    final now = DateTime.now();
    final targetDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysOffset));
    final isSelected =
        _due != null &&
        _due!.year == targetDate.year &&
        _due!.month == targetDate.month &&
        _due!.day == targetDate.day;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : null,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      onPressed: () => setState(() => _due = targetDate),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color priorityColor(Priority p) {
      switch (p) {
        case Priority.high:
          return const Color(0xFFD32F2F); // red
        case Priority.medium:
          return const Color(0xFFF57C00); // orange
        case Priority.low:
          return const Color(0xFF2E7D32); // green
      }
    }

    // Return RGB components for a priority color so we can create translucent variants
    List<int> priorityRgb(Priority p) {
      switch (p) {
        case Priority.high:
          return [211, 47, 47];
        case Priority.medium:
          return [245, 124, 0];
        case Priority.low:
          return [46, 125, 50];
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Görev')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _titleCtl,
                                decoration: InputDecoration(
                                  labelText: 'Başlık',
                                  prefixIcon: const Icon(Icons.task, size: 28),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Başlık gerekli'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesCtl,
                          decoration: InputDecoration(
                            labelText: 'Notlar',
                            prefixIcon: const Icon(Icons.note),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),

                        // Priority chips
                        Text(
                          'Öncelik',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: Priority.values.map((p) {
                            final selected = p == _priority;
                            return ChoiceChip(
                              label: Text(p.turkishName),
                              selected: selected,
                              onSelected: (sel) {
                                if (!sel) return;
                                setState(() => _priority = p);
                              },
                              backgroundColor: selected
                                  ? Color.fromRGBO(
                                      priorityRgb(p)[0],
                                      priorityRgb(p)[1],
                                      priorityRgb(p)[2],
                                      0.12,
                                    )
                                  : null,
                              selectedColor: Color.fromRGBO(
                                priorityRgb(p)[0],
                                priorityRgb(p)[1],
                                priorityRgb(p)[2],
                                0.18,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? priorityColor(p)
                                    : Colors.grey.shade300,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Quick date buttons
                        Text(
                          'Hızlı Seçim',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _quickDateButton('Bugün', 0),
                            _quickDateButton('Yarın', 1),
                            _quickDateButton('1 Hafta', 7),
                            _quickDateButton('2 Hafta', 14),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Date picker row
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _due == null
                                    ? 'Bitiş tarihi yok'
                                    : '${_due!.day}/${_due!.month}/${_due!.year}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.edit_calendar),
                              label: const Text('Tarih seç'),
                              onPressed: () async {
                                final now = DateTime.now();
                                final today = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                );
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _due ?? today,
                                  firstDate: today,
                                  lastDate: DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  ).add(const Duration(days: 365)),
                                );
                                if (d != null) setState(() => _due = d);
                              },
                            ),
                            if (_due != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _due = null),
                                tooltip: 'Tarihi temizle',
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Live preview
                        Text(
                          'Önizleme',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 8,
                              height: 48,
                              decoration: BoxDecoration(
                                color: priorityColor(_priority),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            title: Text(
                              _titleCtl.text.isEmpty
                                  ? 'Başlık girilmedi'
                                  : _truncate(_titleCtl.text, 60),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: _notesCtl.text.isEmpty
                                ? null
                                : Text(_truncate(_notesCtl.text, 100)),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (_due != null)
                                  Text(
                                    '${_due!.day}/${_due!.month}/${_due!.year}',
                                  ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color.fromRGBO(
                                      priorityRgb(_priority)[0],
                                      priorityRgb(_priority)[1],
                                      priorityRgb(_priority)[2],
                                      0.12,
                                    ),
                                  ),
                                  child: Text(
                                    _priority.turkishName,
                                    style: TextStyle(
                                      color: priorityColor(_priority),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isSaving ? null : _submit,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: _isSaving
                                  ? SizedBox(
                                      key: ValueKey('progress'),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : _saved
                                  ? const Row(
                                      key: ValueKey('done'),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check),
                                        SizedBox(width: 8),
                                        Text('Kaydedildi'),
                                      ],
                                    )
                                  : const Row(
                                      key: ValueKey('save'),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.save),
                                        SizedBox(width: 8),
                                        Text('Kaydet'),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
