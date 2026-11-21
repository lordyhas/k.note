import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/widgets/app_icons.dart';
import 'package:knote/ui/core/widgets/responsive.dart';
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
        leading: AppIcon(AppIcons.checkCircle, color: colors.text),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => StreamBuilder<List<CheckList>>(
          stream: _tasks,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              debugPrint('Tasks could not be loaded: ${snapshot.error}');
              return _buildMessage(AppIcons.warning, l10n.tasksLoadError);
            } else if (!snapshot.hasData ||
                snapshot.data!.every((t) => _removedIds.contains(t.id))) {
              return _buildMessage(AppIcons.checkCircle, l10n.tasksEmpty);
            } else {
              final tasks = snapshot.data!
                  .where((t) => !_removedIds.contains(t.id))
                  .toList();
              final activeTasks = tasks.where((t) => !t.isAllChecked).toList()
                ..sort(compareActiveTasks);
              final completedTasks = tasks.where((t) => t.isAllChecked).toList()
                ..sort(compareCompletedTasks);

              return ListView(
                padding:
                    centeredPadding(constraints.maxWidth, bottom: fabClearance),
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
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.tasksNew,
        onPressed: () =>
            showTaskQuickAdd(context, firebaseManager: _firebaseManager),
        child: const AppIcon(AppIcons.add),
      ),
    );
  }

  /// Empty and error states.
  Widget _buildMessage(AppIcons icon, String text) {
    final color = AppColors.of(context).textMuted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 100, color: color),
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
    // The due date is red when late and highlighted when due today.
    final now = DateTime.now();
    final due = task.dueDate;
    final dueColor = due == null
        ? iconColor
        : isOverdue(due, now: now)
            ? colors.danger
            : isDueToday(due, now: now)
                ? colors.link
                : iconColor;

    return Dismissible(
      key: Key(task.id ?? task.title),
      background: Container(
        alignment: Alignment.centerRight,
        color: colors.danger,
        padding: const EdgeInsets.only(right: 20.0),
        child: AppIcon(AppIcons.trash, color: colors.text),
      ),
      onDismissed: (_) => _delete(task),
      child: Card(
        color: taskColor,
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
                      // Completing a repeating task adds its next one.
                      final next = updatedTask.isAllChecked
                          ? task.nextOccurrence(id: const Uuid().v4())
                          : null;
                      saveInBackground(
                          () => _firebaseManager.updateTaskWithNext(
                              task: updatedTask, next: next),
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
                              ? AppIcon(AppIcons.check,
                                  size: 16, color: colors.onAccent)
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
                              AppIcon(AppIcons.calendar,
                                  size: 12, color: iconColor),
                              const SizedBox(width: 4),
                              Text(
                                dueDateText(l10n, task.dueDate!, now: now),
                                style: TextStyle(color: dueColor, fontSize: 12),
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
                  icon: AppIcon(
                    task.isImportant ? AppIcons.starSolid : AppIcons.star,
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

/// Order of the active tasks: the nearest due date first (so overdue tasks
/// come first), then the tasks without a due date. Ties keep the creation
/// order, oldest first, so editing a task doesn't move it.
int compareActiveTasks(CheckList a, CheckList b) {
  final aDue = a.dueDate, bDue = b.dueDate;
  if (aDue != null && bDue != null) {
    final byDue = aDue.compareTo(bDue);
    if (byDue != 0) return byDue;
  } else if (aDue != null) {
    return -1;
  } else if (bDue != null) {
    return 1;
  }
  return _byDate(a.creationTime, b.creationTime);
}

/// Order of the completed tasks: the last one completed (modified) first.
int compareCompletedTasks(CheckList a, CheckList b) => _byDate(
    a.modificationTime ?? a.creationTime, b.modificationTime ?? b.creationTime,
    newestFirst: true);

/// Oldest (or newest) first, dates missing from older documents last.
int _byDate(DateTime? a, DateTime? b, {bool newestFirst = false}) {
  if (a == null || b == null) return a == null ? (b == null ? 0 : 1) : -1;
  return newestFirst ? b.compareTo(a) : a.compareTo(b);
}
