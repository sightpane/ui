import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/features/sessions/session_detail_page.dart';

import 'helpers/test_app.dart';

TimelineItem nav(int s, String message, [Map<String, Object?>? data]) =>
    TimelineItem(
      id: s,
      ts: DateTime(2026, 9, 7, 10, 0, s),
      type: 'breadcrumb',
      name: 'navigation',
      body: {'message': message, 'data': ?data},
    );

void main() {
  test('route stops come from navigation, repeats folded', () {
    final stops = routeStops([
      nav(1, 'push /home', {'from': '', 'to': '/home'}),
      nav(2, 'push /home', {'from': '/home', 'to': '/home'}),
      TimelineItem(
        id: 3,
        ts: DateTime(2026, 9, 7, 10, 0, 3),
        type: 'event',
        name: 'tap',
        body: const {'name': 'tap'},
      ),
      // An older item without data: the route is the message's last word.
      nav(4, 'replace /cart'),
    ]);
    expect([for (final s in stops) s.route], ['/home', '/cart']);
    expect(stops.last.ts, DateTime(2026, 9, 7, 10, 0, 4));
  });

  test('a timeline row says where, with what, or from where', () {
    final event = TimelineItem(
      id: 1,
      ts: DateTime(2026),
      type: 'event',
      name: 'deposit',
      body: const {
        'name': 'deposit',
        'props': {'amount': 50},
      },
    );
    expect(TimelineRow.titleOf(event), 'deposit');
    expect(TimelineRow.detailOf(event), '{"amount":50}');
    expect(
      TimelineRow.detailOf(
        nav(1, 'push /cart', {'from': '/home', 'to': '/cart'}),
      ),
      '/home → /cart',
    );
    final error = TimelineItem(
      id: 2,
      ts: DateTime(2026),
      type: 'error',
      name: 'TypeError',
      body: const {'exception': 'TypeError', 'message': 'x', 'stack': 'raw'},
      frames: const [
        SourceFrame(
          file: 'lib/cart.dart',
          line: 88,
          column: 3,
          function: 'Cart.submit',
          minified: 'a.b',
          resolved: true,
        ),
      ],
    );
    // A resolved frame beats the raw stack.
    expect(TimelineRow.detailOf(error), 'Cart.submit · lib/cart.dart:88');
  });

  testWidgets('the route strip marks the route at the cursor and seeks', (
    tester,
  ) async {
    DateTime? sought;
    final stops = routeStops([
      nav(1, 'push /home', {'to': '/home'}),
      nav(5, 'push /cart', {'from': '/home', 'to': '/cart'}),
    ]);
    await pumpWidgetWithL10n(
      tester,
      RouteFlow(
        stops: stops,
        current: DateTime(2026, 9, 7, 10, 0, 6),
        onSeek: (t) => sought = t,
      ),
    );
    expect(find.text('Rota akışı'), findsOneWidget);
    expect(find.widgetWithText(SecondaryButton, '/cart'), findsOneWidget);
    expect(find.widgetWithText(OutlineButton, '/home'), findsOneWidget);
    await tester.tap(find.text('/home'));
    expect(sought, DateTime(2026, 9, 7, 10, 0, 1));
  });

  test('replay positions read as mm:ss, h:mm:ss past an hour', () {
    expect(replayClock(const Duration(seconds: 164)), '02:44');
    expect(replayClock(const Duration(hours: 1, seconds: 5)), '1:00:05');
  });
}
