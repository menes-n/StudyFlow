// Giriş Ekranı

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home.dart';

// Kullanıcı giriş yapmasını sağlayan ekran
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Giriş ekranı durum widget'ı
class _LoginScreenState extends State<LoginScreen> {
  // Metin alanları için kontrolcüler: kullanıcı adı, e-posta, parola
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();

  // Yüklenme ve hata durumu: buton devre dışı bırakma ve hata mesajı gösterimi
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    // Kaynakları temizle: TextEditingController'ları serbest bırak
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  // Giriş işlemini gerçekleştir: doğrulama, local kaydetme ve yönlendirme
  Future<void> _login() async {
    // Form doğrulaması: boş alan kontrolü
    if (_usernameCtl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Kullanıcı adı boş olamaz!');
      return;
    }

    if (_emailCtl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'E-posta boş olamaz!');
      return;
    }

    if (_passCtl.text.isEmpty) {
      setState(() => _errorMessage = 'Parola boş olamaz!');
      return;
    }

    // Hata temizleme ve yükleme durumunu aktif etme
    setState(() => _errorMessage = null);
    setState(() => _loading = true);

    // Küçük bir gecikme ile giriş animasyonu hissettir
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Kullanıcı bilgilerini SharedPreferences üzerinden sakla
    await AuthService.instance.setUsername(_usernameCtl.text.trim());
    await AuthService.instance.setEmail(_emailCtl.text.trim());
    await AuthService.instance.setLoggedIn(true);

    if (!mounted) return;
    // Ana ekrana git ve bu ekranı geri dönüş yığınına ekleme
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Genel: bu ekran bir Scaffold içerir; AppBar geri butonu, body ise formu barındırır
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: color),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(''),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Günlük çalışma düzenini takip et ve gelişimini gör.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Eğer bir hata mesajı varsa burada gösterilir
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Kullanıcı adı alanı
                        TextField(
                          controller: _usernameCtl,
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: Icon(Icons.person),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 12),

                        // E-posta alanı
                        TextField(
                          controller: _emailCtl,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),

                        // Parola alanı (gizli)
                        TextField(
                          controller: _passCtl,
                          decoration: const InputDecoration(
                            labelText: 'Parola',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),

                        // Giriş butonu: _login metodunu tetikler, yükleme gösterir
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _loading ? null : _login,
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Giriş Yap'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Parola unutma bağlantısı (henüz implement edilmedi)
                        TextButton(
                          onPressed: () {},
                          child: const Text('Parolanızı mı unuttunuz?'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
