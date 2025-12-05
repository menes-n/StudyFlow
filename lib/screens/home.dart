// Ana Ekran - Görevleri ve rutinleri gösterir

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'adhoc_pomodoro.dart';
import 'add_task.dart';
import 'edit_task.dart';
import 'profile.dart';
import 'settings.dart';
import 'about.dart';
import 'auth_entry.dart';
import '../state/app_state.dart';
import '../models/task.dart';
import '../services/auth_service.dart';

// Uygulamanın ana ekranı
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Ana ekran durum widget'ı
class _HomeScreenState extends State<HomeScreen> {
  // FAB (Floating Action Button) genişletilmiş mi
  bool _fabExpanded = false;
  // Kullanıcı bilgileri
  String _username = 'Kullanıcı';
  String _email = 'user@example.com';

  // Bölümlerin genişletilme durumları
  final Map<String, bool> _expandedSections = {
    'today': false,
    'tomorrow': false,
    'week': false,
    'month': false,
    'later': false,
    'completed': false,
  };

  @override
  void initState() {
    super.initState();
    // Kullanıcı bilgilerini yükle
    _loadUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndOfferMigratePastTasks();
    });
  }

  // initState içinde kısa açıklama: kullanıcı bilgileri ve geçmiş görev kontrolü başlatılır

  // Kullanıcı bilgilerini depolamadan yükle
  Future<void> _loadUserInfo() async {
    // Depolamadan kullanıcı bilgilerini al
    final username = await AuthService.instance.getUsername();
    final email = await AuthService.instance.getEmail();
    if (mounted) {
      // Arayüzü güncelle
      setState(() {
        _username = username;
        _email = email;
      });
    }
  }

  // Geçmiş tarihe sahip görevleri kontrol et ve taşıyı teklif et
  Future<void> _checkAndOfferMigratePastTasks() async {
    try {
      final app = context.read<AppState>();
      final now = DateTime.now();
      // Bugünün başını al
      final today = DateTime(now.year, now.month, now.day);

      // Geçmiş tarihe sahip tamamlanmamış görevleri filtrele
      final pastTasks = app.tasks.where((t) {
        if (t.dueDateMillis == null) return false;
        if (t.completed) return false;
        final d = DateTime.fromMillisecondsSinceEpoch(
          t.dueDateMillis!,
        ).toLocal();
        return d.isBefore(today);
      }).toList();

      if (pastTasks.isEmpty) return;

      // Kullanıcıdan geçmiş görevleri bugüne taşıyıp taşımayacağını sor
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Geçmiş Tarihli Görevler Bulundu'),
            content: Text(
              '${pastTasks.length} adet geçmiş tarihe sahip görev bulundu. Hepsini bugüne taşımak ister misiniz?\n\n(Not: Bu işlem geri alınamaz.)',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Taşı'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      for (final t in pastTasks) {
        final updated = Task(
          id: t.id,
          title: t.title,
          notes: t.notes,
          completed: t.completed,
          dueDateMillis: today.millisecondsSinceEpoch,
          priority: t.priority,
          blockIds: List<String>.from(t.blockIds),
          pomodoroMinutes: t.pomodoroMinutes,
          pomodoroSessionsCompleted: t.pomodoroSessionsCompleted,
          lastSessionMillis: t.lastSessionMillis,
        );
        await app.updateTask(updated);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pastTasks.length} görev bugüne taşındı.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Görevleri taşırken bir hata oluştu: '
              '${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  void _toggleSection(String section) {
    setState(() {
      for (final key in _expandedSections.keys) {
        _expandedSections[key] =
            (key == section) && !_expandedSections[section]!;
      }
    });
  }

  // Bölüm genişletme işlemi: sadece verilen bölümü açık/kapalı yapar

  Widget _buildProgressIndicator(AppState appState) {
    final allTasks = appState.tasks;
    final completedCount = allTasks.where((t) => t.completed).length;
    final totalCount = allTasks.length;
    final progress = totalCount == 0
        ? 0.0
        : (completedCount / totalCount).clamp(0.0, 1.0);

    if (totalCount == 0) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Genel İlerleme',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('0 / 0', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Henüz görev yok',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Genel İlerleme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$completedCount / $totalCount',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: width * value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.lerp(
                                      Colors.deepOrange,
                                      Colors.orange,
                                      value,
                                    )!,
                                    Color.lerp(
                                      Colors.orange,
                                      Colors.green,
                                      value,
                                    )!,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),

                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromRGBO(255, 255, 255, 0.03),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% tamamlandı',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ana ekran Scaffold: AppBar, body (bölümler, listeler) ve FAB
    // Body içinde görev bölümleri (bugün, yarın, hafta vb.) render edilir
    final app = context.watch<AppState>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = today.add(const Duration(days: 6));
    final firstOfNextMonth = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);

    final todayTasks = app.tasksForDate(today);
    final tomorrowTasks = app.tasksForDate(tomorrow);
    final weekTasks = app.tasks.where((t) {
      if (t.completed) return false;
      if (t.dueDateMillis == null) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(t.dueDateMillis!).toLocal();
      final td = DateTime(d.year, d.month, d.day);
      return !td.isBefore(today.add(const Duration(days: 1))) &&
          !td.isAfter(weekEnd) &&
          td != today &&
          td != tomorrow;
    }).toList();
    final monthTasks = app.tasks.where((t) {
      if (t.completed) return false;
      if (t.dueDateMillis == null) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(t.dueDateMillis!).toLocal();
      final td = DateTime(d.year, d.month, d.day);
      return d.year == now.year &&
          d.month == now.month &&
          td != today &&
          td != tomorrow &&
          td.isAfter(today);
    }).toList();
    final laterTasks = app.tasks.where((t) {
      if (t.completed) return false;
      if (t.dueDateMillis == null) return true;
      final d = DateTime.fromMillisecondsSinceEpoch(t.dueDateMillis!).toLocal();
      return d.isAtSameMomentAs(firstOfNextMonth) ||
          d.isAfter(firstOfNextMonth);
    }).toList();

    final completedTasks = app.tasks.where((t) => t.completed).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('StudyFlow')),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(_username),
                accountEmail: Text(_email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (!mounted) return;
                  navigator.push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ayarlar'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (!mounted) return;
                  navigator.push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Çıkış Yap'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  await AuthService.instance.setLoggedIn(false);
                  if (!mounted) return;
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthEntry()),
                    (route) => false,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Hakkında'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (!mounted) return;
                  navigator.push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                _buildProgressIndicator(app),
                const SizedBox(height: 20),

                _ExpandableSectionTile(
                  title: 'BUGÜN',
                  count: todayTasks.length,
                  color: const Color(0xFF4CAF50),
                  tasks: todayTasks,
                  isExpanded: _expandedSections['today'] ?? false,
                  onToggle: () => _toggleSection('today'),
                ),
                const SizedBox(height: 8),
                _ExpandableSectionTile(
                  title: 'YARIN',
                  count: tomorrowTasks.length,
                  color: const Color(0xFF4FC3F7),
                  tasks: tomorrowTasks,
                  isExpanded: _expandedSections['tomorrow'] ?? false,
                  onToggle: () => _toggleSection('tomorrow'),
                ),
                const SizedBox(height: 8),
                _ExpandableSectionTile(
                  title: 'HAFTA BOYUNCA',
                  count: weekTasks.length,
                  color: const Color(0xFF7986CB),
                  tasks: weekTasks,
                  isExpanded: _expandedSections['week'] ?? false,
                  onToggle: () => _toggleSection('week'),
                ),
                const SizedBox(height: 8),
                _ExpandableSectionTile(
                  title: 'BU AY',
                  count: monthTasks.length,
                  color: const Color(0xFF9C6CE0),
                  tasks: monthTasks,
                  isExpanded: _expandedSections['month'] ?? false,
                  onToggle: () => _toggleSection('month'),
                ),
                const SizedBox(height: 8),
                _ExpandableSectionTile(
                  title: 'DAHA SONRA',
                  count: laterTasks.length,
                  color: const Color(0xFFB63FCF),
                  tasks: laterTasks,
                  isExpanded: _expandedSections['later'] ?? false,
                  onToggle: () => _toggleSection('later'),
                ),
                const SizedBox(height: 8),
                _ExpandableSectionTile(
                  title: 'TAMAMLANDI',
                  count: completedTasks.length,
                  color: const Color(0xFF795548),
                  tasks: completedTasks,
                  isExpanded: _expandedSections['completed'] ?? false,
                  showCompleteButton: false,
                  onToggle: () => _toggleSection('completed'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_fabExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Yeni Görev'),
                        onTap: () {
                          final navigator = Navigator.of(context);
                          setState(() => _fabExpanded = false);
                          navigator.push(
                            MaterialPageRoute(
                              builder: (_) => const AddTaskScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.flash_on_rounded),
                        title: const Text('Hızlı Pomodoro Başlat'),
                        onTap: () {
                          setState(() => _fabExpanded = false);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AdHocPomodoroScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          FloatingActionButton(
            heroTag: 'main_fab',
            onPressed: () {
              setState(() => _fabExpanded = !_fabExpanded);
            },
            tooltip: 'Menü',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: _fabExpanded
                  ? const Icon(key: ValueKey('close'), Icons.close, size: 35)
                  : const Icon(key: ValueKey('list'), Icons.list, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSectionTile extends StatefulWidget {
  final String title;
  final int count;
  final Color color;
  final List<Task> tasks;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool showCompleteButton;

  const _ExpandableSectionTile({
    required this.title,
    required this.count,
    required this.color,
    required this.tasks,
    required this.isExpanded,
    required this.onToggle,
    this.showCompleteButton = true,
  });

  @override
  State<_ExpandableSectionTile> createState() => _ExpandableSectionTileState();
}

class _ExpandableSectionTileState extends State<_ExpandableSectionTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onToggle,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 255, 255, 0.22),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.count == 0 ? '—' : '${widget.count}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  widget.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (widget.isExpanded && widget.tasks.isNotEmpty)
          Container(
            color: widget.color.withAlpha(26),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._buildPriorityGroup(Priority.high, const Color(0xFFE53935)),

                ..._buildPriorityGroup(
                  Priority.medium,
                  const Color(0xFFFFA726),
                ),

                ..._buildPriorityGroup(Priority.low, const Color(0xFF66BB6A)),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildPriorityGroup(Priority priority, Color color) {
    final tasksInPriority = widget.tasks
        .where((t) => t.priority == priority)
        .toList();

    if (tasksInPriority.isEmpty) {
      return [];
    }
    final List<Widget> taskWidgets = tasksInPriority.map((task) {
      final app = context.read<AppState>();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          child: ListTile(
            leading: Container(
              width: 6,
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(task.title),
            subtitle: (task.notes != null && task.notes!.isNotEmpty)
                ? Text(task.notes!)
                : null,
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.showCompleteButton)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      final updatedTask = Task(
                        id: task.id,
                        title: task.title,
                        notes: task.notes,
                        completed: true,
                        dueDateMillis: task.dueDateMillis,
                        priority: task.priority,
                        blockIds: task.blockIds,
                        pomodoroMinutes: task.pomodoroMinutes,
                        pomodoroSessionsCompleted:
                            task.pomodoroSessionsCompleted,
                        lastSessionMillis: task.lastSessionMillis,
                      );
                      await app.updateTask(updatedTask);
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.orange),
                    onPressed: () async {
                      final updatedTask = Task(
                        id: task.id,
                        title: task.title,
                        notes: task.notes,
                        completed: false,
                        dueDateMillis: task.dueDateMillis,
                        priority: task.priority,
                        blockIds: task.blockIds,
                        pomodoroMinutes: task.pomodoroMinutes,
                        pomodoroSessionsCompleted:
                            task.pomodoroSessionsCompleted,
                        lastSessionMillis: task.lastSessionMillis,
                      );
                      await app.updateTask(updatedTask);
                    },
                  ),
                const SizedBox(height: 6),
                if (!task.completed)
                  IconButton(
                    icon: const Icon(Icons.timer, color: Colors.purple),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdHocPomodoroScreen(task: task),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 6),
                if (!task.completed)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      app.deleteTask(task.id);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return [
      Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            border: Border.all(color: color, width: 1.0),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: taskWidgets,
          ),
        ),
      ),
    ];
  }
}
