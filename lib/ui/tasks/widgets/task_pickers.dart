import 'package:flutter/material.dart';

import 'package:knote/domain/models/task_repeat.dart';

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

/// Shortcuts offered by the "Set due date" menu, as in Microsoft To Do.
enum DueDateShortcut { today, tomorrow, nextWeek }

/// The date (at midnight) a [shortcut] stands for, counted from [now].
///
/// "Next week" is the first day of the following week, where weeks start on
/// [firstDayOfWeekIndex] (0 = Sunday, as in
/// [MaterialLocalizations.firstDayOfWeekIndex]).
DateTime dueDateFor(
  DueDateShortcut shortcut, {
  required DateTime now,
  required int firstDayOfWeekIndex,
}) {
  final today = DateTime(now.year, now.month, now.day);
  switch (shortcut) {
    case DueDateShortcut.today:
      return today;
    case DueDateShortcut.tomorrow:
      return DateTime(today.year, today.month, today.day + 1);
    case DueDateShortcut.nextWeek:
      return _startOfNextWeek(today, firstDayOfWeekIndex);
  }
}

DateTime _startOfNextWeek(DateTime today, int firstDayOfWeekIndex) {
  final todayIndex = today.weekday % 7; // DateTime.sunday (7) -> 0
  var days = (firstDayOfWeekIndex - todayIndex) % 7;
  if (days == 0) days = 7;
  return DateTime(today.year, today.month, today.day + days);
}

/// Shortcuts offered by the "Remind me" menu, as in Microsoft To Do.
enum ReminderShortcut { laterToday, tomorrow, nextWeek }

/// Hour of the day used by the "Tomorrow" and "Next week" reminders.
const reminderMorningHour = 9;

/// The moment a reminder [shortcut] stands for, counted from [now].
///
/// "Later today" is three hours from now, rounded up to the next full hour;
/// it is null when that would fall on another day. "Tomorrow" and "Next week"
/// are at [reminderMorningHour], next week starting on [firstDayOfWeekIndex]
/// (0 = Sunday).
DateTime? reminderFor(
  ReminderShortcut shortcut, {
  required DateTime now,
  required int firstDayOfWeekIndex,
}) {
  final today = DateTime(now.year, now.month, now.day);
  switch (shortcut) {
    case ReminderShortcut.laterToday:
      final later = now.add(const Duration(hours: 3));
      final onTheHour = later.minute == 0 &&
          later.second == 0 &&
          later.millisecond == 0 &&
          later.microsecond == 0;
      final reminder = DateTime(later.year, later.month, later.day, later.hour)
          .add(Duration(hours: onTheHour ? 0 : 1));
      final isToday = reminder.year == today.year &&
          reminder.month == today.month &&
          reminder.day == today.day;
      return isToday ? reminder : null;
    case ReminderShortcut.tomorrow:
      return DateTime(
          today.year, today.month, today.day + 1, reminderMorningHour);
    case ReminderShortcut.nextWeek:
      final day = _startOfNextWeek(today, firstDayOfWeekIndex);
      return DateTime(day.year, day.month, day.day, reminderMorningHour);
  }
}

/// Asks for a custom repeat rule ("every N days/weeks/months/years", with
/// weekdays for weeks). Returns null if the user cancels.
Future<TaskRepeat?> pickCustomRepeat(BuildContext context,
    {TaskRepeat? initial}) {
  return showDialog<TaskRepeat>(
    context: context,
    builder: (context) => Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          surface: Color(0xFF1F1F1F),
        ),
      ),
      child: CustomRepeatDialog(initial: initial),
    ),
  );
}

/// Dialog behind [pickCustomRepeat].
class CustomRepeatDialog extends StatefulWidget {
  const CustomRepeatDialog({super.key, this.initial});

  final TaskRepeat? initial;

  @override
  State<CustomRepeatDialog> createState() => _CustomRepeatDialogState();
}

class _CustomRepeatDialogState extends State<CustomRepeatDialog> {
  late int _interval = widget.initial?.interval ?? 1;
  late RepeatUnit _unit = widget.initial?.unit ?? RepeatUnit.week;
  late final Set<int> _weekdays = {
    ...?widget.initial?.weekdays,
    if (widget.initial?.weekdays.isEmpty ?? true) DateTime.now().weekday,
  };

  String _unitLabel(RepeatUnit unit) =>
      _interval == 1 ? unit.name : '${unit.name}s';

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    // ISO weekdays (1 = Monday ... 7 = Sunday) in the locale's week order.
    final orderedDays = [
      for (var i = 0; i < 7; i++)
        switch ((localizations.firstDayOfWeekIndex + i) % 7) {
          0 => DateTime.sunday,
          final day => day,
        },
    ];

    return AlertDialog(
      backgroundColor: const Color(0xFF1F1F1F),
      title: const Text('Repeat every'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Fewer',
                onPressed:
                    _interval > 1 ? () => setState(() => _interval--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_interval', style: const TextStyle(fontSize: 18)),
              IconButton(
                tooltip: 'More',
                onPressed:
                    _interval < 99 ? () => setState(() => _interval++) : null,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 8),
              DropdownButton<RepeatUnit>(
                value: _unit,
                dropdownColor: const Color(0xFF2B2B2B),
                onChanged: (unit) => setState(() => _unit = unit!),
                items: [
                  for (final unit in RepeatUnit.values)
                    DropdownMenuItem(
                        value: unit, child: Text(_unitLabel(unit))),
                ],
              ),
            ],
          ),
          if (_unit == RepeatUnit.week) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final day in orderedDays)
                  FilterChip(
                    label: Text(localizations.narrowWeekdays[day % 7]),
                    selected: _weekdays.contains(day),
                    showCheckmark: false,
                    // A weekly rule keeps at least one day.
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _weekdays.add(day);
                      } else if (_weekdays.length > 1) {
                        _weekdays.remove(day);
                      }
                    }),
                  ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            TaskRepeat.custom(
              interval: _interval,
              unit: _unit,
              weekdays: _unit == RepeatUnit.week ? {..._weekdays} : const {},
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
