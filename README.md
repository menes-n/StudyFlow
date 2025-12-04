# StudyFlow

StudyFlow, günlük çalışma düzeninizi düzenlemenize ve takip etmenize yardımcı olan hafif, modern bir Flutter uygulamasıdır. Görev yönetimi, basit pomodoro zamanlayıcı, tarih bazlı planlama ve önceliklendirme gibi özellikleri içerir.

**Bu proje**: kişisel çalışma alışkanlıklarını kaydetmek, görevleri tarihlendirmek ve odaklanma seanslarını (Pomodoro) hızlıca başlatmak için tasarlanmıştır.

**Öne Çıkan Özellikler**
- **Görev Bölümleri**: BUGÜN, YARIN, HAFTA, BU AY, DAHA SONRA ve TAMAMLANDI şeklinde düzenlenmiş akordiyon listeleri.
- **Genel İlerleme Göstergesi**: Tüm görevlerin tamamlanma yüzdesini ve toplam/bitmiş sayısını gösterir.
- **Pomodoro Zamanlayıcı**: Hızlı pomodoro başlatma ve süre seçim çipleri (koyu/açık mod uyumlu).
- **Gelişmiş Tarih Desteği**: Görev ekleme/düzenleme sırasında geçmiş tarihler seçimi engellenir; geçmiş görevleri toplu taşımak için uyarı/migration desteği bulunur.
- **Tema Desteği**: Açık / koyu mod uyumlu renkler ve okunabilirlik düzeltmeleri.

**Ekran Görüntüleri**

> Yerel geliştirme ortamınızda `flutter run` ile uygulamayı çalıştırdıktan sonra ekran görüntüleri burada görüntülenecektir. (Assets altında logo ve örnek görseller eklenmişse otomatik olarak gösterilebilir.)

---

**Hızlı Başlangıç**

Gereksinimler:
- `Flutter` SDK (stable kanal) kurulu olmalı.
- Cihaz/emülatör hazır olmalı (Windows, Android, iOS, macOS, Linux desteklenir).

Kopyala ve çalıştır:

```powershell
git clone <repo-url>
cd studyflow
flutter pub get
flutter analyze
flutter run
```

Not: Windows üzerinde geliştiriyorsanız hedefi belirtmek için `flutter run -d windows` kullanabilirsiniz.

**Yapı ve Test Komutları**
- Bağımlılıkları güncelle: `flutter pub get`
- Statik analiz: `flutter analyze`
- Uygulamayı çalıştır: `flutter run`

---

**Geliştirici Notları**
- `AppState` (`lib/state/app_state.dart`) uygulamanın ana durum deposudur — görevleri, rutinleri ve blokları burada saklanır.
- Görev tarihleri `dueDateMillis` olarak tutulur — uygulama yerel zamana (`toLocal()`) dikkat ederek tarih kontrolü yapar.
- Pomodoro ekranı: `lib/screens/adhoc_pomodoro.dart` — çipler ve koyu mod uyumu iyileştirildi.

---

**Katkıda Bulunma**

1. Fork'layın.
2. Yeni bir branch oluşturun: `git checkout -b feature/isim`
3. Değişiklikleri yapın ve commit edin.
4. PR açın ve kısa açıklama ekleyin.

Lütfen büyük değişiklikler için önce bir issue açın ve tasarım/arayüz kararlarını tartışalım.

---

**Sık Karşılaşılan Sorunlar**
- "Göreve yanlışlıkla geçmiş tarih atadım": Uygulama, geçmiş tarihli görevleri tespit edip toplu olarak bugüne taşıma seçeneği sunar (Ana ekranda gösterilir).
- Koyu modda okunamayan metinler: `lib/screens/*` içinde theme-aware renkler kullanıldı; eğer hâlâ okunma sorunu varsa lütfen issue açın.

---

**Lisans & İletişim**
- Bu proje MIT lisansı ile dağıtılabilir (isteğe bağlı olarak lisans ekleyebilirim).
- Sorular/geri bildirim için repo issues bölümünü kullanın.

Teşekkürler — iyi çalışmalar ve odaklanmalar!
