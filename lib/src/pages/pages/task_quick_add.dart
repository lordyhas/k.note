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
  /// Menu value for clearing the repeat option; a null value would be
  /// reported as a cancelled menu.
  static const _never = '';

  final _titleController = TextEditingController();
  final _focusNode = FocusNode();
  DateTime? _dueDate;
  DateTime? _reminderTime;
  String? _repeat;

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
        repeat: _repeat,
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

  Future<void> _pickReminder() async {
    final picked = await pickTaskReminder(context);
    if (picked != null) setState(() => _reminderTime = picked);
    _focusNode.requestFocus();
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
                    _OptionButton(
                      icon: Icons.notifications_none,
                      label: _reminderTime == null
                          ? 'Remind me'
                          : DateFormat('MMM d, HH:mm').format(_reminderTime!),
                      isActive: _reminderTime != null,
                      onPressed: _pickReminder,
                    ),
                    PopupMenuButton<String>(
                      color: const Color(0xFF1F1F1F),
                      onSelected: (value) {
                        setState(
                            () => _repeat = value == _never ? null : value);
                        _focusNode.requestFocus();
                      },
                      itemBuilder: (_) => [
                        for (final option in taskRepeatOptions)
                          PopupMenuItem(
                            value: option,
                            child: Text(option,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        if (_repeat != null)
                          const PopupMenuItem(
                            value: _never,
                            child: Text('Never repeat',
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                      ],
                      child: IgnorePointer(
                        child: _OptionButton(
                          icon: Icons.repeat,
                          label: _repeat ?? 'Repeat',
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
