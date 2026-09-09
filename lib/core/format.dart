import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';

/// Date, number, percentage and duration formats.
///
/// Formats depend on the language — the decimal separator, the month name, the
/// date order and "5 dk önce" / "5 minutes ago" all change — which is why [Fmt]
/// is not static but one instance per language. [Fmt.of] hands out that
/// instance; inside a widget there is the `context.fmt` shortcut ([FmtContext]).
///
/// The date patterns live in the ARB files (`fmtDateTimePattern` and friends):
/// they are not translations but how that language writes dates, and a
/// translator has to be able to change them.
class Fmt {
  Fmt(this.l10n)
    : _int = NumberFormat.decimalPattern(l10n.localeName),
      _pct0 = NumberFormat.decimalPercentPattern(
        locale: l10n.localeName,
        decimalDigits: 0,
      ),
      _pct1 = NumberFormat.decimalPercentPattern(
        locale: l10n.localeName,
        decimalDigits: 1,
      ),
      _dt = DateFormat(l10n.fmtDateTimePattern, l10n.localeName),
      _clock = DateFormat(l10n.fmtClockPattern, l10n.localeName),
      _day = DateFormat(l10n.fmtDayPattern, l10n.localeName);

  final L l10n;
  final NumberFormat _int, _pct0, _pct1;
  final DateFormat _dt, _clock, _day;

  static final _cache = <String, Fmt>{};

  /// The formatter for the current language. Building the `intl` formatters is
  /// not cheap, so one is built per language and kept.
  static Fmt of(BuildContext context) {
    final l10n = L.of(context);
    return _cache.putIfAbsent(l10n.localeName, () => Fmt(l10n));
  }

  String integer(num v) => _int.format(v);
  String dateTime(DateTime? t) => t == null ? l10n.commonEmpty : _dt.format(t);
  String clock(DateTime t) => _clock.format(t);

  /// The backend's day key in `2026-09-07` form → a short day label.
  String day(String iso) {
    final t = DateTime.tryParse(iso);
    return t == null ? iso : _day.format(t);
  }

  /// A ratio between 0 and 1 → a percentage. Whole values get no decimal.
  String percent(double v) {
    final p = v * 100;
    return (p % 1 == 0 ? _pct0 : _pct1).format(v);
  }

  String duration(Duration d) {
    if (d.inSeconds < 60) return l10n.fmtSeconds(d.inSeconds);
    if (d.inMinutes < 60) return l10n.fmtMinutes(d.inMinutes);
    return l10n.fmtHours((d.inMinutes / 60).toStringAsFixed(1));
  }

  String relative(DateTime? t) {
    if (t == null) return l10n.commonEmpty;
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l10n.fmtJustNow;
    if (d.inHours < 1) return l10n.fmtMinutesAgo(d.inMinutes);
    if (d.inDays < 1) return l10n.fmtHoursAgo(d.inHours);
    return l10n.fmtDaysAgo(d.inDays);
  }

  String shortId(String id) => id.length > 8 ? id.substring(0, 8) : id;

  /// Upper case for table headers. In Turkish `toUpperCase()` turns `i` into
  /// `I` ("İstisna" → "İSTISNA"); the dotted capital `İ` is the correct one.
  String upper(String s) => l10n.localeName.startsWith('tr')
      ? s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase()
      : s.toUpperCase();
}

extension FmtContext on BuildContext {
  /// The formatter for the current language.
  Fmt get fmt => Fmt.of(this);

  /// The strings of the current language.
  L get l10n => L.of(this);
}
