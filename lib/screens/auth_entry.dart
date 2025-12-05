// Giriş/Kayıt Ekranı Seçimi

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

// Giriş veya kayıt seçeneğini gösterir
class AuthEntry extends StatelessWidget {
  const AuthEntry({super.key});

  @override
  Widget build(BuildContext context) {
    // Giriş/Kayıt seçim ekranı Scaffold: logo ve iki seçenek
    // - Logo: uygulama görsel tanıtımı
    // - Butonlar: kullanıcıyı giriş veya kayıt ekranına yönlendirir
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş / Kayıt')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Uygulama logosu gösterimi
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hoş geldiniz',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hesabınızı kullanarak giriş yapın veya yeni hesap oluşturun.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                // Giriş butonu: Login ekranına yönlendirir
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Kayıt butonu: Register ekranına yönlendirir
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      'Kaydol',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
