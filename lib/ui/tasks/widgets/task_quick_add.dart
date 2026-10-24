import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/task_repeat.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/tasks/widgets/task_pickers.dart';
import 'package:knote/ui/tasks/widgets/task_text.dart';
import 'package:knote/utils/save_in_background.dart';

/// Opens the Microsoft To Do style "Add a task" sheet above the keyboard.
///
/// Each submitted title is saved right away and the field is cleared, so
/// several tasks can be added in a row without leaving the tasks screen.
Future<void> showTaskQuickAdd(
  BuildContext context, {
  required FirestoreService firebaseManager,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.of(context).surfaceHigh,
    shape: const RoundedRectangleBorder(),
    builder: (_) => TaskQuickAddSheet(firebaseManager: firebaseManager),
  );
}

class TaskQuickAddSheet extends StatefulWidget {
  const TaskQuickAddSheet({super.key, required this.firebaseManager});

  final FirestoreService firebaseManager;

  @override
  State<TaskQuickAddSheet> createState() => _TaskQuickAddSheetState();
}

class _TaskQuickAddSheetState extends State<TaskQuickAddSheet> {
  final _titleController = TextEditingController();
  final _focusNode = FocusNode();
  DateTime? _dueDate;
  DateTime? _reminderTime;
  TaskRepeat? _repeat;

  /// Shown in the sheet when a task could not be saved; a snack bar would be
  /// hidden behind the sheet.
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final dueDate = _dueDate;
    final reminderTime = _reminderTime;
    final repeat = _repeat;
    final now = DateTime.now();
    final task = CheckList(
      id: const Uuid().v4(),
      title: title,
      list: const [],
      creationTime: now,
      modificationTime: now,
      dueDate: dueDate,
      reminderTime: reminderTime,
      repeat: repeat?.encode(),
    );

    // The form is cleared right away (the write succeeds locally even
    // offline); if the server rejects the task, it is put back for a retry.
    saveInBackground(
      () => widget.firebaseManager.addTaskInCloud(task: task),
      failureMessage: l10n.taskSaveFailedNamed(title),
      onFailure: () {
        if (!mounted || _titleController.text.isNotEmpty) return false;
        setState(() {
          _titleController.text = title;
          _dueDate = dueDate;
          _reminderTime = reminderTime;
          _repeat = repeat;
          _error = l10n.taskQuickAddFailed;
        });
        return true;
      },
    );

    setState(() {
      _titleController.clear();
      _dueDate = null;
      _reminderTime = null;
      _repeat = null;
      _error = null;
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
    final l10n = context.l10n;
    final dueDate = _dueDate;
    if (dueDate == null) return l10n.setDueDate;
    if (dueDate == _shortcutDate(DueDateShortcut.today)) return l10n.dueToday;
    if (dueDate == _shortcutDate(DueDateShortcut.tomorrow)) {
      return l10n.dueTomorrow;
    }
    return l10n.dueOn(shortDate(l10n, dueDate));
  }

  List<PopupMenuEntry<_DueDateChoice>> _dueDateMenu(BuildContext context) {
    final l10n = context.l10n;
    String weekday(DueDateShortcut shortcut) =>
        weekdayName(l10n, _shortcutDate(shortcut));
    return [
      _menuItem(_DueDateChoice.today, Icons.today_outlined,
          l10n.menuToday(weekday(DueDateShortcut.today))),
      _menuItem(_DueDateChoice.tomorrow, Icons.event_outlined,
          l10n.menuTomorrow(weekday(DueDateShortcut.tomorrow))),
      _menuItem(_DueDateChoice.nextWeek, Icons.date_range_outlined,
          l10n.menuNextWeek(weekday(DueDateShortcut.nextWeek))),
      _menuItem(
          _DueDateChoice.pick, Icons.edit_calendar_outlined, l10n.pickDate),
      if (_dueDate != null) ...[
        const PopupMenuDivider(),
        _menuItem(
            _DueDateChoice.remove, Icons.delete_outline, l10n.removeDueDate,
            color: AppColors.of(context).danger),
      ],
    ];
  }

  PopupMenuItem<T> _menuItem<T>(T value, IconData icon, String label,
      {Color? color}) {
    color ??= AppColors.of(context).text;
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
    final l10n = context.l10n;
    final reminder = _reminderTime;
    if (reminder == null) return l10n.remindMe;
    final day = DateTime(reminder.year, reminder.month, reminder.day);
    if (day == _shortcutDate(DueDateShortcut.today)) {
      return l10n.remindMeAt(_time(reminder));
    }
    if (day == _shortcutDate(DueDateShortcut.tomorrow)) {
      return l10n.reminderTomorrowAt(_time(reminder));
    }
    return l10n.reminderOn(shortDate(l10n, reminder), _time(reminder));
  }

  List<PopupMenuEntry<_ReminderChoice>> _reminderMenu(BuildContext context) {
    final laterToday = _shortcutReminder(ReminderShortcut.laterToday);
    final tomorrow = _shortcutReminder(ReminderShortcut.tomorrow)!;
    final nextWeek = _shortcutReminder(ReminderShortcut.nextWeek)!;
    final l10n = context.l10n;
    String dayAndTime(DateTime dateTime) =>
        '${DateFormat.E(l10n.localeName).format(dateTime)} ${_time(dateTime)}';
    return [
      if (laterToday != null)
        _menuItem(_ReminderChoice.laterToday, Icons.update,
            l10n.menuLaterToday(_time(laterToday))),
      _menuItem(_ReminderChoice.tomorrow, Icons.schedule,
          l10n.menuTomorrow(dayAndTime(tomorrow))),
      _menuItem(_ReminderChoice.nextWeek, Icons.arrow_circle_right_outlined,
          l10n.menuNextWeek(dayAndTime(nextWeek))),
      _menuItem(_ReminderChoice.pick, Icons.edit_calendar_outlined,
          l10n.pickDateAndTime),
      if (_reminderTime != null) ...[
        const PopupMenuDivider(),
        _menuItem(
            _ReminderChoice.remove, Icons.delete_outline, l10n.removeReminder,
            color: AppColors.of(context).danger),
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
    final l10n = context.l10n;
    return [
      for (final preset in TaskRepeat.presets)
        _menuItem<Object>(
            preset, _repeatIcons[preset]!, repeatText(l10n, preset)),
      _menuItem<Object>(_RepeatAction.custom, Icons.tune, l10n.repeatCustom),
      if (_repeat != null) ...[
        const PopupMenuDivider(),
        _menuItem<Object>(
            _RepeatAction.never, Icons.delete_outline, l10n.repeatNever,
            color: AppColors.of(context).danger),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final repeat = _repeat;
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.radio_button_unchecked,
                        color: colors.textMuted, size: 28),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      focusNode: _focusNode,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(color: colors.text, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: l10n.quickAddHint,
                        hintStyle: TextStyle(color: colors.textMuted),
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
                        tooltip: l10n.quickAddSubmit,
                        onPressed: canSubmit ? _submit : null,
                        style: IconButton.styleFrom(
                          backgroundColor: colors.accent,
                          disabledBackgroundColor: colors.disabled,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: Icon(Icons.arrow_upward, color: colors.text),
                      );
                    },
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(52, 0, 8, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text(_error!, style: TextStyle(color: colors.danger)),
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PopupMenuButton<_DueDateChoice>(
                      color: colors.surfaceHigh,
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
                      color: colors.surfaceHigh,
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
                      color: colors.surfaceHigh,
                      onSelected: _onRepeatSelected,
                      onCanceled: _focusNode.requestFocus,
                      itemBuilder: _repeatMenu,
                      child: IgnorePointer(
                        child: _OptionButton(
                          icon: Icons.repeat,
                          label: repeat == null
                              ? l10n.repeat
                              : repeatText(l10n, repeat),
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
    final colors = AppColors.of(context);
    final color = isActive ? colors.accent : colors.text;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 15)),
    );
  }
}
