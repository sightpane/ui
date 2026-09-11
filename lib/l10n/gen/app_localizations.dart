import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @commonRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get commonRefresh;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonCreate.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get commonCreate;

  /// No description provided for @commonApply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get commonApply;

  /// No description provided for @commonLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get commonLoading;

  /// No description provided for @commonCopied.
  ///
  /// In tr, this message translates to:
  /// **'Kopyalandı'**
  String get commonCopied;

  /// No description provided for @commonAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get commonAll;

  /// No description provided for @commonNoRecords.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt yok.'**
  String get commonNoRecords;

  /// No description provided for @commonNoData.
  ///
  /// In tr, this message translates to:
  /// **'Veri yok.'**
  String get commonNoData;

  /// No description provided for @commonAnonymous.
  ///
  /// In tr, this message translates to:
  /// **'anonim'**
  String get commonAnonymous;

  /// No description provided for @commonError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get commonError;

  /// No description provided for @commonOwner.
  ///
  /// In tr, this message translates to:
  /// **'sahip'**
  String get commonOwner;

  /// No description provided for @commonMember.
  ///
  /// In tr, this message translates to:
  /// **'üye'**
  String get commonMember;

  /// No description provided for @commonOpen.
  ///
  /// In tr, this message translates to:
  /// **'açık'**
  String get commonOpen;

  /// No description provided for @commonResolved.
  ///
  /// In tr, this message translates to:
  /// **'çözüldü'**
  String get commonResolved;

  /// No description provided for @commonEnded.
  ///
  /// In tr, this message translates to:
  /// **'bitti'**
  String get commonEnded;

  /// The no-value marker; the same dash in every language
  ///
  /// In tr, this message translates to:
  /// **'—'**
  String get commonEmpty;

  /// No description provided for @errNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamıyor ({endpoint}).'**
  String errNetwork(String endpoint);

  /// No description provided for @errInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı.'**
  String get errInvalidCredentials;

  /// No description provided for @errSessionExpired.
  ///
  /// In tr, this message translates to:
  /// **'Oturum geçersiz; yeniden giriş yapın.'**
  String get errSessionExpired;

  /// No description provided for @errOwnerRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için proje sahibi olmalısınız.'**
  String get errOwnerRequired;

  /// No description provided for @errNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bulunamadı.'**
  String get errNotFound;

  /// No description provided for @errEmailTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kayıtlı.'**
  String get errEmailTaken;

  /// No description provided for @errPasswordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalı.'**
  String get errPasswordTooShort;

  /// No description provided for @errInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin.'**
  String get errInvalidEmail;

  /// No description provided for @errUnknownMember.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-postayla kayıtlı kullanıcı yok; önce kayıt olmalı.'**
  String get errUnknownMember;

  /// No description provided for @errSelfRemove.
  ///
  /// In tr, this message translates to:
  /// **'Kendinizi projeden çıkaramazsınız.'**
  String get errSelfRemove;

  /// No description provided for @errProjectNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Proje adı gerekli.'**
  String get errProjectNameRequired;

  /// No description provided for @errUnsupportedLocale.
  ///
  /// In tr, this message translates to:
  /// **'Bu dil desteklenmiyor.'**
  String get errUnsupportedLocale;

  /// No description provided for @errAlertChannelInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz bildirim kanalı bilgisi.'**
  String get errAlertChannelInvalid;

  /// No description provided for @errAlertRuleInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz uyarı kuralı bilgisi.'**
  String get errAlertRuleInvalid;

  /// No description provided for @errAlertSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim gönderilemedi.'**
  String get errAlertSendFailed;

  /// No description provided for @fmtJustNow.
  ///
  /// In tr, this message translates to:
  /// **'az önce'**
  String get fmtJustNow;

  /// No description provided for @fmtMinutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} dk önce'**
  String fmtMinutesAgo(int count);

  /// No description provided for @fmtHoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} sa önce'**
  String fmtHoursAgo(int count);

  /// No description provided for @fmtDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String fmtDaysAgo(int count);

  /// No description provided for @fmtSeconds.
  ///
  /// In tr, this message translates to:
  /// **'{count} sn'**
  String fmtSeconds(int count);

  /// No description provided for @fmtMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{count} dk'**
  String fmtMinutes(int count);

  /// No description provided for @fmtHours.
  ///
  /// In tr, this message translates to:
  /// **'{hours} sa'**
  String fmtHours(String hours);

  /// intl DateFormat pattern — not a translation but how that language writes dates
  ///
  /// In tr, this message translates to:
  /// **'dd.MM.yyyy HH:mm'**
  String get fmtDateTimePattern;

  /// Short day pattern for chart and column labels
  ///
  /// In tr, this message translates to:
  /// **'dd MMM'**
  String get fmtDayPattern;

  /// Clock pattern for the replay player
  ///
  /// In tr, this message translates to:
  /// **'HH:mm:ss'**
  String get fmtClockPattern;

  /// No description provided for @navOverview.
  ///
  /// In tr, this message translates to:
  /// **'Genel bakış'**
  String get navOverview;

  /// No description provided for @navIssues.
  ///
  /// In tr, this message translates to:
  /// **'Hatalar'**
  String get navIssues;

  /// No description provided for @navSessions.
  ///
  /// In tr, this message translates to:
  /// **'Oturumlar'**
  String get navSessions;

  /// No description provided for @navUsers.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar'**
  String get navUsers;

  /// No description provided for @navReleases.
  ///
  /// In tr, this message translates to:
  /// **'Sürümler'**
  String get navReleases;

  /// No description provided for @navEvents.
  ///
  /// In tr, this message translates to:
  /// **'Olaylar'**
  String get navEvents;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @releasesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sürümler'**
  String get releasesTitle;

  /// No description provided for @releasesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} sürüm'**
  String releasesCount(int count);

  /// No description provided for @releasesLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sürümler alınamadı: {error}'**
  String releasesLoadFailed(String error);

  /// No description provided for @releasesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sürüm verisi yok.'**
  String get releasesEmpty;

  /// No description provided for @colCrashFreeRate.
  ///
  /// In tr, this message translates to:
  /// **'Hatasız Oturum %'**
  String get colCrashFreeRate;

  /// No description provided for @colAdoption.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım %'**
  String get colAdoption;

  /// No description provided for @colErrorSessions.
  ///
  /// In tr, this message translates to:
  /// **'Hatalı Oturum'**
  String get colErrorSessions;

  /// No description provided for @issueReleaseFirst.
  ///
  /// In tr, this message translates to:
  /// **'İlk sürüm'**
  String get issueReleaseFirst;

  /// No description provided for @issueReleaseLast.
  ///
  /// In tr, this message translates to:
  /// **'Son sürüm'**
  String get issueReleaseLast;

  /// No description provided for @issueReleaseResolvedIn.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldüğü sürüm'**
  String get issueReleaseResolvedIn;

  /// No description provided for @shellSourceTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak kodu: {url}'**
  String shellSourceTooltip(String url);

  /// No description provided for @shellSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış'**
  String get shellSignOut;

  /// No description provided for @shellLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get shellLanguage;

  /// A language name is written in its own language
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// A language name is written in its own language
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @authSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get authSignIn;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'sightpane panosuna hesabınızla devam edin.'**
  String get authSignInSubtitle;

  /// No description provided for @authNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get authNoAccount;

  /// No description provided for @authGoRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt olun'**
  String get authGoRegister;

  /// No description provided for @authRegisterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt olun, ilk projenizi açın, anahtarınızı SDK’ya verin.'**
  String get authRegisterSubtitle;

  /// No description provided for @authHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get authHaveAccount;

  /// No description provided for @authGoSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapın'**
  String get authGoSignIn;

  /// No description provided for @authRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get authRegister;

  /// No description provided for @authEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get authEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'ad@sirket.com'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get authPassword;

  /// No description provided for @authPasswordRepeat.
  ///
  /// In tr, this message translates to:
  /// **'Şifre (tekrar)'**
  String get authPasswordRepeat;

  /// No description provided for @authFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Ayşe Yılmaz'**
  String get authFullNameHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'en az 6 karakter'**
  String get authPasswordHint;

  /// No description provided for @authInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalı'**
  String get authPasswordTooShort;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get authPasswordMismatch;

  /// No description provided for @projectsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Projeler'**
  String get projectsTitle;

  /// No description provided for @projectsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} proje'**
  String projectsCount(int count);

  /// No description provided for @projectsNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni proje'**
  String get projectsNew;

  /// No description provided for @projectsLoading.
  ///
  /// In tr, this message translates to:
  /// **'Projeler yükleniyor'**
  String get projectsLoading;

  /// No description provided for @projectsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Projeler alınamadı: {error}'**
  String projectsLoadFailed(String error);

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz projeniz yok.'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Bir proje açın; anahtarını ve adresini SDK’ya verin.'**
  String get projectsEmptyBody;

  /// No description provided for @projectsCreateFirst.
  ///
  /// In tr, this message translates to:
  /// **'İlk projeyi oluştur'**
  String get projectsCreateFirst;

  /// No description provided for @projectKeyAndAge.
  ///
  /// In tr, this message translates to:
  /// **'anahtar {key} · {age}'**
  String projectKeyAndAge(String key, String age);

  /// No description provided for @projectStatSessions24h.
  ///
  /// In tr, this message translates to:
  /// **'Oturum 24s'**
  String get projectStatSessions24h;

  /// No description provided for @projectStatErrors24h.
  ///
  /// In tr, this message translates to:
  /// **'Hata 24s'**
  String get projectStatErrors24h;

  /// No description provided for @projectStatOpenIssues.
  ///
  /// In tr, this message translates to:
  /// **'Açık grup'**
  String get projectStatOpenIssues;

  /// No description provided for @projectCreated.
  ///
  /// In tr, this message translates to:
  /// **'{name} oluşturuldu'**
  String projectCreated(String name);

  /// No description provided for @projectGoTo.
  ///
  /// In tr, this message translates to:
  /// **'Projeye git'**
  String get projectGoTo;

  /// No description provided for @projectName.
  ///
  /// In tr, this message translates to:
  /// **'Proje adı'**
  String get projectName;

  /// Inline form warning, no full stop — errProjectNameRequired is the server error
  ///
  /// In tr, this message translates to:
  /// **'Proje adı gerekli'**
  String get projectNameRequired;

  /// No description provided for @projectNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Kasa uygulaması'**
  String get projectNameHint;

  /// No description provided for @projectPlatform.
  ///
  /// In tr, this message translates to:
  /// **'Platform'**
  String get projectPlatform;

  /// No description provided for @setupAddress.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get setupAddress;

  /// No description provided for @setupApiKey.
  ///
  /// In tr, this message translates to:
  /// **'API anahtarı'**
  String get setupApiKey;

  /// No description provided for @setupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum'**
  String get setupTitle;

  /// No description provided for @overviewSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'son {days} gün'**
  String overviewSubtitle(int days);

  /// No description provided for @overviewDaysShort.
  ///
  /// In tr, this message translates to:
  /// **'{days} g'**
  String overviewDaysShort(int days);

  /// No description provided for @overviewStatsLoading.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler yükleniyor'**
  String get overviewStatsLoading;

  /// No description provided for @overviewStatsFailed.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler alınamadı: {error}'**
  String overviewStatsFailed(String error);

  /// No description provided for @overviewSessionsAndErrors.
  ///
  /// In tr, this message translates to:
  /// **'Oturumlar ve hatalar'**
  String get overviewSessionsAndErrors;

  /// No description provided for @overviewSessionsAndErrorsNote.
  ///
  /// In tr, this message translates to:
  /// **'gün bazında · amber oturum, kırmızı hata'**
  String get overviewSessionsAndErrorsNote;

  /// No description provided for @overviewEvents.
  ///
  /// In tr, this message translates to:
  /// **'Olaylar'**
  String get overviewEvents;

  /// No description provided for @overviewByDay.
  ///
  /// In tr, this message translates to:
  /// **'gün bazında'**
  String get overviewByDay;

  /// No description provided for @overviewTopIssues.
  ///
  /// In tr, this message translates to:
  /// **'En sık hatalar'**
  String get overviewTopIssues;

  /// No description provided for @overviewNoOpenIssues.
  ///
  /// In tr, this message translates to:
  /// **'Açık hata yok.'**
  String get overviewNoOpenIssues;

  /// No description provided for @overviewPlatforms.
  ///
  /// In tr, this message translates to:
  /// **'Platformlar'**
  String get overviewPlatforms;

  /// No description provided for @overviewReleases.
  ///
  /// In tr, this message translates to:
  /// **'Sürümler'**
  String get overviewReleases;

  /// No description provided for @overviewTopEvents.
  ///
  /// In tr, this message translates to:
  /// **'En sık olaylar'**
  String get overviewTopEvents;

  /// No description provided for @kpiSessions.
  ///
  /// In tr, this message translates to:
  /// **'Oturum'**
  String get kpiSessions;

  /// No description provided for @kpiVisitorsNote.
  ///
  /// In tr, this message translates to:
  /// **'{count} ziyaretçi (kullanıcı + IP + tarayıcı)'**
  String kpiVisitorsNote(String count);

  /// No description provided for @kpiErrors.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get kpiErrors;

  /// No description provided for @kpiOpenGroupsNote.
  ///
  /// In tr, this message translates to:
  /// **'{count} açık grup'**
  String kpiOpenGroupsNote(String count);

  /// No description provided for @kpiCrashFree.
  ///
  /// In tr, this message translates to:
  /// **'Hatasız oturum'**
  String get kpiCrashFree;

  /// No description provided for @kpiEvents.
  ///
  /// In tr, this message translates to:
  /// **'Olay'**
  String get kpiEvents;

  /// No description provided for @kpiFramesNote.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt karesi'**
  String kpiFramesNote(String count);

  /// No description provided for @livePages.
  ///
  /// In tr, this message translates to:
  /// **'Sayfalar'**
  String get livePages;

  /// No description provided for @liveRouteCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} rota'**
  String liveRouteCount(int count);

  /// No description provided for @liveNoPages.
  ///
  /// In tr, this message translates to:
  /// **'Şu anda görüntülenen sayfa yok.'**
  String get liveNoPages;

  /// No description provided for @liveNoRoute.
  ///
  /// In tr, this message translates to:
  /// **'(rota yok)'**
  String get liveNoRoute;

  /// No description provided for @livePeopleCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi'**
  String livePeopleCount(int count);

  /// No description provided for @liveViewers.
  ///
  /// In tr, this message translates to:
  /// **'Görüntüleyenler'**
  String get liveViewers;

  /// No description provided for @liveWindow.
  ///
  /// In tr, this message translates to:
  /// **'son {seconds} sn'**
  String liveWindow(int seconds);

  /// No description provided for @liveNoOpenSessions.
  ///
  /// In tr, this message translates to:
  /// **'Açık oturum yok.'**
  String get liveNoOpenSessions;

  /// No description provided for @liveMore.
  ///
  /// In tr, this message translates to:
  /// **'+{count} daha'**
  String liveMore(int count);

  /// No description provided for @liveWaiting.
  ///
  /// In tr, this message translates to:
  /// **'Canlı veri bekleniyor'**
  String get liveWaiting;

  /// No description provided for @liveSummary.
  ///
  /// In tr, this message translates to:
  /// **'{people} kişi şu anda çevrimiçi · {visitors} ziyaretçi'**
  String liveSummary(int people, int visitors);

  /// No description provided for @liveRefreshNote.
  ///
  /// In tr, this message translates to:
  /// **'saniyede bir yenilenir'**
  String get liveRefreshNote;

  /// No description provided for @issuesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hatalar'**
  String get issuesTitle;

  /// No description provided for @issuesOpenCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} açık grup'**
  String issuesOpenCount(int count);

  /// No description provided for @issuesShowResolved.
  ///
  /// In tr, this message translates to:
  /// **'Çözülenleri göster'**
  String get issuesShowResolved;

  /// No description provided for @issuesGroups.
  ///
  /// In tr, this message translates to:
  /// **'Hata grupları'**
  String get issuesGroups;

  /// No description provided for @issuesGroupingNote.
  ///
  /// In tr, this message translates to:
  /// **'aynı istisna + aynı yığın karesi tek grup'**
  String get issuesGroupingNote;

  /// No description provided for @issuesLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hatalar alınamadı: {error}'**
  String issuesLoadFailed(String error);

  /// No description provided for @issuesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Hata yok.'**
  String get issuesEmpty;

  /// No description provided for @colError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get colError;

  /// No description provided for @colException.
  ///
  /// In tr, this message translates to:
  /// **'İstisna'**
  String get colException;

  /// No description provided for @colCount.
  ///
  /// In tr, this message translates to:
  /// **'Sayı'**
  String get colCount;

  /// No description provided for @colFirst.
  ///
  /// In tr, this message translates to:
  /// **'İlk'**
  String get colFirst;

  /// No description provided for @colLast.
  ///
  /// In tr, this message translates to:
  /// **'Son'**
  String get colLast;

  /// No description provided for @colStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get colStatus;

  /// No description provided for @issueDetailFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hata grubu alınamadı: {error}'**
  String issueDetailFailed(String error);

  /// No description provided for @issueSeenSummary.
  ///
  /// In tr, this message translates to:
  /// **'{count} kez · ilk {first} · son {last}'**
  String issueSeenSummary(String count, String first, String last);

  /// No description provided for @issueReopen.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden aç'**
  String get issueReopen;

  /// No description provided for @issueResolve.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü'**
  String get issueResolve;

  /// No description provided for @issueResolvedToast.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü olarak işaretlendi'**
  String get issueResolvedToast;

  /// No description provided for @issueResolvedToastNote.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden görülürse otomatik açılır.'**
  String get issueResolvedToastNote;

  /// No description provided for @issueAssignee.
  ///
  /// In tr, this message translates to:
  /// **'Atanan'**
  String get issueAssignee;

  /// No description provided for @issueUnassigned.
  ///
  /// In tr, this message translates to:
  /// **'Atanmamış'**
  String get issueUnassigned;

  /// No description provided for @issueStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get issueStatus;

  /// No description provided for @issueStatusOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get issueStatusOpen;

  /// No description provided for @issueStatusResolved.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü'**
  String get issueStatusResolved;

  /// No description provided for @issueStatusIgnored.
  ///
  /// In tr, this message translates to:
  /// **'Göz ardı edildi'**
  String get issueStatusIgnored;

  /// No description provided for @issueStatusSnoozed.
  ///
  /// In tr, this message translates to:
  /// **'Ertelendi'**
  String get issueStatusSnoozed;

  /// No description provided for @issueActionIgnore.
  ///
  /// In tr, this message translates to:
  /// **'Göz ardı et'**
  String get issueActionIgnore;

  /// No description provided for @issueActionSnooze.
  ///
  /// In tr, this message translates to:
  /// **'Ertele'**
  String get issueActionSnooze;

  /// No description provided for @issueSnoozeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hatayı ertele'**
  String get issueSnoozeTitle;

  /// No description provided for @issueSnoozeDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süreye göre'**
  String get issueSnoozeDuration;

  /// No description provided for @issueSnooze1Hour.
  ///
  /// In tr, this message translates to:
  /// **'1 saat'**
  String get issueSnooze1Hour;

  /// No description provided for @issueSnooze24Hours.
  ///
  /// In tr, this message translates to:
  /// **'24 saat'**
  String get issueSnooze24Hours;

  /// No description provided for @issueSnooze7Days.
  ///
  /// In tr, this message translates to:
  /// **'7 gün'**
  String get issueSnooze7Days;

  /// No description provided for @issueSnoozeCount.
  ///
  /// In tr, this message translates to:
  /// **'Oluşum sayısına göre'**
  String get issueSnoozeCount;

  /// No description provided for @issueSnoozeCount10.
  ///
  /// In tr, this message translates to:
  /// **'10 kez daha olunca'**
  String get issueSnoozeCount10;

  /// No description provided for @issueSnoozeCount50.
  ///
  /// In tr, this message translates to:
  /// **'50 kez daha olunca'**
  String get issueSnoozeCount50;

  /// No description provided for @issueSnoozeCount100.
  ///
  /// In tr, this message translates to:
  /// **'100 kez daha olunca'**
  String get issueSnoozeCount100;

  /// No description provided for @issueComments.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get issueComments;

  /// No description provided for @issueCommentsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yok.'**
  String get issueCommentsEmpty;

  /// No description provided for @issueCommentAdd.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz...'**
  String get issueCommentAdd;

  /// No description provided for @issueCommentSend.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get issueCommentSend;

  /// No description provided for @issueIgnoredToast.
  ///
  /// In tr, this message translates to:
  /// **'Hata göz ardı edildi'**
  String get issueIgnoredToast;

  /// No description provided for @issueSnoozedToast.
  ///
  /// In tr, this message translates to:
  /// **'Hata ertelendi'**
  String get issueSnoozedToast;

  /// No description provided for @issueStack.
  ///
  /// In tr, this message translates to:
  /// **'Yığın'**
  String get issueStack;

  /// No description provided for @issueNoStack.
  ///
  /// In tr, this message translates to:
  /// **'(yığın yok)'**
  String get issueNoStack;

  /// No description provided for @issueStackSymbolicated.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak eşlendi'**
  String get issueStackSymbolicated;

  /// No description provided for @issueStackRaw.
  ///
  /// In tr, this message translates to:
  /// **'Ham yığın'**
  String get issueStackRaw;

  /// No description provided for @issueStackUnresolved.
  ///
  /// In tr, this message translates to:
  /// **'eşlenmedi'**
  String get issueStackUnresolved;

  /// No description provided for @issueStackMinifiedHint.
  ///
  /// In tr, this message translates to:
  /// **'Küçültülmüş yapı — bu sürüm için kaynak haritası yükleyin'**
  String get issueStackMinifiedHint;

  /// No description provided for @issueOccurrences.
  ///
  /// In tr, this message translates to:
  /// **'Oluşumlar'**
  String get issueOccurrences;

  /// No description provided for @issueOccurrencesNote.
  ///
  /// In tr, this message translates to:
  /// **'son {count}'**
  String issueOccurrencesNote(int count);

  /// No description provided for @colTime.
  ///
  /// In tr, this message translates to:
  /// **'Zaman'**
  String get colTime;

  /// No description provided for @colSession.
  ///
  /// In tr, this message translates to:
  /// **'Oturum'**
  String get colSession;

  /// No description provided for @colRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rota'**
  String get colRoute;

  /// No description provided for @colFrame.
  ///
  /// In tr, this message translates to:
  /// **'Kare'**
  String get colFrame;

  /// No description provided for @colMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get colMessage;

  /// No description provided for @sessionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturumlar'**
  String get sessionsTitle;

  /// No description provided for @sessionsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} oturum'**
  String sessionsCount(int count);

  /// No description provided for @sessionsUserFilterHint.
  ///
  /// In tr, this message translates to:
  /// **'kullanıcı kimliği'**
  String get sessionsUserFilterHint;

  /// No description provided for @sessionsOnlyErrors.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca hatalı'**
  String get sessionsOnlyErrors;

  /// No description provided for @sessionsRecent.
  ///
  /// In tr, this message translates to:
  /// **'Son oturumlar'**
  String get sessionsRecent;

  /// No description provided for @sessionsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Oturumlar alınamadı: {error}'**
  String sessionsLoadFailed(String error);

  /// No description provided for @sessionsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu filtreye uyan oturum yok. SDK bağlıysa birkaç saniye içinde oturumlar burada görünür.'**
  String get sessionsEmpty;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: release:1.0 browser:Chrome route:/pay props.plan:pro errors:true'**
  String get searchHint;

  /// No description provided for @searchFilterQuick.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Filtreler'**
  String get searchFilterQuick;

  /// No description provided for @searchClear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get searchClear;

  /// No description provided for @searchInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Arama sorgusu geçersiz: {error}'**
  String searchInvalid(String error);

  /// No description provided for @searchPlaceholderIssues.
  ///
  /// In tr, this message translates to:
  /// **'Hata ara (örn: title:boom resolved:false)'**
  String get searchPlaceholderIssues;

  /// No description provided for @filterByField.
  ///
  /// In tr, this message translates to:
  /// **'ALANA GÖRE FİLTRELE'**
  String get filterByField;

  /// No description provided for @filterValues.
  ///
  /// In tr, this message translates to:
  /// **'DEĞER SEÇİN'**
  String get filterValues;

  /// No description provided for @filterBrowserDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tarayıcıya göre filtrele'**
  String get filterBrowserDesc;

  /// No description provided for @filterPlatformDesc.
  ///
  /// In tr, this message translates to:
  /// **'Platforma göre filtrele'**
  String get filterPlatformDesc;

  /// No description provided for @filterReleaseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sürüme göre filtrele'**
  String get filterReleaseDesc;

  /// No description provided for @filterRouteDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ekran / rotaya göre filtrele'**
  String get filterRouteDesc;

  /// No description provided for @filterUserDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıya göre filtrele'**
  String get filterUserDesc;

  /// No description provided for @filterOsDesc.
  ///
  /// In tr, this message translates to:
  /// **'İşletim sistemine göre filtrele'**
  String get filterOsDesc;

  /// No description provided for @filterErrorsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hata durumuna göre filtrele'**
  String get filterErrorsDesc;

  /// No description provided for @filterStatusDesc.
  ///
  /// In tr, this message translates to:
  /// **'Duruma göre filtrele'**
  String get filterStatusDesc;

  /// No description provided for @filterAssigneeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sorumluya göre filtrele'**
  String get filterAssigneeDesc;

  /// No description provided for @filterTitleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Başlığa göre filtrele'**
  String get filterTitleDesc;

  /// No description provided for @filterExceptionDesc.
  ///
  /// In tr, this message translates to:
  /// **'İstisna türüne göre filtrele'**
  String get filterExceptionDesc;

  /// No description provided for @filterResolvedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Çözülme durumuna göre filtrele'**
  String get filterResolvedDesc;

  /// No description provided for @colUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get colUser;

  /// No description provided for @colIp.
  ///
  /// In tr, this message translates to:
  /// **'IP'**
  String get colIp;

  /// No description provided for @colPlatform.
  ///
  /// In tr, this message translates to:
  /// **'Platform'**
  String get colPlatform;

  /// No description provided for @colRelease.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get colRelease;

  /// No description provided for @colStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get colStart;

  /// No description provided for @colDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get colDuration;

  /// No description provided for @colEvent.
  ///
  /// In tr, this message translates to:
  /// **'Olay'**
  String get colEvent;

  /// No description provided for @sessionLoading.
  ///
  /// In tr, this message translates to:
  /// **'Oturum yükleniyor'**
  String get sessionLoading;

  /// No description provided for @sessionLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Oturum alınamadı: {error}'**
  String sessionLoadFailed(String error);

  /// No description provided for @sessionReplay.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt'**
  String get sessionReplay;

  /// No description provided for @sessionFramesAndDuration.
  ///
  /// In tr, this message translates to:
  /// **'{frames} kare · {duration}'**
  String sessionFramesAndDuration(int frames, String duration);

  /// No description provided for @sessionTimeline.
  ///
  /// In tr, this message translates to:
  /// **'Zaman çizgisi'**
  String get sessionTimeline;

  /// No description provided for @sessionItemCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} öğe'**
  String sessionItemCount(int count);

  /// No description provided for @sessionNoItems.
  ///
  /// In tr, this message translates to:
  /// **'Öğe yok.'**
  String get sessionNoItems;

  /// No description provided for @sessionHeader.
  ///
  /// In tr, this message translates to:
  /// **'Oturum {id}'**
  String sessionHeader(String id);

  /// No description provided for @sessionFullscreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturum {id} · {user}'**
  String sessionFullscreenTitle(String id, String user);

  /// No description provided for @replayNoFrames.
  ///
  /// In tr, this message translates to:
  /// **'Bu oturumda kare yok (SightpaneReplay sarılmamış ya da kayıt kapalı).'**
  String get replayNoFrames;

  /// No description provided for @replayNoFramesGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bu oturumda kare yok (oturum kaydı kapalı veya gönderilmemiş).'**
  String get replayNoFramesGeneric;

  /// No description provided for @replayDomPlayerTitle.
  ///
  /// In tr, this message translates to:
  /// **'DOM Kaydı ({count} olay)'**
  String replayDomPlayerTitle(int count);

  /// No description provided for @replayPosition.
  ///
  /// In tr, this message translates to:
  /// **'{position} / {total} sn'**
  String replayPosition(String position, String total);

  /// No description provided for @replayBuffer.
  ///
  /// In tr, this message translates to:
  /// **'önbellek {done}/{total}'**
  String replayBuffer(int done, int total);

  /// No description provided for @replayFullscreenHint.
  ///
  /// In tr, this message translates to:
  /// **'ESC kapatır · boşluk oynat/duraklat'**
  String get replayFullscreenHint;

  /// No description provided for @itemIssueLink.
  ///
  /// In tr, this message translates to:
  /// **'Hata grubu #{id}'**
  String itemIssueLink(int id);

  /// No description provided for @itemRoute.
  ///
  /// In tr, this message translates to:
  /// **'rota {route}'**
  String itemRoute(String route);

  /// No description provided for @itemBreadcrumbsBefore.
  ///
  /// In tr, this message translates to:
  /// **'Hata öncesi adımlar'**
  String get itemBreadcrumbsBefore;

  /// No description provided for @sessionClientInfo.
  ///
  /// In tr, this message translates to:
  /// **'İstemci ve Ortam Bilgileri'**
  String get sessionClientInfo;

  /// No description provided for @clientPlatform.
  ///
  /// In tr, this message translates to:
  /// **'Platform'**
  String get clientPlatform;

  /// No description provided for @clientPlatformDesktop.
  ///
  /// In tr, this message translates to:
  /// **'Masaüstü (Desktop)'**
  String get clientPlatformDesktop;

  /// No description provided for @clientPlatformWeb.
  ///
  /// In tr, this message translates to:
  /// **'Web'**
  String get clientPlatformWeb;

  /// No description provided for @clientPlatformMobile.
  ///
  /// In tr, this message translates to:
  /// **'Mobil'**
  String get clientPlatformMobile;

  /// No description provided for @clientOS.
  ///
  /// In tr, this message translates to:
  /// **'İşletim Sistemi'**
  String get clientOS;

  /// No description provided for @clientOsVersion.
  ///
  /// In tr, this message translates to:
  /// **'OS Sürümü'**
  String get clientOsVersion;

  /// No description provided for @clientKernel.
  ///
  /// In tr, this message translates to:
  /// **'Çekirdek (Kernel)'**
  String get clientKernel;

  /// No description provided for @clientKernelVersion.
  ///
  /// In tr, this message translates to:
  /// **'Çekirdek Sürümü'**
  String get clientKernelVersion;

  /// No description provided for @clientBrowser.
  ///
  /// In tr, this message translates to:
  /// **'Tarayıcı'**
  String get clientBrowser;

  /// No description provided for @clientBrowserVersion.
  ///
  /// In tr, this message translates to:
  /// **'Tarayıcı Sürümü'**
  String get clientBrowserVersion;

  /// No description provided for @clientArch.
  ///
  /// In tr, this message translates to:
  /// **'Mimari'**
  String get clientArch;

  /// No description provided for @clientCores.
  ///
  /// In tr, this message translates to:
  /// **'CPU Çekirdekleri'**
  String get clientCores;

  /// No description provided for @clientScreen.
  ///
  /// In tr, this message translates to:
  /// **'Ekran Çözünürlüğü'**
  String get clientScreen;

  /// No description provided for @clientLocale.
  ///
  /// In tr, this message translates to:
  /// **'Dil / Yerel Ayar'**
  String get clientLocale;

  /// No description provided for @clientSdk.
  ///
  /// In tr, this message translates to:
  /// **'SDK'**
  String get clientSdk;

  /// No description provided for @eventsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Olaylar'**
  String get eventsTitle;

  /// No description provided for @eventsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'son 30 gün'**
  String get eventsSubtitle;

  /// No description provided for @eventsTypes.
  ///
  /// In tr, this message translates to:
  /// **'Olay türleri'**
  String get eventsTypes;

  /// No description provided for @eventsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Olaylar alınamadı: {error}'**
  String eventsLoadFailed(String error);

  /// No description provided for @eventsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Olay yok. SDK’da Hog.capture(’olay’) çağırın.'**
  String get eventsEmpty;

  /// No description provided for @colTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get colTotal;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsProjectLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Proje alınamadı: {error}'**
  String settingsProjectLoadFailed(String error);

  /// No description provided for @settingsProject.
  ///
  /// In tr, this message translates to:
  /// **'Proje'**
  String get settingsProject;

  /// No description provided for @settingsMemberReadOnly.
  ///
  /// In tr, this message translates to:
  /// **'üye · yalnızca görüntüleme'**
  String get settingsMemberReadOnly;

  /// No description provided for @settingsProjectNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get settingsProjectNameLabel;

  /// No description provided for @settingsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get settingsSaved;

  /// No description provided for @settingsRotateKey.
  ///
  /// In tr, this message translates to:
  /// **'Anahtarı döndür'**
  String get settingsRotateKey;

  /// No description provided for @settingsRotateKeyBody.
  ///
  /// In tr, this message translates to:
  /// **'Eski anahtarla gönderen uygulamalar reddedilecek. Yeni anahtarı SDK yapılandırmasına işlemeniz gerekir.'**
  String get settingsRotateKeyBody;

  /// No description provided for @settingsRotate.
  ///
  /// In tr, this message translates to:
  /// **'Döndür'**
  String get settingsRotate;

  /// No description provided for @settingsSdkSetup.
  ///
  /// In tr, this message translates to:
  /// **'SDK kurulumu'**
  String get settingsSdkSetup;

  /// No description provided for @settingsSdkSetupNote.
  ///
  /// In tr, this message translates to:
  /// **'endpoint ve apiKey init sırasında verilir'**
  String get settingsSdkSetupNote;

  /// No description provided for @settingsMembers.
  ///
  /// In tr, this message translates to:
  /// **'Üyeler'**
  String get settingsMembers;

  /// No description provided for @settingsMemberRemoved.
  ///
  /// In tr, this message translates to:
  /// **'Üye çıkarıldı'**
  String get settingsMemberRemoved;

  /// No description provided for @settingsMemberAdded.
  ///
  /// In tr, this message translates to:
  /// **'Üye eklendi'**
  String get settingsMemberAdded;

  /// No description provided for @settingsAddMember.
  ///
  /// In tr, this message translates to:
  /// **'Üye ekle'**
  String get settingsAddMember;

  /// No description provided for @settingsMemberEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'uye@sirket.com (kayıtlı olmalı)'**
  String get settingsMemberEmailHint;

  /// No description provided for @settingsAlertsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uyarılar ve Bildirimler'**
  String get settingsAlertsTitle;

  /// No description provided for @settingsAlertChannels.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Kanalları'**
  String get settingsAlertChannels;

  /// No description provided for @settingsAlertChannelsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bildirim kanalı eklenmedi.'**
  String get settingsAlertChannelsEmpty;

  /// No description provided for @settingsAlertChannelAdd.
  ///
  /// In tr, this message translates to:
  /// **'Kanal ekle'**
  String get settingsAlertChannelAdd;

  /// No description provided for @settingsAlertChannelName.
  ///
  /// In tr, this message translates to:
  /// **'Kanal adı'**
  String get settingsAlertChannelName;

  /// No description provided for @settingsAlertChannelKind.
  ///
  /// In tr, this message translates to:
  /// **'Kanal türü'**
  String get settingsAlertChannelKind;

  /// No description provided for @settingsAlertChannelTarget.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get settingsAlertChannelTarget;

  /// No description provided for @settingsAlertChannelTargetHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta, Slack veya Webhook URL'**
  String get settingsAlertChannelTargetHint;

  /// No description provided for @settingsAlertChannelSecret.
  ///
  /// In tr, this message translates to:
  /// **'Gizli anahtar (Secret)'**
  String get settingsAlertChannelSecret;

  /// No description provided for @settingsAlertChannelSecretHint.
  ///
  /// In tr, this message translates to:
  /// **'Webhook için isteğe bağlı HMAC anahtarı'**
  String get settingsAlertChannelSecretHint;

  /// No description provided for @settingsAlertChannelTest.
  ///
  /// In tr, this message translates to:
  /// **'Test gönder'**
  String get settingsAlertChannelTest;

  /// No description provided for @settingsAlertChannelTestSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Test bildirimi başarıyla gönderildi.'**
  String get settingsAlertChannelTestSuccess;

  /// No description provided for @settingsAlertChannelDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu bildirim kanalını silmek istediğinize emin misiniz?'**
  String get settingsAlertChannelDeleteConfirm;

  /// No description provided for @settingsAlertRules.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı Kuralları'**
  String get settingsAlertRules;

  /// No description provided for @settingsAlertRulesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz uyarı kuralı eklenmedi.'**
  String get settingsAlertRulesEmpty;

  /// No description provided for @settingsAlertRuleAdd.
  ///
  /// In tr, this message translates to:
  /// **'Kural ekle'**
  String get settingsAlertRuleAdd;

  /// No description provided for @settingsAlertRuleName.
  ///
  /// In tr, this message translates to:
  /// **'Kural adı'**
  String get settingsAlertRuleName;

  /// No description provided for @settingsAlertRuleKind.
  ///
  /// In tr, this message translates to:
  /// **'Olay türü'**
  String get settingsAlertRuleKind;

  /// No description provided for @settingsAlertRuleKindNewIssue.
  ///
  /// In tr, this message translates to:
  /// **'Yeni hata'**
  String get settingsAlertRuleKindNewIssue;

  /// No description provided for @settingsAlertRuleKindRegression.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden oluşan hata (Regresyon)'**
  String get settingsAlertRuleKindRegression;

  /// No description provided for @settingsAlertRuleKindRateSpike.
  ///
  /// In tr, this message translates to:
  /// **'Hata oranı artışı (Spike)'**
  String get settingsAlertRuleKindRateSpike;

  /// No description provided for @settingsAlertRuleKindCrashFree.
  ///
  /// In tr, this message translates to:
  /// **'Çökmesiz oturum düşüşü'**
  String get settingsAlertRuleKindCrashFree;

  /// No description provided for @settingsAlertRuleChannels.
  ///
  /// In tr, this message translates to:
  /// **'Kanallar'**
  String get settingsAlertRuleChannels;

  /// No description provided for @settingsAlertRuleChannelsSelectHint.
  ///
  /// In tr, this message translates to:
  /// **'En az bir kanal seçin'**
  String get settingsAlertRuleChannelsSelectHint;

  /// No description provided for @settingsAlertRuleThreshold.
  ///
  /// In tr, this message translates to:
  /// **'Eşik değeri'**
  String get settingsAlertRuleThreshold;

  /// No description provided for @settingsAlertRuleWindow.
  ///
  /// In tr, this message translates to:
  /// **'Zaman aralığı (dakika)'**
  String get settingsAlertRuleWindow;

  /// No description provided for @settingsAlertRuleEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Etkin'**
  String get settingsAlertRuleEnabled;

  /// No description provided for @settingsAlertRuleDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu uyarı kuralını silmek istediğinize emin misiniz?'**
  String get settingsAlertRuleDeleteConfirm;

  /// No description provided for @settingsDangerZone.
  ///
  /// In tr, this message translates to:
  /// **'Tehlikeli bölge'**
  String get settingsDangerZone;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In tr, this message translates to:
  /// **'Projeyi ve tüm oturum, hata, kare verisini kalıcı olarak siler.'**
  String get settingsDeleteBody;

  /// No description provided for @settingsDeleteProject.
  ///
  /// In tr, this message translates to:
  /// **'Projeyi sil'**
  String get settingsDeleteProject;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" silinsin mi?'**
  String settingsDeleteConfirmTitle(String name);

  /// No description provided for @settingsDeleteConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz.'**
  String get settingsDeleteConfirmBody;

  /// No description provided for @performanceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Performans'**
  String get performanceTitle;

  /// No description provided for @performanceSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} işlem izleniyor'**
  String performanceSubtitle(int count);

  /// No description provided for @performanceEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz performans verisi yok.'**
  String get performanceEmpty;

  /// No description provided for @performanceLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Performans verisi yüklenemedi: {error}'**
  String performanceLoadFailed(String error);

  /// No description provided for @colOperation.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Türü'**
  String get colOperation;

  /// No description provided for @colTransaction.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Adı'**
  String get colTransaction;

  /// No description provided for @colP50.
  ///
  /// In tr, this message translates to:
  /// **'p50'**
  String get colP50;

  /// No description provided for @colP95.
  ///
  /// In tr, this message translates to:
  /// **'p95'**
  String get colP95;

  /// No description provided for @colAvg.
  ///
  /// In tr, this message translates to:
  /// **'Ort.'**
  String get colAvg;

  /// No description provided for @colCalls.
  ///
  /// In tr, this message translates to:
  /// **'Çağrı'**
  String get colCalls;

  /// No description provided for @colErrorRate.
  ///
  /// In tr, this message translates to:
  /// **'Hata %'**
  String get colErrorRate;

  /// No description provided for @colAction.
  ///
  /// In tr, this message translates to:
  /// **'İşlem'**
  String get colAction;

  /// No description provided for @performanceSlowestSamples.
  ///
  /// In tr, this message translates to:
  /// **'En Yavaş Örnekler'**
  String get performanceSlowestSamples;

  /// No description provided for @performanceViewReplay.
  ///
  /// In tr, this message translates to:
  /// **'Kaydı Aç'**
  String get performanceViewReplay;

  /// No description provided for @performanceDays7.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 Gün'**
  String get performanceDays7;

  /// No description provided for @performanceDays14.
  ///
  /// In tr, this message translates to:
  /// **'Son 14 Gün'**
  String get performanceDays14;

  /// No description provided for @performanceDays30.
  ///
  /// In tr, this message translates to:
  /// **'Son 30 Gün'**
  String get performanceDays30;

  /// No description provided for @usersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar'**
  String get usersTitle;

  /// No description provided for @usersSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} kullanıcı'**
  String usersSubtitle(int count);

  /// No description provided for @usersSearchPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı veya e-posta ara...'**
  String get usersSearchPlaceholder;

  /// No description provided for @usersLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar alınamadı: {error}'**
  String usersLoadFailed(String error);

  /// No description provided for @usersEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı.'**
  String get usersEmpty;

  /// No description provided for @kpiTotalUsers.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Kullanıcı'**
  String get kpiTotalUsers;

  /// No description provided for @kpiActiveUsers.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Kullanıcı (Dönem)'**
  String get kpiActiveUsers;

  /// No description provided for @kpiAvgDuration.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Süre'**
  String get kpiAvgDuration;

  /// No description provided for @kpiSessionsPerUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Başı Oturum'**
  String get kpiSessionsPerUser;

  /// No description provided for @chartActiveUsers.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Aktif Kullanıcılar (DAU)'**
  String get chartActiveUsers;

  /// No description provided for @chartActiveUsersSub.
  ///
  /// In tr, this message translates to:
  /// **'mavi aktif kullanıcılar · kırmızı hatalı kullanıcılar'**
  String get chartActiveUsersSub;

  /// No description provided for @colAvgDuration.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Süre'**
  String get colAvgDuration;

  /// No description provided for @colFirstSeen.
  ///
  /// In tr, this message translates to:
  /// **'İlk Görülme'**
  String get colFirstSeen;

  /// No description provided for @colLastSeen.
  ///
  /// In tr, this message translates to:
  /// **'Son Görülme'**
  String get colLastSeen;

  /// No description provided for @userDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Detayları'**
  String get userDetailTitle;

  /// No description provided for @actionViewSessions.
  ///
  /// In tr, this message translates to:
  /// **'Oturumları Gör'**
  String get actionViewSessions;

  /// No description provided for @actionExportData.
  ///
  /// In tr, this message translates to:
  /// **'Veriyi İndir (JSON)'**
  String get actionExportData;

  /// No description provided for @actionDeleteData.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Verisini Sil'**
  String get actionDeleteData;

  /// No description provided for @userDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcının tüm oturum ve hata kayıtları silinsin mi?'**
  String get userDeleteConfirm;

  /// No description provided for @userDeleteSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı verisi başarıyla silindi.'**
  String get userDeleteSuccess;

  /// No description provided for @userCustomProps.
  ///
  /// In tr, this message translates to:
  /// **'Özel Nitelikler'**
  String get userCustomProps;

  /// No description provided for @navFunnels.
  ///
  /// In tr, this message translates to:
  /// **'Huniler'**
  String get navFunnels;

  /// No description provided for @funnelsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dönüşüm Hunileri'**
  String get funnelsTitle;

  /// No description provided for @funnelsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} huni tanımlı'**
  String funnelsSubtitle(int count);

  /// No description provided for @funnelCreate.
  ///
  /// In tr, this message translates to:
  /// **'Huni Oluştur'**
  String get funnelCreate;

  /// No description provided for @funnelName.
  ///
  /// In tr, this message translates to:
  /// **'Huni Adı'**
  String get funnelName;

  /// No description provided for @funnelDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get funnelDescription;

  /// No description provided for @funnelSteps.
  ///
  /// In tr, this message translates to:
  /// **'Huni Adımları'**
  String get funnelSteps;

  /// No description provided for @funnelStepAdd.
  ///
  /// In tr, this message translates to:
  /// **'Adım Ekle'**
  String get funnelStepAdd;

  /// No description provided for @funnelStepEvent.
  ///
  /// In tr, this message translates to:
  /// **'Olay Adı'**
  String get funnelStepEvent;

  /// No description provided for @funnelWindow.
  ///
  /// In tr, this message translates to:
  /// **'Dönüşüm Penceresi'**
  String get funnelWindow;

  /// No description provided for @funnelWindow1d.
  ///
  /// In tr, this message translates to:
  /// **'1 Gün'**
  String get funnelWindow1d;

  /// No description provided for @funnelWindow7d.
  ///
  /// In tr, this message translates to:
  /// **'7 Gün'**
  String get funnelWindow7d;

  /// No description provided for @funnelWindow14d.
  ///
  /// In tr, this message translates to:
  /// **'14 Gün'**
  String get funnelWindow14d;

  /// No description provided for @funnelWindow30d.
  ///
  /// In tr, this message translates to:
  /// **'30 Gün'**
  String get funnelWindow30d;

  /// No description provided for @funnelsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tanımlanmış bir huni yok.'**
  String get funnelsEmpty;

  /// No description provided for @funnelsEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı yolculuklarındaki dönüşüm ve terk oranlarını izlemek için ilk huninizi oluşturun.'**
  String get funnelsEmptyHint;

  /// No description provided for @funnelOverallConversion.
  ///
  /// In tr, this message translates to:
  /// **'Genel Dönüşüm Oranı'**
  String get funnelOverallConversion;

  /// No description provided for @funnelCompletedSessions.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlayan Oturum'**
  String get funnelCompletedSessions;

  /// No description provided for @funnelTotalSessions.
  ///
  /// In tr, this message translates to:
  /// **'Başlayan Oturum'**
  String get funnelTotalSessions;

  /// No description provided for @funnelMedianTime.
  ///
  /// In tr, this message translates to:
  /// **'Medyan Dönüşüm Süresi'**
  String get funnelMedianTime;

  /// No description provided for @funnelStepConversion.
  ///
  /// In tr, this message translates to:
  /// **'Adım Dönüşümü'**
  String get funnelStepConversion;

  /// No description provided for @funnelDropOff.
  ///
  /// In tr, this message translates to:
  /// **'Terk Eden'**
  String get funnelDropOff;

  /// No description provided for @funnelWatchReplays.
  ///
  /// In tr, this message translates to:
  /// **'Terk Eden Kayıtları İzle ({count})'**
  String funnelWatchReplays(int count);

  /// No description provided for @funnelDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu huniyi silmek istediğinizden emin misiniz?'**
  String get funnelDeleteConfirm;

  /// No description provided for @funnelDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Huni silindi.'**
  String get funnelDeleted;

  /// No description provided for @funnelCreated.
  ///
  /// In tr, this message translates to:
  /// **'Huni oluşturuldu.'**
  String get funnelCreated;

  /// No description provided for @funnelUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Huni güncellendi.'**
  String get funnelUpdated;

  /// No description provided for @funnelStepMin.
  ///
  /// In tr, this message translates to:
  /// **'En az 2 adım gereklidir.'**
  String get funnelStepMin;

  /// No description provided for @navRetention.
  ///
  /// In tr, this message translates to:
  /// **'Elde Tutma (Retention)'**
  String get navRetention;

  /// No description provided for @navCohorts.
  ///
  /// In tr, this message translates to:
  /// **'Kohortlar'**
  String get navCohorts;

  /// No description provided for @retentionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Elde Tutma Matrisi'**
  String get retentionTitle;

  /// No description provided for @retentionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıların zaman içinde uygulamanıza geri dönüş oranlarını kohort bazında analiz edin.'**
  String get retentionSubtitle;

  /// No description provided for @retentionPeriodDay.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get retentionPeriodDay;

  /// No description provided for @retentionPeriodWeek.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get retentionPeriodWeek;

  /// No description provided for @retentionTargetEvent.
  ///
  /// In tr, this message translates to:
  /// **'İlk Olay (Hedef)'**
  String get retentionTargetEvent;

  /// No description provided for @retentionReturnEvent.
  ///
  /// In tr, this message translates to:
  /// **'Dönüş Olayı'**
  String get retentionReturnEvent;

  /// No description provided for @retentionAllUsers.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Kullanıcılar'**
  String get retentionAllUsers;

  /// No description provided for @retentionCohortFilter.
  ///
  /// In tr, this message translates to:
  /// **'Kohort Filtresi'**
  String get retentionCohortFilter;

  /// No description provided for @retentionHeatmapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Elde Tutma Isı Haritası'**
  String get retentionHeatmapTitle;

  /// No description provided for @retentionBucket.
  ///
  /// In tr, this message translates to:
  /// **'Kohort Başlangıcı'**
  String get retentionBucket;

  /// No description provided for @retentionUsers.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get retentionUsers;

  /// No description provided for @retentionPeriodN.
  ///
  /// In tr, this message translates to:
  /// **'{unit} {index}'**
  String retentionPeriodN(String unit, int index);

  /// No description provided for @retentionEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen aralıkta elde tutma verisi bulunamadı.'**
  String get retentionEmpty;

  /// No description provided for @cohortsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Davranışsal Kohortlar'**
  String get cohortsTitle;

  /// No description provided for @cohortsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıları belirli davranış ve özelliklere göre segmentlere ayırın.'**
  String get cohortsSubtitle;

  /// No description provided for @newCohort.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kohort'**
  String get newCohort;

  /// No description provided for @cohortName.
  ///
  /// In tr, this message translates to:
  /// **'Kohort Adı'**
  String get cohortName;

  /// No description provided for @cohortDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get cohortDescription;

  /// No description provided for @cohortRules.
  ///
  /// In tr, this message translates to:
  /// **'Dinamik Kurallar'**
  String get cohortRules;

  /// No description provided for @cohortDynamic.
  ///
  /// In tr, this message translates to:
  /// **'Dinamik'**
  String get cohortDynamic;

  /// No description provided for @cohortStatic.
  ///
  /// In tr, this message translates to:
  /// **'Statik'**
  String get cohortStatic;

  /// No description provided for @cohortMemberCount.
  ///
  /// In tr, this message translates to:
  /// **'Üye Sayısı'**
  String get cohortMemberCount;

  /// No description provided for @refreshCohort.
  ///
  /// In tr, this message translates to:
  /// **'Kohortu Güncelle'**
  String get refreshCohort;

  /// No description provided for @cohortRefreshed.
  ///
  /// In tr, this message translates to:
  /// **'Kohort üyeleri güncellendi.'**
  String get cohortRefreshed;

  /// No description provided for @cohortCreated.
  ///
  /// In tr, this message translates to:
  /// **'Kohort oluşturuldu.'**
  String get cohortCreated;

  /// No description provided for @cohortDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kohort silindi.'**
  String get cohortDeleted;

  /// No description provided for @cohortDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu kohortu silmek istediğinizden emin misiniz?'**
  String get cohortDeleteConfirm;

  /// No description provided for @cohortEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tanımlanmış bir kohort yok.'**
  String get cohortEmpty;

  /// No description provided for @cohortEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıları davranışlarına göre gruplandırmak için ilk kohortunuzu oluşturun.'**
  String get cohortEmptyHint;

  /// No description provided for @cohortAddRule.
  ///
  /// In tr, this message translates to:
  /// **'Kural Ekle'**
  String get cohortAddRule;

  /// No description provided for @cohortEventName.
  ///
  /// In tr, this message translates to:
  /// **'Olay Adı'**
  String get cohortEventName;

  /// No description provided for @cohortOperator.
  ///
  /// In tr, this message translates to:
  /// **'İşleç'**
  String get cohortOperator;

  /// No description provided for @cohortValue.
  ///
  /// In tr, this message translates to:
  /// **'Değer'**
  String get cohortValue;

  /// No description provided for @cohortWindowDays.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Penceresi (Gün)'**
  String get cohortWindowDays;

  /// No description provided for @navPaths.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Yolları (Paths)'**
  String get navPaths;

  /// No description provided for @pathsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Yolculuk Akışları'**
  String get pathsTitle;

  /// No description provided for @pathsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıların ekranlar ve olaylar arasındaki geçişlerini Sankey akış şemasıyla inceleyin.'**
  String get pathsSubtitle;

  /// No description provided for @pathsForward.
  ///
  /// In tr, this message translates to:
  /// **'İleri (Başlangıçtan)'**
  String get pathsForward;

  /// No description provided for @pathsReverse.
  ///
  /// In tr, this message translates to:
  /// **'Geriye Doğru (Hedefe)'**
  String get pathsReverse;

  /// No description provided for @pathsRootEvent.
  ///
  /// In tr, this message translates to:
  /// **'Kök Olay / Ekran'**
  String get pathsRootEvent;

  /// No description provided for @pathsRootPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Örn: route:/login veya error'**
  String get pathsRootPlaceholder;

  /// No description provided for @pathsStepLimit.
  ///
  /// In tr, this message translates to:
  /// **'Adım Derinliği'**
  String get pathsStepLimit;

  /// No description provided for @pathsExclude.
  ///
  /// In tr, this message translates to:
  /// **'Hariç Tutulanlar'**
  String get pathsExclude;

  /// No description provided for @pathsExcludePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Örn: heartbeat, pointer'**
  String get pathsExcludePlaceholder;

  /// No description provided for @pathsThreshold.
  ///
  /// In tr, this message translates to:
  /// **'Eşik (%)'**
  String get pathsThreshold;

  /// No description provided for @pathsDiagramTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçiş Akış Şeması (Sankey)'**
  String get pathsDiagramTitle;

  /// No description provided for @pathsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen kriterlere uygun kullanıcı yolu bulunamadı.'**
  String get pathsEmpty;

  /// No description provided for @pathsSampleSessions.
  ///
  /// In tr, this message translates to:
  /// **'Örnek Oturumlar ({count})'**
  String pathsSampleSessions(int count);

  /// No description provided for @pathsReplaysModalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuk Oturum Kayıtları'**
  String get pathsReplaysModalTitle;

  /// No description provided for @pathsExit.
  ///
  /// In tr, this message translates to:
  /// **'Terk (Exit)'**
  String get pathsExit;

  /// No description provided for @navFeatureFlags.
  ///
  /// In tr, this message translates to:
  /// **'Özellik Bayrakları (Flags)'**
  String get navFeatureFlags;

  /// No description provided for @flagsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özellik Bayrakları & Uzaktan Yapılandırma'**
  String get flagsTitle;

  /// No description provided for @flagsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kod yayınlamadan özellikleri anında açıp kapatın, kademeli dağıtım (canary) ve kural hedeflemesi yapın.'**
  String get flagsSubtitle;

  /// No description provided for @flagsNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bayrak'**
  String get flagsNew;

  /// No description provided for @flagsKey.
  ///
  /// In tr, this message translates to:
  /// **'Bayrak Anahtarı (Key)'**
  String get flagsKey;

  /// No description provided for @flagsKeyHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: new_checkout_flow'**
  String get flagsKeyHint;

  /// No description provided for @flagsName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get flagsName;

  /// No description provided for @flagsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get flagsDesc;

  /// No description provided for @flagsRollout.
  ///
  /// In tr, this message translates to:
  /// **'Kademeli Dağıtım (%)'**
  String get flagsRollout;

  /// No description provided for @flagsActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get flagsActive;

  /// No description provided for @flagsDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Devre Dışı'**
  String get flagsDisabled;

  /// No description provided for @flagsVariants.
  ///
  /// In tr, this message translates to:
  /// **'Çoklu Varyantlar (Multivariant)'**
  String get flagsVariants;

  /// No description provided for @flagsFilters.
  ///
  /// In tr, this message translates to:
  /// **'Hedefleme Kuralları'**
  String get flagsFilters;

  /// No description provided for @flagsAddFilter.
  ///
  /// In tr, this message translates to:
  /// **'Kural Ekle'**
  String get flagsAddFilter;

  /// No description provided for @flagsAddVariant.
  ///
  /// In tr, this message translates to:
  /// **'Varyant Ekle'**
  String get flagsAddVariant;

  /// No description provided for @flagsTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Değerlendirme Testi'**
  String get flagsTestTitle;

  /// No description provided for @flagsTestDistinctId.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı ID (distinct_id)'**
  String get flagsTestDistinctId;

  /// No description provided for @flagsTestResult.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirme Sonucu'**
  String get flagsTestResult;

  /// No description provided for @flagsDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Bayrak silindi.'**
  String get flagsDeleted;

  /// No description provided for @flagsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Bayrak kaydedildi.'**
  String get flagsSaved;

  /// No description provided for @flagsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir özellik bayrağı oluşturulmadı.'**
  String get flagsEmpty;

  /// No description provided for @navExperiments.
  ///
  /// In tr, this message translates to:
  /// **'Deneyler (A/B Testi)'**
  String get navExperiments;

  /// No description provided for @experimentsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Deneyler (A/B Testi)'**
  String get experimentsTitle;

  /// No description provided for @experimentsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Dönüşüm oranlarını artırmak ve hipotezleri istatistiksel güvenle doğrulamak için kontrollü A/B testleri çalıştırın.'**
  String get experimentsDesc;

  /// No description provided for @experimentsNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Deney'**
  String get experimentsNew;

  /// No description provided for @experimentsRunning.
  ///
  /// In tr, this message translates to:
  /// **'Devam Eden'**
  String get experimentsRunning;

  /// No description provided for @experimentsDraft.
  ///
  /// In tr, this message translates to:
  /// **'Taslak'**
  String get experimentsDraft;

  /// No description provided for @experimentsConcluded.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get experimentsConcluded;

  /// No description provided for @experimentsTargetMetric.
  ///
  /// In tr, this message translates to:
  /// **'Birincil Hedef Olayı'**
  String get experimentsTargetMetric;

  /// No description provided for @experimentsFlagKey.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı Özellik Bayrağı'**
  String get experimentsFlagKey;

  /// No description provided for @experimentsSampleSize.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Örneklem Boyutu'**
  String get experimentsSampleSize;

  /// No description provided for @experimentsSignificant.
  ///
  /// In tr, this message translates to:
  /// **'İstatistiksel Olarak Anlamlı'**
  String get experimentsSignificant;

  /// No description provided for @experimentsNeedsData.
  ///
  /// In tr, this message translates to:
  /// **'Daha Fazla Veri Gerekiyor'**
  String get experimentsNeedsData;

  /// No description provided for @experimentsDeclareWinner.
  ///
  /// In tr, this message translates to:
  /// **'Kazananı İlan Et'**
  String get experimentsDeclareWinner;

  /// No description provided for @experimentsRolloutWinner.
  ///
  /// In tr, this message translates to:
  /// **'Kazananı %100 Dağıt'**
  String get experimentsRolloutWinner;

  /// No description provided for @experimentsWinnerDeclared.
  ///
  /// In tr, this message translates to:
  /// **'Kazanan ilan edildi ve özellik bayrağı %100 güncellendi.'**
  String get experimentsWinnerDeclared;

  /// No description provided for @experimentsConversionRate.
  ///
  /// In tr, this message translates to:
  /// **'Dönüşüm Oranı'**
  String get experimentsConversionRate;

  /// No description provided for @experimentsParticipants.
  ///
  /// In tr, this message translates to:
  /// **'Katılımcılar'**
  String get experimentsParticipants;

  /// No description provided for @experimentsConversions.
  ///
  /// In tr, this message translates to:
  /// **'Dönüşümler'**
  String get experimentsConversions;

  /// No description provided for @experimentsRelativeLift.
  ///
  /// In tr, this message translates to:
  /// **'Göreceli Artış'**
  String get experimentsRelativeLift;

  /// No description provided for @experimentsChanceToWin.
  ///
  /// In tr, this message translates to:
  /// **'Kazanma Şansı'**
  String get experimentsChanceToWin;

  /// No description provided for @experimentsConfidenceInterval.
  ///
  /// In tr, this message translates to:
  /// **'%95 Güven Aralığı'**
  String get experimentsConfidenceInterval;

  /// No description provided for @experimentsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir A/B deneyi oluşturulmadı.'**
  String get experimentsEmpty;

  /// No description provided for @experimentsDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu deneyi silmek istediğinizden emin misiniz?'**
  String get experimentsDeleteConfirm;

  /// No description provided for @navSurveys.
  ///
  /// In tr, this message translates to:
  /// **'Anketler & Geri Bildirim'**
  String get navSurveys;

  /// No description provided for @surveysTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Anketleri & Geri Bildirim'**
  String get surveysTitle;

  /// No description provided for @surveysDesc.
  ///
  /// In tr, this message translates to:
  /// **'NPS, CSAT ve serbest metin anketleriyle doğrudan oturum kayıtlarına bağlı kullanıcı geri bildirimleri toplayın.'**
  String get surveysDesc;

  /// No description provided for @surveysNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Anket'**
  String get surveysNew;

  /// No description provided for @surveysType.
  ///
  /// In tr, this message translates to:
  /// **'Anket Türü'**
  String get surveysType;

  /// No description provided for @surveysQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Soru'**
  String get surveysQuestion;

  /// No description provided for @surveysResponses.
  ///
  /// In tr, this message translates to:
  /// **'Yanıtlar'**
  String get surveysResponses;

  /// No description provided for @surveysNpsScore.
  ///
  /// In tr, this message translates to:
  /// **'Net Promoter Score (NPS)'**
  String get surveysNpsScore;

  /// No description provided for @surveysCsatScore.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri Memnuniyeti (CSAT)'**
  String get surveysCsatScore;

  /// No description provided for @surveysPromoters.
  ///
  /// In tr, this message translates to:
  /// **'Destekçiler (9-10)'**
  String get surveysPromoters;

  /// No description provided for @surveysPassives.
  ///
  /// In tr, this message translates to:
  /// **'Pasifler (7-8)'**
  String get surveysPassives;

  /// No description provided for @surveysDetractors.
  ///
  /// In tr, this message translates to:
  /// **'Kötüleyenler (0-6)'**
  String get surveysDetractors;

  /// No description provided for @surveysWatchReplay.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu İzle'**
  String get surveysWatchReplay;

  /// No description provided for @surveysNoReplay.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Yok'**
  String get surveysNoReplay;

  /// No description provided for @surveysEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir anket oluşturulmadı.'**
  String get surveysEmpty;

  /// No description provided for @surveysDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu anketi silmek istediğinizden emin misiniz?'**
  String get surveysDeleteConfirm;

  /// No description provided for @surveysDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Anket silindi.'**
  String get surveysDeleted;

  /// No description provided for @surveysSaved.
  ///
  /// In tr, this message translates to:
  /// **'Anket kaydedildi.'**
  String get surveysSaved;

  /// No description provided for @surveysScoreDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Puan Dağılımı'**
  String get surveysScoreDistribution;

  /// No description provided for @surveysIndividualResponses.
  ///
  /// In tr, this message translates to:
  /// **'Bireysel Yanıtlar'**
  String get surveysIndividualResponses;

  /// No description provided for @surveysActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get surveysActive;

  /// No description provided for @surveysInactive.
  ///
  /// In tr, this message translates to:
  /// **'Pasif'**
  String get surveysInactive;

  /// No description provided for @navCrons.
  ///
  /// In tr, this message translates to:
  /// **'Cron & Heartbeat'**
  String get navCrons;

  /// No description provided for @cronsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cron İşleri & Heartbeat İzleme'**
  String get cronsTitle;

  /// No description provided for @cronsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan işlerinizi, zamanlanmış görevleri ve worker heartbeat sinyallerini izleyin, gecikmelerde anında uyarı alın.'**
  String get cronsDesc;

  /// No description provided for @cronsNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Cron İzleyici'**
  String get cronsNew;

  /// No description provided for @cronsSchedule.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlama (Crontab)'**
  String get cronsSchedule;

  /// No description provided for @cronsTimezone.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Dilimi'**
  String get cronsTimezone;

  /// No description provided for @cronsGracePeriod.
  ///
  /// In tr, this message translates to:
  /// **'Tolerans Süresi (dk)'**
  String get cronsGracePeriod;

  /// No description provided for @cronsMaxRuntime.
  ///
  /// In tr, this message translates to:
  /// **'Maks Çalışma Süresi (dk)'**
  String get cronsMaxRuntime;

  /// No description provided for @cronsNextExpected.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Beklenen'**
  String get cronsNextExpected;

  /// No description provided for @cronsLastCheckin.
  ///
  /// In tr, this message translates to:
  /// **'Son Check-in'**
  String get cronsLastCheckin;

  /// No description provided for @cronsStatusOk.
  ///
  /// In tr, this message translates to:
  /// **'Çalışıyor'**
  String get cronsStatusOk;

  /// No description provided for @cronsStatusInProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşlemde'**
  String get cronsStatusInProgress;

  /// No description provided for @cronsStatusMissed.
  ///
  /// In tr, this message translates to:
  /// **'Kaçırıldı'**
  String get cronsStatusMissed;

  /// No description provided for @cronsStatusError.
  ///
  /// In tr, this message translates to:
  /// **'Hata Aldı'**
  String get cronsStatusError;

  /// No description provided for @cronsTimeline24h.
  ///
  /// In tr, this message translates to:
  /// **'24 Saatlik Durum Geçmişi'**
  String get cronsTimeline24h;

  /// No description provided for @cronsIntegrationSnippets.
  ///
  /// In tr, this message translates to:
  /// **'Entegrasyon Kodları'**
  String get cronsIntegrationSnippets;

  /// No description provided for @cronsHistory.
  ///
  /// In tr, this message translates to:
  /// **'Check-in Geçmişi'**
  String get cronsHistory;

  /// No description provided for @cronsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir cron izleyicisi eklenmedi.'**
  String get cronsEmpty;

  /// No description provided for @cronsDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu cron izleyicisini silmek istediğinizden emin misiniz?'**
  String get cronsDeleteConfirm;

  /// No description provided for @cronsDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Cron izleyicisi silindi.'**
  String get cronsDeleted;

  /// No description provided for @cronsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Cron izleyicisi kaydedildi.'**
  String get cronsSaved;

  /// No description provided for @cronsSlug.
  ///
  /// In tr, this message translates to:
  /// **'Slug / Tanımlayıcı'**
  String get cronsSlug;

  /// No description provided for @cronsName.
  ///
  /// In tr, this message translates to:
  /// **'İzleyici Adı'**
  String get cronsName;

  /// No description provided for @cronsDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get cronsDuration;

  /// No description provided for @cronsMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get cronsMessage;

  /// No description provided for @cronsTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam İzleyici'**
  String get cronsTotal;

  /// No description provided for @navUptime.
  ///
  /// In tr, this message translates to:
  /// **'Uptime & Sentetik'**
  String get navUptime;

  /// No description provided for @uptimeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uptime & Sentetik İzleme'**
  String get uptimeTitle;

  /// No description provided for @uptimeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uç nokta erişilebilirliğini, yanıt sürelerini ve SSL sertifika geçerliliğini aktif olarak izleyin.'**
  String get uptimeDesc;

  /// No description provided for @uptimeNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İzleyici'**
  String get uptimeNew;

  /// No description provided for @uptimeEdit.
  ///
  /// In tr, this message translates to:
  /// **'İzleyiciyi Düzenle'**
  String get uptimeEdit;

  /// No description provided for @uptimeEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir uptime izleyicisi eklenmedi.'**
  String get uptimeEmpty;

  /// No description provided for @uptimeEmptyDesc.
  ///
  /// In tr, this message translates to:
  /// **'API ve web uygulamalarınız için sentetik sağlık kontrolleri oluşturarak kesintileri anında tespit edin.'**
  String get uptimeEmptyDesc;

  /// No description provided for @uptimeTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam İzleyici'**
  String get uptimeTotal;

  /// No description provided for @uptimeSLA.
  ///
  /// In tr, this message translates to:
  /// **'SLA Oranı'**
  String get uptimeSLA;

  /// No description provided for @uptimeUp.
  ///
  /// In tr, this message translates to:
  /// **'Çalışıyor'**
  String get uptimeUp;

  /// No description provided for @uptimeDegraded.
  ///
  /// In tr, this message translates to:
  /// **'Kısmi Kesinti'**
  String get uptimeDegraded;

  /// No description provided for @uptimeDown.
  ///
  /// In tr, this message translates to:
  /// **'Kesintide'**
  String get uptimeDown;

  /// No description provided for @uptimeCheckNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Kontrol Et'**
  String get uptimeCheckNow;

  /// No description provided for @uptimeChecking.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol ediliyor...'**
  String get uptimeChecking;

  /// No description provided for @uptimeCheckedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol başarıyla tamamlandı.'**
  String get uptimeCheckedSuccess;

  /// No description provided for @uptimeCheckedFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol başarısız oldu.'**
  String get uptimeCheckedFailed;

  /// No description provided for @uptimeDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu uptime izleyicisini silmek istediğinizden emin misiniz?'**
  String get uptimeDeleteConfirm;

  /// No description provided for @uptimeDeleted.
  ///
  /// In tr, this message translates to:
  /// **'İzleyici silindi.'**
  String get uptimeDeleted;

  /// No description provided for @uptimeSaved.
  ///
  /// In tr, this message translates to:
  /// **'İzleyici kaydedildi.'**
  String get uptimeSaved;

  /// No description provided for @uptimeName.
  ///
  /// In tr, this message translates to:
  /// **'İzleyici Adı'**
  String get uptimeName;

  /// No description provided for @uptimeURL.
  ///
  /// In tr, this message translates to:
  /// **'Hedef URL'**
  String get uptimeURL;

  /// No description provided for @uptimeMethod.
  ///
  /// In tr, this message translates to:
  /// **'HTTP Yöntemi'**
  String get uptimeMethod;

  /// No description provided for @uptimeInterval.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Aralığı'**
  String get uptimeInterval;

  /// No description provided for @uptimeTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Aşımı'**
  String get uptimeTimeout;

  /// No description provided for @uptimeExpectedStatus.
  ///
  /// In tr, this message translates to:
  /// **'Beklenen Durum Kodu'**
  String get uptimeExpectedStatus;

  /// No description provided for @uptimeSSLCheck.
  ///
  /// In tr, this message translates to:
  /// **'SSL/TLS Sertifika Kontrolü'**
  String get uptimeSSLCheck;

  /// No description provided for @uptimeSSLIssuer.
  ///
  /// In tr, this message translates to:
  /// **'Sertifika Sağlayıcı'**
  String get uptimeSSLIssuer;

  /// No description provided for @uptimeSSLExpires.
  ///
  /// In tr, this message translates to:
  /// **'SSL Süresi'**
  String get uptimeSSLExpires;

  /// No description provided for @uptimeSSLValid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli'**
  String get uptimeSSLValid;

  /// No description provided for @uptimeSSLExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi Doldu'**
  String get uptimeSSLExpired;

  /// No description provided for @uptimeSSLDaysLeft.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün kaldı'**
  String uptimeSSLDaysLeft(int days);

  /// No description provided for @uptimeTimeline90d.
  ///
  /// In tr, this message translates to:
  /// **'90 Günlük Erişilebilirlik Geçmişi'**
  String get uptimeTimeline90d;

  /// No description provided for @uptimeResponseTime.
  ///
  /// In tr, this message translates to:
  /// **'Yanıt Süresi'**
  String get uptimeResponseTime;

  /// No description provided for @uptimeAvgResponseTime.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Yanıt Süresi'**
  String get uptimeAvgResponseTime;

  /// No description provided for @uptimeRecentChecks.
  ///
  /// In tr, this message translates to:
  /// **'Son Kontroller'**
  String get uptimeRecentChecks;

  /// No description provided for @uptimeStatusCode.
  ///
  /// In tr, this message translates to:
  /// **'Durum Kodu'**
  String get uptimeStatusCode;

  /// No description provided for @uptimeCheckedAt.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Zamanı'**
  String get uptimeCheckedAt;

  /// No description provided for @uptimeErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hata Detayı'**
  String get uptimeErrorMessage;

  /// No description provided for @uptimeStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get uptimeStatus;

  /// No description provided for @uptimeLastChecked.
  ///
  /// In tr, this message translates to:
  /// **'Son Kontrol'**
  String get uptimeLastChecked;

  /// No description provided for @navAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Metrik Uyarıları'**
  String get navAlerts;

  /// No description provided for @alertsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Metrik Uyarıları & Anomali Tespiti'**
  String get alertsTitle;

  /// No description provided for @alertsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Metrik eşiklerini, anomali artışlarını ve olay durumlarını izleyin.'**
  String get alertsSubtitle;

  /// No description provided for @alertsTabRules.
  ///
  /// In tr, this message translates to:
  /// **'Kurallar'**
  String get alertsTabRules;

  /// No description provided for @alertsTabIncidents.
  ///
  /// In tr, this message translates to:
  /// **'Olay Geçmişi'**
  String get alertsTabIncidents;

  /// No description provided for @alertsNewRule.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kural'**
  String get alertsNewRule;

  /// No description provided for @alertsEditRule.
  ///
  /// In tr, this message translates to:
  /// **'Kuralı Düzenle'**
  String get alertsEditRule;

  /// No description provided for @alertsRuleName.
  ///
  /// In tr, this message translates to:
  /// **'Kural Adı'**
  String get alertsRuleName;

  /// No description provided for @alertsMetricType.
  ///
  /// In tr, this message translates to:
  /// **'Metrik Türü'**
  String get alertsMetricType;

  /// No description provided for @alertsComparison.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırma Operatörü'**
  String get alertsComparison;

  /// No description provided for @alertsCriticalThreshold.
  ///
  /// In tr, this message translates to:
  /// **'Kritik Eşik'**
  String get alertsCriticalThreshold;

  /// No description provided for @alertsWarningThreshold.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı Eşiği (İsteğe bağlı)'**
  String get alertsWarningThreshold;

  /// No description provided for @alertsWindowMinutes.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirme Penceresi'**
  String get alertsWindowMinutes;

  /// No description provided for @alertsTargetFilter.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Filtresi (örn: route:/checkout)'**
  String get alertsTargetFilter;

  /// No description provided for @alertsChannels.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Kanalları'**
  String get alertsChannels;

  /// No description provided for @alertsSaveRule.
  ///
  /// In tr, this message translates to:
  /// **'Kuralı Kaydet'**
  String get alertsSaveRule;

  /// No description provided for @alertsRuleSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kural başarıyla kaydedildi.'**
  String get alertsRuleSaved;

  /// No description provided for @alertsDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu metrik uyarı kuralını silmek istediğinize emin misiniz?'**
  String get alertsDeleteConfirm;

  /// No description provided for @alertsDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kural silindi.'**
  String get alertsDeleted;

  /// No description provided for @alertsStatusFiring.
  ///
  /// In tr, this message translates to:
  /// **'Tetiklendi'**
  String get alertsStatusFiring;

  /// No description provided for @alertsStatusWarning.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı'**
  String get alertsStatusWarning;

  /// No description provided for @alertsStatusOk.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get alertsStatusOk;

  /// No description provided for @alertsStatusResolved.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü'**
  String get alertsStatusResolved;

  /// No description provided for @alertsPreviewChart.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş Metrik & Eşik Önizlemesi (Son 7 Gün)'**
  String get alertsPreviewChart;

  /// No description provided for @alertsPreviewSub.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş verilere göre kuralın ne zaman tetikleneceğini görselleştirin.'**
  String get alertsPreviewSub;

  /// No description provided for @alertsEmptyRules.
  ///
  /// In tr, this message translates to:
  /// **'Henüz metrik kuralı tanımlanmadı.'**
  String get alertsEmptyRules;

  /// No description provided for @alertsEmptyIncidents.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı olay bulunmuyor.'**
  String get alertsEmptyIncidents;

  /// No description provided for @alertsPeakValue.
  ///
  /// In tr, this message translates to:
  /// **'Zirve Değer'**
  String get alertsPeakValue;

  /// No description provided for @alertsDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get alertsDuration;

  /// No description provided for @alertsTriggerNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Test Et'**
  String get alertsTriggerNow;

  /// No description provided for @alertsOperatorGt.
  ///
  /// In tr, this message translates to:
  /// **'Büyüktür (>)'**
  String get alertsOperatorGt;

  /// No description provided for @alertsOperatorGte.
  ///
  /// In tr, this message translates to:
  /// **'Büyük veya eşittir (>=)'**
  String get alertsOperatorGte;

  /// No description provided for @alertsOperatorLt.
  ///
  /// In tr, this message translates to:
  /// **'Küçüktür (<)'**
  String get alertsOperatorLt;

  /// No description provided for @alertsOperatorSpike.
  ///
  /// In tr, this message translates to:
  /// **'Anomali Artışı (x Kat)'**
  String get alertsOperatorSpike;

  /// No description provided for @alertsMetricErrorCount.
  ///
  /// In tr, this message translates to:
  /// **'Hata Sayısı'**
  String get alertsMetricErrorCount;

  /// No description provided for @alertsMetricErrorRate.
  ///
  /// In tr, this message translates to:
  /// **'Hata Oranı (%)'**
  String get alertsMetricErrorRate;

  /// No description provided for @alertsMetricP95Duration.
  ///
  /// In tr, this message translates to:
  /// **'p95 Yanıt Süresi (ms)'**
  String get alertsMetricP95Duration;

  /// No description provided for @alertsMetricCrashCount.
  ///
  /// In tr, this message translates to:
  /// **'Çökme Sayısı'**
  String get alertsMetricCrashCount;

  /// No description provided for @navTraces.
  ///
  /// In tr, this message translates to:
  /// **'Dağıtık İzler (Traces)'**
  String get navTraces;

  /// No description provided for @tracesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dağıtık İzleme & Waterfall'**
  String get tracesTitle;

  /// No description provided for @tracesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Mikroservisler ve veritabanı sorguları arasındaki gecikme ve N+1 sorunlarını analiz edin.'**
  String get tracesSubtitle;

  /// No description provided for @tracesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir iz (trace) kaydı bulunamadı.'**
  String get tracesEmpty;

  /// No description provided for @tracesFilterService.
  ///
  /// In tr, this message translates to:
  /// **'Servis'**
  String get tracesFilterService;

  /// No description provided for @tracesFilterMinDuration.
  ///
  /// In tr, this message translates to:
  /// **'Min Süre (ms)'**
  String get tracesFilterMinDuration;

  /// No description provided for @tracesSearchPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'İz ID veya kök işlem ara...'**
  String get tracesSearchPlaceholder;

  /// No description provided for @traceDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'İz Detayı'**
  String get traceDetailTitle;

  /// No description provided for @traceDetailSpanCount.
  ///
  /// In tr, this message translates to:
  /// **'Span Sayısı'**
  String get traceDetailSpanCount;

  /// No description provided for @traceDetailServiceCount.
  ///
  /// In tr, this message translates to:
  /// **'Servis Sayısı'**
  String get traceDetailServiceCount;

  /// No description provided for @traceDetailDuration.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre'**
  String get traceDetailDuration;

  /// No description provided for @traceSuspectNPlus1.
  ///
  /// In tr, this message translates to:
  /// **'Olası N+1 Sorgu Sorunu Tespit Edildi!'**
  String get traceSuspectNPlus1;

  /// No description provided for @traceSpanDetails.
  ///
  /// In tr, this message translates to:
  /// **'Span Detayı'**
  String get traceSpanDetails;

  /// No description provided for @traceSqlStatement.
  ///
  /// In tr, this message translates to:
  /// **'SQL Sorgusu'**
  String get traceSqlStatement;

  /// No description provided for @traceAttributes.
  ///
  /// In tr, this message translates to:
  /// **'Nitelikler & Etiketler'**
  String get traceAttributes;

  /// No description provided for @traceStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get traceStatus;

  /// No description provided for @traceRootSpan.
  ///
  /// In tr, this message translates to:
  /// **'Kök İşlem'**
  String get traceRootSpan;

  /// No description provided for @traceTimestamp.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Zamanı'**
  String get traceTimestamp;

  /// No description provided for @performanceViewTrace.
  ///
  /// In tr, this message translates to:
  /// **'İz / Trace'**
  String get performanceViewTrace;

  /// No description provided for @navProfiling.
  ///
  /// In tr, this message translates to:
  /// **'Sürekli Profilleme'**
  String get navProfiling;

  /// No description provided for @profilingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sürekli CPU Profilleme & Flame Chart'**
  String get profilingTitle;

  /// No description provided for @profilingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Üretim ortamındaki çağrı yığınlarını (call stack) ve en yavaş fonksiyonları interaktif alev grafiği ile analiz edin.'**
  String get profilingSubtitle;

  /// No description provided for @profilingEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir CPU profil kaydı bulunamadı.'**
  String get profilingEmpty;

  /// No description provided for @profilingTransaction.
  ///
  /// In tr, this message translates to:
  /// **'İşlem (Transaction)'**
  String get profilingTransaction;

  /// No description provided for @profilingDuration.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre'**
  String get profilingDuration;

  /// No description provided for @profilingCpuTime.
  ///
  /// In tr, this message translates to:
  /// **'CPU Süresi'**
  String get profilingCpuTime;

  /// No description provided for @profilingThread.
  ///
  /// In tr, this message translates to:
  /// **'İş Parçacığı (Thread)'**
  String get profilingThread;

  /// No description provided for @profilingPlatform.
  ///
  /// In tr, this message translates to:
  /// **'Platform'**
  String get profilingPlatform;

  /// No description provided for @profilingSamples.
  ///
  /// In tr, this message translates to:
  /// **'Örnek Sayısı (Samples)'**
  String get profilingSamples;

  /// No description provided for @profilingFrames.
  ///
  /// In tr, this message translates to:
  /// **'Fonksiyon Sayısı (Frames)'**
  String get profilingFrames;

  /// No description provided for @profilingSlowFunctions.
  ///
  /// In tr, this message translates to:
  /// **'En Yavaş Fonksiyonlar'**
  String get profilingSlowFunctions;

  /// No description provided for @profilingFunctionName.
  ///
  /// In tr, this message translates to:
  /// **'Fonksiyon Adı'**
  String get profilingFunctionName;

  /// No description provided for @profilingSelfTime.
  ///
  /// In tr, this message translates to:
  /// **'Öz Süre (Self Time)'**
  String get profilingSelfTime;

  /// No description provided for @profilingTotalTime.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre (Total Time)'**
  String get profilingTotalTime;

  /// No description provided for @profilingCallCount.
  ///
  /// In tr, this message translates to:
  /// **'Çağrı Sayısı'**
  String get profilingCallCount;

  /// No description provided for @profilingDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil & Flame Graph Detayı'**
  String get profilingDetailTitle;

  /// No description provided for @profilingSearchFrame.
  ///
  /// In tr, this message translates to:
  /// **'Fonksiyon veya dosya ara...'**
  String get profilingSearchFrame;

  /// No description provided for @profilingInvertFlame.
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdan Yukarı (Icicle)'**
  String get profilingInvertFlame;

  /// No description provided for @profilingResetZoom.
  ///
  /// In tr, this message translates to:
  /// **'Yakınlaştırmayı Sıfırla'**
  String get profilingResetZoom;

  /// No description provided for @profilingSelectedFrame.
  ///
  /// In tr, this message translates to:
  /// **'Seçili Fonksiyon Detayı'**
  String get profilingSelectedFrame;

  /// No description provided for @profilingViewProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Görüntüle'**
  String get profilingViewProfile;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'tr':
      return LTr();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
