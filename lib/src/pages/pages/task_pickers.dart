import 'package:flutter/material.dart';

/// Values offered for a task's `repeat` field.
const taskRepeatOptions = ['Daily', 'Weekdays', 'Weekly', 'Monthly', 'Yearly'];

Widget _darkPickerTheme(BuildContext context, Widget? child) {
  return Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Colors.blueAccent,
        onPrimary: Colors.white,
        surface: Color(0xFF1F1F1F),
        onSurface: Colors.white,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1F1F1F)),
    ),
    child: child!,
  );
}

/// Asks for a task's due date. Returns null if the user cancels.
Future<DateTime?> pickTaskDueDate(BuildContext context, {DateTime? initial}) {
  return showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
    builder: _darkPickerTheme,
  );
}

/// Asks for a reminder date, then a time. Returns null if the user cancels
/// either step.
Future<DateTime?> pickTaskReminder(BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
    builder: _darkPickerTheme,
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: _darkPickerTheme,
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
