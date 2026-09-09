import 'package:flutter_test/flutter_test.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/features/sessions/session_detail_page.dart'
    show StackTraceView;

import 'helpers/test_app.dart';

// A release web build's stack is minified JavaScript. The backend resolves it
// against the source map uploaded for that release; this is what the resolved
// half looks like, and what happens when there is nothing to resolve it with.

const _minified =
    'Error\n    at aI.\$2 (https://app.example.com/main.dart.js:12345:67)';
const _native = '#0 CashierPage.settle (package:app/cashier.dart:120:5)';

const _frames = [
  SourceFrame(
    file: 'lib/cashier.dart',
    line: 120,
    column: 4,
    function: 'openTill',
    minified: 'aI.\$2 (https://app.example.com/main.dart.js:12345:67)',
    resolved: true,
  ),
  SourceFrame(
    file: 'https://app.example.com/flutter.js',
    line: 9,
    column: 1,
    function: 'x',
    minified: 'x (https://app.example.com/flutter.js:9:1)',
    resolved: false,
  ),
];

void main() {
  testWidgets('resolved frames replace the minified stack', (tester) async {
    await pumpWidgetWithL10n(
      tester,
      const StackTraceView(stack: _minified, frames: _frames),
    );

    expect(find.text('openTill'), findsOneWidget);
    expect(find.text('lib/cashier.dart:120'), findsOneWidget);
    // The raw text is behind a fold: it is still the record, but it is not what
    // anyone opens the page to read.
    expect(find.textContaining('main.dart.js:12345'), findsNothing);

    // A frame no map covered is kept and marked, not dropped — a hole in a
    // stack reads worse than a line nobody can decode.
    expect(find.text('eşlenmedi'), findsOneWidget);
    expect(
      find.textContaining('flutter.js:9:1'),
      findsOneWidget,
      reason: 'an unresolved frame keeps its minified text',
    );

    await tester.tap(find.text('Ham yığın'));
    await tester.pumpAndSettle();
    expect(find.textContaining('main.dart.js:12345'), findsOneWidget);
  });

  // Nothing uploaded: the stack is shown as it always was, plus the one thing
  // worth saying about a minified one.
  testWidgets('a minified stack with no map says what to do', (tester) async {
    await pumpWidgetWithL10n(tester, const StackTraceView(stack: _minified));
    expect(find.textContaining('main.dart.js:12345'), findsOneWidget);
    expect(
      find.textContaining('kaynak haritası yükleyin'),
      findsOneWidget,
      reason: 'the hint is the whole point of noticing it is minified',
    );
  });

  // A native stack is already readable; suggesting a source map there would be
  // noise on every error from every mobile and desktop app.
  testWidgets('a native stack gets no hint', (tester) async {
    await pumpWidgetWithL10n(tester, const StackTraceView(stack: _native));
    expect(find.textContaining('package:app/cashier.dart'), findsOneWidget);
    expect(find.textContaining('kaynak haritası yükleyin'), findsNothing);
  });

  test('symbolicated frames are read from beside the body, not inside it', () {
    final item = TimelineItem.fromJson(const {
      'id': 1,
      'ts': '2026-09-09T10:00:00Z',
      'type': 'error',
      'name': 'StateError: boom',
      'body': {'stack': _minified},
      'symbolicated': {
        'frames': [
          {
            'file': 'lib/cashier.dart',
            'line': 120,
            'column': 4,
            'function': 'openTill',
            'minified': 'aI.\$2 (main.dart.js:1:1)',
            'resolved': true,
          },
        ],
      },
    });
    expect(item.frames, hasLength(1));
    expect(item.frames.single.location, 'lib/cashier.dart:120');
    expect(item.frames.single.resolved, isTrue);
    // The body is untouched by all of this.
    expect(item.body['stack'], _minified);

    // An item from a backend that never symbolicated anything has none.
    expect(
      TimelineItem.fromJson(const {
        'id': 2,
        'ts': '2026-09-09T10:00:00Z',
        'type': 'error',
        'body': {'stack': _native},
      }).frames,
      isEmpty,
    );
  });
}
