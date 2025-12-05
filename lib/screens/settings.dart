// Ayarlar Ekranı

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_state.dart';

// Uygulama ayarlarını yönetir
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// Ayarlar ekranı durum widget'ı
class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  // Pomodoro ayarları: çalışma ve mola süreleri (dakika)
  int _pomodoroMinutes = 25;
  int _breakMinutes = 5;

  // Bildirim ve görünüm ayarları
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Ayarları depolamadan yükle
    _loadSettings();
  }

  // initState açıklama: SharedPreferences'dan saklanan ayarlar yüklenir

  // Depolamadan ayarları yükle: SharedPreferences'dan varsayılan/kaydedilmiş değerleri oku
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // Depolanmış ayarları veya varsayılan değerleri al
      _pomodoroMinutes = _prefs.getInt('pomodoro_minutes') ?? 25;
      _breakMinutes = _prefs.getInt('break_minutes') ?? 5;
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = _prefs.getBool('sound_enabled') ?? true;
      _darkModeEnabled = _prefs.getBool('dark_mode_enabled') ?? false;
      _isLoading = false;
    });
  }

  // Ayarı depolamaya kaydet: int veya bool değerleri SharedPreferences'a yaz
  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Genel: Ayarlar ekranı ListView ve section başlıkları ile organize edilmiş
    // Bölümler: Pomodoro, Bildirimler, Görünüm, Hakkında
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ayarlar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          // Pomodoro bölümü: çalışma ve mola süresi ayarları
          _buildSectionHeader('Pomodoro'),
          _buildSliderTile(
            title: 'Çalışma Süresi',
            subtitle: '$_pomodoroMinutes dakika',
            value: _pomodoroMinutes.toDouble(),
            min: 5,
            max: 60,
            onChanged: (value) async {
              setState(() => _pomodoroMinutes = value.toInt());
              await _saveSetting('pomodoro_minutes', value.toInt());
            },
          ),
          _buildSliderTile(
            title: 'Mola Süresi',
            subtitle: '$_breakMinutes dakika',
            value: _breakMinutes.toDouble(),
            min: 1,
            max: 30,
            onChanged: (value) async {
              setState(() => _breakMinutes = value.toInt());
              await _saveSetting('break_minutes', value.toInt());
            },
          ),
          const Divider(),

          // Bildirim bölümü: bildirim ve ses ayarları
          _buildSectionHeader('Bildirimler'),
          _buildSwitchTile(
            title: 'Bildirimleri Etkinleştir',
            subtitle: 'Görevler hakkında bildirim al',
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await _saveSetting('notifications_enabled', value);
            },
          ),
          _buildSwitchTile(
            title: 'Ses Efektleri',
            subtitle: 'Pomodoro tamamlandığında ses oynat',
            value: _soundEnabled,
            onChanged: (value) async {
              setState(() => _soundEnabled = value);
              await _saveSetting('sound_enabled', value);
            },
          ),
          const Divider(),

          // Görünüm bölümü: tema seçimi
          _buildSectionHeader('Görünüm'),
          _buildSwitchTile(
            title: 'Koyu Mod',
            subtitle: 'Koyu tema etkinleştir',
            value: _darkModeEnabled,
            onChanged: (value) async {
              final app = context.read<AppState>();
              setState(() => _darkModeEnabled = value);
              await _saveSetting('dark_mode_enabled', value);
              await app.setDarkMode(value);
            },
          ),
          const Divider(),

          // Hakkında bölümü: uygulama versiyonu ve açıklaması
          _buildSectionHeader('Hakkında'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StudyFlow v1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Verimli görev yönetimi ve Pomodoro tekniği',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bölüm başlığı widget'ı: ayarlar bölümlerini görsel olarak ayırır
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  // Switch tile widget'ı: boolean ayarları için on/off anahtar gösterir
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  // Slider tile widget'ı: sayısal ayarları (dakika vb.) için kaydırma çubuğu gösterir
  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
