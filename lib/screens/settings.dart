import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  int _pomodoroMinutes = 25;
  int _breakMinutes = 5;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _pomodoroMinutes = _prefs.getInt('pomodoro_minutes') ?? 25;
      _breakMinutes = _prefs.getInt('break_minutes') ?? 5;
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = _prefs.getBool('sound_enabled') ?? true;
      _darkModeEnabled = _prefs.getBool('dark_mode_enabled') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
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
