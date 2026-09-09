import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/auth.dart';
import '../../shared/language_switch.dart';
import '../../shared/widgets.dart';
import '../../core/format.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(), _password = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(
      () => _err = !_email.text.contains('@')
          ? context.l10n.authInvalidEmail
          : (_password.text.isEmpty ? context.l10n.authPasswordRequired : null),
    );
    if (_err != null) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;
    final error =
        _err ??
        (auth.hasError ? describeError(context.l10n, auth.error!) : null);
    return AuthScaffold(
      title: context.l10n.authSignIn,
      subtitle: context.l10n.authSignInSubtitle,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.authNoAccount,
            style: const TextStyle(color: Tokens.textDim, fontSize: 12),
          ),
          GhostButton(
            size: ButtonSize.small,
            onPressed: () => context.go('/register'),
            child: Text(context.l10n.authGoRegister),
          ),
        ],
      ),
      children: [
        FieldLabel(context.l10n.authEmail),
        TextField(
          controller: _email,
          enabled: !busy,
          placeholder: Text(context.l10n.authEmailHint),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
        ),
        const Gap(12),
        FieldLabel(context.l10n.authPassword),
        TextField(
          controller: _password,
          enabled: !busy,
          obscureText: true,
          placeholder: const Text('••••••••'),
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(),
          features: const [InputFeature.passwordToggle()],
        ),
        if (error != null) FieldError(error),
        const Gap(20),
        PrimaryButton(
          onPressed: busy ? null : _submit,
          child: busy
              ? const CircularProgressIndicator(size: 16)
              : Text(context.l10n.authSignIn),
        ),
      ],
    );
  }
}

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _email = TextEditingController(),
      _name = TextEditingController(),
      _password = TextEditingController(),
      _password2 = TextEditingController();
  String? _err;

  @override
  void dispose() {
    for (final c in [_email, _name, _password, _password2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _err = !_email.text.contains('@')
          ? context.l10n.authInvalidEmail
          : _password.text.length < 6
          ? context.l10n.authPasswordTooShort
          : _password.text != _password2.text
          ? context.l10n.authPasswordMismatch
          : null;
    });
    if (_err != null) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(_email.text, _name.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;
    final error =
        _err ??
        (auth.hasError ? describeError(context.l10n, auth.error!) : null);
    return AuthScaffold(
      title: context.l10n.authRegisterTitle,
      subtitle: context.l10n.authRegisterSubtitle,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.authHaveAccount,
            style: const TextStyle(color: Tokens.textDim, fontSize: 12),
          ),
          GhostButton(
            size: ButtonSize.small,
            onPressed: () => context.go('/login'),
            child: Text(context.l10n.authGoSignIn),
          ),
        ],
      ),
      children: [
        FieldLabel(context.l10n.authFullName),
        TextField(
          controller: _name,
          enabled: !busy,
          placeholder: Text(context.l10n.authFullNameHint),
          textInputAction: TextInputAction.next,
        ),
        const Gap(12),
        FieldLabel(context.l10n.authEmail),
        TextField(
          controller: _email,
          enabled: !busy,
          placeholder: Text(context.l10n.authEmailHint),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const Gap(12),
        FieldLabel(context.l10n.authPassword),
        TextField(
          controller: _password,
          enabled: !busy,
          obscureText: true,
          placeholder: Text(context.l10n.authPasswordHint),
          textInputAction: TextInputAction.next,
          features: const [InputFeature.passwordToggle()],
        ),
        const Gap(12),
        FieldLabel(context.l10n.authPasswordRepeat),
        TextField(
          controller: _password2,
          enabled: !busy,
          obscureText: true,
          placeholder: const Text('••••••••'),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        if (error != null) FieldError(error),
        const Gap(20),
        PrimaryButton(
          onPressed: busy ? null : _submit,
          child: busy
              ? const CircularProgressIndicator(size: 16)
              : Text(context.l10n.authRegister),
        ),
      ],
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footer,
  });
  final String title, subtitle;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Tokens.bg,
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.activity, size: 22, color: Tokens.accent),
                  Gap(8),
                  Text(
                    'sightpane',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Tokens.textStrong,
                    ),
                  ),
                ],
              ),
              const Gap(24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Tokens.textStrong,
                ),
              ),
              const Gap(6),
              Text(subtitle, style: const TextStyle(color: Tokens.textMuted)),
              const Gap(22),
              ...children,
              const Gap(14),
              footer,
              const Gap(10),
              const Center(child: LanguageSwitch()),
              const Gap(6),
              const SourceLink(),
            ],
          ),
        ),
      ),
    ),
  );
}

/// AGPL-3.0 §13: a link to the source for anyone using this over a network.
class SourceLink extends StatelessWidget {
  const SourceLink({super.key});
  static const url = 'https://github.com/sightpane/sightpane';

  @override
  Widget build(BuildContext context) => Center(
    child: SelectableText(
      'sightpane · AGPL-3.0 · $url',
      style: const TextStyle(fontSize: 11, color: Tokens.textFaint),
      textAlign: TextAlign.center,
    ),
  );
}
