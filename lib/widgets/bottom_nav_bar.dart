import 'package:flutter/material.dart';

import '../navigation/app_tab.dart';
import 'workout_action_button.dart';

/// The persistent destination bar, with a raised action in the middle.
///
/// Five equal slots rather than four tabs plus an overlay: giving the middle
/// slot to [WorkoutActionButton] keeps the layout arithmetic honest. Padding
/// four tabs apart and floating a circle over the seam would leave the button
/// off-centre by half a destination's width, which is exactly the sort of
/// one-pixel disagreement a designer notices immediately.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onWorkoutPressed,
    this.actionSize = 56,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelected;

  /// Opens a session. The bar does not know whether that resumes today's plan
  /// or starts something new; the button owns no state of its own.
  final VoidCallback onWorkoutPressed;

  /// Index of [tab] in the bar, counting the action's own slot.
  ///
  /// Public so a caller that navigates programmatically can highlight the right
  /// destination without reimplementing the offset.
  static int slotOf(AppTab tab) => _slots.indexOf(tab);

  final double actionSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        NavigationBar(
          // Position in the bar, not the enum index: the action occupies a
          // slot of its own, so calendar is at 1 but library at 3. Deriving it
          // from the same list that builds the destinations means the two can
          // never disagree.
          selectedIndex: _slots.indexOf(selected),
          // Maps the tapped slot back to its destination. Going through the slot list
          // rather than AppTab.values is what keeps the action's own slot from
          // shifting every destination after it by one.
          onDestinationSelected: (index) {
            final tab = _slots[index];
            if (tab != null) onSelected(tab);
          },
          destinations: [for (final tab in _slots) _destination(context, tab)],
        ),
        // Sits above the bar so the raised circle reads as an action on the bar
        // rather than a fifth destination. IgnorePointer is not needed: the
        // middle slot of the bar behind it is transparent and this button is
        // the only thing there to receive a tap.
        WorkoutActionButton(onPressed: onWorkoutPressed, size: actionSize),
      ],
    );
  }

  /// The four destinations interleaved with the empty middle slot.
  ///
  /// The blank keeps [AppTab.calendar] and [AppTab.library] the correct
  /// distance apart with the action between them, and keeps their `index` in
  /// step with the enum without any offset arithmetic at the call site.
  static List<AppTab?> get _slots => [
    AppTab.home,
    AppTab.calendar,
    null,
    AppTab.library,
    AppTab.profile,
  ];

  Widget _destination(BuildContext context, AppTab? tab) {
    // The middle slot carries no destination. Rendering an empty one keeps the
    // bar's spacing and selection maths correct while leaving the tap to the
    // button drawn over it.
    if (tab == null) {
      return const NavigationDestination(icon: SizedBox.shrink(), label: '');
    }

    final isSelected = tab == selected;
    return NavigationDestination(
      icon: Icon(isSelected ? tab.selectedIcon : tab.icon),
      selectedIcon: Icon(tab.selectedIcon),
      label: tab.label,
      // Long press opens nothing, so the tooltip is what makes a destination's
      // name reachable without leaving the bar.
      tooltip: tab.label,
    );
  }
}
