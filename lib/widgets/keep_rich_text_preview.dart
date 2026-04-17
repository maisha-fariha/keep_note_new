import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';

class KeepRichTextPreview extends StatefulWidget {
  final String content;
  final int maxLines;

  const KeepRichTextPreview({
    super.key,
    required this.content,
    this.maxLines = 6,
  });

  @override
  State<KeepRichTextPreview> createState() => _KeepRichTextPreviewState();
}

class _KeepRichTextPreviewState extends State<KeepRichTextPreview> {
  late final QuillController _controller;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: _loadDocument(widget.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller.readOnly = true;
  }

  @override
  void didUpdateWidget(covariant KeepRichTextPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.document = _loadDocument(widget.content);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Document _loadDocument(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return Document();
    try {
      final decoded = jsonDecode(s);
      if (decoded is List) {
        return Document.fromJson(List<Map<String, dynamic>>.from(decoded));
      }
      return Document()..insert(0, raw);
    } catch (_) {
      return Document()..insert(0, raw);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rough height cap to avoid huge cards. This isn't exact line measurement,
    // but provides a good UI constraint for grid/list previews.
    final estimatedLineHeight = DefaultTextStyle.of(context).style.fontSize ?? 14;
    final maxHeight = (estimatedLineHeight * 1.4) * widget.maxLines;

    return ClipRect(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SizedBox(
          width: double.infinity,
          child: IgnorePointer(
            child: QuillEditor(
              controller: _controller,
              focusNode: _focusNode,
              scrollController: _scrollController,
              config: QuillEditorConfig(
                expands: false,
                padding: EdgeInsets.zero,
                scrollable: false,
                showCursor: false,
                enableInteractiveSelection: false,
                maxContentWidth: double.infinity,
                customStyleBuilder: (attribute) {
                  if (attribute.key == Attribute.font.key) {
                    final name = attribute.value?.toString();
                    if (name == null || name.isEmpty) return const TextStyle();
                    try {
                      return GoogleFonts.getFont(name);
                    } catch (_) {
                      return TextStyle(fontFamily: name);
                    }
                  }
                  return const TextStyle();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

