// Rutin Ekleme/Düzenleme Ekranı

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/routine.dart';
import '../state/app_state.dart';

// Yeni rutin eklemek veya mevcut rutini düzenlemek için ekran
class AddRoutineScreen extends StatefulWidget {
  final Routine? routine;

  const AddRoutineScreen({super.key, this.routine});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

// Rutin ekleme/düzenleme ekranı durum widget'ı
class _AddRoutineScreenState extends State<AddRoutineScreen> {
  // Form anahtarı
  final _formKey = GlobalKey<FormState>();
  // Metin giriş kontrolcüleri
  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '25');
  // Seçilen renk
  int _color = Colors.indigo.toARGB32();

  // Düzenleme mi yoksa ekleme mi
  bool get isEdit => widget.routine != null;

  @override
  void initState() {
    super.initState();
    // Düzenleme modunda ise mevcut verileri yükle
    if (isEdit) {
      final r = widget.routine!;
      _titleCtrl.text = r.title;
      _durationCtrl.text = r.durationMinutes.toString();
      _color = r.colorValue;
    }
  }

  @override
  void dispose() {
    // Kontrolcüleri temizle
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  // Rutin kaydetme işlemi
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Form verilerini al
    final title = _titleCtrl.text.trim();
    final duration = int.tryParse(_durationCtrl.text) ?? 25;
    final app = Provider.of<AppState>(context, listen: false);

    try {
      // Düzenleme veya yeni ekleme işlemi yap
      if (isEdit) {
        final r = widget.routine!;
        r.title = title;
        r.durationMinutes = duration;
        r.colorValue = _color;
        // Güncellenmiş rutini kaydet
        await app.updateRoutine(r);
      } else {
        // Yeni rutin oluştur
        final r = Routine.create(
          title: title,
          durationMinutes: duration,
          colorValue: _color,
        );

        // Yeni rutini uygulama state'e ekle
        await app.addRoutine(r);
        // Başarı ise ekrandan geri dön
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Hata yakalama: kullanıcıya SnackBar ile bildir, konsola yazma
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rutin kaydedilirken hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: sayfa düzeni (AppBar, Body, Actions)
    // AppBar: başlık ve kaydetme/güncelleme butonu
    // Body: form alanları (başlık, süre, renk)
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Rutin Düzenle' : 'Rutin Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Süre (dakika)'),
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Dakika giriniz';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isEdit ? 'Renk (değiştir)' : 'Renk:',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildChip(Colors.indigo),
                  _buildChip(Colors.teal),
                  _buildChip(Colors.orange),
                  _buildChip(Colors.pink),
                  _buildChip(Colors.green),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(isEdit ? 'Güncelle' : 'Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(Color c) {
    final selected = c.toARGB32() == _color;
    return ChoiceChip(
      label: const SizedBox.shrink(),
      selected: selected,
      onSelected: (_) => setState(() => _color = c.toARGB32()),
      avatar: CircleAvatar(backgroundColor: c),
      selectedColor: c.withAlpha((0.9 * 255).round()),
    );
  }

  Widget _buildChip(Color c) => _buildColorPicker(c);
}
