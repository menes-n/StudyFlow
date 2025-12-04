import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'auth_entry.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Show splash for a short duration, then route based on auth state
    Future.delayed(const Duration(milliseconds: 900)).then((_) async {
      if (!mounted) return;
      final loggedIn = await AuthService.instance.isLoggedIn();
      if (!mounted) return;
      if (loggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthEntry()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 16),
              Text(
                'StudyFlow',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kahveni hazırla, görevler sıraya girdi.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
