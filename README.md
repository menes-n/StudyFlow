 # StudyFlow

 StudyFlow, günlük çalışma rutininizi düzenlemenize ve odaklanma seanslarınızı takip etmenize yardımcı olan hafif, modern bir Flutter uygulamasıdır.

 Bu repository, görev yönetimi, Pomodoro desteği, kısa oyun molaları (mini oyun) ve tarih tabanlı planlama için temel bir uygulama iskeleti sağlar.

 **Öne Çıkan Özellikler**
 - Görev bölümlendirmesi: BUGÜN, YARIN, HAFTA, BU AY, DAHA SONRA, TAMAMLANDI
 - Genel ilerleme göstergesi (tamamlanan/toplam görevler)
 - Hızlı Pomodoro başlatma
 - Basit mini oyun: Yılan (MiniGame)
 - Tema desteği: Açık / Koyu mod uyumu (theme-aware renkler kullanılır)
 - Local persist: Görevler ve ayarlar cihaz üzerinde saklanır (SharedPreferences/StorageService)

 **Kısa Teknoloji Özeti**
 - Flutter (Dart) — UI & uygulama
 - Provider — basit state yönetimi (`AppState`)
 - shared_preferences (veya proje içi StorageService) — kalıcı veri

 ---

 ## Hızlı Başlangıç

 Gereksinimler
 - Flutter SDK (stable kanal) kurulu olmalı
 - Cihaz veya emülatör hazır olmalı

 Kopyala ve çalıştır (PowerShell örneği):

 ```powershell
 git clone <repo-url>
 cd studyflow
 flutter pub get
 flutter analyze
 flutter run -d windows # veya -d chrome / -d edge / -d <device id>
 ```

 Notlar
 - `flutter analyze` uygulama genelindeki potansiyel sorunları yakalamaya yardımcı olur.
 - Masaüstünde çalıştırmak için `-d windows` veya emülatör dahilinde mobil hedefleri kullanın.

 ---

 ## Geliştirme & Yapı

 - Ana uygulama giriş noktası: `lib/main.dart`
 - Ekranlar: `lib/screens/` (ör. `home.dart`, `adhoc_pomodoro.dart`, `mini_game.dart`)
 - Uygulama durumu: `lib/state/app_state.dart` (Provider ile kullanılır)
 - Modeller: `lib/models/`

 Önemli not: UI değişiklikleri yaparken `flutter analyze` ve `flutter format` kullanarak stil ve hataları düzenli olarak kontrol edin.

 ---

 ## Testler & Analiz

 - Statik analiz: `flutter analyze`
 - Kod biçimlendirme: `flutter format .`

 (Proje şu an birim testleri/ widget testleri içermiyor)

 ---

 ## Sık Karşılaşılan Sorunlar & Çözümler

 - Koyu/Açık mod görünürlük sorunları
	 - Tema bazlı renkler `ColorScheme` üzerinden seçildi. Eğer bir değer okunamıyorsa ilgili bileşenin `colorScheme` kullanımını kontrol edin (ör. `onPrimary`, `primaryContainer`).

 - Deprecation uyarıları
	 - `withOpacity` yerine `withValues(alpha: ..)` kullanımı tercih edildi (precision uyarıları nedeniyle).

 ---

 ## Katkıda Bulunma

 1. Fork'layın
 2. Yeni bir branch oluşturun: `git checkout -b feature/isim`
 3. Değişiklikleri yapın, commit edin
 4. PR açın ve kısa açıklama ekleyin

 Öneriler
 - Küçük değişiklikler için doğrudan PR gönderebilirsiniz.
 - Büyük değişiklikler veya API değişimleri için önce bir issue açın.

 ---

 ## CI / Öneriler

 Basit bir GitHub Actions iş akışı önerisi:
 - `flutter analyze` çalıştır
 - `flutter test` (testler eklendiğinde)

 ---

Teşekkürler — iyi çalışmalar ve odaklanmalar!
