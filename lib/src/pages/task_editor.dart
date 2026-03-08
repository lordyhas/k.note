import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/data/database/firebase_manager.dart';
import 'package:knote/data/database/database_model.dart';
import 'package:uuid/uuid.dart';

class TaskEditor extends StatefulWidget {
  static const String routeName = '/task_editor';
  final CheckList? task;

  const TaskEditor({super.key, this.task});

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late List<TodoItem> _items;
  late final FirebaseManager _firebaseManager;
  Color _color = Colors.white; // Keep color for compatibility
  String? _id;

  // New fields state
  bool _isImportant = false;
  bool _isMyDay = false;
  DateTime? _dueDate;
  DateTime? _reminderTime;
  String? _repeat;

  @override
  void initState() {
    super.initState();
    _firebaseManager = FirebaseManager.user(
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
    if (_titleController.text.isEmpty &&
        _items.isEmpty &&
        _noteController.text.isEmpty) {
      return;
    }

    final newTask = CheckList(
      id: _id,
      title: _titleController.text.isEmpty
          ? 'Untitled Task'
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

    if (widget.task == null) {
      _firebaseManager.addTaskInCloud(task: newTask);
    } else {
      _firebaseManager.updateTaskInCloud(task: newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        // if (didPop) _saveTask(); // already saved manually or by back button potentially?
        // PopScope(onPopInvoked: (didPop) {}) with didPop true means it ALREADY popped.
        // We generally can't prevent pop here easily without canPop: false.
        // But if we want to save on exit, we can do it here.
        _saveTask();
      },
      child: Scaffold(
        backgroundColor: Colors.black, // Dark theme
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.circle, color: _color),
              onPressed: _showColorPicker,
            ),
            IconButton(
              icon: Icon(_isImportant ? Icons.star : Icons.star_border,
                  color: _isImportant ? Colors.blueAccent : Colors.white),
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
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.grey),
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
                      side: const BorderSide(color: Colors.grey),
                      checkColor: Colors.white,
                      activeColor: Colors.blueAccent,
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: item.text,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) {
                          _items[index] =
                              TodoItem(text: val, isDone: item.isDone);
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Step',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => setState(() => _items.removeAt(index)),
                    ),
                  ],
                ),
              );
            }),

            // Add Step Button
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blueAccent),
              title: const Text('Add step',
                  style: TextStyle(color: Colors.blueAccent)),
              onTap: _addItem,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(color: Colors.grey),

            // Options
            _buildOptionTile(
              icon: Icons.wb_sunny_outlined,
              text: _isMyDay ? 'Added to My Day' : 'Add to My Day',
              isActive: _isMyDay,
              onTap: () => setState(() => _isMyDay = !_isMyDay),
            ),
            _buildOptionTile(
              icon: Icons.notifications_none,
              text: _reminderTime == null
                  ? 'Remind me'
                  : 'Remind me at ${DateFormat('HH:mm').format(_reminderTime!)}',
              isActive: _reminderTime != null,
              onTap: _pickReminderTime,
            ),
            _buildOptionTile(
              icon: Icons.calendar_today,
              text: _dueDate == null
                  ? 'Add due date'
                  : 'Due ${DateFormat('EEE, MMM d').format(_dueDate!)}',
              isActive: _dueDate != null,
              onTap: _pickDueDate,
            ),
            _buildOptionTile(
              icon: Icons.repeat,
              text: _repeat ?? 'Repeat',
              isActive: _repeat != null,
              onTap: () {
                setState(() => _repeat = _repeat == null ? 'Daily' : null);
              },
            ),
            _buildOptionTile(
              icon: Icons.attach_file,
              text: 'Add file',
              isActive: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('File attachment not implemented yet')));
              },
            ),
            const Divider(color: Colors.grey),

            // Note
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Add note',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF1F1F1F),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created on ${_dateFormat(widget.task?.creationTime ?? DateTime.now())}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () {
                  final id = _id;
                  if (id != null) {
                    _firebaseManager.deleteTask(taskId: id).then((_) {
                      Navigator.pop(context);
                    });
                  } else {
                    Navigator.pop(context);
                  }
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
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey),
      title: Text(text,
          style:
              TextStyle(color: isActive ? Colors.blueAccent : Colors.white70)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      trailing: isActive
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1F1F1F),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1F1F1F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickReminderTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        setState(() {
          _reminderTime = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  String _dateFormat(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
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
