# Kratos Uzaktan Destek paketleri

Bu dal üç imzasız test paketi üretir:

- `Kratos-Musteri-Destek-Windows-x64.exe`: Kurulum gerektirmeyen, yalnızca gelen bağlantıları kabul eden müşteri uygulaması.
- `Kratos-Teknisyen-Windows-x64.exe`: Yalnızca giden bağlantı başlatan Windows teknisyen uygulaması.
- `Kratos-Teknisyen-macOS-Apple-Silicon.dmg` ve `Kratos-Teknisyen-macOS-Intel.dmg`: macOS teknisyen uygulamaları.

Paketler `.github/workflows/kratos-packages.yml` iş akışından elle oluşturulur. Her paketin yanında SHA-256 doğrulama dosyası bulunur.

## Müşteri uygulaması

Müşteri uygulaması taşınabilir çalışır; kurulum sihirbazı açmaz. Uygulama yalnızca gelen destek bağlantıları için kullanılabilir. Aşağıdaki yetkiler uygulama seviyesinde varsayılan açık ve sabittir:

- Klavye ve fare
- Pano
- Dosya aktarımı
- Ses

Bağlantı sekiz karakterlik geçici parola ile doğrulanır. Windows, işletim sistemi seviyesinde UAC onayı isteyebilir.

## Teknisyen uygulamaları

Teknisyen sürümleri yalnızca uzak cihaza bağlantı başlatır. Windows paketi taşınabilir `.exe`, macOS paketleri sürükle-bırak `.dmg` biçimindedir.

## Dağıtım notları

İlk çıktılar kod imzasızdır. Windows SmartScreen ve macOS Gatekeeper ilk açılışta uyarı gösterebilir. Genel kullanıma geçmeden önce Windows Authenticode imzası ile Apple Developer ID imzası/notarizasyonu eklenmelidir.

Bu proje RustDesk tabanlıdır ve GNU AGPL-3.0 lisansına tabidir. Dağıtılan sürümlerin karşılık gelen kaynak koduna müşterilerin erişebilmesi gerekir.
