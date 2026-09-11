// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app/theme/tokens.dart';
import '../l10n/gen/app_localizations.dart';

/// A selectable suggestion option for a filter key.
class FilterOption {
  const FilterOption({
    required this.value,
    this.label,
    this.description,
    this.icon,
  });

  final String value;
  final String? label;
  final String? description;
  final IconData? icon;
}

/// Definition of a filter key (e.g. `browser`, `platform`, `release`).
class FilterKeyDefinition {
  const FilterKeyDefinition({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    this.options = const [],
    this.dynamicOptions,
  });

  final String key;
  final String label;
  final String description;
  final IconData icon;
  final List<FilterOption> options;
  final List<FilterOption> Function()? dynamicOptions;

  List<FilterOption> allOptions() {
    final res = <FilterOption>[];
    final seen = <String>{};
    for (final opt in options) {
      if (seen.add(opt.value.toLowerCase())) {
        res.add(opt);
      }
    }
    if (dynamicOptions != null) {
      for (final opt in dynamicOptions!()) {
        if (seen.add(opt.value.toLowerCase())) {
          res.add(opt);
        }
      }
    }
    return res;
  }
}

/// Token parsing information for the word currently being edited.
class _ActiveTokenInfo {
  const _ActiveTokenInfo({
    required this.tokenStartIndex,
    required this.tokenEndIndex,
    required this.rawToken,
    required this.hasColon,
    required this.key,
    required this.valuePrefix,
  });

  final int tokenStartIndex;
  final int tokenEndIndex;
  final String rawToken;
  final bool hasColon;
  final String key;
  final String valuePrefix;

  static _ActiveTokenInfo parse(String text, int cursor) {
    if (text.isEmpty) {
      return const _ActiveTokenInfo(
        tokenStartIndex: 0,
        tokenEndIndex: 0,
        rawToken: '',
        hasColon: false,
        key: '',
        valuePrefix: '',
      );
    }

    final safeCursor = cursor.clamp(0, text.length);

    // Find start of token (scan backward until space)
    var start = safeCursor;
    while (start > 0 && text[start - 1] != ' ') {
      start--;
    }

    // Find end of token (scan forward until space)
    var end = safeCursor;
    while (end < text.length && text[end] != ' ') {
      end++;
    }

    final rawToken = text.substring(start, end);
    final colonIdx = rawToken.indexOf(':');

    if (colonIdx >= 0) {
      final key = rawToken.substring(0, colonIdx).trim().toLowerCase();
      final valuePrefix = rawToken.substring(colonIdx + 1).trim();
      return _ActiveTokenInfo(
        tokenStartIndex: start,
        tokenEndIndex: end,
        rawToken: rawToken,
        hasColon: true,
        key: key,
        valuePrefix: valuePrefix,
      );
    } else {
      return _ActiveTokenInfo(
        tokenStartIndex: start,
        tokenEndIndex: end,
        rawToken: rawToken,
        hasColon: false,
        key: rawToken.trim().toLowerCase(),
        valuePrefix: '',
      );
    }
  }
}

enum _SuggestionKind { key, value }

class _SuggestionItem {
  const _SuggestionItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.keyDef,
    this.option,
  });

  final _SuggestionKind kind;
  final String title;
  final String subtitle;
  final IconData icon;
  final FilterKeyDefinition? keyDef;
  final FilterOption? option;
}

/// A GitHub-style search input with real-time autocompletion dropdown for filter keys and values.
class FilterSearchField extends StatefulWidget {
  const FilterSearchField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onSubmitted,
    required this.filterKeys,
    this.onClear,
    this.width = 340,
    this.leadingIcon = LucideIcons.search,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onSubmitted;
  final List<FilterKeyDefinition> filterKeys;
  final VoidCallback? onClear;
  final double width;
  final IconData leadingIcon;

  @override
  State<FilterSearchField> createState() => _FilterSearchFieldState();
}

class _FilterSearchFieldState extends State<FilterSearchField> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final Object _tapGroupId = Object();

  List<_SuggestionItem> _suggestions = [];
  int _highlightedIndex = 0;
  String _headerTitle = '';
  _ActiveTokenInfo? _activeToken;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _updateSuggestions();
      _showOverlay();
    } else {
      // Small delay to allow tap to register on suggestion items
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    }
  }

  void _onTextChanged() {
    if (_focusNode.hasFocus) {
      _updateSuggestions();
      if (!_overlayController.isShowing) {
        _showOverlay();
      }
    }
    setState(() {}); // Rebuild for clear button
  }

  void _showOverlay() {
    if (!_overlayController.isShowing) {
      _overlayController.show();
    }
  }

  void _hideOverlay() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  void _updateSuggestions() {
    final text = widget.controller.text;
    final cursor = widget.controller.selection.baseOffset;
    final info = _ActiveTokenInfo.parse(text, cursor);
    _activeToken = info;

    final items = <_SuggestionItem>[];

    if (info.hasColon) {
      // VALUE MODE: Find definition for info.key
      final keyDef = widget.filterKeys.firstWhere(
        (k) => k.key.toLowerCase() == info.key,
        orElse: () => FilterKeyDefinition(
          key: info.key,
          label: info.key,
          description: '',
          icon: LucideIcons.filter,
        ),
      );

      final allOpts = keyDef.allOptions();
      final valPrefix = info.valuePrefix.toLowerCase();
      final filtered = valPrefix.isEmpty
          ? allOpts
          : allOpts.where((o) => o.value.toLowerCase().contains(valPrefix) || (o.label?.toLowerCase().contains(valPrefix) ?? false)).toList();

      for (final opt in filtered) {
        items.add(
          _SuggestionItem(
            kind: _SuggestionKind.value,
            title: opt.value,
            subtitle: opt.label ?? opt.description ?? '',
            icon: opt.icon ?? keyDef.icon,
            keyDef: keyDef,
            option: opt,
          ),
        );
      }
      final loc = Localizations.of<L>(context, L);
      final valTitle = loc?.filterValues ?? 'SELECT VALUE';
      _headerTitle = '$valTitle: ${keyDef.key.toUpperCase()}';
    } else {
      // KEY MODE: Filter keys by prefix
      final keyPrefix = info.key;
      final filtered = keyPrefix.isEmpty
          ? widget.filterKeys
          : widget.filterKeys.where(
              (k) => k.key.toLowerCase().contains(keyPrefix) || k.label.toLowerCase().contains(keyPrefix),
            ).toList();

      for (final k in filtered) {
        items.add(
          _SuggestionItem(
            kind: _SuggestionKind.key,
            title: '${k.key}:',
            subtitle: k.description,
            icon: k.icon,
            keyDef: k,
          ),
        );
      }
      final loc = Localizations.of<L>(context, L);
      _headerTitle = loc?.filterByField ?? 'FILTER BY FIELD';
    }

    setState(() {
      _suggestions = items;
      _highlightedIndex = items.isEmpty ? 0 : _highlightedIndex.clamp(0, items.length - 1);
    });
  }

  void _selectItem(_SuggestionItem item) {
    final text = widget.controller.text;
    final info = _activeToken ?? _ActiveTokenInfo.parse(text, widget.controller.selection.baseOffset);

    if (item.kind == _SuggestionKind.key) {
      // Complete key with colon, e.g. "browser:"
      final keyDef = item.keyDef!;
      final replacement = '${keyDef.key}:';
      final newText = text.replaceRange(info.tokenStartIndex, info.tokenEndIndex, replacement);
      final newCursor = info.tokenStartIndex + replacement.length;

      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );

      _focusNode.requestFocus();
      _updateSuggestions();
      _showOverlay();
    } else {
      // Complete key + value with trailing space, e.g. "browser:Chrome "
      final key = info.key;
      final val = item.option!.value;
      final replacement = '$key:$val ';
      final newText = text.replaceRange(info.tokenStartIndex, info.tokenEndIndex, replacement);
      final newCursor = info.tokenStartIndex + replacement.length;

      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );

      _hideOverlay();
      widget.onSubmitted(newText.trim());
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (_overlayController.isShowing && _suggestions.isNotEmpty) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _highlightedIndex = (_highlightedIndex + 1) % _suggestions.length;
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _highlightedIndex = (_highlightedIndex - 1 + _suggestions.length) % _suggestions.length;
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.tab) {
        if (_highlightedIndex >= 0 && _highlightedIndex < _suggestions.length) {
          _selectItem(_suggestions[_highlightedIndex]);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _hideOverlay();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _hideOverlay();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: _buildOverlay,
        child: TapRegion(
          groupId: _tapGroupId,
          child: SizedBox(
            width: widget.width,
            child: Focus(
              focusNode: _focusNode,
              onKeyEvent: _handleKeyEvent,
              child: TextField(
                controller: widget.controller,
                placeholder: Text(widget.placeholder),
                onSubmitted: (v) {
                  _hideOverlay();
                  widget.onSubmitted(v.trim());
                },
                features: [
                  InputFeature.leading(Icon(widget.leadingIcon, size: 14)),
                  if (widget.controller.text.isNotEmpty)
                    InputFeature.trailing(
                      GhostButton(
                        density: ButtonDensity.compact,
                        size: ButtonSize.xSmall,
                        onPressed: () {
                          widget.controller.clear();
                          _hideOverlay();
                          widget.onClear?.call();
                          widget.onSubmitted('');
                        },
                        child: const Icon(LucideIcons.x, size: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final scaling = theme.scaling;

    return CompositedTransformFollower(
      link: _layerLink,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      offset: Offset(0, 4 * scaling),
      child: Align(
        alignment: Alignment.topLeft,
        child: TapRegion(
          groupId: _tapGroupId,
          child: Container(
            width: widget.width < 360 ? 360 * scaling : widget.width,
            constraints: BoxConstraints(maxHeight: 290 * scaling),
            decoration: BoxDecoration(
              color: Tokens.panel,
              border: Border.all(color: Tokens.border),
              borderRadius: BorderRadius.circular(Tokens.radius),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (e.g. "FILTER BY FIELD" or "SELECT VALUE: BROWSER")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        _headerTitle,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Tokens.textDim,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '↑↓ / Tab / Enter',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Tokens.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: Tokens.border),
                // Suggestions list
                if (_suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      Localizations.of<L>(context, L)?.sessionsEmpty ?? 'No matching filters',
                      style: const TextStyle(fontSize: 12, color: Tokens.textDim),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        final isHighlighted = index == _highlightedIndex;

                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) {
                            setState(() => _highlightedIndex = index);
                          },
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _selectItem(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              color: isHighlighted
                                  ? Tokens.brand.withValues(alpha: 0.12)
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 14,
                                    color: isHighlighted ? Tokens.brand : Tokens.textDim,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: item.kind == _SuggestionKind.key
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isHighlighted ? Tokens.brand : Tokens.textStrong,
                                    ),
                                  ),
                                  if (item.subtitle.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.subtitle,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Tokens.textDim,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ] else
                                    const Spacer(),
                                  if (isHighlighted)
                                    const Icon(
                                      LucideIcons.cornerDownLeft,
                                      size: 11,
                                      color: Tokens.textDim,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
