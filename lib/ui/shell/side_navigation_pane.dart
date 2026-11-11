import 'package:flutter/material.dart';

import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/themes/app_theme.dart';

/// An entry of [SideNavigationPane].
class SideNavigationDestination {
  const SideNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  final IconData icon;

  /// Shown instead of [icon] when the entry is selected.
  final IconData? selectedIcon;

  final String label;
}

/// The navigation on the left of a wide window, in the style of Fluent's
/// NavigationView: the selected entry has a soft fill and a small accent
/// bar.
///
/// [expanded] shows the labels; otherwise it is a narrow rail of icons,
/// each with its label as a tooltip. It scrolls when the window is too
/// short for every entry (a phone in landscape).
class SideNavigationPane extends StatelessWidget {
  const SideNavigationPane({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.expanded,
    this.title,
    this.footerCount = 0,
  });

  final List<SideNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Whether labels are shown beside the icons.
  final bool expanded;

  /// Shown above the entries when [expanded].
  final String? title;

  /// How many of the last [destinations] sit under a divider.
  final int footerCount;

  static const expandedWidth = 264.0;
  static const compactWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final firstFooter = destinations.length - footerCount;
    return Container(
      width: expanded ? expandedWidth : compactWidth,
      // The whole height of the window, however few entries there are.
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.navigationBar,
        border: Border(right: BorderSide(color: colors.stroke)),
      ),
      child: SafeArea(
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (expanded && title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              for (var i = 0; i < destinations.length; i++) ...[
                if (footerCount > 0 && i == firstFooter)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: expanded ? 24 : 12, vertical: 8),
                    child: const Divider(height: 1),
                  ),
                _PaneItem(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  expanded: expanded,
                  onTap: () {
                    if (i != selectedIndex) onSelected(i);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaneItem extends StatelessWidget {
  const _PaneItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final SideNavigationDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(AppTheme.controlRadius);
    final icon = Icon(
      selected
          ? destination.selectedIcon ?? destination.icon
          : destination.icon,
      color: colors.text,
    );

    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color:
            selected ? colors.text.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          // 48 dp: the minimum touch target.
          child: SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 3,
                  height: selected ? 18 : 0,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (expanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 12),
                    child: Row(
                      children: [
                        icon,
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.text,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(child: icon),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      selected: selected,
      child: expanded ? tile : Tooltip(message: destination.label, child: tile),
    );
  }
}
