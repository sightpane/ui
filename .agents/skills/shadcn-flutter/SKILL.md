---
name: shadcn-flutter
description: Component, theming, typography and overlay reference for shadcn_flutter (the UI kit of the sightpane dashboard in ). Use whenever the user touches dashboard UI — adds a page, panel, table, form, dialog, toast, select, tabs, badge, or tweaks colors/spacing — or asks "which shadcn widget", "how do I show a dialog", "pano ekranı", "widget ekle", or when a Material widget (Scaffold/AppBar/Icons/showDialog/ScaffoldMessenger) is about to be used in , which this package does not support. Consult the component .md before writing the widget, not after it fails to compile.
---

# Shadcn Flutter

A cohesive UI ecosystem for Flutter—components, theming, and tooling—ready to ditch Material and Cupertino. Built with modern design tokens and high-quality widgets across mobile, web, and desktop.

## Getting Started

To set up a fresh Flutter application with Shadcn Flutter:

1. Add the dependency:
   ```shell
   flutter pub add shadcn_flutter
   ```

2. Configure your `main.dart`:
   ```dart
   import 'package:shadcn_flutter/shadcn_flutter.dart';

   void main() {
     runApp(
       ShadcnApp(
         title: 'My App',
         theme: ThemeData(
           colorScheme: ColorSchemes.darkSlate,
           radius: 0.5,
         ),
         home: const MyHomePage(),
       ),
     );
   }

   class MyHomePage extends StatelessWidget {
     const MyHomePage({super.key});

     @override
     Widget build(BuildContext context) {
       return const Scaffold(
         child: Center(
           child: Text('Hello World!').h1(),
         ),
       );
     }
   }
   ```

## Guides

Learn the core concepts and design system fundamentals.

| Name | Description | Path |
| :--- | :--- | :--- |
| **Introduction** | Overview of the ecosystem, features, and FAQ. | [guides/introduction.md](./guides/introduction.md) |
| **Installation** | Step-by-step setup for stable and experimental versions. | [guides/installation.md](./guides/installation.md) |
| **Theming** | Customizing tokens like radius, density, and scaling. | [guides/theming.md](./guides/theming.md) |
| **Colors** | Using the Tailwind-based color palette and ColorShades. | [guides/colors.md](./guides/colors.md) |
| **Typography** | Semantic text styles and widget extensions. | [guides/typography.md](./guides/typography.md) |
| **Layout** | Spacing, gaps, and responsive layout helpers. | [guides/layout.md](./guides/layout.md) |
| **Icons** | Accessing the 10,000+ bundled icons (Lucide, Radix, etc). | [guides/icons.md](./guides/icons.md) |
| **Interop** | Using Material and Cupertino widgets incrementally. | [guides/interop.md](./guides/interop.md) |
| **State Management** | Guide to the built-in Data and Model state system. | [guides/state_management.md](./guides/state_management.md) |
| **Web Preloader** | Customizing the loading experience for web apps. | [guides/web_preloader.md](./guides/web_preloader.md) |

## Components

Shadcn Flutter features over 100+ high-quality components. Below are the core categories.

### Animation
| Component | Path |
| :--- | :--- |
| **Number Ticker** | [components/animation/number_ticker.md](./components/animation/number_ticker.md) |

### Control
| Component | Path |
| :--- | :--- |
| **Button** | [components/control/button.md](./components/control/button.md) |

### Disclosure
| Component | Path |
| :--- | :--- |
| **Accordion** | [components/disclosure/accordion.md](./components/disclosure/accordion.md) |
| **Collapsible** | [components/disclosure/collapsible.md](./components/disclosure/collapsible.md) |

### Display
| Component | Path |
| :--- | :--- |
| **Avatar** | [components/display/avatar.md](./components/display/avatar.md) |
| **Chat Bubble** | [components/display/chat.md](./components/display/chat.md) |
| **Code Snippet** | [components/display/code_snippet.md](./components/display/code_snippet.md) |
| **Table** | [components/display/table.md](./components/display/table.md) |
| **Tracker** | [components/display/tracker.md](./components/display/tracker.md) |

### Feedback
| Component | Path |
| :--- | :--- |
| **Alert** | [components/feedback/alert.md](./components/feedback/alert.md) |
| **Alert Dialog** | [components/feedback/alert_dialog.md](./components/feedback/alert_dialog.md) |
| **Progress** | [components/feedback/progress.md](./components/feedback/progress.md) |
| **Toast** | [components/feedback/toast.md](./components/feedback/toast.md) |

### Form
| Component | Path |
| :--- | :--- |
| **AutoComplete** | [components/form/autocomplete.md](./components/form/autocomplete.md) |
| **Checkbox** | [components/form/checkbox.md](./components/form/checkbox.md) |
| **Chip Input** | [components/form/chip_input.md](./components/form/chip_input.md) |
| **Color Picker** | [components/form/color_picker.md](./components/form/color_picker.md) |
| **Date Picker** | [components/form/date_picker.md](./components/form/date_picker.md) |
| **Form** | [components/form/form.md](./components/form/form.md) |
| **Formatted Input** | [components/form/formatted_input.md](./components/form/formatted_input.md) |
| **Text Input** | [components/form/input.md](./components/form/input.md) |
| **Input OTP** | [components/form/input_otp.md](./components/form/input_otp.md) |
| **Item Picker** | [components/form/item_picker.md](./components/form/item_picker.md) |
| **Phone Input** | [components/form/phone_input.md](./components/form/phone_input.md) |
| **Radio Group** | [components/form/radio_group.md](./components/form/radio_group.md) |
| **Select** | [components/form/select.md](./components/form/select.md) |
| **Slider** | [components/form/slider.md](./components/form/slider.md) |
| **Star Rating** | [components/form/star_rating.md](./components/form/star_rating.md) |
| **Switch** | [components/form/switch.md](./components/form/switch.md) |
| **Text Area** | [components/form/text_area.md](./components/form/text_area.md) |
| **Time Picker** | [components/form/time_picker.md](./components/form/time_picker.md) |

### Layout
| Component | Path |
| :--- | :--- |
| **Card** | [components/layout/card.md](./components/layout/card.md) |
| **Card Image** | [components/layout/card_image.md](./components/layout/card_image.md) |
| **Carousel** | [components/layout/carousel.md](./components/layout/carousel.md) |
| **Divider** | [components/layout/divider.md](./components/layout/divider.md) |
| **Resizable** | [components/layout/resizable.md](./components/layout/resizable.md) |
| **Scaffold** | [components/layout/scaffold.md](./components/layout/scaffold.md) |
| **Sortable** | [components/layout/sortable.md](./components/layout/sortable.md) |
| **Stepper** | [components/layout/stepper.md](./components/layout/stepper.md) |
| **Steps** | [components/layout/steps.md](./components/layout/steps.md) |
| **Timeline** | [components/layout/timeline.md](./components/layout/timeline.md) |

### Navigation
| Component | Path |
| :--- | :--- |
| **Breadcrumb** | [components/navigation/breadcrumb.md](./components/navigation/breadcrumb.md) |
| **Dot Indicator** | [components/navigation/dot_indicator.md](./components/navigation/dot_indicator.md) |
| **Menubar** | [components/navigation/menubar.md](./components/navigation/menubar.md) |
| **Navigation Menu** | [components/navigation/navigation_menu.md](./components/navigation/navigation_menu.md) |
| **Pagination** | [components/navigation/pagination.md](./components/navigation/pagination.md) |
| **Switcher** | [components/navigation/switcher.md](./components/navigation/switcher.md) |
| **Tab List** | [components/navigation/tab_list.md](./components/navigation/tab_list.md) |
| **Tab Pane** | [components/navigation/tab_pane.md](./components/navigation/tab_pane.md) |
| **Tabs** | [components/navigation/tabs.md](./components/navigation/tabs.md) |
| **Tree** | [components/navigation/tree.md](./components/navigation/tree.md) |

### Overlay
| Component | Path |
| :--- | :--- |
| **Dialog** | [components/overlay/dialog.md](./components/overlay/dialog.md) |
| **Drawer** | [components/overlay/drawer.md](./components/overlay/drawer.md) |
| **Hover Card** | [components/overlay/hover_card.md](./components/overlay/hover_card.md) |
| **Pinned Sheet** | [components/overlay/pinned_sheet.md](./components/overlay/pinned_sheet.md) |
| **Popover** | [components/overlay/popover.md](./components/overlay/popover.md) |
| **Swiper** | [components/overlay/swiper.md](./components/overlay/swiper.md) |
| **Tooltip** | [components/overlay/tooltip.md](./components/overlay/tooltip.md) |
| **Window** | [components/overlay/window.md](./components/overlay/window.md) |

### Utility
| Component | Path |
| :--- | :--- |
| **Badge** | [components/utility/badge.md](./components/utility/badge.md) |
| **Calendar** | [components/utility/calendar.md](./components/utility/calendar.md) |
| **Chip** | [components/utility/chip.md](./components/utility/chip.md) |
| **Command** | [components/utility/command.md](./components/utility/command.md) |
| **Context Menu** | [components/utility/context_menu.md](./components/utility/context_menu.md) |
| **Dropdown Menu** | [components/utility/dropdown_menu.md](./components/utility/dropdown_menu.md) |
| **Overflow Marquee** | [components/utility/overflow_marquee.md](./components/utility/overflow_marquee.md) |
| **Refresh Trigger** | [components/utility/refresh_trigger.md](./components/utility/refresh_trigger.md) |

> [!TIP]
> This is a curated list. For the full list of all 100+ components, check the [components directory](./components/).

## Interactive Usage Tips

1. **Wait for Interaction**: When using `Popover` or `Dialog`, prefer using the provided controllers for programmatic access.
2. **Lean on Extensions**: Use `.h1()`, `.p()`, `.iconSmall()` etc., instead of manually configuring `TextStyle` or `size`.
3. **Density Matters**: Use `DensityContainer` or `theme.density` to ensure spacing is consistent across platform-specific densities.

---

## Local note: how sightpane uses shadcn_flutter (read before writing dashboard UI)

The dashboard (this repository) is on **shadcn_flutter 0.0.54**, the Material-free release: it
imports `package:flutter/widgets.dart` only. There is no `shadcn_flutter_material` and no
`MaterialLayer` in the app, so Material widgets (`Scaffold`/`AppBar` from Material, `Icons.*`,
`showDialog`, `ScaffoldMessenger`, `MaterialPageRoute`) assert at runtime. Use the package's
own `Scaffold`, `LucideIcons.*`, `showOverlay`/`showToast`, `ShadcnPageRoute`. Gap comes from
this package (`Gap(8)`); do not add the `gap` dependency the upstream examples import.

**Theme is fixed dark and token-driven.** `AppTheme.dark()` (`lib/app/theme/app_theme.dart`)
is `ColorSchemes.darkZinc.copyWith(...)` with every slot mapped to `Tokens`
(`lib/app/theme/tokens.dart`: `bg`, `panel`, `raised`, `chip`, `border`, `text`, `textMuted`,
`accent` = brand amber, `ok`, `danger`, `info`, `radius = 6`). Colors come from `Tokens` or
`Theme.of(context).colorScheme`, never literals; `withValues(alpha:)`, not `withOpacity`.
`ShadcnApp.router` (`lib/app/app.dart`) passes `theme` and `darkTheme` the same object with
`themeMode: ThemeMode.dark`, locale `tr`, and a `FallbackShadcnLocalizationsDelegate` because
the package ships only `en` — keep that delegate when touching the app root.

**House wrappers first, raw components second.** `lib/shared/widgets.dart` already has
`PageHeader`, `PanelCard`, `PanelMessage`, `KpiTile`/`KpiRow`, `Pill`, `FieldLabel`,
`FieldError`, `CopyField`, `toast(context, title, subtitle:)`, `showAppDialog(context, dialog)`
(= `showOverlay(context, const DialogConfiguration(), builder:).future`), `ConfirmDialog`,
`BarChart`, `DataTable<T>`. Reuse them so pages stay visually consistent; add a new wrapper
there rather than styling a component inline on one page.

**Conventions seen across the pages** (`lib/features/*`): buttons are `GhostButton` /
`PrimaryButton` / `OutlineButton` / `SecondaryButton` / `DestructiveButton` with
`size: ButtonSize.small` and `density: ButtonDensity.compact`/`icon`; text uses the
extensions `.small()`, `.xSmall()`, `.textMuted()`, `.mono()` (tabular figures via
`AppTheme.mono()`); icons are `LucideIcons.*` at 14–16 px; `Toggle` for segmented choices
such as the 7/14/30/90-day range (no `Select` on any page yet — when one is needed, pass
`adaptiveOverlay: false` so it stays a popover on desktop web instead of converting to a
sheet); `Card(filled: true)` / `SurfaceCard` for surfaces. Turkish uppercase: never `toUpperCase()` on user-visible text
(`i` → `İ`).

**Testing.** Widget tests pump pages through `pumpApp(tester, testContainer(FakeApi()))`
(`test/helpers/test_app.dart`), which builds `ShadcnApp.router` with `testTheme` and one
`ProviderContainer`. Overlays opened with `showOverlay` need `settle(tester)`; toasts need
`dismissToasts(tester)` before the test ends. Finders on shadcn buttons: `find.widgetWithText(GhostButton, '…')`.

The upstream docs above are for **0.0.54** at upstream commit `a7c10e0` (2026-09-06); the
installed source is at `~/.pub-cache/hosted/pub.dev/shadcn_flutter-0.0.54/lib/src/` — grep it
when a parameter in the .md does not compile.
