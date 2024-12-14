# GuidesTürkiye Frontend

GuidesTürkiye, Türkiye'nin turistik bölgeleri hakkında kapsamlı bilgiler sunan ve kullanıcıların seyahat planlamalarını kolaylaştıran bir platformdur. Bu proje, platformun **Flutter** kullanılarak geliştirilmiş mobil uygulama arayüzünü içerir.

## Özellikler

- **Çoklu Platform Desteği**: Android, iOS, Web ve masaüstü platformlarında sorunsuz çalışır.
- **Kapsamlı İçerik**: Türkiye'nin farklı bölgeleri hakkında detaylı bilgiler ve rehberlik sağlar.
- **Kullanıcı Dostu Arayüz**: Modern ve sezgisel tasarım ile kullanıcı deneyimini artırır.
- **Güncel Veriler**: Firebase entegrasyonu sayesinde sürekli güncellenen içerik sunar.

## Gereksinimler

Projeyi çalıştırmak için aşağıdaki araçların sisteminizde kurulu olması gerekmektedir:

- **Flutter SDK**: [Flutter Kurulumu](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Flutter ile birlikte gelir.
- **Android Studio veya Xcode**: Geliştirme ve emülatörler için gereklidir.
- **Firebase Hesabı**: Proje için Firebase yapılandırması gereklidir.

## Kurulum

1. **Depoyu Klonlayın**:
```bash
git clone https://github.com/muhammedaliuyanik/guidesturkiye-frontend.git
cd guidesturkiye-frontend
flutter pub get
```
## Firebase'i Yapılandırın:
- Firebase konsolunda yeni bir proje oluşturun.
- google-services.json (Android) ve GoogleService-Info.plist (iOS) dosyalarını indirin.
- Bu dosyaları ilgili platform dizinlerine yerleştirin.
```bash
flutter run
```
