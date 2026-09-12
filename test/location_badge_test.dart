import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/shared/widgets/location_badge.dart';

void main() {
  group('Session location & coordinates models', () {
    test('parses GeoIP and coordinates from JSON', () {
      final json = {
        'id': 'sess-test',
        'project_id': 1,
        'started_at': '2026-09-12T10:00:00Z',
        'last_seen_at': '2026-09-12T10:05:00Z',
        'country_code': 'TR',
        'country_name': 'Turkey',
        'region': 'Istanbul',
        'city': 'Istanbul',
        'latitude': 41.0082,
        'longitude': 28.9784,
      };

      final s = Session.fromJson(json);
      expect(s.countryCode, 'TR');
      expect(s.countryName, 'Turkey');
      expect(s.region, 'Istanbul');
      expect(s.city, 'Istanbul');
      expect(s.latitude, 41.0082);
      expect(s.longitude, 28.9784);
      expect(s.hasCoordinates, isTrue);
      expect(s.coordinatesLabel, '41.0082, 28.9784');
      expect(s.locationLabel, 'Istanbul, Turkey');
    });

    test('handles local network and null coordinates', () {
      final json = {
        'id': 'sess-local',
        'project_id': 1,
        'started_at': '2026-09-12T10:00:00Z',
        'last_seen_at': '2026-09-12T10:05:00Z',
        'country_code': 'LOCAL',
        'country_name': 'Local Network',
        'city': 'Local',
      };

      final s = Session.fromJson(json);
      expect(s.countryCode, 'LOCAL');
      expect(s.hasCoordinates, isFalse);
      expect(s.coordinatesLabel, '');
      expect(s.locationLabel, 'Local Network');
    });
  });

  group('LocationBadge Widget', () {
    testWidgets('renders location and flag for valid country', (tester) async {
      final session = Session(
        id: 's1',
        projectId: 1,
        startedAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
        countryCode: 'TR',
        countryName: 'Turkey',
        city: 'Istanbul',
        latitude: 41.0082,
        longitude: 28.9784,
      );

      await tester.pumpWidget(
        ShadcnApp(
          home: Scaffold(
            child: LocationBadge(session: session, showCoordinates: true),
          ),
        ),
      );

      expect(find.text('Istanbul, Turkey'), findsOneWidget);
      expect(find.text('(41.0082, 28.9784)'), findsOneWidget);
    });

    testWidgets('renders local network fallback icon and label', (tester) async {
      final session = Session(
        id: 's2',
        projectId: 1,
        startedAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
        countryCode: 'LOCAL',
        countryName: 'Local Network',
      );

      await tester.pumpWidget(
        ShadcnApp(
          home: Scaffold(
            child: LocationBadge(session: session),
          ),
        ),
      );

      expect(find.text('Local Network'), findsOneWidget);
      expect(find.byIcon(LucideIcons.network), findsOneWidget);
    });
  });
}
