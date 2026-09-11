---
name: flutter-chart
description: Build charts and data visualizations in Flutter with the Graphic library (package:graphic, Grammar of Graphics) — bar, line, area, pie, scatter, heatmap, sparklines, custom shapes, tooltips, crosshairs, selections, animations. Use whenever the user wants a chart, graph, plot, sparkline, trend line, distribution, timeline histogram or "grafik" in the sightpane dashboard (), wants to replace or extend the hand-drawn `BarChart` in lib/shared/widgets.dart, or asks anything about the graphic package's API. Also use when a stats/overview/events page needs a visual that a KPI tile cannot express.
---

# Flutter Chart with Graphic

A skill for helping users build data visualizations in Flutter using the [Graphic](https://pub.dev/packages/graphic) library — a Grammar of Graphics-based charting library.

## When to Use

- User wants to create any type of chart in Flutter (bar, line, area, pie, scatter, heatmap, etc.)
- User needs help configuring chart appearance, interactivity, or animations
- User asks about Graphic library APIs or usage patterns
- User wants to convert data into visual representations
- **User wants to create custom, bespoke visualizations** — Graphic's customization system is its most powerful feature and a key strength of AI-assisted development

## Why Custom Charts?

Standard chart types (bar, line, pie) only cover a fraction of data visualization needs. Graphic is built on Grammar of Graphics theory, which means **every visual layer is independently customizable**:

- **Custom Shapes** — Render any geometry (triangles, lollipops, arrows, gauges, bullet charts, sparklines, etc.)
- **Custom Tooltips** — Fully custom interactive overlays with any layout
- **Custom Annotations** — Draw any graphics at data or absolute positions
- **Custom Encoders** — Map data to visuals using arbitrary logic
- **Custom Modifiers** — Define custom collision/arrangement behavior

This makes AI-assisted development especially valuable: the AI can write custom shape renderers, coordinate math, and drawing code that would be tedious to implement manually.

**Always consider customization when the user's requirements don't perfectly match a standard chart type.** See `references/customization.md` for the comprehensive customization guide.

## Quick Start

### Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  graphic: ^latest
```

Then run `flutter pub get`.

### Import

```dart
import 'package:graphic/graphic.dart';
```

### Minimal Example

```dart
Chart(
  data: [
    {'category': 'A', 'value': 10},
    {'category': 'B', 'value': 20},
    {'category': 'C', 'value': 15},
  ],
  variables: {
    'category': Variable(
      accessor: (Map map) => map['category'] as String,
    ),
    'value': Variable(
      accessor: (Map map) => map['value'] as num,
    ),
  },
  marks: [IntervalMark()],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Core Concepts

Graphic follows the **Grammar of Graphics** theory. A chart is composed of independent, declarative layers:

```
data → Variable → Scale → Encode → Mark → Shape → Render
```

Everything is configured through the single `Chart<D>` widget constructor. There are no imperative APIs — all configuration is declarative.

### The Chart Widget

`Chart<D>` is the only public widget. The type parameter `D` is the data item type. Key parameters:

| Parameter | Type | Purpose |
|-----------|------|---------|
| `data` | `List<D>` | **Required.** Data to visualize |
| `variables` | `Map<String, Variable<D, dynamic>>` | **Required.** How to extract values from data |
| `marks` | `List<Mark>` | **Required.** Geometry types to render |
| `coord` | `Coord?` | Coordinate system (default: `RectCoord`) |
| `axes` | `List<AxisGuide>?` | Axis configuration |
| `tooltip` | `TooltipGuide?` | Tooltip on interaction |
| `crosshair` | `CrosshairGuide?` | Crosshair on interaction |
| `annotations` | `List<Annotation>?` | Static annotations |
| `selections` | `Map<String, Selection>?` | Named selection behaviors |
| `transforms` | `List<VariableTransform>?` | Data transforms (filter, sort, proportion) |
| `padding` | `EdgeInsets Function(Size)?` | Padding around the plot area |
| `transition` | — | Set on each Mark, not on Chart |

See `references/chart-widget.md` for full parameter details.

### Variables

Variables define how raw data maps to abstract values:

```dart
variables: {
  'date': Variable(
    accessor: (MyData d) => d.date,
    scale: TimeScale(formatter: (t) => DateFormat.MMMd().format(t)),
  ),
  'value': Variable(
    accessor: (MyData d) => d.value,
    scale: LinearScale(min: 0),
  ),
}
```

Each variable can have a `Scale` that controls domain-to-range mapping. See `references/scales.md`.

### Marks

Marks are the geometric elements that represent data:

| Mark | Use Case | Default Shape |
|------|----------|---------------|
| `IntervalMark` | Bar charts, histograms, pie charts | `RectShape` |
| `LineMark` | Line charts, sparklines | `BasicLineShape` |
| `AreaMark` | Area charts, stream graphs | `BasicAreaShape` |
| `PointMark` | Scatter plots, bubble charts | `CircleShape` |
| `PolygonMark` | Heatmaps, treemaps | `HeatmapShape` |
| `CustomMark` | Candlestick, custom shapes | Any `Shape` |

See `references/marks.md` for parameters and `references/shapes.md` for shape options.

### Encodes (Aesthetic Mappings)

Encodes map data values to visual properties. Every encode supports three modes:

1. **Fixed value**: `ColorEncode(value: Colors.blue)`
2. **Variable mapping**: `ColorEncode(variable: 'type', values: Defaults.colors10)`
3. **Custom function**: `ColorEncode(encoder: (tuple) => myColorLogic(tuple))`

Available encodes: `ColorEncode`, `SizeEncode`, `ShapeEncode`, `LabelEncode`, `GradientEncode`, `ElevationEncode`.

See `references/encodes.md` for details.

### Position Algebra (Varset)

Position is specified using `Varset` algebra with three operators:

| Operator | Name | Effect |
|----------|------|--------|
| `*` | Cross | Assigns variables to different dimensions (x, y) |
| `+` | Blend | Combines variables on the same dimension |
| `/` | Nest | Groups data by a variable |

```dart
// x=date, y=value, grouped by type
position: Varset('date') * Varset('value') / Varset('type')
```

See `references/algebra.md` for details.

### Coordinates

- **`RectCoord`** — Cartesian coordinates (default). Supports `transposed`, `horizontalRange`, `verticalRange`.
- **`PolarCoord`** — Polar/radial coordinates for pie charts, radar charts, rose charts. Supports `startAngle`, `endAngle`, `startRadius`, `endRadius`.

See `references/coordinates.md` for details.

### Interaction

Define named selections and use them in encode updaters:

```dart
selections: {
  'tap': PointSelection(dim: Dim.x),
},
marks: [
  IntervalMark(
    color: ColorEncode(
      value: Colors.blue,
      updaters: {
        'tap': {
          true: (color) => color.withAlpha(255),   // selected
          false: (color) => color.withAlpha(100),  // not selected
        },
      },
    ),
  ),
],
```

See `references/selections.md` for selection types and gesture configuration.

### Modifiers

Modifiers handle geometry collision/arrangement:

- `StackModifier()` — Stack elements (stacked bar, stacked area)
- `DodgeModifier()` — Place side by side (grouped bar)
- `JitterModifier()` — Random scatter (strip plot)
- `SymmetricModifier()` — Center symmetrically (stream graph)

See `references/modifiers.md`.

### Animation

```dart
IntervalMark(
  transition: Transition(duration: Duration(seconds: 1), curve: Curves.easeOut),
  entrance: {MarkEntrance.y},  // Animate from y=0
  tag: (tuple) => tuple['id'].toString(),  // Element matching for transitions
)
```

See `references/animation.md`.

## Common Chart Recipes

### Bar Chart
```dart
marks: [IntervalMark()]
coord: RectCoord()  // default
```

### Horizontal Bar Chart
```dart
marks: [IntervalMark()]
coord: RectCoord(transposed: true)
```

### Grouped Bar Chart
```dart
marks: [
  IntervalMark(
    position: Varset('x') * Varset('y') / Varset('group'),
    color: ColorEncode(variable: 'group', values: Defaults.colors10),
    modifiers: [DodgeModifier()],
  ),
]
```

### Stacked Bar Chart
```dart
marks: [
  IntervalMark(
    position: Varset('x') * Varset('y') / Varset('group'),
    color: ColorEncode(variable: 'group', values: Defaults.colors10),
    modifiers: [StackModifier()],
  ),
]
```

### Line Chart
```dart
marks: [LineMark()]
```

### Smooth Line Chart
```dart
marks: [
  LineMark(shape: ShapeEncode(value: BasicLineShape(smooth: true))),
]
```

### Area Chart
```dart
marks: [AreaMark()]
```

### Pie Chart
```dart
transforms: [Proportion(variable: 'value', as: 'percent')],
marks: [
  IntervalMark(
    position: Varset('percent') / Varset('category'),
    color: ColorEncode(variable: 'category', values: Defaults.colors10),
    modifiers: [StackModifier()],
  ),
],
coord: PolarCoord(transposed: true, dimCount: 1),
```

### Scatter Plot
```dart
marks: [
  PointMark(
    size: SizeEncode(variable: 'magnitude', values: [2, 20]),
    color: ColorEncode(variable: 'type', values: Defaults.colors10),
  ),
]
```

### Rose Chart
```dart
marks: [IntervalMark(color: ColorEncode(variable: 'name', values: Defaults.colors10))],
coord: PolarCoord(startRadius: 0.15),
```

See `references/examples.md` for more complete examples.

## Custom Chart Development

Graphic's greatest strength is its **fully customizable rendering pipeline**. When standard chart types don't meet requirements, create custom visualizations by implementing your own shapes, tooltips, annotations, and encoders.

### Custom Shapes — The Core Extension Point

Create entirely new chart geometries by extending a Shape base class and implementing `drawGroupPrimitives()`:

```dart
class LollipopShape extends IntervalShape {
  LollipopShape({this.radius = 6});
  final double radius;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group, CoordConv coord, Offset origin,
  ) {
    final rst = <MarkElement>[];
    for (var item in group) {
      if (item.position.any((p) => !p.dy.isFinite)) continue;
      final style = getPaintStyle(item, false, 0, null, null);
      final base = coord.convert(item.position[0]);
      final tip = coord.convert(item.position[1]);

      // Stem line
      rst.add(PolylineElement(
        points: [base, tip],
        style: PaintStyle(strokeColor: style.fillColor, strokeWidth: 2),
        tag: item.tag,
      ));
      // Circle head
      rst.add(CircleElement(
        center: tip, radius: radius, style: style, tag: item.tag,
      ));
    }
    return rst;
  }

  @override
  bool equalTo(Object other) =>
    other is LollipopShape && radius == other.radius;
}
```

**Available base classes**: `IntervalShape`, `LineShape`, `AreaShape`, `PointShape`, `PolygonShape`

**Available drawing primitives**: `RectElement`, `CircleElement`, `PolygonElement`, `PolylineElement`, `ArcElement`, `SectorElement`, `SplineElement`, `PathElement`, `LabelElement`, `GroupElement`

### Custom Tooltip Renderer

```dart
tooltip: TooltipGuide(
  renderer: (Size size, Offset anchor, Map<int, Tuple> selected) {
    final t = selected.values.first;
    return [
      RectElement(
        rect: Rect.fromCenter(center: anchor, width: 100, height: 36),
        borderRadius: BorderRadius.circular(6),
        style: PaintStyle(fillColor: Colors.black87, elevation: 4),
      ),
      LabelElement(
        text: '${t['name']}: ${t['value']}',
        anchor: anchor,
        style: LabelStyle(
          textStyle: TextStyle(color: Colors.white, fontSize: 12),
          align: Alignment.center,
        ),
      ),
    ];
  },
)
```

### Custom Encoder Functions

Every encode supports arbitrary logic via `encoder`:

```dart
color: ColorEncode(encoder: (tuple) {
  final v = tuple['value'] as num;
  return v > 100 ? Colors.red : v > 50 ? Colors.orange : Colors.green;
}),

label: LabelEncode(encoder: (tuple) => Label(
  '${tuple['value']}%',
  LabelStyle(textStyle: TextStyle(
    fontSize: (tuple['value'] as num) > 50 ? 14 : 10,
    fontWeight: FontWeight.bold,
  )),
)),
```

### Key Classes for Custom Development

| Class | Purpose |
|-------|---------|
| `Attributes` | Encoded data element — contains `position`, `color`, `gradient`, `size`, `label`, `tag` |
| `CoordConv` | Converts normalized [0,1] positions to canvas pixels via `convert()`/`invert()` |
| `PaintStyle` | Full paint specification — fill, stroke, gradient, dash, elevation, shadow |
| `MarkElement` | Drawing primitives — the building blocks for custom rendering |
| `getPaintStyle()` | Utility to extract `PaintStyle` from `Attributes` |

**See `references/customization.md` for the comprehensive guide** including coordinate handling, all drawing primitives, custom annotations, custom modifiers, and best practices.

## Guides & Annotations

- **Axes**: Use `Defaults.horizontalAxis`, `Defaults.verticalAxis` for quick setup, or customize with `AxisGuide`. See `references/guides.md`.
- **Tooltip**: `TooltipGuide()` with optional custom renderer. See `references/guides.md`.
- **Crosshair**: `CrosshairGuide()`. See `references/guides.md`.
- **Annotations**: `LineAnnotation`, `RegionAnnotation`, `TagAnnotation`, `CustomAnnotation`. See `references/annotations.md`.

## Styling

- `PaintStyle` — Fill/stroke colors, gradients, dash patterns, shadows
- `LabelStyle` — Text style, alignment, rotation, offset
- `Defaults` — Built-in color palettes (`colors10`, `colors20`), preset axes, default styles

See `references/styling.md`.

## Event Streams

Charts expose `StreamController` parameters for external event coupling:

- `gestureStream` — Send/receive gesture events
- `resizeStream` — React to resize events
- `changeDataStream` — React to data change events
- `selectionStream` (on Mark) — Programmatically set selections

## Dynamic Data

Simply update the `data` parameter via `setState()`:

```dart
setState(() {
  data = newData;
});
```

The chart automatically re-renders with transition animations when `tag` is set.

## Important Notes

- The `Chart` widget is the **only** public widget — all configuration is via its constructor
- `color` and `gradient` on encodes are **mutually exclusive**
- Pie charts require `Proportion` transform + `PolarCoord(transposed: true, dimCount: 1)`
- Use `tag` on marks for smooth transition animations between data states
- `Varset` `/` (nest) operator is required for grouping (multi-series, stacked, dodged)
- Function-typed properties are always treated as "unchanged" in equality comparisons

## Reference Files

| File | Content |
|------|---------|
| `references/customization.md` | **Custom chart development guide** — shapes, tooltips, annotations, encoders, drawing primitives |
| `references/chart-widget.md` | Full Chart widget parameter reference |
| `references/marks.md` | All mark types and parameters |
| `references/encodes.md` | Aesthetic encoding reference |
| `references/shapes.md` | Shape types for each mark |
| `references/scales.md` | Scale types and configuration |
| `references/coordinates.md` | Coordinate system reference |
| `references/guides.md` | Axis, Tooltip, Crosshair reference |
| `references/annotations.md` | Annotation types reference |
| `references/selections.md` | Selection and interaction reference |
| `references/modifiers.md` | Geometry modifier reference |
| `references/transforms.md` | Data transform reference |
| `references/algebra.md` | Varset algebra reference |
| `references/animation.md` | Transition and entrance animation reference |
| `references/styling.md` | PaintStyle, LabelStyle, Defaults reference |
| `references/examples.md` | Complete chart examples |

When answering user questions, **read the source code** for the most accurate and up-to-date API details. The library uses extensive code comments as documentation. In this environment the package source is at `~/.pub-cache/hosted/pub.dev/graphic-2.7.0/` (run `dart pub cache add graphic --version 2.7.0` if missing). Key source directories under `lib/src/`:

- `lib/src/chart/` — Chart widget
- `lib/src/mark/` — Mark types
- `lib/src/encode/` — Encode types
- `lib/src/shape/` — Shape implementations
- `lib/src/scale/` — Scale types
- `lib/src/coord/` — Coordinate systems
- `lib/src/guide/` — Axis, Tooltip, Crosshair, Annotations
- `lib/src/interaction/` — Selection, gestures
- `lib/src/variable/` — Variable and transforms
- `lib/src/algebra/` — Varset algebra
- `lib/src/common/` — Shared types (Label, PaintStyle, Defaults)

---

## Local note: charts in the sightpane dashboard (read before adding a chart)

**graphic is not yet a dependency of this repository.** Today's charts are hand-drawn:
`BarChart` in `lib/shared/widgets.dart` (a `Row` of bars with a secondary error series, used
by `OverviewPage` for daily sessions/errors and events) and the event-name × day table in
`EventsPage`. Before the first `Chart(...)` widget, run `flutter pub add
graphic` (pin `^2.7.0`; it needs Flutter ≥ 3.16 and only `collection`, `vector_math`,
`path_drawing`), and mention the new dependency in the PR — the dashboard has kept its
dependency list short on purpose. Do not add it to `package/` (the SDK must stay on
`http` + `clock` + `web`).

**Palette and theme.** The dashboard is fixed dark (`Tokens.bg` `#0E0D0B`), so
`Defaults.colors10` and `Colors.*` from the upstream examples are wrong here (and `Colors`
is Material, which the app does not import). Use `Tokens.accent` (brand amber) for the
primary series, `Tokens.danger` for errors, `Tokens.info`/`Tokens.ok` for secondary series,
`Tokens.textMuted`/`Tokens.textDim` for axis labels and grid lines (`PaintStyle(strokeColor:
Tokens.hairline)`), `AppTheme.mono(size: 11)` for tick labels so digits stay tabular.
Tooltip surfaces: `Tokens.raised` fill, `Tokens.border` stroke, `Tokens.radius`. Keep the
existing `BarChart` visual language (thin bars, bottom labels via `Fmt.day`) when replacing
it so the overview does not look like two different products.

**Data shapes come from `lib/core/models.dart`.** `ProjectStats.daily` is `List<DayStat>`
(`day` ISO string, `sessions`, `errors`, `events`, `users`); `EventCount` is
`(name, day, count, users)`; `LiveStatus.routes` and `platforms`/`releases` are
`List<NameCount>`. Write `Variable(accessor: (DayStat d) => d.sessions)` against those
classes rather than converting to `Map`s. For the day axis use `Variable(accessor: (DayStat
d) => DateTime.parse(d.day), scale: TimeScale(formatter: (t) => Fmt.day(...)))` or keep the
string and an `OrdinalScale` — the backend already returns one row per day, zero-filled.

**Refresh and sizing.** `OverviewPage` invalidates `statsProvider` every second; give marks a
`tag` so transitions are smooth and avoid rebuilding the `Chart` with a new `variables` map
instance each tick (hoist it to a `static final`/top-level so equality holds). Charts must
sit in a bounded box (`SizedBox(height: …)` or `Expanded`), and the page must still fit
`mobileSize` (390 px) in tests — the `PanelCard` grid collapses to one column under
`Tokens.mobileBreakpoint`.

**Tests.** Pump through `pumpApp(tester, testContainer(FakeApi()))`
(`test/helpers/test_app.dart`); `FakeApi.statsValue.daily` has seven `DayStat`s you can assert
against with `find.byType(Chart)` plus the axis labels. Graphic paints with `CustomPaint`, so
assert on the data you passed and on labels, not on pixels.

Upstream skill: entronad/graphic `skills/flutter-chart` at commit `3b6f31e` (2026-02-25),
matching graphic 2.7.0.
