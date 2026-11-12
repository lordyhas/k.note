import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Window widths, in logical pixels, at which the layout changes. They are
/// the Material window size classes: a phone in portrait is compact, a
/// phone in landscape or a small tablet is medium, a tablet in landscape or
/// a desktop window is expanded.
abstract final class Breakpoints {
  /// From this width the shell shows a rail of icons instead of the bottom
  /// bar.
  static const medium = 600.0;

  /// From this width the shell shows the full navigation pane, with labels.
  static const expanded = 840.0;
}

/// How wide content grows before it stops and stays centered: text lines
/// and list rows that span a whole desktop window are hard to read.
abstract final class ContentWidths {
  /// Sign-in and other short forms.
  static const form = 420.0;

  /// Lists, settings and long text.
  static const reading = 720.0;

  /// The note editor.
  static const editor = 800.0;

  /// Pages laid out in several columns.
  static const wide = 1200.0;
}

/// Space left under a scrolling list so its last row can be scrolled clear
/// of the floating action button.
const double fabClearance = 88.0;

/// Gives [child] the width of the window, up to [maxWidth], and centers it
/// horizontally.
///
/// For content that does not scroll, or that may leave the sides of the
/// window inert. A scroll view should use [centeredPadding] instead, so the
/// whole window width still scrolls it.
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    super.key,
    this.maxWidth = ContentWidths.reading,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        // As wide as allowed, so the content does not shrink to its own
        // width in a narrow window.
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// The padding that centers the content of a scroll view [width] wide in a
/// column of at most [maxWidth], leaving at least [gutter] on each side.
EdgeInsets centeredPadding(
  double width, {
  double maxWidth = ContentWidths.reading,
  double gutter = 16,
  double top = 0,
  double bottom = 0,
}) {
  final side = math.max(gutter, (width - maxWidth) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}
