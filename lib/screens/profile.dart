// Profil Ekranı

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../state/app_state.dart';
import 'auth_entry.dart';

// Kullanıcı profil bilgilerini gösterir
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Profil ekranı durum widget'ı
class _ProfileScreenState extends State<ProfileScreen> {
  // Kullanıcı verilerini asenkron olarak getiren Future
  late Future<Map<String, String>> _userDataFuture;
  // Metin giriş kontrolcüleri: profil düzenleme formu için
  late TextEditingController _usernameCtl;
  late TextEditingController _emailCtl;
  // Düzenleme modu: true ise form alanları düzenlenebilir olur
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _usernameCtl = TextEditingController();
    _emailCtl = TextEditingController();
    // Kullanıcı verilerini yükle
    _userDataFuture = _loadUserData();
  }

  // initState açıklama: kontrolcüler başlatılır ve mevcut kullanıcı verileri yüklenir

  // Depolamadan kullanıcı verilerini yükle
  Future<Map<String, String>> _loadUserData() async {
    // Kullanıcı bilgilerini depolamadan al
    final username = await AuthService.instance.getUsername();
    final email = await AuthService.instance.getEmail();
    // Kontrolcüleri doldur
    _usernameCtl.text = username;
    _emailCtl.text = email;
    return {'username': username, 'email': email};
  }

  // _loadUserData: SharedPreferences'dan kullanıcı bilgilerini okur ve kontrolcüleri günceller

  // Profili kaydet
  Future<void> _saveProfile() async {
    // Güncellenmiş verileri depolamaya kaydet
    await AuthService.instance.setUsername(_usernameCtl.text);
    await AuthService.instance.setEmail(_emailCtl.text);

    if (!mounted) return;
    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil güncellendi'),
        duration: Duration(milliseconds: 900),
      ),
    );

    // Düzenleme modundan çık
    setState(() => _isEditing = false);
    // Verileri yeniden yükle
    _userDataFuture = _loadUserData();
  }

  // _saveProfile: Girilen bilgileri kalıcı depolamaya kaydeder ve kullanıcıya bildirim gösterir

  // Çıkış işlemi
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthEntry()),
        (route) => false,
      );
    }
  }

  // _logout: Kullanıcıdan onay alır, çıkış yapar ve yetkilendirme giriş ekranına yönlendirir

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Profil ekranı Scaffold: kullanıcı bilgileri ve eylemler
    // Body: profil kartı, düzenleme formları ve çıkış butonu
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Map<String, String>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _usernameCtl.text,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _emailCtl.text,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Bilgileri',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          if (!_isEditing)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: const Text('Kullanıcı Adı'),
                                  subtitle: Text(_usernameCtl.text),
                                  dense: true,
                                ),
                                const SizedBox(height: 8),
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: const Text('E-posta'),
                                  subtitle: Text(_emailCtl.text),
                                  dense: true,
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _usernameCtl,
                                  decoration: InputDecoration(
                                    labelText: 'Kullanıcı Adı',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _emailCtl,
                                  decoration: InputDecoration(
                                    labelText: 'E-posta',
                                    prefixIcon: const Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_isEditing)
                                TextButton(
                                  onPressed: () {
                                    _usernameCtl.text =
                                        snapshot.data?['username'] ?? '';
                                    _emailCtl.text =
                                        snapshot.data?['email'] ?? '';
                                    setState(() => _isEditing = false);
                                  },
                                  child: const Text('İptal'),
                                ),
                              const SizedBox(width: 8),
                              if (_isEditing)
                                ElevatedButton.icon(
                                  onPressed: _saveProfile,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Kaydet'),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      setState(() => _isEditing = true),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Düzenle'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'İstatistikler',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Consumer<AppState>(
                            builder: (context, appState, _) {
                              final completedCount = appState.tasks
                                  .where((t) => t.completed)
                                  .length;
                              final totalCount = appState.tasks.length;

                              return Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.check_circle),
                                    title: const Text('Tamamlanan Görevler'),
                                    trailing: Text(
                                      '$completedCount',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    dense: true,
                                  ),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    leading: const Icon(Icons.assignment),
                                    title: const Text('Toplam Görevler'),
                                    trailing: Text(
                                      '$totalCount',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    dense: true,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
