// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class LTr extends L {
  LTr([String locale = 'tr']) : super(locale);

  @override
  String get commonRefresh => 'Yenile';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonCreate => 'Oluştur';

  @override
  String get commonApply => 'Uygula';

  @override
  String get commonLoading => 'Yükleniyor';

  @override
  String get commonCopied => 'Kopyalandı';

  @override
  String get commonAll => 'Tümü';

  @override
  String get commonNoRecords => 'Kayıt yok.';

  @override
  String get commonNoData => 'Veri yok.';

  @override
  String get commonAnonymous => 'anonim';

  @override
  String get commonError => 'Hata';

  @override
  String get commonOwner => 'sahip';

  @override
  String get commonMember => 'üye';

  @override
  String get commonOpen => 'açık';

  @override
  String get commonResolved => 'çözüldü';

  @override
  String get commonEnded => 'bitti';

  @override
  String get commonEmpty => '—';

  @override
  String errNetwork(String endpoint) {
    return 'Sunucuya ulaşılamıyor ($endpoint).';
  }

  @override
  String get errInvalidCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get errSessionExpired => 'Oturum geçersiz; yeniden giriş yapın.';

  @override
  String get errOwnerRequired => 'Bu işlem için proje sahibi olmalısınız.';

  @override
  String get errNotFound => 'Bulunamadı.';

  @override
  String get errEmailTaken => 'Bu e-posta zaten kayıtlı.';

  @override
  String get errPasswordTooShort => 'Şifre en az 6 karakter olmalı.';

  @override
  String get errInvalidEmail => 'Geçerli bir e-posta girin.';

  @override
  String get errUnknownMember =>
      'Bu e-postayla kayıtlı kullanıcı yok; önce kayıt olmalı.';

  @override
  String get errSelfRemove => 'Kendinizi projeden çıkaramazsınız.';

  @override
  String get errProjectNameRequired => 'Proje adı gerekli.';

  @override
  String get errUnsupportedLocale => 'Bu dil desteklenmiyor.';

  @override
  String get errAlertChannelInvalid => 'Geçersiz bildirim kanalı bilgisi.';

  @override
  String get errAlertRuleInvalid => 'Geçersiz uyarı kuralı bilgisi.';

  @override
  String get errAlertSendFailed => 'Bildirim gönderilemedi.';

  @override
  String get fmtJustNow => 'az önce';

  @override
  String fmtMinutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String fmtHoursAgo(int count) {
    return '$count sa önce';
  }

  @override
  String fmtDaysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String fmtSeconds(int count) {
    return '$count sn';
  }

  @override
  String fmtMinutes(int count) {
    return '$count dk';
  }

  @override
  String fmtHours(String hours) {
    return '$hours sa';
  }

  @override
  String get fmtDateTimePattern => 'dd.MM.yyyy HH:mm';

  @override
  String get fmtDayPattern => 'dd MMM';

  @override
  String get fmtClockPattern => 'HH:mm:ss';

  @override
  String get navOverview => 'Genel bakış';

  @override
  String get navIssues => 'Hatalar';

  @override
  String get navSessions => 'Oturumlar';

  @override
  String get navUsers => 'Kullanıcılar';

  @override
  String get navReleases => 'Sürümler';

  @override
  String get navEvents => 'Olaylar';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get releasesTitle => 'Sürümler';

  @override
  String releasesCount(int count) {
    return '$count sürüm';
  }

  @override
  String releasesLoadFailed(String error) {
    return 'Sürümler alınamadı: $error';
  }

  @override
  String get releasesEmpty => 'Henüz sürüm verisi yok.';

  @override
  String get colCrashFreeRate => 'Hatasız Oturum %';

  @override
  String get colAdoption => 'Kullanım %';

  @override
  String get colErrorSessions => 'Hatalı Oturum';

  @override
  String get issueReleaseFirst => 'İlk sürüm';

  @override
  String get issueReleaseLast => 'Son sürüm';

  @override
  String get issueReleaseResolvedIn => 'Çözüldüğü sürüm';

  @override
  String shellSourceTooltip(String url) {
    return 'Kaynak kodu: $url';
  }

  @override
  String get shellSignOut => 'Çıkış';

  @override
  String get shellLanguage => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get authSignIn => 'Giriş yap';

  @override
  String get authSignInSubtitle => 'sightpane panosuna hesabınızla devam edin.';

  @override
  String get authNoAccount => 'Hesabınız yok mu?';

  @override
  String get authGoRegister => 'Kayıt olun';

  @override
  String get authRegisterTitle => 'Hesap oluştur';

  @override
  String get authRegisterSubtitle =>
      'Kayıt olun, ilk projenizi açın, anahtarınızı SDK’ya verin.';

  @override
  String get authHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get authGoSignIn => 'Giriş yapın';

  @override
  String get authRegister => 'Kayıt ol';

  @override
  String get authEmail => 'E-posta';

  @override
  String get authEmailHint => 'ad@sirket.com';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authPasswordRepeat => 'Şifre (tekrar)';

  @override
  String get authFullName => 'Ad Soyad';

  @override
  String get authFullNameHint => 'Ayşe Yılmaz';

  @override
  String get authPasswordHint => 'en az 6 karakter';

  @override
  String get authInvalidEmail => 'Geçerli bir e-posta girin';

  @override
  String get authPasswordRequired => 'Şifre gerekli';

  @override
  String get authPasswordTooShort => 'Şifre en az 6 karakter olmalı';

  @override
  String get authPasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String get projectsTitle => 'Projeler';

  @override
  String projectsCount(int count) {
    return '$count proje';
  }

  @override
  String get projectsNew => 'Yeni proje';

  @override
  String get projectsLoading => 'Projeler yükleniyor';

  @override
  String projectsLoadFailed(String error) {
    return 'Projeler alınamadı: $error';
  }

  @override
  String get projectsEmptyTitle => 'Henüz projeniz yok.';

  @override
  String get projectsEmptyBody =>
      'Bir proje açın; anahtarını ve adresini SDK’ya verin.';

  @override
  String get projectsCreateFirst => 'İlk projeyi oluştur';

  @override
  String projectKeyAndAge(String key, String age) {
    return 'anahtar $key · $age';
  }

  @override
  String get projectStatSessions24h => 'Oturum 24s';

  @override
  String get projectStatErrors24h => 'Hata 24s';

  @override
  String get projectStatOpenIssues => 'Açık grup';

  @override
  String projectCreated(String name) {
    return '$name oluşturuldu';
  }

  @override
  String get projectGoTo => 'Projeye git';

  @override
  String get projectName => 'Proje adı';

  @override
  String get projectNameRequired => 'Proje adı gerekli';

  @override
  String get projectNameHint => 'Kasa uygulaması';

  @override
  String get projectPlatform => 'Platform';

  @override
  String get setupAddress => 'Adres';

  @override
  String get setupApiKey => 'API anahtarı';

  @override
  String get setupTitle => 'Kurulum';

  @override
  String overviewSubtitle(int days) {
    return 'son $days gün';
  }

  @override
  String overviewDaysShort(int days) {
    return '$days g';
  }

  @override
  String get overviewStatsLoading => 'İstatistikler yükleniyor';

  @override
  String overviewStatsFailed(String error) {
    return 'İstatistikler alınamadı: $error';
  }

  @override
  String get overviewSessionsAndErrors => 'Oturumlar ve hatalar';

  @override
  String get overviewSessionsAndErrorsNote =>
      'gün bazında · amber oturum, kırmızı hata';

  @override
  String get overviewEvents => 'Olaylar';

  @override
  String get overviewByDay => 'gün bazında';

  @override
  String get overviewTopIssues => 'En sık hatalar';

  @override
  String get overviewNoOpenIssues => 'Açık hata yok.';

  @override
  String get overviewPlatforms => 'Platformlar';

  @override
  String get overviewReleases => 'Sürümler';

  @override
  String get overviewTopEvents => 'En sık olaylar';

  @override
  String get kpiSessions => 'Oturum';

  @override
  String kpiVisitorsNote(String count) {
    return '$count ziyaretçi (kullanıcı + IP + tarayıcı)';
  }

  @override
  String get kpiErrors => 'Hata';

  @override
  String kpiOpenGroupsNote(String count) {
    return '$count açık grup';
  }

  @override
  String get kpiCrashFree => 'Hatasız oturum';

  @override
  String get kpiEvents => 'Olay';

  @override
  String kpiFramesNote(String count) {
    return '$count kayıt karesi';
  }

  @override
  String get livePages => 'Sayfalar';

  @override
  String liveRouteCount(int count) {
    return '$count rota';
  }

  @override
  String get liveNoPages => 'Şu anda görüntülenen sayfa yok.';

  @override
  String get liveNoRoute => '(rota yok)';

  @override
  String livePeopleCount(int count) {
    return '$count kişi';
  }

  @override
  String get liveViewers => 'Görüntüleyenler';

  @override
  String liveWindow(int seconds) {
    return 'son $seconds sn';
  }

  @override
  String get liveNoOpenSessions => 'Açık oturum yok.';

  @override
  String liveMore(int count) {
    return '+$count daha';
  }

  @override
  String get liveWaiting => 'Canlı veri bekleniyor';

  @override
  String liveSummary(int people, int visitors) {
    return '$people kişi şu anda çevrimiçi · $visitors ziyaretçi';
  }

  @override
  String get liveRefreshNote => 'saniyede bir yenilenir';

  @override
  String get issuesTitle => 'Hatalar';

  @override
  String issuesOpenCount(int count) {
    return '$count açık grup';
  }

  @override
  String get issuesShowResolved => 'Çözülenleri göster';

  @override
  String get issuesGroups => 'Hata grupları';

  @override
  String get issuesGroupingNote => 'aynı istisna + aynı yığın karesi tek grup';

  @override
  String issuesLoadFailed(String error) {
    return 'Hatalar alınamadı: $error';
  }

  @override
  String get issuesEmpty => 'Hata yok.';

  @override
  String get colError => 'Hata';

  @override
  String get colException => 'İstisna';

  @override
  String get colCount => 'Sayı';

  @override
  String get colFirst => 'İlk';

  @override
  String get colLast => 'Son';

  @override
  String get colStatus => 'Durum';

  @override
  String issueDetailFailed(String error) {
    return 'Hata grubu alınamadı: $error';
  }

  @override
  String issueSeenSummary(String count, String first, String last) {
    return '$count kez · ilk $first · son $last';
  }

  @override
  String get issueReopen => 'Yeniden aç';

  @override
  String get issueResolve => 'Çözüldü';

  @override
  String get issueResolvedToast => 'Çözüldü olarak işaretlendi';

  @override
  String get issueResolvedToastNote => 'Yeniden görülürse otomatik açılır.';

  @override
  String get issueAssignee => 'Atanan';

  @override
  String get issueUnassigned => 'Atanmamış';

  @override
  String get issueStatus => 'Durum';

  @override
  String get issueStatusOpen => 'Açık';

  @override
  String get issueStatusResolved => 'Çözüldü';

  @override
  String get issueStatusIgnored => 'Göz ardı edildi';

  @override
  String get issueStatusSnoozed => 'Ertelendi';

  @override
  String get issueActionIgnore => 'Göz ardı et';

  @override
  String get issueActionSnooze => 'Ertele';

  @override
  String get issueSnoozeTitle => 'Hatayı ertele';

  @override
  String get issueSnoozeDuration => 'Süreye göre';

  @override
  String get issueSnooze1Hour => '1 saat';

  @override
  String get issueSnooze24Hours => '24 saat';

  @override
  String get issueSnooze7Days => '7 gün';

  @override
  String get issueSnoozeCount => 'Oluşum sayısına göre';

  @override
  String get issueSnoozeCount10 => '10 kez daha olunca';

  @override
  String get issueSnoozeCount50 => '50 kez daha olunca';

  @override
  String get issueSnoozeCount100 => '100 kez daha olunca';

  @override
  String get issueComments => 'Yorumlar';

  @override
  String get issueCommentsEmpty => 'Henüz yorum yok.';

  @override
  String get issueCommentAdd => 'Yorum yaz...';

  @override
  String get issueCommentSend => 'Gönder';

  @override
  String get issueIgnoredToast => 'Hata göz ardı edildi';

  @override
  String get issueSnoozedToast => 'Hata ertelendi';

  @override
  String get issueStack => 'Yığın';

  @override
  String get issueNoStack => '(yığın yok)';

  @override
  String get issueStackSymbolicated => 'Kaynak eşlendi';

  @override
  String get issueStackRaw => 'Ham yığın';

  @override
  String get issueStackUnresolved => 'eşlenmedi';

  @override
  String get issueStackMinifiedHint =>
      'Küçültülmüş yapı — bu sürüm için kaynak haritası yükleyin';

  @override
  String get issueOccurrences => 'Oluşumlar';

  @override
  String issueOccurrencesNote(int count) {
    return 'son $count';
  }

  @override
  String get colTime => 'Zaman';

  @override
  String get colSession => 'Oturum';

  @override
  String get colRoute => 'Rota';

  @override
  String get colFrame => 'Kare';

  @override
  String get colMessage => 'Mesaj';

  @override
  String get sessionsTitle => 'Oturumlar';

  @override
  String sessionsCount(int count) {
    return '$count oturum';
  }

  @override
  String get sessionsUserFilterHint => 'kullanıcı kimliği';

  @override
  String get sessionsOnlyErrors => 'Yalnızca hatalı';

  @override
  String get sessionsRecent => 'Son oturumlar';

  @override
  String sessionsLoadFailed(String error) {
    return 'Oturumlar alınamadı: $error';
  }

  @override
  String get sessionsEmpty =>
      'Bu filtreye uyan oturum yok. SDK bağlıysa birkaç saniye içinde oturumlar burada görünür.';

  @override
  String get searchHint =>
      'Örn: release:1.0 browser:Chrome route:/pay props.plan:pro errors:true';

  @override
  String get searchFilterQuick => 'Hızlı Filtreler';

  @override
  String get searchClear => 'Temizle';

  @override
  String searchInvalid(String error) {
    return 'Arama sorgusu geçersiz: $error';
  }

  @override
  String get searchPlaceholderIssues =>
      'Hata ara (örn: title:boom resolved:false)';

  @override
  String get filterByField => 'ALANA GÖRE FİLTRELE';

  @override
  String get filterValues => 'DEĞER SEÇİN';

  @override
  String get filterBrowserDesc => 'Tarayıcıya göre filtrele';

  @override
  String get filterPlatformDesc => 'Platforma göre filtrele';

  @override
  String get filterReleaseDesc => 'Sürüme göre filtrele';

  @override
  String get filterRouteDesc => 'Ekran / rotaya göre filtrele';

  @override
  String get filterUserDesc => 'Kullanıcıya göre filtrele';

  @override
  String get filterOsDesc => 'İşletim sistemine göre filtrele';

  @override
  String get filterErrorsDesc => 'Hata durumuna göre filtrele';

  @override
  String get filterStatusDesc => 'Duruma göre filtrele';

  @override
  String get filterAssigneeDesc => 'Sorumluya göre filtrele';

  @override
  String get filterTitleDesc => 'Başlığa göre filtrele';

  @override
  String get filterExceptionDesc => 'İstisna türüne göre filtrele';

  @override
  String get filterResolvedDesc => 'Çözülme durumuna göre filtrele';

  @override
  String get colUser => 'Kullanıcı';

  @override
  String get colIp => 'IP';

  @override
  String get colPlatform => 'Platform';

  @override
  String get colRelease => 'Sürüm';

  @override
  String get colStart => 'Başlangıç';

  @override
  String get colDuration => 'Süre';

  @override
  String get colEvent => 'Olay';

  @override
  String get sessionLoading => 'Oturum yükleniyor';

  @override
  String sessionLoadFailed(String error) {
    return 'Oturum alınamadı: $error';
  }

  @override
  String get sessionReplay => 'Kayıt';

  @override
  String sessionFramesAndDuration(int frames, String duration) {
    return '$frames kare · $duration';
  }

  @override
  String get sessionTimeline => 'Zaman çizgisi';

  @override
  String sessionItemCount(int count) {
    return '$count öğe';
  }

  @override
  String get sessionNoItems => 'Öğe yok.';

  @override
  String sessionHeader(String id) {
    return 'Oturum $id';
  }

  @override
  String sessionFullscreenTitle(String id, String user) {
    return 'Oturum $id · $user';
  }

  @override
  String get replayNoFrames =>
      'Bu oturumda kare yok (SightpaneReplay sarılmamış ya da kayıt kapalı).';

  @override
  String get replayNoFramesGeneric =>
      'Bu oturumda kare yok (oturum kaydı kapalı veya gönderilmemiş).';

  @override
  String replayDomPlayerTitle(int count) {
    return 'DOM Kaydı ($count olay)';
  }

  @override
  String replayPosition(String position, String total) {
    return '$position / $total sn';
  }

  @override
  String replayBuffer(int done, int total) {
    return 'önbellek $done/$total';
  }

  @override
  String get replayFullscreenHint => 'ESC kapatır · boşluk oynat/duraklat';

  @override
  String itemIssueLink(int id) {
    return 'Hata grubu #$id';
  }

  @override
  String itemRoute(String route) {
    return 'rota $route';
  }

  @override
  String get itemBreadcrumbsBefore => 'Hata öncesi adımlar';

  @override
  String get sessionClientInfo => 'İstemci ve Ortam Bilgileri';

  @override
  String get clientPlatform => 'Platform';

  @override
  String get clientPlatformDesktop => 'Masaüstü (Desktop)';

  @override
  String get clientPlatformWeb => 'Web';

  @override
  String get clientPlatformMobile => 'Mobil';

  @override
  String get clientOS => 'İşletim Sistemi';

  @override
  String get clientOsVersion => 'OS Sürümü';

  @override
  String get clientKernel => 'Çekirdek (Kernel)';

  @override
  String get clientKernelVersion => 'Çekirdek Sürümü';

  @override
  String get clientBrowser => 'Tarayıcı';

  @override
  String get clientBrowserVersion => 'Tarayıcı Sürümü';

  @override
  String get clientArch => 'Mimari';

  @override
  String get clientCores => 'CPU Çekirdekleri';

  @override
  String get clientScreen => 'Ekran Çözünürlüğü';

  @override
  String get clientLocale => 'Dil / Yerel Ayar';

  @override
  String get clientSdk => 'SDK';

  @override
  String get eventsTitle => 'Olaylar';

  @override
  String get eventsSubtitle => 'son 30 gün';

  @override
  String get eventsTypes => 'Olay türleri';

  @override
  String eventsLoadFailed(String error) {
    return 'Olaylar alınamadı: $error';
  }

  @override
  String get eventsEmpty => 'Olay yok. SDK’da Hog.capture(’olay’) çağırın.';

  @override
  String get colTotal => 'Toplam';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String settingsProjectLoadFailed(String error) {
    return 'Proje alınamadı: $error';
  }

  @override
  String get settingsProject => 'Proje';

  @override
  String get settingsMemberReadOnly => 'üye · yalnızca görüntüleme';

  @override
  String get settingsProjectNameLabel => 'Ad';

  @override
  String get settingsSaved => 'Kaydedildi';

  @override
  String get settingsRotateKey => 'Anahtarı döndür';

  @override
  String get settingsRotateKeyBody =>
      'Eski anahtarla gönderen uygulamalar reddedilecek. Yeni anahtarı SDK yapılandırmasına işlemeniz gerekir.';

  @override
  String get settingsRotate => 'Döndür';

  @override
  String get settingsSdkSetup => 'SDK kurulumu';

  @override
  String get settingsSdkSetupNote =>
      'endpoint ve apiKey init sırasında verilir';

  @override
  String get settingsMembers => 'Üyeler';

  @override
  String get settingsMemberRemoved => 'Üye çıkarıldı';

  @override
  String get settingsMemberAdded => 'Üye eklendi';

  @override
  String get settingsAddMember => 'Üye ekle';

  @override
  String get settingsMemberEmailHint => 'uye@sirket.com (kayıtlı olmalı)';

  @override
  String get settingsAlertsTitle => 'Uyarılar ve Bildirimler';

  @override
  String get settingsAlertChannels => 'Bildirim Kanalları';

  @override
  String get settingsAlertChannelsEmpty => 'Henüz bildirim kanalı eklenmedi.';

  @override
  String get settingsAlertChannelAdd => 'Kanal ekle';

  @override
  String get settingsAlertChannelName => 'Kanal adı';

  @override
  String get settingsAlertChannelKind => 'Kanal türü';

  @override
  String get settingsAlertChannelTarget => 'Hedef';

  @override
  String get settingsAlertChannelTargetHint =>
      'E-posta, Slack veya Webhook URL';

  @override
  String get settingsAlertChannelSecret => 'Gizli anahtar (Secret)';

  @override
  String get settingsAlertChannelSecretHint =>
      'Webhook için isteğe bağlı HMAC anahtarı';

  @override
  String get settingsAlertChannelTest => 'Test gönder';

  @override
  String get settingsAlertChannelTestSuccess =>
      'Test bildirimi başarıyla gönderildi.';

  @override
  String get settingsAlertChannelDeleteConfirm =>
      'Bu bildirim kanalını silmek istediğinize emin misiniz?';

  @override
  String get settingsAlertRules => 'Uyarı Kuralları';

  @override
  String get settingsAlertRulesEmpty => 'Henüz uyarı kuralı eklenmedi.';

  @override
  String get settingsAlertRuleAdd => 'Kural ekle';

  @override
  String get settingsAlertRuleName => 'Kural adı';

  @override
  String get settingsAlertRuleKind => 'Olay türü';

  @override
  String get settingsAlertRuleKindNewIssue => 'Yeni hata';

  @override
  String get settingsAlertRuleKindRegression =>
      'Yeniden oluşan hata (Regresyon)';

  @override
  String get settingsAlertRuleKindRateSpike => 'Hata oranı artışı (Spike)';

  @override
  String get settingsAlertRuleKindCrashFree => 'Çökmesiz oturum düşüşü';

  @override
  String get settingsAlertRuleChannels => 'Kanallar';

  @override
  String get settingsAlertRuleChannelsSelectHint => 'En az bir kanal seçin';

  @override
  String get settingsAlertRuleThreshold => 'Eşik değeri';

  @override
  String get settingsAlertRuleWindow => 'Zaman aralığı (dakika)';

  @override
  String get settingsAlertRuleEnabled => 'Etkin';

  @override
  String get settingsAlertRuleDeleteConfirm =>
      'Bu uyarı kuralını silmek istediğinize emin misiniz?';

  @override
  String get settingsDangerZone => 'Tehlikeli bölge';

  @override
  String get settingsDeleteBody =>
      'Projeyi ve tüm oturum, hata, kare verisini kalıcı olarak siler.';

  @override
  String get settingsDeleteProject => 'Projeyi sil';

  @override
  String settingsDeleteConfirmTitle(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get settingsDeleteConfirmBody => 'Bu işlem geri alınamaz.';

  @override
  String get performanceTitle => 'Performans';

  @override
  String performanceSubtitle(int count) {
    return '$count işlem izleniyor';
  }

  @override
  String get performanceEmpty => 'Henüz performans verisi yok.';

  @override
  String performanceLoadFailed(String error) {
    return 'Performans verisi yüklenemedi: $error';
  }

  @override
  String get colOperation => 'İşlem Türü';

  @override
  String get colTransaction => 'İşlem Adı';

  @override
  String get colP50 => 'p50';

  @override
  String get colP95 => 'p95';

  @override
  String get colAvg => 'Ort.';

  @override
  String get colCalls => 'Çağrı';

  @override
  String get colErrorRate => 'Hata %';

  @override
  String get colAction => 'İşlem';

  @override
  String get performanceSlowestSamples => 'En Yavaş Örnekler';

  @override
  String get performanceViewReplay => 'Kaydı Aç';

  @override
  String get performanceDays7 => 'Son 7 Gün';

  @override
  String get performanceDays14 => 'Son 14 Gün';

  @override
  String get performanceDays30 => 'Son 30 Gün';

  @override
  String get usersTitle => 'Kullanıcılar';

  @override
  String usersSubtitle(int count) {
    return '$count kullanıcı';
  }

  @override
  String get usersSearchPlaceholder => 'Kullanıcı veya e-posta ara...';

  @override
  String usersLoadFailed(String error) {
    return 'Kullanıcılar alınamadı: $error';
  }

  @override
  String get usersEmpty => 'Kullanıcı bulunamadı.';

  @override
  String get kpiTotalUsers => 'Toplam Kullanıcı';

  @override
  String get kpiActiveUsers => 'Aktif Kullanıcı (Dönem)';

  @override
  String get kpiAvgDuration => 'Ortalama Süre';

  @override
  String get kpiSessionsPerUser => 'Kullanıcı Başı Oturum';

  @override
  String get chartActiveUsers => 'Günlük Aktif Kullanıcılar (DAU)';

  @override
  String get chartActiveUsersSub =>
      'mavi aktif kullanıcılar · kırmızı hatalı kullanıcılar';

  @override
  String get colAvgDuration => 'Ort. Süre';

  @override
  String get colFirstSeen => 'İlk Görülme';

  @override
  String get colLastSeen => 'Son Görülme';

  @override
  String get userDetailTitle => 'Kullanıcı Detayları';

  @override
  String get actionViewSessions => 'Oturumları Gör';

  @override
  String get actionExportData => 'Veriyi İndir (JSON)';

  @override
  String get actionDeleteData => 'Kullanıcı Verisini Sil';

  @override
  String get userDeleteConfirm =>
      'Bu kullanıcının tüm oturum ve hata kayıtları silinsin mi?';

  @override
  String get userDeleteSuccess => 'Kullanıcı verisi başarıyla silindi.';

  @override
  String get userCustomProps => 'Özel Nitelikler';

  @override
  String get navFunnels => 'Huniler';

  @override
  String get funnelsTitle => 'Dönüşüm Hunileri';

  @override
  String funnelsSubtitle(int count) {
    return '$count huni tanımlı';
  }

  @override
  String get funnelCreate => 'Huni Oluştur';

  @override
  String get funnelName => 'Huni Adı';

  @override
  String get funnelDescription => 'Açıklama';

  @override
  String get funnelSteps => 'Huni Adımları';

  @override
  String get funnelStepAdd => 'Adım Ekle';

  @override
  String get funnelStepEvent => 'Olay Adı';

  @override
  String get funnelWindow => 'Dönüşüm Penceresi';

  @override
  String get funnelWindow1d => '1 Gün';

  @override
  String get funnelWindow7d => '7 Gün';

  @override
  String get funnelWindow14d => '14 Gün';

  @override
  String get funnelWindow30d => '30 Gün';

  @override
  String get funnelsEmpty => 'Henüz tanımlanmış bir huni yok.';

  @override
  String get funnelsEmptyHint =>
      'Kullanıcı yolculuklarındaki dönüşüm ve terk oranlarını izlemek için ilk huninizi oluşturun.';

  @override
  String get funnelOverallConversion => 'Genel Dönüşüm Oranı';

  @override
  String get funnelCompletedSessions => 'Tamamlayan Oturum';

  @override
  String get funnelTotalSessions => 'Başlayan Oturum';

  @override
  String get funnelMedianTime => 'Medyan Dönüşüm Süresi';

  @override
  String get funnelStepConversion => 'Adım Dönüşümü';

  @override
  String get funnelDropOff => 'Terk Eden';

  @override
  String funnelWatchReplays(int count) {
    return 'Terk Eden Kayıtları İzle ($count)';
  }

  @override
  String get funnelDeleteConfirm =>
      'Bu huniyi silmek istediğinizden emin misiniz?';

  @override
  String get funnelDeleted => 'Huni silindi.';

  @override
  String get funnelCreated => 'Huni oluşturuldu.';

  @override
  String get funnelUpdated => 'Huni güncellendi.';

  @override
  String get funnelStepMin => 'En az 2 adım gereklidir.';

  @override
  String get navRetention => 'Elde Tutma (Retention)';

  @override
  String get navCohorts => 'Kohortlar';

  @override
  String get retentionTitle => 'Kullanıcı Elde Tutma Matrisi';

  @override
  String get retentionSubtitle =>
      'Kullanıcıların zaman içinde uygulamanıza geri dönüş oranlarını kohort bazında analiz edin.';

  @override
  String get retentionPeriodDay => 'Günlük';

  @override
  String get retentionPeriodWeek => 'Haftalık';

  @override
  String get retentionTargetEvent => 'İlk Olay (Hedef)';

  @override
  String get retentionReturnEvent => 'Dönüş Olayı';

  @override
  String get retentionAllUsers => 'Tüm Kullanıcılar';

  @override
  String get retentionCohortFilter => 'Kohort Filtresi';

  @override
  String get retentionHeatmapTitle => 'Elde Tutma Isı Haritası';

  @override
  String get retentionBucket => 'Kohort Başlangıcı';

  @override
  String get retentionUsers => 'Kullanıcı';

  @override
  String retentionPeriodN(String unit, int index) {
    return '$unit $index';
  }

  @override
  String get retentionEmpty => 'Seçilen aralıkta elde tutma verisi bulunamadı.';

  @override
  String get cohortsTitle => 'Davranışsal Kohortlar';

  @override
  String get cohortsSubtitle =>
      'Kullanıcıları belirli davranış ve özelliklere göre segmentlere ayırın.';

  @override
  String get newCohort => 'Yeni Kohort';

  @override
  String get cohortName => 'Kohort Adı';

  @override
  String get cohortDescription => 'Açıklama';

  @override
  String get cohortRules => 'Dinamik Kurallar';

  @override
  String get cohortDynamic => 'Dinamik';

  @override
  String get cohortStatic => 'Statik';

  @override
  String get cohortMemberCount => 'Üye Sayısı';

  @override
  String get refreshCohort => 'Kohortu Güncelle';

  @override
  String get cohortRefreshed => 'Kohort üyeleri güncellendi.';

  @override
  String get cohortCreated => 'Kohort oluşturuldu.';

  @override
  String get cohortDeleted => 'Kohort silindi.';

  @override
  String get cohortDeleteConfirm =>
      'Bu kohortu silmek istediğinizden emin misiniz?';

  @override
  String get cohortEmpty => 'Henüz tanımlanmış bir kohort yok.';

  @override
  String get cohortEmptyHint =>
      'Kullanıcıları davranışlarına göre gruplandırmak için ilk kohortunuzu oluşturun.';

  @override
  String get cohortAddRule => 'Kural Ekle';

  @override
  String get cohortEventName => 'Olay Adı';

  @override
  String get cohortOperator => 'İşleç';

  @override
  String get cohortValue => 'Değer';

  @override
  String get cohortWindowDays => 'Zaman Penceresi (Gün)';

  @override
  String get navPaths => 'Kullanıcı Yolları (Paths)';

  @override
  String get pathsTitle => 'Kullanıcı Yolculuk Akışları';

  @override
  String get pathsSubtitle =>
      'Kullanıcıların ekranlar ve olaylar arasındaki geçişlerini Sankey akış şemasıyla inceleyin.';

  @override
  String get pathsForward => 'İleri (Başlangıçtan)';

  @override
  String get pathsReverse => 'Geriye Doğru (Hedefe)';

  @override
  String get pathsRootEvent => 'Kök Olay / Ekran';

  @override
  String get pathsRootPlaceholder => 'Örn: route:/login veya error';

  @override
  String get pathsStepLimit => 'Adım Derinliği';

  @override
  String get pathsExclude => 'Hariç Tutulanlar';

  @override
  String get pathsExcludePlaceholder => 'Örn: heartbeat, pointer';

  @override
  String get pathsThreshold => 'Eşik (%)';

  @override
  String get pathsDiagramTitle => 'Geçiş Akış Şeması (Sankey)';

  @override
  String get pathsEmpty =>
      'Seçilen kriterlere uygun kullanıcı yolu bulunamadı.';

  @override
  String pathsSampleSessions(int count) {
    return 'Örnek Oturumlar ($count)';
  }

  @override
  String get pathsReplaysModalTitle => 'Yolculuk Oturum Kayıtları';

  @override
  String get pathsExit => 'Terk (Exit)';
}
