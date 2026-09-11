// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:sightpane_dashboard/shared/widgets.dart';

void main() {
  testWidgets('FilterSearchField shows keys on focus and typing', (tester) async {
    final controller = TextEditingController();
    String submittedQuery = '';

    final filterKeys = [
      const FilterKeyDefinition(
        key: 'browser',
        label: 'browser',
        description: 'Filter by browser',
        icon: LucideIcons.globe,
        options: [
          FilterOption(value: 'Chrome', label: 'Google Chrome'),
          FilterOption(value: 'Firefox', label: 'Mozilla Firefox'),
        ],
      ),
      const FilterKeyDefinition(
        key: 'platform',
        label: 'platform',
        description: 'Filter by platform',
        icon: LucideIcons.layers,
        options: [
          FilterOption(value: 'web', label: 'Web application'),
          FilterOption(value: 'android', label: 'Android app'),
        ],
      ),
    ];

    await tester.pumpWidget(
      ShadcnApp(
        home: Scaffold(
          child: Center(
            child: FilterSearchField(
              controller: controller,
              placeholder: 'Search...',
              onSubmitted: (q) => submittedQuery = q,
              filterKeys: filterKeys,
            ),
          ),
        ),
      ),
    );

    // Tap search field to focus
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    // Dropdown overlay should be showing key suggestions
    expect(find.text('browser:'), findsOneWidget);
    expect(find.text('platform:'), findsOneWidget);

    // Type 'bro'
    await tester.enterText(find.byType(TextField), 'bro');
    await tester.pumpAndSettle();

    expect(find.text('browser:'), findsOneWidget);
    expect(find.text('platform:'), findsNothing);

    // Tap 'browser:' suggestion
    await tester.tap(find.text('browser:'));
    await tester.pumpAndSettle();

    // Text field should now contain 'browser:' and switch to value suggestions
    expect(controller.text, 'browser:');
    expect(find.text('Chrome'), findsOneWidget);
    expect(find.text('Firefox'), findsOneWidget);

    // Tap 'Chrome'
    await tester.tap(find.text('Chrome'));
    await tester.pumpAndSettle();

    // Text field should complete to 'browser:Chrome ' and submit
    expect(controller.text, 'browser:Chrome ');
    expect(submittedQuery, 'browser:Chrome');
  });

  testWidgets('FilterSearchField keyboard navigation with arrows and enter', (tester) async {
    final controller = TextEditingController();
    String submittedQuery = '';

    final filterKeys = [
      const FilterKeyDefinition(
        key: 'browser',
        label: 'browser',
        description: 'Filter by browser',
        icon: LucideIcons.globe,
        options: [
          FilterOption(value: 'Chrome', label: 'Google Chrome'),
          FilterOption(value: 'Firefox', label: 'Mozilla Firefox'),
        ],
      ),
      const FilterKeyDefinition(
        key: 'platform',
        label: 'platform',
        description: 'Filter by platform',
        icon: LucideIcons.layers,
        options: [
          FilterOption(value: 'web', label: 'Web application'),
        ],
      ),
    ];

    await tester.pumpWidget(
      ShadcnApp(
        home: Scaffold(
          child: Center(
            child: FilterSearchField(
              controller: controller,
              placeholder: 'Search...',
              onSubmitted: (q) => submittedQuery = q,
              filterKeys: filterKeys,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('browser:'), findsOneWidget);

    // Press Enter to select the first highlighted key ('browser:')
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(controller.text, 'browser:');
    expect(find.text('Chrome'), findsOneWidget);

    // Arrow down to highlight 'Firefox'
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    // Press Enter to select 'Firefox'
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(controller.text, 'browser:Firefox ');
    expect(submittedQuery, 'browser:Firefox');
  });

  testWidgets('FilterSearchField escape dismisses overlay and clear button resets', (tester) async {
    final controller = TextEditingController();
    String submittedQuery = 'init';
    bool cleared = false;

    final filterKeys = [
      FilterKeyDefinition(
        key: 'browser',
        label: 'browser',
        description: 'Filter by browser',
        icon: LucideIcons.globe,
        options: const [
          FilterOption(value: 'Chrome'),
        ],
        dynamicOptions: () => const [
          FilterOption(value: 'Arc Browser'),
        ],
      ),
    ];

    await tester.pumpWidget(
      ShadcnApp(
        home: Scaffold(
          child: Center(
            child: FilterSearchField(
              controller: controller,
              placeholder: 'Search...',
              onSubmitted: (q) => submittedQuery = q,
              onClear: () => cleared = true,
              filterKeys: filterKeys,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.text('browser:'), findsOneWidget);

    // Press Escape to dismiss overlay
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('browser:'), findsNothing);

    // Type 'browser:' to test dynamic options
    await tester.enterText(find.byType(TextField), 'browser:');
    await tester.pumpAndSettle();
    expect(find.text('Chrome'), findsOneWidget);
    expect(find.text('Arc Browser'), findsOneWidget);

    // Clear button (Icon LucideIcons.x inside trailing)
    final clearBtn = find.byIcon(LucideIcons.x);
    expect(clearBtn, findsOneWidget);
    await tester.tap(clearBtn);
    await tester.pumpAndSettle();

    expect(controller.text, '');
    expect(cleared, isTrue);
    expect(submittedQuery, '');
  });
}
