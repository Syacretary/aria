import 'package:flutter/material.dart';

/// A compact Markdown renderer for ARIA replies: paragraphs, headings, lists,
/// bold, italic, and inline code without pulling in a web-style renderer.
class AriaMarkdownText extends StatelessWidget {
  const AriaMarkdownText(
    this.data, {
    super.key,
    required this.style,
    this.color,
  });

  final String data;
  final TextStyle style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _buildBlock(blocks[i]),
        ],
      ],
    );
  }

  Widget _buildBlock(_MarkdownBlock block) {
    final blockStyle = style.copyWith(
      color: color ?? style.color,
      fontWeight: block.heading ? FontWeight.w700 : style.fontWeight,
      fontSize: block.heading ? (style.fontSize ?? 14) * 1.08 : style.fontSize,
      height: 1.42,
    );
    final spans = _inlineSpans(block.text, blockStyle);
    if (block.listPrefix == null) return Text.rich(TextSpan(children: spans));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 20, child: Text(block.listPrefix!, style: blockStyle)),
        Expanded(child: Text.rich(TextSpan(children: spans))),
      ],
    );
  }

  List<_MarkdownBlock> _parseBlocks(String source) {
    final blocks = <_MarkdownBlock>[];
    for (final rawLine in source.trim().split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final heading = RegExp(r'^#{1,3}\s+(.+)$').firstMatch(line);
      if (heading != null) {
        blocks.add(_MarkdownBlock(heading.group(1)!, heading: true));
        continue;
      }

      final bullet = RegExp(r'^(?:[-*•])\s+(.+)$').firstMatch(line);
      if (bullet != null) {
        blocks.add(_MarkdownBlock(bullet.group(1)!, listPrefix: '•'));
        continue;
      }

      final numbered = RegExp(r'^(\d{1,2})[.)]\s+(.+)$').firstMatch(line);
      if (numbered != null) {
        blocks.add(
          _MarkdownBlock(
            numbered.group(2)!,
            listPrefix: '${numbered.group(1)}.',
          ),
        );
        continue;
      }

      final paragraph = line.replaceAll(RegExp(r'^>\s?'), '');
      blocks.add(_MarkdownBlock(paragraph));
    }
    if (blocks.isEmpty) blocks.add(_MarkdownBlock(source));
    return blocks;
  }

  List<InlineSpan> _inlineSpans(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'\*\*(.+?)\*\*|__(.+?)__|\*(.+?)\*|_(.+?)_|`(.+?)`',
    );
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final value =
          match.group(1) ??
          match.group(2) ??
          match.group(3) ??
          match.group(4) ??
          match.group(5)!;
      final isBold = match.group(1) != null || match.group(2) != null;
      final isCode = match.group(5) != null;
      spans.add(
        TextSpan(
          text: value,
          style: base.copyWith(
            fontWeight: isBold ? FontWeight.w700 : base.fontWeight,
            fontStyle: !isBold && !isCode ? FontStyle.italic : base.fontStyle,
            fontFamily: isCode ? 'monospace' : base.fontFamily,
            backgroundColor: isCode ? base.color?.withValues(alpha: .08) : null,
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return spans;
  }
}

class _MarkdownBlock {
  const _MarkdownBlock(this.text, {this.heading = false, this.listPrefix});

  final String text;
  final bool heading;
  final String? listPrefix;
}
