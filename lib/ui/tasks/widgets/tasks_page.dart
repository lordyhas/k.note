import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/themes/dimens.dart';
import 'package:knote/ui/core/widgets/undo_snack_bar.dart';
import 'package:knote/ui/tasks/widgets/task_editor_page.dart';
import 'package:knote/ui/tasks/widgets/task_pickers.dart';
import 'package:knote/ui/tasks/widgets/task_quick_add.dart';
import 'package:knote/ui/tasks/widgets/task_text.dart';
import 'package:knote/utils/save_in_background.dart';

class TasksPage extends StatefulWidget {
  static const routeName = "tasks";

  /// Defaults to the signed-in user's [FirestoreService]; tests pass a fake.
  final FirestoreService? firebaseManager;

  const TasksPage({super.key, this.firebaseManager});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late final FirestoreService _firebaseManager;
  late final Stream<List<CheckList>> _tasks;

  /// Tasks swiped away. They are hidden at once, because a dismissed
  /// [Dismissible] must leave the tree before the stream reports the delete,
  /// and shown again on Undo or if the delete fails.
  final Set<String?> _removedIds = {};

  void _delete(CheckList task) {
    final l10n = context.l10n;
    setState(() => _removedIds.add(task.id));
    saveInBackground(() => _firebaseManager.deleteTask(taskId: task.id),
        failureMessage: l10n.taskDeleteFailed, onFailure: () {
      if (mounted) setState(() => _removedIds.remove(task.id));
      return false;
    });
    showUndoSnackBar(l10n.taskDeleted(task.title), onUndo: () {
      if (mounted) setState(() => _removedIds.remove(task.id));
      saveInBackground(() => _firebaseManager.addTaskInCloud(task: task),
          failureMessage: l10n.taskRestoreFailed);
    });
  }

  @override
  void initState() {
    super.initState();
    _firebaseManager = widget.firebaseManager ??
        FirestoreService.user(
            BlocProvider.of<AuthenticationBloc>(context).state.user);
    _tasks = _firebaseManager.watchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.tasksTitle,
            style: TextStyle(
                color: colors.text, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: colors.background,
        elevation: 0,
        leading: Icon(Icons.task_alt, color: colors.text),
        actions: [
          //todo: pop up menu
          IconButton(
            tooltip: l10n.moreOptions,
            icon: Icon(Icons.more_vert, color: colors.text),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 910),
        child: StreamBuilder<List<CheckList>>(
          stream: _tasks,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              debugPrint('Tasks could not be loaded: ${snapshot.error}');
              return _buildMessage(Icons.error_outline, l10n.tasksLoadError);
            } else if (!snapshot.hasData ||
                snapshot.data!.every((t) => _removedIds.contains(t.id))) {
              return _buildMessage(Icons.task_alt, l10n.tasksEmpty);
            } else {
              final tasks = snapshot.data!
                  .where((t) => !_removedIds.contains(t.id))
                  .toList();
              final activeTasks = tasks.where((t) => !t.isAllChecked).toList();
              final completedTasks =
                  tasks.where((t) => t.isAllChecked).toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  if (activeTasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(l10n.tasksActive,
                          style: TextStyle(color: colors.textMuted)),
                    ),
                    ...activeTasks.map((t) => _buildTaskItem(t)),
                  ],
                  if (completedTasks.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text(l10n.tasksCompleted(completedTasks.length),
                          style: TextStyle(color: colors.text)),
                      iconColor: colors.text,
                      collapsedIconColor: colors.text,
                      children:
                          completedTasks.map((t) => _buildTaskItem(t)).toList(),
                    ),
                  ],
                ],
              );
            }
          },
        ),
      ),
      //bottomNavigationBar: const SizedBox(height: 70),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: fabBottomPadding),
        child: FloatingActionButton(
          tooltip: l10n.tasksNew,
          backgroundColor: colors.accent,
          onPressed: () =>
              showTaskQuickAdd(context, firebaseManager: _firebaseManager),
          child: Icon(Icons.add, color: colors.text),
        ),
      ),
    );
  }

  /// Empty and error states.
  Widget _buildMessage(IconData icon, String text) {
    final color = AppColors.of(context).textMuted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: color),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(CheckList task) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    Color taskColor = Color(task.colorValue);
    bool isDark = taskColor.computeLuminance() < 0.5;
    // White is the default task color, shown as a plain card.
    if (taskColor.toARGB32() == Colors.white.toARGB32()) {
      taskColor = colors.surface;
      isDark = true;
    }
    Color textColor = isDark ? Colors.white : Colors.black;
    Color iconColor = isDark ? Colors.grey : Colors.black54;

    return Dismissible(
      key: Key(task.id ?? task.title),
      background: Container(
        alignment: Alignment.centerRight,
        color: colors.danger,
        padding: const EdgeInsets.only(right: 20.0),
        child: Icon(Icons.delete, color: colors.text),
      ),
      onDismissed: (_) => _delete(task),
      child: Card(
        color: taskColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: InkWell(
          onTap: () => GoRouter.of(context)
              .pushNamed(TaskEditorPage.routeName, extra: task),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  checked: task.isAllChecked,
                  label: task.isAllChecked
                      ? l10n.taskMarkNotCompleted
                      : l10n.taskMarkCompleted,
                  child: InkResponse(
                    radius: 24,
                    onTap: () {
                      final updatedTask = CheckList(
                        id: task.id,
                        title: task.title,
                        list: task.list,
                        isAllChecked: !task.isAllChecked,
                        color: Color(task.colorValue),
                        creationTime: task.creationTime,
                        modificationTime: DateTime.now(),
                        isImportant: task.isImportant,
                        isMyDay: task.isMyDay,
                        dueDate: task.dueDate,
                        reminderTime: task.reminderTime,
                        repeat: task.repeat,
                        note: task.note,
                      );
                      saveInBackground(
                          () => _firebaseManager.updateTaskInCloud(
                              task: updatedTask),
                          failureMessage: l10n.taskUpdateFailed);
                    },
                    // 48 x 48: the minimum touch target.
                    child: SizedBox.square(
                      dimension: 48,
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: task.isAllChecked
                                    ? colors.accent
                                    : iconColor,
                                width: 2),
                            color: task.isAllChecked
                                ? colors.accent
                                : Colors.transparent,
                          ),
                          child: task.isAllChecked
                              ? Icon(Icons.check, size: 16, color: colors.text)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                            color: task.isAllChecked
                                ? colors.textMuted
                                : textColor,
                            fontSize: 16,
                            decoration: task.isAllChecked
                                ? TextDecoration.lineThrough
                                : null),
                      ),
                      if (task.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 12, color: iconColor),
                              const SizedBox(width: 4),
                              Text(
                                dueDateText(l10n, task.dueDate!,
                                    now: DateTime.now()),
                                style: TextStyle(
                                    color: isOverdue(task.dueDate!,
                                            now: DateTime.now())
                                        ? colors.danger
                                        : iconColor,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: task.isImportant
                      ? l10n.taskRemoveImportance
                      : l10n.taskMarkImportant,
                  icon: Icon(
                    task.isImportant ? Icons.star : Icons.star_border,
                    color: task.isImportant ? colors.accent : iconColor,
                  ),
                  onPressed: () {
                    final updatedTask = CheckList(
                      id: task.id,
                      title: task.title,
                      list: task.list,
                      isAllChecked: task.isAllChecked,
                      color: Color(task.colorValue),
                      creationTime: task.creationTime,
                      modificationTime: DateTime.now(),
                      isImportant: !task.isImportant,
                      isMyDay: task.isMyDay,
                      dueDate: task.dueDate,
                      reminderTime: task.reminderTime,
                      repeat: task.repeat,
                      note: task.note,
                    );
                    saveInBackground(
                        () => _firebaseManager.updateTaskInCloud(
                            task: updatedTask),
                        failureMessage: l10n.taskUpdateFailed);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
