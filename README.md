# sightpane dashboard

The Flutter web dashboard for [sightpane](https://github.com/sightpane/sightpane)
— sign in, create a project, then watch sessions, errors, events and replays
arrive.

| Repository | What it is |
|---|---|
| [sightpane/sightpane](https://github.com/sightpane/sightpane) | the Go backend this talks to, and the Docker deployment that serves this build |
| **[sightpane/ui](https://github.com/sightpane/ui)** (here) | this dashboard |
| [sightpane/flutter](https://github.com/sightpane/flutter) | the Dart/Flutter SDK that sends the data |

This is a plain Flutter web app with no dependency on the SDK repository; it only
reads the backend's REST API. The normal deployment does not run this on its own
— the backend serves the built output from `SIGHTPANE_UI_DIR`, so both sit on one
origin. The `Dockerfile` here is for serving it separately behind its own ingress.

---

The Flutter web dashboard for `sightpane/backend` (it also builds for Linux
desktop). The Sentry/PostHog flow: register → sign in → create a project → hand
the key and the address to `Sightpane.init` → sessions, errors, events and statistics
arrive.

```bash
./run.sh                     # flutter run -d chrome --dart-define-from-file=config.json
flutter build web --dart-define-from-file=config.json
SIGHTPANE_UI_DIR=$PWD/build/web ../backend/sightpane   # the backend serves it on the same port
flutter test
```

`config.json` → `SIGHTPANE_API_URL` (default `http://localhost:8790`; leave it empty and
the page's own origin is used on web, which is how the Docker image is built). A
local backend creates the `admin@sightpane.local / admin123` admin and the "Casino CRM"
project with the key `dev` on startup.

## Pages

| Route | Content |
|---|---|
| `/login`, `/register` | email + password; the token lives in SharedPreferences |
| `/projects` | cards (24-hour sessions/errors, open groups), **New project** → key + `Sightpane.init` snippet |
| `/projects/:id` | **Live**: how many people and visitors are online right now, people per page, the viewer list (user, browser, IP, route, duration) — refreshed every second; KPIs (sessions, visitors, errors, crash-free %, events), daily bars, most frequent errors, platform/release distribution; 7/14/30/90 days |
| `/projects/:id/sessions` | list, "only with errors", user filter; `/sessions/:sid` → the replay player (frames, pointer trail + cursor + click rings, speed, scrubbing), the timeline, the error stack and the steps before it |
| `/projects/:id/issues` | error groups, show resolved; `/issues/:iid` → stack, occurrences, resolve / reopen |
| `/projects/:id/events` | event name × day table |
| `/projects/:id/settings` | name, API key (copy / rotate), setup snippet, members (add by email, remove), delete project (owner only) |

## Language

The dashboard is Turkish and English. The strings live in `lib/l10n/app_tr.arb`
(the source language) and `app_en.arb`; neither is edited by hand — the single
source is `tool/gen_arb.py` and both are generated from it. `flutter gen-l10n`
writes the `L` class into `lib/l10n/gen/` (and `flutter run` / `flutter test` run
it for you).

```bash
# new string: add a row to the table in tool/gen_arb.py, then
python3 tool/gen_arb.py && flutter gen-l10n
```

In code, `context.l10n.<key>`; for dates, numbers and durations, `context.fmt`
(`core/format.dart`). Date patterns are part of the translation
(`fmtDateTimePattern`), because how a date is written is language-specific.
Adding a language means: a column in the table, an `app_<code>.arb`, and a
`ShadcnLocalizations` subclass for it in
`lib/app/theme/shadcn_localizations_fallback.dart` (the package only ships `en`).

Language selection order: `?lang=en` → the choice made in this browser
(`SharedPreferences`, `hog_locale`) → the account's language (`users.locale`,
`PATCH /api/v1/auth/me`) → the browser language → Turkish. The switch is in the
top bar and on the sign-in page.

Backend errors are translated by their **code**, not their text
(`core/auth.dart` `describeError`): the server's English wording can change
without the dashboard showing the wrong sentence.

## Structure

`lib/core` — `SightpaneApi` (abstract) + `HttpSightpaneApi`, models, `AuthController`
(AsyncNotifier), Riverpod providers. `lib/features/*` the pages, `lib/shell` the
top bar and project menu, `lib/shared/widgets.dart` panel/KPI/table/dialog/bar
chart. Tests run through the router with a `FakeApi`
(`test/helpers/test_app.dart` → `pumpApp`, `setUpLoggedIn`).

The player buffers frames with `FramePrefetcher`: before playback the first 10
frames are precached in order ("buffer 4/10") and the play button unlocks once the
buffer is full; as the cursor advances the window slides and one more frame is
requested. A frame that fails to load does not block the buffer.

Fullscreen: the ⤢ button in the player opens the recording area on a black page
pushed onto the root navigator, filling the window (on web the browser is also
put into fullscreen with `requestFullscreen`, via `package:web`); ESC or ✕ closes
it, space plays/pauses. The same `ReplayController` and `FramePrefetcher` are
reused, so position and buffer are preserved.

## License

**AGPL-3.0-or-later** (`LICENSE`), the same as the backend it is served by. As
§13 requires, the dashboard shows the source address on the sign-in page and in
the top bar; keep that in place when changing either screen.

Copyright (C) 2026 Can Us.
