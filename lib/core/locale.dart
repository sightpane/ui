import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/gen/app_localizations.dart';
import 'api.dart';
import 'auth.dart';

/// How the dashboard language is picked, strongest source first:
///
/// 1. `?lang=en` — so a link can be shared in a specific language,
/// 2. the choice made in this browser (`SharedPreferences`),
/// 3. the account language (`users.locale`; the same language when signing in
///    from another device),
/// 4. the browser / operating system language,
/// 5. Turkish.
///
/// Steps 1–2 and 4–5 are known synchronously at startup, which is why
/// [resolveStartupLocale] is called inside `main` and supplied through
/// [initialLocaleProvider] — that way the dashboard does not paint one frame in
/// the wrong language and correct itself afterwards. Step 3 only arrives once
/// the user signs in, and is applied only if the viewer made no choice in this
/// browser.
const localeStorageKey = 'sightpane_locale';

/// The key used before the project was renamed; read once so a chosen language
/// is not forgotten on upgrade.
const legacyLocaleStorageKey = 'hog_locale';

/// The language read at startup; `main` overrides it, tests pin it.
final initialLocaleProvider = Provider<Locale?>((_) => null);

/// The supported languages (from the generated [L] class; the ARB files are
/// the single source).
List<Locale> get supportedLocales => L.supportedLocales;

bool _isSupported(String code) =>
    supportedLocales.any((l) => l.languageCode == code);

/// [stored] is the choice made in this browser, [platform] the device
/// language. Only supported languages are accepted; if none matches, Turkish.
Locale resolveStartupLocale({String? stored, Locale? platform, Uri? url}) {
  final fromUrl = (url ?? Uri.base).queryParameters['lang'];
  for (final code in [fromUrl, stored, platform?.languageCode]) {
    if (code != null && code.isNotEmpty && _isSupported(code)) {
      return Locale(code);
    }
  }
  return const Locale('tr');
}

/// Reads the choice from local storage at startup. `main` calls this before
/// `runApp`.
Future<Locale> loadStartupLocale() async {
  String? stored;
  try {
    final p = await SharedPreferences.getInstance();
    stored =
        p.getString(localeStorageKey) ?? p.getString(legacyLocaleStorageKey);
  } catch (_) {
    // With no storage (private tab, locked-down browser) we fall through to the
    // remaining steps in silence.
  }
  return resolveStartupLocale(
    stored: stored,
    platform: WidgetsBinding.instance.platformDispatcher.locale,
  );
}

class LocaleController extends Notifier<Locale> {
  /// Whether the viewer picked the language by hand in this browser. Once they
  /// have, the account language no longer overwrites it — otherwise the language
  /// switch would snap back the moment they signed in.
  bool _chosen = false;

  @override
  Locale build() {
    ref.listen(authControllerProvider, (_, next) {
      final code = next.value?.user.locale ?? '';
      if (!_chosen && code.isNotEmpty && _isSupported(code)) {
        state = Locale(code);
      }
    });
    return ref.read(initialLocaleProvider) ??
        resolveStartupLocale(
          platform: WidgetsBinding.instance.platformDispatcher.locale,
        );
  }

  /// Switches the language: the screen turns over at once, persisting happens in
  /// the background. It is written to the server too so the user sees the same
  /// language when signing in from another device; a network error does not undo
  /// the switch.
  Future<void> set(Locale locale) async {
    _chosen = true;
    state = locale;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(localeStorageKey, locale.languageCode);
    } catch (_) {}
    if (ref.read(authControllerProvider).value == null) return;
    try {
      await ref.read(apiProvider).updateMe(locale: locale.languageCode);
    } catch (_) {
      // The language is already stored locally; the server gets it on the next
      // change.
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
