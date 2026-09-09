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
