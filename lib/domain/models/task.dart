import 'package:flutter/material.dart';

import 'package:knote/domain/models/document_model.dart';
import 'package:knote/domain/models/task_repeat.dart';

class TodoItem implements DataToMap {
  final String text;
  final bool isDone;

  const TodoItem({required this.text, required this.isDone});

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
        text: map['text'],
        isDone: map['is_done'],
      );

  @override
  Map<String, dynamic> asMap() => {
        'text': text,
        'is_done': isDone,
      };

  @override
  void toDisplay() {}
}

class CheckList extends DocumentModel {
  final dynamic id;
  String title;
  final List<TodoItem> list;
  final bool isAllChecked;
  final int colorValue;
  final DateTime? creationTime;
  DateTime? modificationTime;

  // New fields for ToDo style
  bool isImportant;
  bool isMyDay;
  DateTime? dueDate;
  DateTime? reminderTime;
  String? repeat;
  String? note;

  CheckList({
    this.id,
    required this.title,
    required this.list,
    this.isAllChecked = false,
    Color color = Colors.white,
    this.creationTime,
    this.modificationTime,
    this.isImportant = false,
    this.isMyDay = false,
    this.dueDate,
    this.reminderTime,
    this.repeat,
    this.note,
  }) : colorValue = color.toARGB32();

  List<Map<String, dynamic>> get listMap => list.map((e) => e.asMap()).toList();

  @override
  Map<String, dynamic> asMap() => {
        'id': id,
        'title': title,
        'is_all_checked': isAllChecked,
        'list': listMap,
        'color': colorValue,
        'creation_time': creationTime,
        'last_time': modificationTime,
        'is_important': isImportant,
        'is_my_day': isMyDay,
        'due_date': dueDate,
        'reminder_time': reminderTime,
        'repeat': repeat,
        'note': note,
      };

  factory CheckList.fromMap(Map<String, dynamic> map) => CheckList(
        id: map['id'],
        title: map['title'] as String,
        isAllChecked: map['is_all_checked'] as bool,
        list: (map['list'] as List<dynamic>)
            .map((e) => TodoItem.fromMap(e))
            .toList(),
        color: Color(map['color'] ?? Colors.white.toARGB32()),
        creationTime: (map['creation_time'] != null)
            ? map['creation_time'].toDate()
            : null,
        modificationTime:
            (map['last_time'] != null) ? map['last_time'].toDate() : null,
        isImportant: map['is_important'] ?? false,
        isMyDay: map['is_my_day'] ?? false,
        dueDate: (map['due_date'] != null) ? map['due_date'].toDate() : null,
        reminderTime: (map['reminder_time'] != null)
            ? map['reminder_time'].toDate()
            : null,
        repeat: map['repeat'],
        note: map['note'],
      );

  /// The copy of a repeating task to do next, once this one is completed:
  /// unchecked, due on the next date of [repeat] after [dueDate], with the
  /// reminder moved by the same number of days. A task with neither a due
  /// date nor a reminder repeats from [now]. Null if the task does not repeat.
  CheckList? nextOccurrence({required String id, DateTime? now}) {
    final rule = TaskRepeat.parse(repeat);
    if (rule == null) return null;
    now ??= DateTime.now();
    final due = dueDate;
    final reminder = reminderTime;
    final from = due ?? reminder ?? now;
    final next = rule.nextAfter(from);
    final days = DateTime.utc(next.year, next.month, next.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;
    DateTime shift(DateTime date) => DateTime(date.year, date.month,
        date.day + days, date.hour, date.minute, date.second);
    return CheckList(
      id: id,
      title: title,
      list: [for (final item in list) TodoItem(text: item.text, isDone: false)],
      color: Color(colorValue),
      creationTime: now,
      modificationTime: now,
      isImportant: isImportant,
      dueDate: due != null
          ? shift(due)
          : reminder == null
              ? next
              : null,
      reminderTime: reminder == null ? null : shift(reminder),
      repeat: repeat,
      note: note,
    );
  }

  @override
  void toDisplay() {
    debugPrint("*** \n${toString()}{");
    asMap().forEach((key, value) => debugPrint("$key : $value,"));
    debugPrint('} \n***');
  }
}
