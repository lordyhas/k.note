import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/task_repeat.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/tasks/widgets/task_pickers.dart';
import 'package:knote/ui/tasks/widgets/task_text.dart';
import 'package:knote/utils/save_in_background.dart';

class TaskEditorPage extends StatefulWidget {
  static const String routeName = '/task_editor';
  final CheckList? task;

  const TaskEditorPage({super.key, this.task});

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late List<TodoItem> _items;
  late final FirestoreService _firebaseManager;
  Color _color = Colors.white; // Keep color for compatibility
  String? _id;

  // New fields state
  bool _isImportant = false;
  bool _isMyDay = false;
  bool _isDeleted = false;
  DateTime? _dueDate;
  DateTime? _reminderTime;
  String? _repeat;

  @override
  void initState() {
    super.initState();
    _firebaseManager = FirestoreService.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user);

    if (widget.task != null) {
      _titleController = TextEditingController(text: widget.task!.title);
      _items = List.from(widget.task!.list);
      _color = Color(widget.task!.colorValue);
      _id = widget.task!.id;
      _isImportant = widget.task!.isImportant;
      _isMyDay = widget.task!.isMyDay;
      _dueDate = widget.task!.dueDate;
      _reminderTime = widget.task!.reminderTime;
      _repeat = widget.task!.repeat;
      _noteController = TextEditingController(text: widget.task!.note ?? '');
    } else {
      _titleController = TextEditingController();
      _noteController = TextEditingController();
      _items = [];
      _id = const Uuid().v4();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final l10n = context.l10n;
    if (_isDeleted) return;
    if (_titleController.text.isEmpty &&
        _items.isEmpty &&
        _noteController.text.isEmpty) {
      return;
    }

    final newTask = CheckList(
      id: _id,
      title: _titleController.text.isEmpty
          ? l10n.untitledTask
          : _titleController.text,
      list: _items,
      color: _color,
      isAllChecked: _items.isNotEmpty && _items.every((e) => e.isDone),
      creationTime: widget.task?.creationTime ?? DateTime.now(),
      modificationTime: DateTime.now(),
      isImportant: _isImportant,
      isMyDay: _isMyDay,
      dueDate: _dueDate,
      reminderTime: _reminderTime,
      repeat: _repeat,
      note: _noteController.text,
    );

    saveInBackground(
      () => widget.task == null
          ? _firebaseManager.addTaskInCloud(task: newTask)
          : _firebaseManager.updateTaskInCloud(task: newTask),
      failureMessage: l10n.taskSaveFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        // Save on exit; skipped when the task was just deleted.
        _saveTask();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icon(Icons.arrow_back, color: colors.text),
            onPressed: () {
              context.pop();
            },
          ),
          actions: [
            IconButton(
              tooltip: l10n.taskColor,
              icon: Icon(Icons.circle, color: _color),
              onPressed: _showColorPicker,
            ),
            IconButton(
              tooltip: _isImportant
                  ? l10n.taskRemoveImportance
                  : l10n.taskMarkImportant,
              icon: Icon(_isImportant ? Icons.star : Icons.star_border,
                  color: _isImportant ? colors.accent : colors.text),
              onPressed: () {
                setState(() => _isImportant = !_isImportant);
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title
            TextField(
              controller: _titleController,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.text),
              decoration: InputDecoration(
                hintText: l10n.titleHint,
                hintStyle: TextStyle(color: colors.textMuted),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),

            // Steps (Checklist)
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Dismissible(
                key: Key('step_$index'),
                onDismissed: (direction) {
                  setState(() => _items.removeAt(index));
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: item.isDone,
                      onChanged: (val) {
                        setState(() {
                          _items[index] =
                              TodoItem(text: item.text, isDone: val ?? false);
                        });
                      },
                      shape: const CircleBorder(), // Round checkbox
                      side: BorderSide(color: colors.textMuted),
                      checkColor: colors.text,
                      activeColor: colors.accent,
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: item.text,
                        style: TextStyle(color: colors.text),
                        onChanged: (val) {
                          _items[index] =
                              TodoItem(text: val, isDone: item.isDone);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.taskStepHint,
                          hintStyle: TextStyle(color: colors.textMuted),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.taskRemoveStep,
                      icon: Icon(Icons.close, color: colors.textMuted),
                      onPressed: () => setState(() => _items.removeAt(index)),
                    ),
                  ],
                ),
              );
            }),

            // Add Step Button
            ListTile(
              leading: Icon(Icons.add, color: colors.accent),
              title: Text(l10n.taskAddStep,
                  style: TextStyle(color: colors.accent)),
              onTap: _addItem,
              contentPadding: EdgeInsets.zero,
            ),
            Divider(color: colors.textMuted),

            // Options
            _buildOptionTile(
              icon: Icons.wb_sunny_outlined,
              text: _isMyDay ? l10n.taskAddedToMyDay : l10n.taskAddToMyDay,
              isActive: _isMyDay,
              onTap: () => setState(() => _isMyDay = !_isMyDay),
            ),
            _buildOptionTile(
              icon: Icons.notifications_none,
              text: _reminderTime == null
                  ? l10n.remindMe
                  : l10n.remindMeAt(MaterialLocalizations.of(context)
                      .formatTimeOfDay(TimeOfDay.fromDateTime(_reminderTime!))),
              isActive: _reminderTime != null,
              onTap: _pickReminderTime,
            ),
            _buildOptionTile(
              icon: Icons.calendar_today,
              text: _dueDate == null
                  ? l10n.taskAddDueDate
                  : l10n.dueOn(shortDate(l10n, _dueDate!)),
              isActive: _dueDate != null,
              onTap: _pickDueDate,
            ),
            _buildOptionTile(
              icon: Icons.repeat,
              text: _repeat == null
                  ? l10n.repeat
                  : repeatValueText(l10n, _repeat!),
              isActive: _repeat != null,
              onTap: () {
                setState(() =>
                    _repeat = _repeat == null ? TaskRepeat.daily.encode() : null);
              },
            ),
            _buildOptionTile(
              icon: Icons.attach_file,
              text: l10n.taskAddFile,
              isActive: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.taskFilesUnavailable)));
              },
            ),
            Divider(color: colors.textMuted),

            // Note
            TextField(
              controller: _noteController,
              style: TextStyle(color: colors.text, fontSize: 14),
              maxLines: null,
              decoration: InputDecoration(
                hintText: l10n.taskNoteHint,
                hintStyle: TextStyle(color: colors.textMuted),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: colors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.taskCreatedOn(shortDate(
                    l10n, widget.task?.creationTime ?? DateTime.now())),
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
              IconButton(
                tooltip: l10n.taskDelete,
                icon: Icon(Icons.delete_outline, color: colors.text),
                onPressed: () {
                  _isDeleted = true;
                  final id = _id;
                  // Don't wait for the server: offline it never answers.
                  if (id != null && widget.task != null) {
                    saveInBackground(
                        () => _firebaseManager.deleteTask(taskId: id),
                        failureMessage: l10n.taskDeleteFailed);
                  }
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      {required IconData icon,
      required String text,
      required bool isActive,
      required VoidCallback onTap}) {
    final colors = AppColors.of(context);
    return ListTile(
      leading: Icon(icon, color: isActive ? colors.accent : colors.textMuted),
      title: Text(text,
          style: TextStyle(
              color: isActive
                  ? colors.accent
                  : colors.text.withValues(alpha: 0.7))),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      trailing: isActive
          ? IconButton(
              tooltip: context.l10n.remove,
              icon: Icon(Icons.close, color: colors.textMuted),
              onPressed: () {
                if (icon == Icons.wb_sunny_outlined) {
                  setState(() => _isMyDay = false);
                } else if (icon == Icons.notifications_none) {
                  setState(() => _reminderTime = null);
                } else if (icon == Icons.calendar_today) {
                  setState(() => _dueDate = null);
                } else if (icon == Icons.repeat) {
                  setState(() => _repeat = null);
                }
              },
            )
          : null,
    );
  }

  void _addItem() {
    setState(() {
      _items.add(const TodoItem(text: '', isDone: false));
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await pickTaskDueDate(context, initial: _dueDate);
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminderTime() async {
    final picked = await pickTaskReminder(context);
    if (picked != null) setState(() => _reminderTime = picked);
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      builder: (context) {
        return SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Colors.white,
              Colors.redAccent,
              Colors.blueAccent,
              Colors.greenAccent,
              Colors.yellowAccent,
              Colors.purpleAccent,
              Colors.orangeAccent,
              Colors.pinkAccent,
            ]
                .map((c) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _color = c);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(backgroundColor: c),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
