import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:keep_note_new/widgets/keep_text_color_bottom_sheet.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class KeepRichTextToolbar extends StatefulWidget {
  final QuillController controller;

  const KeepRichTextToolbar({super.key, required this.controller});

  @override
  State<KeepRichTextToolbar> createState() => _KeepRichTextToolbarState();
}

class _KeepRichTextToolbarState extends State<KeepRichTextToolbar> {
  static const _sizes = <String>['12', '14', '16', '18', '20', '24', '28', '32'];
  static const _fonts = <String>[
    'Default',
    'Roboto',
    'Lato',
    'Poppins',
    'Merriweather',
    'Source Sans Pro',
    'Fira Sans',
  ];

  Color _currentColor = Colors.black;
  String _currentSize = '16';
  String _currentFont = 'Default';
  StreamSubscription<dynamic>? _changesSub;
  void Function(TextSelection textSelection)? _previousOnSelectionChanged;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
    _syncFromSelection();
  }

  @override
  void didUpdateWidget(covariant KeepRichTextToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController(widget.controller);
      _syncFromSelection();
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController(QuillController controller) {
    // Listen to both document edits and cursor/selection changes.
    _changesSub = controller.changes.listen((_) => _syncFromSelection());

    _previousOnSelectionChanged = controller.onSelectionChanged;
    controller.onSelectionChanged = (selection) {
      _previousOnSelectionChanged?.call(selection);
      _syncFromSelection();
    };
  }

  void _detachController() {
    _changesSub?.cancel();
    _changesSub = null;

    // Restore external selection handler (if any).
    if (_previousOnSelectionChanged != null) {
      widget.controller.onSelectionChanged = _previousOnSelectionChanged;
    } else {
      widget.controller.onSelectionChanged = null;
    }
    _previousOnSelectionChanged = null;
  }

  void _syncFromSelection() {
    final style = widget.controller.getSelectionStyle();

    final colorAttr = style.attributes[Attribute.color.key];
    final sizeAttr = style.attributes[Attribute.size.key];
    final fontAttr = style.attributes[Attribute.font.key];

    final nextColor = _parseHexColor(colorAttr?.value?.toString());
    final nextSize = sizeAttr?.value?.toString();
    final nextFont = fontAttr?.value?.toString();

    if (mounted) {
      setState(() {
        // If no explicit color on selection, reflect default black.
        _currentColor = nextColor ?? Colors.black;
        if (nextSize != null && _sizes.contains(nextSize)) {
          _currentSize = nextSize;
        } else if (nextSize == null) {
          _currentSize = '16';
        }
        if (nextFont != null && _fonts.contains(nextFont)) {
          _currentFont = nextFont;
        } else if (nextFont == null) {
          _currentFont = 'Default';
        }
      });
    }
  }

  bool _isActive(Attribute attr) =>
      widget.controller.getSelectionStyle().attributes.containsKey(attr.key);

  void _toggle(Attribute attr) {
    if (_isActive(attr)) {
      widget.controller.formatSelection(Attribute.clone(attr, null));
    } else {
      widget.controller.formatSelection(attr);
    }
  }

  void _setSize(String size) {
    widget.controller.formatSelection(
      Attribute.fromKeyValue(Attribute.size.key, size),
    );
  }

  void _setColor(Color color) {
    final hex = _toHexRgb(color);
    widget.controller.formatSelection(
      Attribute.fromKeyValue(Attribute.color.key, hex),
    );
    setState(() {
      _currentColor = color;
    });
  }

  void _setFont(String font) {
    if (font == 'Default') {
      widget.controller.formatSelection(
        Attribute.fromKeyValue(Attribute.font.key, null),
      );
      setState(() => _currentFont = 'Default');
      return;
    }

    // Ensure the font family is registered/loaded (google_fonts lazily loads).
    try {
      GoogleFonts.getFont(font);
    } catch (_) {
      // If unavailable, still set attribute; editor will fall back gracefully.
    }

    widget.controller.formatSelection(
      Attribute.fromKeyValue(Attribute.font.key, font),
    );
    setState(() => _currentFont = font);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: const Color(0xFFF6FAF2),
      child: SizedBox(
        height: 52,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 8),
              _iconBtn(
                icon: Icons.format_bold,
                active: _isActive(Attribute.bold),
                onTap: () => _toggle(Attribute.bold),
              ),
              _iconBtn(
                icon: Icons.format_italic,
                active: _isActive(Attribute.italic),
                onTap: () => _toggle(Attribute.italic),
              ),
              _iconBtn(
                icon: Icons.format_underline,
                active: _isActive(Attribute.underline),
                onTap: () => _toggle(Attribute.underline),
              ),
              const VerticalDivider(width: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentFont,
                    items: _fonts
                        .map(
                          (f) => DropdownMenuItem<String>(
                            value: f,
                            child: Text(f),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      _setFont(val);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentSize,
                    items: _sizes
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text('${s}px'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _currentSize = val);
                      _setSize(val);
                    },
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  KeepTextColorBottomSheet.show(
                    context,
                    selectedColor: _currentColor,
                    onColorSelected: _setColor,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.format_color_text, size: 20),
                      const SizedBox(width: 6),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _currentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool active,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? Colors.grey.shade300 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

String _toHexRgb(Color color) {
  final rr = (color.r * 255.0).round().clamp(0, 255);
  final gg = (color.g * 255.0).round().clamp(0, 255);
  final bb = (color.b * 255.0).round().clamp(0, 255);
  final r = rr.toRadixString(16).padLeft(2, '0');
  final g = gg.toRadixString(16).padLeft(2, '0');
  final b = bb.toRadixString(16).padLeft(2, '0');
  return '#$r$g$b';
}

Color? _parseHexColor(String? value) {
  if (value == null) return null;
  final v = value.trim();
  if (!v.startsWith('#')) return null;
  final hex = v.substring(1);
  if (hex.length != 6) return null;
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return null;
  return Color(0xFF000000 | parsed);
}

