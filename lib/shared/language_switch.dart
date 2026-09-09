import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../core/format.dart';
import '../core/locale.dart';

/// The language switch. A dropdown is overkill for two languages; the labels
/// are written in their own language ("Türkçe", "English") so a user can
/// recognise the one they are looking for.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    final names = {
      'tr': context.l10n.languageTurkish,
      'en': context.l10n.languageEnglish,
    };
    return Tooltip(
      tooltip: (_) => TooltipContainer(child: Text(context.l10n.shellLanguage)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final l in supportedLocales)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: l.languageCode == current
                  ? SecondaryButton(
                      size: ButtonSize.xSmall,
                      density: ButtonDensity.compact,
                      onPressed: () {},
                      child: Text(names[l.languageCode] ?? l.languageCode),
                    )
                  : GhostButton(
                      size: ButtonSize.xSmall,
                      density: ButtonDensity.compact,
                      onPressed: () => ref.read(localeProvider.notifier).set(l),
                      child: Text(names[l.languageCode] ?? l.languageCode),
                    ),
            ),
        ],
      ),
    );
  }
}
