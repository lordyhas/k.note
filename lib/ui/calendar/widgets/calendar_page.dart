import 'package:flutter/material.dart';

import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/widgets/coming_soon.dart';

/// Placeholder until the calendar view exists.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});
  static const routeName = "calendar";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(context.l10n.calendar),
      ),
      body: const Padding(
        padding: EdgeInsets.only(top: 64.0),
        child: ComingSoon(),
      ),
    );
  }
}
