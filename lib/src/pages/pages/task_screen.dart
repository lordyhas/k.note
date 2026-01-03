import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/data/database/firebase_manager.dart';
import 'package:knote/data/database/database_model.dart';
import 'package:knote/src/pages/task_editor.dart';


class TaskScreen extends StatefulWidget {
  static const routeName = "tasks";

  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final FirebaseManager _firebaseManager;

  @override
  void initState() {
    super.initState();
    _firebaseManager = FirebaseManager.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user);
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
        leading: const BackButton(color: Colors.white),
      ),
      body: FutureBuilder<List<CheckList>>(
        future: _firebaseManager.getTasksInCloud(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            final tasks = snapshot.data!;
            final activeTasks = tasks.where((t) => !t.isAllChecked).toList();
            final completedTasks = tasks.where((t) => t.isAllChecked).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                if (activeTasks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Active', style: TextStyle(color: Colors.grey)),
                  ),
                  ...activeTasks.map((t) => _buildTaskItem(t)).toList(),
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
      bottomNavigationBar: const SizedBox(height: 70),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => GoRouter.of(context).pushNamed(TaskEditor.routeName),
        child: const Icon(Icons.add, color: Colors.white),
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
    if (taskColor.value == Colors.white.value) {
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
      onDismissed: (direction) {
        _firebaseManager.deleteTask(taskId: task.id);
      },
      child: Card(
        color: taskColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: InkWell(
          onTap: () async {
            await GoRouter.of(context)
                .pushNamed(TaskEditor.routeName, extra: task);
            setState(() {});
          },
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
                    _firebaseManager.updateTaskInCloud(task: updatedTask);
                    setState(() {});
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
                                    color:
                                        task.dueDate!.isBefore(DateTime.now())
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
                    _firebaseManager.updateTaskInCloud(task: updatedTask);
                    setState(() {});
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
