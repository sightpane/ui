# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Three repositories, one contract

sightpane is self-hosted error tracking, product analytics and frame-based session
replay. It is split across three repositories that release independently:

| Repository | What it is | Licence |
|---|---|---|
| [sightpane/sightpane](https://github.com/sightpane/sightpane) | Go backend on Fiber v3 + TimescaleDB, the Docker deployment, the product roadmap under `future-todo-files/` | AGPL-3.0-or-later |
| [sightpane/ui](https://github.com/sightpane/ui) | the Flutter web dashboard the backend serves | AGPL-3.0-or-later |
| [sightpane/flutter](https://github.com/sightpane/flutter) | the Dart/Flutter SDK, `sightpane` on pub.dev | Apache-2.0 |

**You can only see one of them at a time.** When a change touches the envelope
contract below, say plainly which of the other two also needs a change and what
it is — nobody reading this repository can check for themselves.

**English is the working language**: code comments, READMEs, issues and commit
messages. The dashboard's user interface is the exception — it is localized, and
its strings live in `lib/l10n/` in the ui repository.

## Commands

```bash
flutter analyze && flutter test
flutter test test/auth_pages_test.dart
python3 tool/gen_arb.py && flutter gen-l10n                # after editing UI strings
python3 tool/gen_icons.py                                  # after changing the mark
./run.sh                                                   # flutter run -d chrome
flutter build web --dart-define-from-file=config.json
```

`config.json` sets `SIGHTPANE_API_URL`; empty means the page's own origin, which
is how the backend's Docker image builds it. To run against a local backend,
build here and start the backend with `SIGHTPANE_UI_DIR=$PWD/build/web`.

`GITHUB_TOKEN` in this environment is a dummy that causes 401. Always run the
GitHub CLI as `env -u GITHUB_TOKEN gh …`.

## The envelope contract

Everything hinges on `POST /api/v1/envelope` (header `X-Sightpane-Key`), body `{sdk, session{id, started_at, user, device, props}, items[]}`. Item `type` values: `breadcrumb`, `event`, `error`, `frame` (base64 PNG + `taps`), `pointer` (`events[{t,x,y,k}]`), `heartbeat` (updates session `last_seen_at`/`current_route`, writes no row), `session_end`. Backend answers 202 `{accepted, rejected}`; unknown items are silently counted as rejected, so contract drift does not fail loudly.

The contract lives in three repositories and they must move together:
- **here** — `lib/core/models.dart` parsers (`_i/_d/_s/_t` tolerate missing fields) and the `FakeApi` fixture in `test/helpers/test_app.dart`
- [sightpane/sightpane](https://github.com/sightpane/sightpane) — `internal/store/ingest.go`, pinned by its `internal/server/server_test.go`
- [sightpane/flutter](https://github.com/sightpane/flutter) — `lib/src/models.dart`, pinned by its `test/models_test.dart`

A field only reaches this dashboard once the backend stores and returns it, so a
change starts there. Adding it here means the model, the `FakeApi` fixture and a
test.

## Localization

Every user-visible string in `lib` comes from the generated `L` class; a literal
Turkish string in a widget is a bug. The single source is `tool/gen_arb.py` — a
table of `key: (tr, en, placeholders)` that emits `lib/l10n/app_tr.arb` (template) and
`app_en.arb`. Never hand-edit the ARB files. `flutter gen-l10n` writes `lib/l10n/gen/`
(and `flutter run`/`build`/`test` run it for you).

- In widgets: `context.l10n.<key>` and `context.fmt` (both extensions in `core/format.dart`).
- `Fmt` is per-locale, not static: number, percent, date and duration formats all change
  with the language, and the date patterns themselves live in the ARB (`fmtDateTimePattern`).
  Turkish decimals use a comma; `Fmt.upper` exists because `toUpperCase()` turns `i` into
  `I` instead of `İ`.
- Backend errors are translated by their `code`, never their message (`core/auth.dart`
  `describeError`). Adding an endpoint means adding a code in `internal/apierr/apierr.go` in [sightpane/sightpane](https://github.com/sightpane/sightpane) and a
  branch there. There is one deliberate legacy fallback for a code-less 401.
- Language order: `?lang=` → `SharedPreferences` `hog_locale` → `users.locale` → browser →
  `tr`. Resolved before `runApp` (`core/locale.dart`), so no wrong-language first frame.
- Tests: `pumpApp` builds the same tree as `HogApp` including `L.delegate` and
  `FallbackShadcnLocalizationsDelegate`; `testContainer(api, locale: …)` pins the language.

## The dashboard

- `core/api.dart`: `SightpaneApi` (abstract) + `HttpSightpaneApi`; `core/providers.dart`: `FutureProvider.autoDispose.family` keyed by **records** (`StatsKey`, `SessionsKey`, …); `core/auth.dart`: `AuthController` (`AsyncNotifier<AuthSession?>`, token in SharedPreferences). `app/router.dart` reads `authControllerProvider` for redirects, so **router and page tree must share one `ProviderContainer`** — a second `ProviderScope` silently breaks auth redirects. Tests use `pumpApp(tester, testContainer(FakeApi()))` + `setUpLoggedIn()` from `test/helpers/test_app.dart` for exactly this reason.
- `AppConfig.apiUrl`: `SIGHTPANE_API_URL` dart-define; empty on web = page origin (how the Docker image is built), otherwise `http://localhost:8790`.
- UI is shadcn_flutter, not Material: `Select(adaptiveOverlay: false)`, `showOverlay` + `DialogConfiguration`, `Card(filled: true)`; colors from `app/theme/tokens.dart`; `withValues(alpha:)` not `withOpacity`. The locale is chosen at runtime, so use `context.fmt.upper` rather than `toUpperCase()`, which turns `i` into `I` instead of `İ`.
- Overview page invalidates `liveProvider`/`statsProvider` every second — use `skipLoadingOnReload: true` on `.when` and keep `build` cheap.
- **Stack traces** (`StackTraceView`, in `session_detail_page.dart` next to
  `CodeBlock`, used by both the issue page and the item detail): a release web
  build's stack is minified JavaScript, and the backend resolves it against an
  uploaded source map. `TimelineItem.frames` comes from `symbolicated`, which
  sits **beside** `body` in the JSON — the body is what the SDK sent and the
  backend hands it back untouched. With frames the resolved list is shown and
  the raw text goes behind a fold; with none, the stack is rendered as before,
  plus a hint to upload a map when it looks minified (`.js:` and no `package:`).
  An unresolved frame is kept and marked rather than dropped.
- Replay player (`features/sessions/session_detail_page.dart`): `ReplayController` owns position/timers; `FramePrefetcher` precaches the first 10 frames then slides one per cursor step, and a failed frame must not block readiness. Fullscreen (`browser_fullscreen*.dart`, conditional import) reuses the same controller so position and buffer survive.

## Repo conventions

- `.claude/skills/` carries `shadcn-flutter` (the UI kit — consult it before writing a widget), `flutter-chart` (the `graphic` package, not yet a dependency), and the shared workflow skills. Provenance of the vendored ones is in `SOURCE-vendored-skills.md`.
- **Shadcn-first rule**: If a component already exists in `shadcn_flutter` (e.g. `Breadcrumb`, `Accordion`, `Avatar`, `Dialog`, `Sheet`, `Popover`, `Select`, `Steps`, `Timeline`, `Tabs`, `Table`, etc.), NEVER build it from scratch. Always consult the `/shadcn-flutter` skill first and wrap or reuse the official component in `lib/shared/widgets/`.
- The official `dart-flutter` plugin is enabled at project scope in `.claude/settings.json`. Its skills are generic Flutter guidance; where they conflict with this repository (Material widgets vs shadcn_flutter, `pumpWidget(MaterialApp(...))` vs `pumpApp`/`FakeApi`), this repository wins.
- `lib/l10n/gen/` is generated but committed, so a fresh clone analyzes without a build step. Regenerate whenever `tool/gen_arb.py` changes.
- The brand mark is drawn, not an asset: `lib/shared/brand.dart` has the
  CustomPainter (a 64-unit grid, four shapes) and `tool/gen_icons.py` redraws the
  favicon and PWA icons from the same numbers. Change one and rerun the other,
  or they drift. Below 20 logical pixels the mark drops its horizontal mullion
  by itself; the top bar relies on that. The wordmark is two weights in one
  `Text.rich`, so `find.text('sightpane')` still matches it.
- `lib/main.dart` carries the AGPL SPDX header. AGPL §13: the sign-in page and the top bar show the source address — keep them when touching either screen.
- Tests assert against the **Turkish** locale (`find.text('Projeler')`); `testContainer(api, locale: …)` pins the language and `test/i18n_test.dart` is where English is exercised. Translating one side of such an assertion breaks the test.
- The roadmap for all three repositories lives in [sightpane/sightpane](https://github.com/sightpane/sightpane) under `future-todo-files/`.
- **Commit on issue/task completion**: Whenever an issue, bug fix, or UI task is finished, run the `/code-auditor` skill on modified files, resolve all findings, verify static checks and tests (`flutter analyze`, `flutter test`), then create a descriptive conventional commit explaining what was changed and why. Do not run `git push` unless explicitly asked.
