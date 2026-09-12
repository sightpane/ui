// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:sightpane_dashboard/core/config.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/features/users/widgets/visitor_map.dart';
import 'package:sightpane_dashboard/l10n/gen/app_localizations.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return ShadcnApp(
      locale: const Locale('en'),
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: Scaffold(
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  group('AppConfig mapTileUrl', () {
    test('defaults to OpenStreetMap url template', () {
      expect(AppConfig.mapTileUrl, 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
    });
  });

  group('GeoLocationPoint Model', () {
    test('parses from JSON correctly and provides label', () {
      final point = GeoLocationPoint.fromJson({
        'country_code': 'TR',
        'country_name': 'Turkey',
        'region': 'Marmara',
        'city': 'Istanbul',
        'latitude': 41.0082,
        'longitude': 28.9784,
        'count': 12,
      });

      expect(point.countryCode, 'TR');
      expect(point.countryName, 'Turkey');
      expect(point.region, 'Marmara');
      expect(point.city, 'Istanbul');
      expect(point.latitude, 41.0082);
      expect(point.longitude, 28.9784);
      expect(point.count, 12);
      expect(point.label, 'Istanbul, Turkey');
    });
  });

  group('VisitorMap Widget', () {
    testWidgets('renders empty placeholder when locations list is empty', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const VisitorMap(locations: [])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Visitor Map'), findsOneWidget);
      expect(find.text('No location data recorded for this period.'), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);
    });

    testWidgets('renders map, markers, and stats when locations exist', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final locations = [
        const GeoLocationPoint(
          countryCode: 'TR',
          countryName: 'Turkey',
          region: 'Istanbul',
          city: 'Istanbul',
          latitude: 41.0082,
          longitude: 28.9784,
          count: 8,
        ),
        const GeoLocationPoint(
          countryCode: 'DE',
          countryName: 'Germany',
          region: 'Berlin',
          city: 'Berlin',
          latitude: 52.5200,
          longitude: 13.4050,
          count: 3,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(VisitorMap(locations: locations)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Visitor Map'), findsOneWidget);
      expect(find.text('2 locations'), findsOneWidget);
      expect(find.text('11 visitors'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(TileLayer), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);

      // Verify quick jump chips
      expect(find.text('Istanbul, Turkey'), findsOneWidget);
      expect(find.text('Berlin, Germany'), findsOneWidget);

      // Tap on the Berlin quick chip to select location
      await tester.tap(find.text('Berlin, Germany'));
      await tester.pumpAndSettle();

      // Selected card details appear
      expect(find.text('3 visitors'), findsOneWidget);
      expect(
        find.text('${locations[1].latitude.toStringAsFixed(2)}, ${locations[1].longitude.toStringAsFixed(2)}'),
        findsOneWidget,
      );

      // Dismiss selected card via close button
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();
      expect(
        find.text('${locations[1].latitude.toStringAsFixed(2)}, ${locations[1].longitude.toStringAsFixed(2)}'),
        findsNothing,
      );
    });
  });
}
