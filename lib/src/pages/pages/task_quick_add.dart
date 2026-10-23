import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knote/data/database/database_model.dart';
import 'package:knote/data/database/firebase_manager.dart';
import 'package:knote/src/pages/pages/task_pickers.dart';
import 'package:uuid/uuid.dart';

/// Opens the Microsoft To Do style "Add a task" sheet above the keyboard.
///
/// Each submitted title is saved right away and the field is cleared, so
/// several tasks can be added in a row without leaving the tasks screen.
Future<void> showTaskQuickAdd(
  BuildContext context, {
  required FirebaseManager firebaseManager,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF2B2B2B),
    shape: const RoundedRectangleBorder(),
    builder: (_) => TaskQuickAddSheet(firebaseManager: firebaseManager),
  );
}

class TaskQuickAddSheet extends StatefulWidget {
  const TaskQuickAddSheet({super.key, required this.firebaseManager});

  final FirebaseManager firebaseManager;

  @override
  State<TaskQuickAddSheet> createState() => _TaskQuickAddSheetState();
}

class _TaskQuickAddSheetState extends State<TaskQuickAddSheet> {
  final _titleController = TextEditingController();
  final _focusNode = FocusNode();
  DateTime? _dueDate;
  DateTime? _reminderTime;
  TaskRepeat? _repeat;

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    widget.firebaseManager.addTaskInCloud(
      task: CheckList(
        id: const Uuid().v4(),
        title: title,
        list: const [],
        creationTime: now,
        modificationTime: now,
        dueDate: _dueDate,
        reminderTime: _reminderTime,
        repeat: _repeat?.encode(),
      ),
    );

    setState(() {
      _titleController.clear();
      _dueDate = null;
      _reminderTime = null;
      _repeat = null;
    });
    _focusNode.requestFocus();
  }

  DateTime _shortcutDate(DueDateShortcut shortcut) => dueDateFor(
        shortcut,
        now: DateTime.now(),
        firstDayOfWeekIndex:
            MaterialLocalizations.of(context).firstDayOfWeekIndex,
      );

  Future<void> _onDueDateSelected(_DueDateChoice choice) async {
    switch (choice) {
      case _DueDateChoice.today:
        setState(() => _dueDate = _shortcutDate(DueDateShortcut.today));
      case _DueDateChoice.tomorrow:
        setState(() => _dueDate = _shortcutDate(DueDateShortcut.tomorrow));
      case _DueDateChoice.nextWeek:
        setState(() => _dueDate = _shortcutDate(DueDateShortcut.nextWeek));
      case _DueDateChoice.pick:
        final picked = await pickTaskDueDate(context, initial: _dueDate);
        if (picked != null) setState(() => _dueDate = picked);
      case _DueDateChoice.remove:
        setState(() => _dueDate = null);
    }
    _focusNode.requestFocus();
  }

  String get _dueDateLabel {
    final dueDate = _dueDate;
    if (dueDate == null) return 'Set due date';
    if (dueDate == _shortcutDate(DueDateShortcut.today)) return 'Due Today';
    if (dueDate == _shortcutDate(DueDateShortcut.tomorrow)) {
      return 'Due Tomorrow';
    }
    return 'Due ${DateFormat('EEE, MMM d').format(dueDate)}';
  }

  List<PopupMenuEntry<_DueDateChoice>> _dueDateMenu(BuildContext context) {
    String weekday(DueDateShortcut shortcut) =>
        DateFormat('EEEE').format(_shortcutDate(shortcut));
    return [
      _menuItem(_DueDateChoice.today, Icons.today_outlined,
          'Today (${weekday(DueDateShortcut.today)})'),
      _menuItem(_DueDateChoice.tomorrow, Icons.event_outlined,
          'Tomorrow (${weekday(DueDateShortcut.tomorrow)})'),
      _menuItem(_DueDateChoice.nextWeek, Icons.date_range_outlined,
          'Next week (${weekday(DueDateShortcut.nextWeek)})'),
      _menuItem(
          _DueDateChoice.pick, Icons.edit_calendar_outlined, 'Pick a date'),
      if (_dueDate != null) ...[
        const PopupMenuDivider(),
        _menuItem(
            _DueDateChoice.remove, Icons.delete_outline, 'Remove due date',
            color: Colors.redAccent),
      ],
    ];
  }

  PopupMenuItem<T> _menuItem<T>(T value, IconData icon, String label,
      {Color color = Colors.white}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  DateTime? _shortcutReminder(ReminderShortcut shortcut) => reminderFor(
        shortcut,
        now: DateTime.now(),
        firstDayOfWeekIndex:
            MaterialLocalizations.of(context).firstDayOfWeekIndex,
      );

  String _time(DateTime dateTime) => MaterialLocalizations.of(context)
      .formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));

  Future<void> _onReminderSelected(_ReminderChoice choice) async {
    switch (choice) {
      case _ReminderChoice.laterToday:
        setState(() =>
            _reminderTime = _shortcutReminder(ReminderShortcut.laterToday));
      case _ReminderChoice.tomorrow:
        setState(
            () => _reminderTime = _shortcutReminder(ReminderShortcut.tomorrow));
      case _ReminderChoice.nextWeek:
        setState(
            () => _reminderTime = _shortcutReminder(ReminderShortcut.nextWeek));
      case _ReminderChoice.pick:
        final picked = await pickTaskReminder(context);
        if (picked != null) setState(() => _reminderTime = picked);
      case _ReminderChoice.remove:
        setState(() => _reminderTime = null);
    }
    _focusNode.requestFocus();
  }

  String get _reminderLabel {
    final reminder = _reminderTime;
    if (reminder == null) return 'Remind me';
    final day = DateTime(reminder.year, reminder.month, reminder.day);
    if (day == _shortcutDate(DueDateShortcut.today)) {
      return 'Remind me at ${_time(reminder)}';
    }
    if (day == _shortcutDate(DueDateShortcut.tomorrow)) {
      return 'Tomorrow, ${_time(reminder)}';
    }
    return '${DateFormat('EEE, MMM d').format(reminder)}, ${_time(reminder)}';
  }

  List<PopupMenuEntry<_ReminderChoice>> _reminderMenu(BuildContext context) {
    final laterToday = _shortcutReminder(ReminderShortcut.laterToday);
    final tomorrow = _shortcutReminder(ReminderShortcut.tomorrow)!;
    final nextWeek = _shortcutReminder(ReminderShortcut.nextWeek)!;
    String dayAndTime(DateTime dateTime) =>
        '${DateFormat('EEE').format(dateTime)} ${_time(dateTime)}';
    return [
      if (laterToday != null)
        _menuItem(_ReminderChoice.laterToday, Icons.update,
            'Later today (${_time(laterToday)})'),
      _menuItem(_ReminderChoice.tomorrow, Icons.schedule,
          'Tomorrow (${dayAndTime(tomorrow)})'),
      _menuItem(_ReminderChoice.nextWeek, Icons.arrow_circle_right_outlined,
          'Next week (${dayAndTime(nextWeek)})'),
      _menuItem(_ReminderChoice.pick, Icons.edit_calendar_outlined,
          'Pick a date & time'),
      if (_reminderTime != null) ...[
        const PopupMenuDivider(),
        _menuItem(
            _ReminderChoice.remove, Icons.delete_outline, 'Remove reminder',
            color: Colors.redAccent),
      ],
    ];
  }

  static const _repeatIcons = {
    TaskRepeat.daily: Icons.today_outlined,
    TaskRepeat.weekdaysOnly: Icons.work_outline,
    TaskRepeat.weekly: Icons.view_week_outlined,
    TaskRepeat.monthly: Icons.calendar_month_outlined,
    TaskRepeat.yearly: Icons.event_repeat_outlined,
  };

  /// Menu values are a [TaskRepeat] preset or a [_RepeatAction].
  Future<void> _onRepeatSelected(Object choice) async {
    switch (choice) {
      case TaskRepeat preset:
        setState(() => _repeat = preset);
      case _RepeatAction.custom:
        final current = _repeat;
        final custom = await pickCustomRepeat(context,
            initial: current != null && current.isCustom ? current : null);
        if (custom != null) setState(() => _repeat = custom);
      case _RepeatAction.never:
        setState(() => _repeat = null);
    }
    _focusNode.requestFocus();
  }

  List<PopupMenuEntry<Object>> _repeatMenu(BuildContext context) {
    return [
      for (final preset in TaskRepeat.presets)
        _menuItem<Object>(preset, _repeatIcons[preset]!, preset.describe()),
      _menuItem<Object>(_RepeatAction.custom, Icons.tune, 'Custom'),
      if (_repeat != null) ...[
        const PopupMenuDivider(),
        _menuItem<Object>(
            _RepeatAction.never, Icons.delete_outline, 'Never repeat',
            color: Colors.redAccent),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.radio_button_unchecked,
                        color: Colors.grey, size: 28),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      focusNode: _focusNode,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Add a task',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      // Keeps the keyboard open so the next task can be typed.
                      onEditingComplete: _submit,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _titleController,
                    builder: (context, value, _) {
                      final canSubmit = value.text.trim().isNotEmpty;
                      return IconButton.filled(
                        tooltip: 'Add',
                        onPressed: canSubmit ? _submit : null,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          disabledBackgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        icon:
                            const Icon(Icons.arrow_upward, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PopupMenuButton<_DueDateChoice>(
                      color: const Color(0xFF2B2B2B),
                      onSelected: _onDueDateSelected,
                      onCanceled: _focusNode.requestFocus,
                      itemBuilder: _dueDateMenu,
                      child: IgnorePointer(
                        child: _OptionButton(
                          icon: Icons.calendar_today_outlined,
                          label: _dueDateLabel,
                          isActive: _dueDate != null,
                          onPressed: () {},
                        ),
                      ),
                    ),
                    PopupMenuButton<_ReminderChoice>(
                      color: const Color(0xFF2B2B2B),
                      onSelected: _onReminderSelected,
                      onCanceled: _focusNode.requestFocus,
                      itemBuilder: _reminderMenu,
                      child: IgnorePointer(
                        child: _OptionButton(
                          icon: Icons.notifications_none,
                          label: _reminderLabel,
                          isActive: _reminderTime != null,
                          onPressed: () {},
                        ),
                      ),
                    ),
                    PopupMenuButton<Object>(
                      color: const Color(0xFF2B2B2B),
                      onSelected: _onRepeatSelected,
                      onCanceled: _focusNode.requestFocus,
                      itemBuilder: _repeatMenu,
                      child: IgnorePointer(
                        child: _OptionButton(
                          icon: Icons.repeat,
                          label: _repeat?.describe() ?? 'Repeat',
                          isActive: _repeat != null,
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DueDateChoice { today, tomorrow, nextWeek, pick, remove }

enum _ReminderChoice { laterToday, tomorrow, nextWeek, pick, remove }

enum _RepeatAction { custom, never }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.blueAccent : Colors.white;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 15)),
    );
  }
}
