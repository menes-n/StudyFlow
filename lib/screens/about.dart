// Hakkında Ekranı

import 'package:flutter/material.dart';

// Uygulama hakkında bilgi gösterir
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Genel: Hakkında ekranı Scaffold içerir; uygulama logosu, açıklama, özellikler ve teknoloji bilgisi gösterir
    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // Uygulama logosu: görsel tanıtım ikonu
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'StudyFlow',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('v1.0.0', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Uygulamadan bölümü: uygulama açıklaması ve amaçları. Uygullamanın amacı, kullanıcılara etkili bir görev yönetimi sistemi sunmaktır
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uygulamadan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'StudyFlow, geliştiricilerin ve öğrencilerin günlük çalışma rutinlerini düzenli ve verimli bir şekilde takip edebilmeleri için tasarlanmış sade ama işlevsel bir mobil uygulamadır.\n\n'
                      'Bu uygulama, Argena Tech Labs Mobile Developer mülakat projesi kapsamında geliştirilmiştir. Kullanıcılar görev ekleyebilir, düzenleyebilir ve tamamlayabilir; ilerlemelerini görsel göstergelerle takip edebilirler. Günlük ve haftalık görünüm seçenekleriyle esnek bir planlama deneyimi sunar.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Özellikler bölümü: uygulamanın sunduğu tüm işlevsel özellikler burada listelenir
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Özellikler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _featureItem(
                      context,
                      Icons.task_alt,
                      'Görev yönetimi (ekleme, düzenleme, tamamlama)',
                    ),
                    _featureItem(
                      context,
                      Icons.calendar_view_day,
                      'Günlük/haftalık görünüm',
                    ),
                    _featureItem(
                      context,
                      Icons.trending_up,
                      'İlerleme göstergesi (tamamlanma oranı)',
                    ),
                    _featureItem(
                      context,
                      Icons.palette,
                      'Basit ve kullanıcı dostu arayüz',
                    ),
                    _featureItem(
                      context,
                      Icons.storage,
                      'Yerel veri saklama desteği',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Teknoloji bölümü: uygulamanın geliştirildiği teknoloji yığınını ve mimari bilgisi
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teknoloji',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Uygulama, Flutter ile geliştirilmiş olup, anlaşılır klasör yapısı, uygun state yönetimi ve responsive tasarım ilkeleriyle yapılandırılmıştır.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Telif hakkı ve lisans bilgisi
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2025 StudyFlow',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tüm hakları saklıdır',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
