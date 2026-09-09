import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import 'api.dart';
import 'models.dart';

/// The session: null means signed out.
class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() => ref.watch(tokenStoreProvider).restore();

  Future<void> login(String email, String password) =>
      _run(() => ref.read(apiProvider).login(email.trim(), password));

  Future<void> register(String email, String name, String password) => _run(
    () => ref.read(apiProvider).register(email.trim(), name.trim(), password),
  );

  Future<void> _run(Future<AuthSession> Function() f) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final s = await f();
      await ref.read(tokenStoreProvider).save(s);
      return s;
    });
  }

  Future<void> logout() async {
    try {
      await ref.read(apiProvider).logout();
    } catch (_) {}
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

/// Turns API errors into a short sentence in the user's language.
///
/// The criterion is the backend's `code` field, not the message text: fixing
/// the server wording must not break the dashboard. There is a fallback on the
/// status code so this also works against an older backend that sends no code;
/// the server's English text is shown only when no rule matches.
String describeError(L l10n, Object e) {
  if (e is! ApiException) return '$e';
  final byCode = switch (e.code) {
    ApiException.codeNetwork => l10n.errNetwork(e.detail ?? ''),
    'auth.invalid_credentials' => l10n.errInvalidCredentials,
    'auth.login_required' || 'auth.invalid_token' => l10n.errSessionExpired,
    'auth.email_taken' => l10n.errEmailTaken,
    'auth.password_too_short' => l10n.errPasswordTooShort,
    'auth.invalid_email' => l10n.errInvalidEmail,
    'auth.unsupported_locale' => l10n.errUnsupportedLocale,
    'project.owner_required' => l10n.errOwnerRequired,
    'project.name_required' => l10n.errProjectNameRequired,
    'project.not_found' ||
    'session.not_found' ||
    'frame.not_found' ||
    'issue.not_found' ||
    'not_found' => l10n.errNotFound,
    'member.unknown_email' => l10n.errUnknownMember,
    'member.owner_self_remove' => l10n.errSelfRemove,
    _ => null,
  };
  if (byCode != null) return byCode;
  return switch (e.status) {
    // Transitional: on a backend without the `code` field a 401 means two
    // different things. Looking at the text is brittle (the codes were added to
    // cut exactly that tie); once backends with codes are everywhere this line
    // can go.
    401 when e.message.contains('password') => l10n.errInvalidCredentials,
    401 => l10n.errSessionExpired,
    403 => l10n.errOwnerRequired,
    404 => l10n.errNotFound,
    409 => l10n.errEmailTaken,
    _ => e.message,
  };
}
