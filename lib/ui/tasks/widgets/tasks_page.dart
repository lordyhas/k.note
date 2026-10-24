import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/widgets/undo_snack_bar.dart';
import 'package:knote/ui/tasks/widgets/task_editor_page.dart';
import 'package:knote/ui/tasks/widgets/task_pickers.dart';
import 'package:knote/ui/tasks/widgets/task_quick_add.dart';
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
    setState(() => _removedIds.add(task.id));
    saveInBackground(() => _firebaseManager.deleteTask(taskId: task.id),
        failureMessage: "The task couldn't be deleted", onFailure: () {
      if (mounted) setState(() => _removedIds.remove(task.id));
      return false;
    });
    showUndoSnackBar('"${task.title}" deleted', onUndo: () {
      if (mounted) setState(() => _removedIds.remove(task.id));
      saveInBackground(() => _firebaseManager.addTaskInCloud(task: task),
          failureMessage: "The task couldn't be restored");
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tasks',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Icon(Icons.task_alt,
            color: Colors.white), // const BackButton(color: Colors.white),
        actions: [
          //todo: pop up menu
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData ||
                snapshot.data!.every((t) => _removedIds.contains(t.id))) {
              return _buildEmptyState();
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          Text('Active', style: TextStyle(color: Colors.grey)),
                    ),
                    ...activeTasks.map((t) => _buildTaskItem(t)),
                  ],
                  if (completedTasks.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text('Completed ${completedTasks.length}',
                          style: const TextStyle(color: Colors.white)),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
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
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () =>
              showTaskQuickAdd(context, firebaseManager: _firebaseManager),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(CheckList task) {
    Color taskColor = Color(task.colorValue);
    bool isDark = taskColor.computeLuminance() < 0.5;
    if (taskColor.toARGB32() == Colors.white.toARGB32()) {
      taskColor = const Color(0xFF1F1F1F);
      isDark = true;
    }
    Color textColor = isDark ? Colors.white : Colors.black;
    Color iconColor = isDark ? Colors.grey : Colors.black54;

    return Dismissible(
      key: Key(task.id ?? task.title),
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
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
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                InkWell(
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
                        failureMessage: "The task couldn't be updated");
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              task.isAllChecked ? Colors.blueAccent : iconColor,
                          width: 2),
                      color: task.isAllChecked
                          ? Colors.blueAccent
                          : Colors.transparent,
                    ),
                    child: task.isAllChecked
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                            color: task.isAllChecked ? Colors.grey : textColor,
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
                                _formatDate(task.dueDate!),
                                style: TextStyle(
                                    color: isOverdue(task.dueDate!,
                                            now: DateTime.now())
                                        ? Colors.red
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
                  icon: Icon(
                    task.isImportant ? Icons.star : Icons.star_border,
                    color: task.isImportant ? Colors.blueAccent : iconColor,
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
                        failureMessage: "The task couldn't be updated");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}";
  }
}
