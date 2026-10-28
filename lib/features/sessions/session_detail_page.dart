import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;

import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'browser_fullscreen.dart';
import 'frame_prefetcher.dart';
import 'replay_size.dart';

export '../../shared/environment_card.dart';

/// Session detail: the replay player + the timeline + the selected item.
class SessionDetailPage extends ConsumerStatefulWidget {
  const SessionDetailPage({
    super.key,
    required this.projectId,
    required this.sessionId,
  });
  final int projectId;
  final String sessionId;
  @override
  ConsumerState<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends ConsumerState<SessionDetailPage> {
  TimelineItem? _selected;

  /// The timeline filter: '' for everything, otherwise an item type.
  String _filter = '';

  /// The side panel's tab: 0 the timeline, 1 device and environment.
  int _tab = 0;
  final _player = ReplayController();
  FramePrefetcher? _prefetcher;

  @visibleForTesting
  ReplayController get controllerForTest => _player;

  @override
  void dispose() {
    _player.dispose();
    _prefetcher?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(sessionDetailProvider(widget.sessionId));
    final api = ref.read(apiProvider);
    return detail.when(
      loading: () => PanelMessage(context.l10n.sessionLoading),
      error: (e, _) => PanelMessage(
        context.l10n.sessionLoadFailed(describeError(context.l10n, e)),
        color: Tokens.danger,
      ),
      data: (d) {
        final s = d.session;
        _player.load(d);
        // Frames are buffered ten at a time before playback; as the cursor
        // advances one more frame is requested.
        _prefetcher ??= FramePrefetcher(
          urls: [for (final f in d.frames) api.frameUrl(s.id, f.seq)],
          load: FramePrefetcher.precacheLoader(context),
        )..start();
        final isNarrow =
            MediaQuery.sizeOf(context).width < Tokens.mobileBreakpoint;
        final isDomSession =
            d.hasDom ||
            (d.frames.isEmpty && d.items.any((it) => it.type == 'dom'));
        final domItems = d.items.where((it) => it.type == 'dom').toList();
        final player = PanelCard(
          title: context.l10n.sessionReplay,
          subtitle: isDomSession
              ? context.l10n.replayDomPlayerTitle(domItems.length)
              : context.l10n.sessionFramesAndDuration(
                  d.frames.length,
                  context.fmt.duration(s.duration),
                ),
          child: isDomSession
              ? DomReplayPlayer(
                  detail: d,
                  controller: _player,
                  onTimeChanged: (t) => setState(() {}),
                )
              : ReplayPlayer(
                  controller: _player,
                  isFlutter: d.isFlutter,
                  screen: s.screen,
                  frameUrl: (seq) => api.frameUrl(s.id, seq),
                  prefetcher: _prefetcher,
                  onTimeChanged: (t) => setState(() {}),
                  onToggleFullscreen: () => FullscreenReplayPage.open(
                    context,
                    controller: _player,
                    frameUrl: (seq) => api.frameUrl(s.id, seq),
                    prefetcher: _prefetcher,
                    title: context.l10n.sessionFullscreenTitle(
                      context.fmt.shortId(s.id),
                      s.userLabel.isEmpty
                          ? context.l10n.commonAnonymous
                          : s.userLabel,
                    ),
                  ),
                ),
        );
        final shown = _filter.isEmpty
            ? d.items
            : d.items.where((it) => it.type == _filter).toList();
        int countOf(String type) =>
            d.items.where((it) => it.type == type).length;
        final filters = <(String, String)>[
          ('', context.l10n.commonAll),
          ('error', context.l10n.navIssues),
          ('event', context.l10n.navEvents),
          ('breadcrumb', context.l10n.sessionFilterBreadcrumbs),
        ];
        final timeline = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (type, label) in filters)
                    if (type.isEmpty || countOf(type) > 0)
                      QuickFilterChip(
                        token: context.l10n.sessionFilterLabel(
                          label,
                          type.isEmpty ? d.items.length : countOf(type),
                        ),
                        selected: _filter == type,
                        onTap: () => setState(() => _filter = type),
                      ),
                ],
              ),
            ),
            if (d.items.isEmpty)
              PanelMessage(context.l10n.sessionNoItems)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                itemCount: shown.length,
                itemBuilder: (context, i) {
                  final it = shown[i];
                  return TimelineRow(
                    item: it,
                    start: _player.t0,
                    active: _player.isCurrent(it.ts) || _selected == it,
                    upcoming: it.ts.isAfter(_player.current),
                    onTap: () {
                      _player.seekTo(it.ts);
                      setState(() => _selected = it);
                    },
                  );
                },
              ),
          ],
        );
        final side = Card(
          padding: EdgeInsets.zero,
          filled: true,
          fillColor: Tokens.panel,
          borderColor: Tokens.border,
          borderRadius: BorderRadius.circular(Tokens.radius),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Tokens.border)),
                ),
                child: TabList(
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                  children: [
                    TabItem(
                      child: Text(
                        '${context.l10n.sessionTimeline} · ${d.items.length}',
                      ),
                    ),
                    TabItem(child: Text(context.l10n.sessionTabDevice)),
                  ],
                ),
              ),
              if (_tab == 0)
                timeline
              else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClientEnvironmentCard(session: s),
                ),
            ],
          ),
        );
        final firstError = d.items
            .where((it) => it.type == 'error')
            .firstOrNull;
        final routes = routeStops(d.items);
        final detailPanel = _selected == null
            ? null
            : ItemDetail(item: _selected!, projectId: widget.projectId);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBreadcrumb(
                items: [
                  BreadcrumbItem(
                    label: context.l10n.sessionsTitle,
                    path: '/projects/${widget.projectId}/sessions',
                  ),
                  BreadcrumbItem(
                    label: context.l10n.sessionHeader(
                      context.fmt.shortId(s.id),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              SessionHeader(
                session: s,
                actions: [
                  if (firstError != null)
                    OutlineButton(
                      size: ButtonSize.small,
                      leading: const Icon(
                        LucideIcons.circleAlert,
                        size: 14,
                        color: Tokens.danger,
                      ),
                      onPressed: () {
                        _player.seekTo(firstError.ts);
                        setState(() {
                          _selected = firstError;
                          _tab = 0;
                        });
                      },
                      child: Text(
                        '${context.l10n.sessionJumpToError} · '
                        '${replayClock(firstError.ts.difference(_player.t0!))}',
                      ),
                    ),
                  if (firstError?.issueId != null)
                    PrimaryButton(
                      size: ButtonSize.small,
                      trailing: const Icon(LucideIcons.arrowRight, size: 14),
                      onPressed: () => context.go(
                        '/projects/${widget.projectId}/issues/${firstError!.issueId}',
                      ),
                      child: Text(context.l10n.sessionOpenIssue),
                    ),
                  GhostButton(
                    size: ButtonSize.small,
                    leading: const Icon(LucideIcons.chevronLeft, size: 14),
                    onPressed: () =>
                        context.go('/projects/${widget.projectId}/sessions'),
                    child: Text(context.l10n.sessionsTitle),
                  ),
                ],
              ),
              const Gap(16),
              if (isNarrow) ...[
                player,
                const Gap(12),
                side,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: player),
                    const Gap(12),
                    Expanded(flex: 2, child: side),
                  ],
                ),
              if (routes.length > 1) ...[
                const Gap(12),
                RouteFlow(
                  stops: routes,
                  current: _player.current,
                  onSeek: (t) {
                    _player.seekTo(t);
                    setState(() {});
                  },
                ),
              ],
              if (detailPanel != null) ...[const Gap(12), detailPanel],
            ],
          ),
        );
      },
    );
  }
}

/// The playback state: the frame list, the time cursor, play/pause.
class ReplayController extends ChangeNotifier {
  List<Frame> frames = const [];
  List<PointerSample> pointer = const [];
  List<DateTime> errorTimes = const [];
  DateTime? t0, t1;
  Duration position = Duration.zero;
  bool playing = false;
  double speed = 1;
  Timer? _timer;
  String? _loadedId;

  void load(SessionDetail d) {
    if (_loadedId == d.session.id) return;
    _loadedId = d.session.id;
    frames = d.frames;
    pointer = d.pointer;
    errorTimes = [
      for (final i in d.items)
        if (i.type == 'error') i.ts,
    ];
    final times = [
      d.session.startedAt,
      ...d.frames.map((f) => f.ts),
      ...d.items.map((i) => i.ts),
    ];
    t0 = times.reduce((a, b) => a.isBefore(b) ? a : b);
    final last = times.reduce((a, b) => a.isAfter(b) ? a : b);
    t1 = last.isAfter(t0!.add(const Duration(seconds: 1)))
        ? last
        : t0!.add(const Duration(seconds: 1));
    position = Duration.zero;
  }

  /// Where the errors fall on the scrubber, 0–1.
  List<double> get errorMarks => [
    if (t0 != null && total.inMilliseconds > 0)
      for (final t in errorTimes)
        t.difference(t0!).inMilliseconds / total.inMilliseconds,
  ];

  Duration get total =>
      t1 == null ? const Duration(seconds: 1) : t1!.difference(t0!);
  DateTime get current => t0!.add(position);

  Frame? frameAt(Duration pos) {
    if (frames.isEmpty) return null;
    Frame? f;
    final t = t0!.add(pos);
    for (final x in frames) {
      if (!x.ts.isAfter(t)) {
        f = x;
      } else {
        break;
      }
    }
    return f ?? frames.first;
  }

  Frame? get currentFrame => frameAt(position);

  /// The index of the current frame in the list (-1 when there is none).
  int get currentFrameIndex {
    final f = currentFrame;
    return f == null ? -1 : frames.indexOf(f);
  }

  /// The cursor: the last sample before the current moment (hidden once it is
  /// older than 1.5 s).
  PointerSample? get cursor {
    final t = current;
    PointerSample? last;
    for (final p in pointer) {
      if (p.ts.isAfter(t)) break;
      last = p;
    }
    if (last == null ||
        t.difference(last.ts) > const Duration(milliseconds: 1500)) {
      return null;
    }
    return last;
  }

  /// The samples within the last [window] (for the trail and the click rings).
  List<PointerSample> trail({
    Duration window = const Duration(milliseconds: 1200),
  }) {
    final t = current, from = t.subtract(window);
    return [
      for (final p in pointer)
        if (!p.ts.isBefore(from) && !p.ts.isAfter(t)) p,
    ];
  }

  bool isCurrent(DateTime ts) {
    final d = current.difference(ts);
    return d >= Duration.zero && d < const Duration(milliseconds: 1500);
  }

  void seek(Duration p) {
    position = p < Duration.zero ? Duration.zero : (p > total ? total : p);
    notifyListeners();
  }

  void seekTo(DateTime ts) => seek(ts.difference(t0!));

  void setSpeed(double s) {
    speed = s;
    notifyListeners();
  }

  void toggle() {
    if (playing) {
      pause();
      return;
    }
    if (position >= total) position = Duration.zero;
    playing = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      position += Duration(milliseconds: (100 * speed).round());
      if (position >= total) {
        position = total;
        pause();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    playing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class DomReplayPlayer extends StatefulWidget {
  const DomReplayPlayer({
    super.key,
    required this.detail,
    required this.controller,
    this.onTimeChanged,
    this.expand = false,
  });

  final SessionDetail detail;
  final ReplayController controller;
  final void Function(Duration)? onTimeChanged;
  final bool expand;

  @override
  State<DomReplayPlayer> createState() => _DomReplayPlayerState();
}

class _DomReplayPlayerState extends State<DomReplayPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
    widget.onTimeChanged?.call(widget.controller.position);
  }

  TimelineItem? get _currentDomItem {
    final dom = widget.detail.items.where((it) => it.type == 'dom').toList();
    if (dom.isEmpty) return null;
    final t = widget.controller.current;
    TimelineItem? active;
    for (final it in dom) {
      if (!it.ts.isAfter(t)) {
        active = it;
      } else {
        break;
      }
    }
    return active ?? dom.first;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final dom = widget.detail.items.where((it) => it.type == 'dom').toList();
    final active = _currentDomItem;

    final viewport = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(Tokens.radius),
          border: Border.all(color: Tokens.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
                border: Border(bottom: BorderSide(color: Color(0xFF3D3D3D))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5F56),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFBD2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27C93F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.globe,
                            size: 12,
                            color: Tokens.textMuted,
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              widget.detail.session.currentRoute.isEmpty
                                  ? 'https://app.local/'
                                  : widget.detail.session.currentRoute,
                              style: AppTheme.mono(
                                size: 11,
                                color: Tokens.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Tokens.brand.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DOM Replay',
                      style: TextStyle(
                        fontSize: 10,
                        color: Tokens.brand,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: active == null
                        ? Text(
                            context.l10n.replayNoFramesGeneric,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Tokens.textDim,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: active.name == 'snapshot'
                                            ? const Color(0x33C084FC)
                                            : const Color(0x3338BDF8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        active.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: active.name == 'snapshot'
                                              ? const Color(0xFFC084FC)
                                              : const Color(0xFF38BDF8),
                                        ),
                                      ),
                                    ),
                                    const Gap(8),
                                    Text(
                                      context.fmt.clock(active.ts),
                                      style: AppTheme.mono(
                                        size: 12,
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 480,
                                    maxHeight: 180,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141414),
                                    border: Border.all(
                                      color: const Color(0xFF333333),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: SingleChildScrollView(
                                    child: SelectableText(
                                      jsonEncode(active.body),
                                      style: AppTheme.mono(
                                        size: 11,
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (c.pointer.isNotEmpty)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: PointerOverlayPainter(
                            cursor: c.cursor,
                            trail: c.trail(),
                            now: c.current,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.expand)
          Expanded(child: Center(child: viewport))
        else
          viewport,
        ReplayControls(
          controller: c,
          enabled: dom.isNotEmpty,
          marks: [
            for (final it in dom)
              if (c.total.inMilliseconds > 0 && c.t0 != null)
                it.ts.difference(c.t0!).inMilliseconds / c.total.inMilliseconds,
          ],
        ),
      ],
    );
  }
}

class ReplayPlayer extends StatefulWidget {
  const ReplayPlayer({
    super.key,
    required this.controller,
    required this.frameUrl,
    this.prefetcher,
    this.onTimeChanged,
    this.expand = false,
    this.onToggleFullscreen,
    this.fullscreen = false,
    this.isFlutter = true,
    this.screen,
  });
  final ReplayController controller;
  final String Function(int seq) frameUrl;
  final FramePrefetcher? prefetcher;
  final void Function(Duration)? onTimeChanged;

  /// In fullscreen: the frame area fills the height it is given.
  final bool expand;
  final bool fullscreen;
  final bool isFlutter;
  final VoidCallback? onToggleFullscreen;

  /// The device's screen in logical pixels, as the session reported it. Inline,
  /// a frame is drawn at this size — what the user saw — and zoomed from there.
  final ({double w, double h})? screen;
  @override
  State<ReplayPlayer> createState() => _ReplayPlayerState();
}

class _ReplayPlayerState extends State<ReplayPlayer> {
  /// Relative to the device's size; null is "as large as fits on screen".
  double? _zoom = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    widget.prefetcher?.addListener(_buffered);
  }

  @override
  void didUpdateWidget(ReplayPlayer old) {
    super.didUpdateWidget(old);
    if (old.prefetcher != widget.prefetcher) {
      old.prefetcher?.removeListener(_buffered);
      widget.prefetcher?.addListener(_buffered);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    widget.prefetcher?.removeListener(_buffered);
    super.dispose();
  }

  void _buffered() {
    if (mounted) setState(() {});
  }

  void _changed() {
    final i = widget.controller.currentFrameIndex;
    if (i >= 0) widget.prefetcher?.setCursor(i);
    if (mounted) setState(() {});
    widget.onTimeChanged?.call(widget.controller.position);
  }

  /// A frame at the device's own size times the zoom, in a letterbox as wide as
  /// the panel, so a phone is not blown up to the panel's width.
  Widget _sizedFrame(BuildContext context, Frame f, Widget content) {
    return CustomPaint(
      painter: const _DotGridPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        child: LayoutBuilder(
          builder: (context, box) {
            final natural = deviceFrameSize(f.width, f.height, widget.screen);
            // A portrait screen is a phone: drawn inside a bezel, whose width
            // comes off what the frame may take.
            final phone = natural.height > natural.width;
            final bezel = phone ? _bezel * 2 + 2 : 0.0;
            final scale = replayScale(
              natural,
              zoom: _zoom,
              maxWidth: box.maxWidth - bezel,
              maxHeight: MediaQuery.sizeOf(context).height * 0.75,
            );
            final atWidth =
                scale >= (box.maxWidth - bezel) / natural.width - 1e-6;
            final zoomIn = atWidth ? null : nextZoomStep(scale, up: true);
            final zoomOut = nextZoomStep(scale, up: false);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.ghost(
                        size: ButtonSize.small,
                        icon: const Icon(LucideIcons.zoomOut, size: 14),
                        onPressed: zoomOut == null
                            ? null
                            : () => setState(() => _zoom = zoomOut),
                      ),
                      // The percentage goes back to the device's own size.
                      GhostButton(
                        size: ButtonSize.xSmall,
                        onPressed: () => setState(() => _zoom = 1),
                        child: Text(
                          context.fmt.percent((scale * 100).round() / 100),
                          style: AppTheme.mono(
                            size: 11,
                            color: Tokens.textMuted,
                          ),
                        ),
                      ),
                      IconButton.ghost(
                        size: ButtonSize.small,
                        icon: const Icon(LucideIcons.zoomIn, size: 14),
                        onPressed: zoomIn == null
                            ? null
                            : () => setState(() => _zoom = zoomIn),
                      ),
                      IconButton.ghost(
                        size: ButtonSize.small,
                        icon: const Icon(LucideIcons.scan, size: 14),
                        onPressed: () => setState(() => _zoom = null),
                      ),
                    ],
                  ),
                ),
                const Gap(6),
                Center(
                  child: _PhoneBezel(
                    enabled: phone,
                    child: SizedBox(
                      key: const ValueKey('replay-frame'),
                      width: natural.width * scale,
                      height: natural.height * scale,
                      child: content,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const _bezel = _PhoneBezel.thickness;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final f = c.currentFrame;
    final pf = widget.prefetcher;
    final idx = c.currentFrameIndex;
    final ready = pf == null || pf.initialReady;
    final frameCached = pf == null || idx < 0 || pf.isLoaded(idx);
    final frameContent = Container(
      color: const Color(0xFF000000),
      child: f == null
          ? Center(
              child: Text(
                widget.isFlutter
                    ? context.l10n.replayNoFrames
                    : context.l10n.replayNoFramesGeneric,
                style: const TextStyle(fontSize: 12, color: Tokens.textDim),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: pf != null && idx >= 0
                      ? pf.providers[idx]
                      : NetworkImage(widget.frameUrl(f.seq)),
                  key: ValueKey(f.seq),
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(LucideIcons.imageOff, color: Tokens.textDim),
                  ),
                ),
                for (final t in f.taps) TapMarker(tap: t),
                if (c.pointer.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: PointerOverlayPainter(
                          cursor: c.cursor,
                          trail: c.trail(),
                          now: c.current,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    color: const Color(0xAA000000),
                    child: Text(
                      '#${f.seq} · ${context.fmt.clock(f.ts)}',
                      style: AppTheme.mono(size: 10, color: Tokens.textMuted),
                    ),
                  ),
                ),
              ],
            ),
    );
    // Fullscreen, and the empty player, fill the width they are given.
    final Widget frameBox = widget.expand || f == null || f.height == 0
        ? AspectRatio(
            aspectRatio: f == null || f.height == 0
                ? 16 / 9
                : (f.width / f.height).clamp(0.4, 3.0),
            child: frameContent,
          )
        : _sizedFrame(context, f, frameContent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.expand)
          Expanded(child: Center(child: frameBox))
        else
          frameBox,
        ReplayControls(
          controller: c,
          enabled: c.frames.isNotEmpty && ready,
          marks: [
            for (final fr in c.frames)
              fr.ts.difference(c.t0!).inMilliseconds / c.total.inMilliseconds,
          ],
          buffer: pf != null && pf.urls.isNotEmpty
              ? BufferBadge(prefetcher: pf, stalled: !frameCached && c.playing)
              : null,
          fullscreen: widget.fullscreen,
          onToggleFullscreen: widget.onToggleFullscreen,
        ),
      ],
    );
  }
}

/// The fullscreen player: a page pushed onto the root navigator; ESC or the
/// button closes it, while the playback state and the buffer carry on with the
/// same controller.
class FullscreenReplayPage extends StatefulWidget {
  const FullscreenReplayPage({
    super.key,
    required this.controller,
    required this.frameUrl,
    required this.prefetcher,
    required this.title,
  });
  final ReplayController controller;
  final String Function(int seq) frameUrl;
  final FramePrefetcher? prefetcher;
  final String title;

  static Future<void> open(
    BuildContext context, {
    required ReplayController controller,
    required String Function(int seq) frameUrl,
    required FramePrefetcher? prefetcher,
    required String title,
  }) async {
    await enterBrowserFullscreen();
    if (!context.mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: true,
        fullscreenDialog: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => FullscreenReplayPage(
          controller: controller,
          frameUrl: frameUrl,
          prefetcher: prefetcher,
          title: title,
        ),
      ),
    );
    await exitBrowserFullscreen();
  }

  @override
  State<FullscreenReplayPage> createState() => _FullscreenReplayPageState();
}

class _FullscreenReplayPageState extends State<FullscreenReplayPage> {
  // Independent of focus: ESC / space work whichever widget holds the focus.
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return false;
    if (e.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return true;
    }
    if (e.logicalKey == LogicalKeyboardKey.space) {
      widget.controller.toggle();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF000000),
    child: Column(
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Tokens.textStrong,
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.replayFullscreenHint,
                style: const TextStyle(fontSize: 11, color: Tokens.textDim),
              ),
              const Gap(8),
              IconButton.ghost(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.x, size: 16),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReplayPlayer(
            controller: widget.controller,
            frameUrl: widget.frameUrl,
            prefetcher: widget.prefetcher,
            expand: true,
            fullscreen: true,
            onToggleFullscreen: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    ),
  );
}

/// The buffer readout: "cache 4/10" and how full the window is.
class BufferBadge extends StatelessWidget {
  const BufferBadge({
    super.key,
    required this.prefetcher,
    this.stalled = false,
  });
  final FramePrefetcher prefetcher;
  final bool stalled;

  @override
  Widget build(BuildContext context) {
    final p = prefetcher;
    final text = p.initialReady
        ? context.l10n.replayBuffer(p.loadedCount, p.urls.length)
        : context.l10n.replayBuffer(p.initialDone, p.initialTarget);
    final color = stalled
        ? Tokens.accentSoft
        : (p.initialReady ? Tokens.textDim : Tokens.info);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!p.initialReady || stalled) ...[
          const CircularProgressIndicator(size: 12),
          const Gap(6),
        ],
        Text(text, style: AppTheme.mono(size: 11, color: color)),
      ],
    );
  }
}

/// The mouse trail: a line over the last 1.2 s (fading out), the cursor arrow
/// and the click rings.
class PointerOverlayPainter extends CustomPainter {
  PointerOverlayPainter({
    required this.cursor,
    required this.trail,
    required this.now,
  });
  final PointerSample? cursor;
  final List<PointerSample> trail;
  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(PointerSample p) => Offset(p.x * size.width, p.y * size.height);
    final moves = trail
        .where((p) => p.kind == 'move' || p.kind == 'down' || p.kind == 'up')
        .toList();
    for (var i = 1; i < moves.length; i++) {
      final age = now.difference(moves[i].ts).inMilliseconds / 1200;
      final paint = Paint()
        ..color = Tokens.info.withValues(alpha: (1 - age).clamp(0.1, 0.9))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(at(moves[i - 1]), at(moves[i]), paint);
    }
    for (final p in trail.where((p) => p.kind == 'down')) {
      final age = now.difference(p.ts).inMilliseconds / 600;
      if (age > 1) continue;
      canvas.drawCircle(
        at(p),
        8 + 16 * age,
        Paint()
          ..color = Tokens.accent.withValues(alpha: (1 - age) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    for (final p in trail.where((p) => p.kind == 'scroll')) {
      final age = now.difference(p.ts).inMilliseconds / 600;
      if (age > 1) continue;
      canvas.drawCircle(
        at(p),
        6,
        Paint()..color = Tokens.ok.withValues(alpha: (1 - age) * 0.7),
      );
    }
    final c = cursor;
    if (c != null) {
      final o = at(c);
      final path = Path()
        ..moveTo(o.dx, o.dy)
        ..lineTo(o.dx, o.dy + 16)
        ..lineTo(o.dx + 4, o.dy + 12)
        ..lineTo(o.dx + 11, o.dy + 12)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(PointerOverlayPainter old) =>
      old.cursor != cursor ||
      old.now != now ||
      old.trail.length != trail.length;
}

/// A tap ring on top of the frame (normalized coordinates).
class TapMarker extends StatelessWidget {
  const TapMarker({super.key, required this.tap});
  final Tap tap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Padding(
      padding: EdgeInsets.only(
        left: (c.maxWidth * tap.x - 12).clamp(0, c.maxWidth),
        top: (c.maxHeight * tap.y - 12).clamp(0, c.maxHeight),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Tokens.accent, width: 3),
            color: Tokens.accent.withValues(alpha: 0.3),
          ),
        ),
      ),
    ),
  );
}

/// A simple scrubber; [marks] are the frame positions.
/// The stage behind a replayed frame: a faint dot grid, so the frame's own
/// edges stay visible against it.
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Tokens.surface);
    final dot = Paint()..color = Tokens.hairline;
    for (var y = 8.0; y < size.height; y += 16) {
      for (var x = 8.0; x < size.width; x += 16) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}

/// A phone's body around a portrait frame, so a replay reads as the device it
/// came from. Adds [thickness] on every side plus a 1 px border.
class _PhoneBezel extends StatelessWidget {
  const _PhoneBezel({required this.enabled, required this.child});
  final bool enabled;
  final Widget child;

  static const thickness = 8.0;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Container(
      padding: const EdgeInsets.all(thickness),
      decoration: BoxDecoration(
        color: Tokens.raised,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Tokens.chip),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(22), child: child),
    );
  }
}

/// mm:ss, or h:mm:ss past an hour — a replay position, not a clock time.
String replayClock(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60, sec = d.inSeconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}

/// The bar under both players: the scrubber, then back 5 s / play / forward
/// 5 s, the position, the buffer, the speed and fullscreen. Wraps onto two
/// lines when the player is narrow.
class ReplayControls extends StatelessWidget {
  const ReplayControls({
    super.key,
    required this.controller,
    required this.enabled,
    required this.marks,
    this.buffer,
    this.fullscreen = false,
    this.onToggleFullscreen,
  });
  final ReplayController controller;
  final bool enabled;
  final List<double> marks;
  final Widget? buffer;
  final bool fullscreen;
  final VoidCallback? onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final total = c.total.inMilliseconds;
    void skip(int seconds) => c.seek(c.position + Duration(seconds: seconds));
    Widget tip(String text, Widget child) => Tooltip(
      tooltip: (_) => TooltipContainer(child: Text(text)),
      child: child,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Tokens.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Scrubber(
            value: total > 0 ? c.position.inMilliseconds / total : 0.0,
            marks: marks,
            errorMarks: c.errorMarks,
            onChanged: (v) =>
                c.seek(Duration(milliseconds: (v * total).round())),
          ),
          const Gap(8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tip(
                    context.l10n.replaySkipBack,
                    IconButton.ghost(
                      size: ButtonSize.small,
                      icon: const Icon(LucideIcons.rotateCcw, size: 15),
                      onPressed: enabled ? () => skip(-5) : null,
                    ),
                  ),
                  const Gap(4),
                  IconButton.primary(
                    shape: ButtonShape.circle,
                    icon: Icon(
                      c.playing ? LucideIcons.pause : LucideIcons.play,
                      size: 16,
                    ),
                    onPressed: enabled ? c.toggle : null,
                  ),
                  const Gap(4),
                  tip(
                    context.l10n.replaySkipForward,
                    IconButton.ghost(
                      size: ButtonSize.small,
                      icon: const Icon(LucideIcons.rotateCw, size: 15),
                      onPressed: enabled ? () => skip(5) : null,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    replayClock(c.position),
                    style: AppTheme.mono(size: 13, color: Tokens.textStrong),
                  ),
                  Text(
                    ' / ${replayClock(c.total)}',
                    style: AppTheme.mono(size: 13, color: Tokens.textMuted),
                  ),
                  if (buffer != null) ...[const Gap(12), buffer!],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Tokens.border),
                      borderRadius: BorderRadius.circular(Tokens.radius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final s in const [1.0, 2.0, 4.0])
                          c.speed == s
                              ? SecondaryButton(
                                  size: ButtonSize.xSmall,
                                  onPressed: () {},
                                  child: Text('${s.toInt()}×'),
                                )
                              : GhostButton(
                                  size: ButtonSize.xSmall,
                                  onPressed: () => c.setSpeed(s),
                                  child: Text(
                                    '${s.toInt()}×',
                                    style: const TextStyle(
                                      color: Tokens.textMuted,
                                    ),
                                  ),
                                ),
                      ],
                    ),
                  ),
                  if (onToggleFullscreen != null) ...[
                    const Gap(6),
                    IconButton.ghost(
                      size: ButtonSize.small,
                      icon: Icon(
                        fullscreen
                            ? LucideIcons.minimize2
                            : LucideIcons.maximize2,
                        size: 14,
                      ),
                      onPressed: onToggleFullscreen,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Scrubber extends StatelessWidget {
  const Scrubber({
    super.key,
    required this.value,
    required this.onChanged,
    this.marks = const [],
    this.errorMarks = const [],
  });
  final double value;
  final List<double> marks;

  /// Error moments, drawn taller and in red above the other marks.
  final List<double> errorMarks;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      void at(double dx) => onChanged((dx / c.maxWidth).clamp(0, 1));
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => at(d.localPosition.dx),
        onHorizontalDragUpdate: (d) => at(d.localPosition.dx),
        child: SizedBox(
          height: 24,
          child: CustomPaint(
            painter: _ScrubberPainter(
              value: value.clamp(0, 1),
              marks: marks,
              errorMarks: errorMarks,
            ),
          ),
        ),
      );
    },
  );
}

class _ScrubberPainter extends CustomPainter {
  _ScrubberPainter({
    required this.value,
    required this.marks,
    this.errorMarks = const [],
  });
  final double value;
  final List<double> marks, errorMarks;
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y - 2, size.width, 4),
        const Radius.circular(2),
      ),
      Paint()..color = Tokens.chip,
    );
    for (final m in marks) {
      canvas.drawRect(
        Rect.fromLTWH(m * size.width, y - 5, 1.5, 10),
        Paint()..color = Tokens.textFaint,
      );
    }
    for (final m in errorMarks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(m * size.width - 1.5, y - 8, 3, 16),
          const Radius.circular(1.5),
        ),
        Paint()..color = Tokens.danger,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y - 2, size.width * value, 4),
        const Radius.circular(2),
      ),
      Paint()..color = Tokens.accent,
    );
    canvas.drawCircle(
      Offset(size.width * value, y),
      6,
      Paint()..color = Tokens.accent,
    );
  }

  @override
  bool shouldRepaint(_ScrubberPainter old) =>
      old.value != value ||
      old.marks != marks ||
      !listEquals(old.errorMarks, errorMarks);
}

/// Who the session belongs to, how it went, and on what: the avatar and name,
/// an error badge, and one chip per known fact about the device and run.
class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.session,
    this.actions = const [],
  });
  final Session session;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final l = context.l10n;
    final fmt = context.fmt;
    // The person the way the sessions list and the Users page show them: the
    // name when the SDK sent one, the email under it.
    final label = s.userName.isNotEmpty ? s.userName : s.userLabel;
    final name = label.isEmpty ? l.commonAnonymous : label;
    final email = s.userName.isNotEmpty ? s.userEmail : '';
    final os = '${s.osName} ${s.osVersion}'.trim();
    final browser = s.isWeb
        ? '${s.browserName} ${s.browserVersion}'.trim()
        : '';
    final location = s.locationLabel.isNotEmpty
        ? s.locationLabel
        : s.countryCode;
    final chips = <(String, String)>[
      if (s.deviceLabel.isNotEmpty) (l.clientDevice, s.deviceLabel),
      if (os.isNotEmpty) (l.clientOS, os),
      if (browser.isNotEmpty) (l.clientBrowser, browser),
      if (s.release.isNotEmpty) (l.colRelease, s.release),
      if (location.isNotEmpty) (l.clientLocation, location),
      if (s.ip.isNotEmpty) (l.colIp, s.ip),
      (l.colDuration, fmt.duration(s.duration)),
      (l.colStart, fmt.dateTime(s.startedAt)),
    ];
    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Avatar(
          initials: label.isEmpty ? '—' : initialsOf(label),
          size: 40,
          backgroundColor: Tokens.chip,
        ),
        const Gap(12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: Tokens.textStrong,
                      ),
                    ),
                  ),
                  if (s.errorCount > 0) ...[
                    const Gap(10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Tokens.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l.sessionErrorBadge(s.errorCount),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Tokens.danger,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                [
                  if (email.isNotEmpty) email,
                  l.sessionHeader(fmt.shortId(s.id)),
                ].join(' · '),
                overflow: TextOverflow.ellipsis,
                style: AppTheme.mono(size: 12, color: Tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final buttons = Wrap(spacing: 8, runSpacing: 8, children: actions);
            if (box.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [identity, const Gap(12), buttons],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identity),
                const Gap(16),
                buttons,
              ],
            );
          },
        ),
        const Gap(12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (k, v) in chips)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Tokens.panel,
                  border: Border.all(color: Tokens.border),
                  borderRadius: BorderRadius.circular(Tokens.radius),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$k  ',
                        style: const TextStyle(color: Tokens.textMuted),
                      ),
                      TextSpan(
                        text: v,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Tokens.textStrong,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A route the user arrived at, and when.
typedef RouteStop = ({String route, DateTime ts});

/// The navigation breadcrumbs in order, a repeat of the same route folded
/// into one stop. The SDK's observer writes `{from, to}` in `data` and
/// "push /x" as the message; older items have only the message.
List<RouteStop> routeStops(List<TimelineItem> items) {
  final stops = <RouteStop>[];
  for (final it in items) {
    if (it.type != 'breadcrumb' || it.name != 'navigation') continue;
    final data = it.body['data'];
    var route = data is Map ? '${data['to'] ?? ''}' : '';
    if (route.isEmpty) {
      final msg = '${it.body['message'] ?? ''}'.trim();
      route = msg.contains(' ') ? msg.substring(msg.lastIndexOf(' ') + 1) : msg;
    }
    if (route.isEmpty) continue;
    if (stops.isNotEmpty && stops.last.route == route) continue;
    stops.add((route: route, ts: it.ts));
  }
  return stops;
}

/// The routes of the session as a strip of chips; the one on screen at the
/// cursor is highlighted, and a chip seeks to its arrival.
class RouteFlow extends StatelessWidget {
  const RouteFlow({
    super.key,
    required this.stops,
    required this.current,
    required this.onSeek,
  });
  final List<RouteStop> stops;
  final DateTime current;
  final ValueChanged<DateTime> onSeek;

  @override
  Widget build(BuildContext context) {
    var at = 0;
    for (var i = 0; i < stops.length; i++) {
      if (!stops[i].ts.isAfter(current)) at = i;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Tokens.panel,
        border: Border.all(color: Tokens.border),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              context.l10n.sessionRouteFlow,
              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
            ),
          ),
          for (var i = 0; i < stops.length; i++) ...[
            if (i > 0)
              const Icon(
                LucideIcons.chevronRight,
                size: 13,
                color: Tokens.textDim,
              ),
            i == at
                ? SecondaryButton(
                    size: ButtonSize.xSmall,
                    onPressed: () => onSeek(stops[i].ts),
                    child: Text(
                      stops[i].route,
                      style: AppTheme.mono(size: 12, color: Tokens.textStrong),
                    ),
                  )
                : OutlineButton(
                    size: ButtonSize.xSmall,
                    onPressed: () => onSeek(stops[i].ts),
                    child: Text(
                      stops[i].route,
                      style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow({
    super.key,
    required this.item,
    required this.active,
    required this.onTap,
    this.start,
    this.upcoming = false,
  });
  final TimelineItem item;
  final bool active;
  final VoidCallback onTap;

  /// The session's first moment: the row shows its offset from it, the way
  /// the player does. Without it, the wall-clock time.
  final DateTime? start;

  /// Not reached by the cursor yet: drawn dimmer.
  final bool upcoming;

  static Color colorOf(TimelineItem i) => switch (i.type) {
    'error' => Tokens.danger,
    'event' => Tokens.accent,
    _ => i.name == 'navigation' ? Tokens.info : Tokens.textDim,
  };

  /// The headline: an event's name without its properties, which go below.
  static String titleOf(TimelineItem i) =>
      i.type == 'event' && '${i.body['name'] ?? ''}'.isNotEmpty
      ? '${i.body['name']}'
      : i.message;

  /// The second line: where an error was thrown, an event's properties, a
  /// navigation's origin, or a breadcrumb's data.
  static String detailOf(TimelineItem i) {
    String encode(Object? v) {
      try {
        return jsonEncode(v);
      } catch (_) {
        return '$v';
      }
    }

    final data = i.body['data'];
    switch (i.type) {
      case 'error':
        final f = i.frames.where((f) => f.resolved).firstOrNull;
        if (f != null) return '${f.function} · ${f.location}';
        final stack = '${i.body['stack'] ?? ''}'.trim();
        return stack.isEmpty ? '' : stack.split('\n').first.trim();
      case 'event':
        final props = i.body['props'];
        return props is Map && props.isNotEmpty ? encode(props) : '';
      default:
        if (i.name == 'navigation' && data is Map) {
          final from = '${data['from'] ?? ''}';
          return from.isEmpty ? '' : '$from → ${data['to'] ?? ''}';
        }
        return data is Map && data.isNotEmpty ? encode(data) : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorOf(item);
    final detail = detailOf(item);
    final t0 = start;
    final time = t0 == null
        ? context.fmt.clock(item.ts)
        : replayClock(
            item.ts.isBefore(t0) ? Duration.zero : item.ts.difference(t0),
          );
    return GhostButton(
      density: ButtonDensity.compact,
      alignment: Alignment.centerLeft,
      onPressed: onTap,
      child: Opacity(
        opacity: upcoming && !active ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Tokens.raised : null,
            borderRadius: BorderRadius.circular(Tokens.radius),
            border: active ? Border.all(color: Tokens.chip) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  time,
                  style: AppTheme.mono(size: 11, color: Tokens.textMuted),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, right: 10),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.fmt.upper(item.category),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: color,
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            titleOf(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: item.type == 'error'
                                  ? Tokens.danger
                                  : Tokens.textStrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (detail.isNotEmpty)
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.mono(size: 11, color: Tokens.textMuted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The detail of the selected item: for an error, the stack trace and the
/// breadcrumbs leading up to it.
class ItemDetail extends StatelessWidget {
  const ItemDetail({super.key, required this.item, required this.projectId});
  final TimelineItem item;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final b = item.body;
    final crumbs = (b['breadcrumbs'] as List?)?.cast<Map>() ?? const [];
    return PanelCard(
      title: '${item.category} · ${context.fmt.dateTime(item.ts)}',
      action: item.issueId == null
          ? null
          : GhostButton(
              size: ButtonSize.small,
              onPressed: () =>
                  context.go('/projects/$projectId/issues/${item.issueId}'),
              child: Text(context.l10n.itemIssueLink(item.issueId!)),
            ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.type == 'error') ...[
              Text(
                item.message,
                style: const TextStyle(
                  color: Tokens.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (b['route'] != null)
                Text(
                  context.l10n.itemRoute('${b['route']}'),
                  style: AppTheme.mono(size: 11, color: Tokens.textDim),
                ),
              const Gap(8),
              StackTraceView(stack: '${b['stack'] ?? ''}', frames: item.frames),
              if (crumbs.isNotEmpty) ...[
                const Gap(10),
                Text(
                  context.l10n.itemBreadcrumbsBefore,
                  style: const TextStyle(fontSize: 12, color: Tokens.textDim),
                ),
                const Gap(4),
                for (final c in crumbs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            '${c['category']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Tokens.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${c['message']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Tokens.text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ] else
              CodeBlock(
                text: b.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
              ),
          ],
        ),
      ),
    );
  }
}

/// An error's stack trace.
///
/// A release web build sends minified JavaScript positions, and the backend
/// resolves them against the source map uploaded for that release. When it did,
/// this shows the resolved frames — the readable half — and keeps the raw text
/// behind a fold, because a wrong map is otherwise invisible. With no frames it
/// is what it always was: the stack as it arrived.
class StackTraceView extends StatefulWidget {
  const StackTraceView({
    super.key,
    required this.stack,
    this.frames = const [],
  });
  final String stack;
  final List<SourceFrame> frames;

  /// Whether [stack] looks like a minified web build — JavaScript positions and
  /// not a single Dart library. That is the case worth pointing at: the stack is
  /// unreadable and one upload fixes it.
  static bool looksMinified(String stack) =>
      stack.contains('.js:') && !stack.contains('package:');

  @override
  State<StackTraceView> createState() => _StackTraceViewState();
}

class _StackTraceViewState extends State<StackTraceView> {
  bool _rawOpen = false;

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CodeBlock(
            text: widget.stack.isEmpty
                ? context.l10n.issueNoStack
                : widget.stack,
          ),
          if (StackTraceView.looksMinified(widget.stack)) ...[
            const Gap(6),
            Text(
              context.l10n.issueStackMinifiedHint,
              style: const TextStyle(fontSize: 11, color: Tokens.textDim),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.issueStackSymbolicated,
          style: const TextStyle(fontSize: 11, color: Tokens.textDim),
        ),
        const Gap(6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Tokens.surface,
            border: Border.all(color: Tokens.border),
            borderRadius: BorderRadius.circular(Tokens.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final f in widget.frames) _FrameRow(frame: f)],
          ),
        ),
        const Gap(6),
        GhostButton(
          size: ButtonSize.small,
          density: ButtonDensity.compact,
          leading: Icon(
            _rawOpen ? LucideIcons.chevronDown : LucideIcons.chevronRight,
            size: 13,
          ),
          onPressed: () => setState(() => _rawOpen = !_rawOpen),
          child: Text(context.l10n.issueStackRaw),
        ),
        if (_rawOpen) ...[const Gap(4), CodeBlock(text: widget.stack)],
      ],
    );
  }
}

class _FrameRow extends StatelessWidget {
  const _FrameRow({required this.frame});
  final SourceFrame frame;

  @override
  Widget build(BuildContext context) {
    // An unresolved frame keeps its minified text: dropping it would leave a
    // hole in the stack, which reads worse than a line nobody can decode.
    if (!frame.resolved) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                frame.minified.isEmpty ? frame.location : frame.minified,
                style: AppTheme.mono(size: 11, color: Tokens.textFaint),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(8),
            Text(
              context.l10n.issueStackUnresolved,
              style: const TextStyle(fontSize: 10, color: Tokens.textFaint),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SelectableText(
              frame.function,
              style: AppTheme.mono(size: 11, color: Tokens.text),
            ),
          ),
          const Gap(10),
          Expanded(
            flex: 3,
            child: SelectableText(
              frame.location,
              style: AppTheme.mono(size: 11, color: Tokens.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(maxHeight: 320),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Tokens.surface,
      border: Border.all(color: Tokens.border),
      borderRadius: BorderRadius.circular(Tokens.radius),
    ),
    child: SingleChildScrollView(
      child: SelectableText(
        text,
        style: AppTheme.mono(size: 11, color: Tokens.textMuted),
      ),
    ),
  );
}
