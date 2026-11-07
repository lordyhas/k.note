import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/domain/models/task.dart';

void main() {
  group('TodoItem', () {
    test('fromMap creates correct TodoItem', () {
      final map = {'text': 'Buy milk', 'is_done': false};
      final item = TodoItem.fromMap(map);
      expect(item.text, 'Buy milk');
      expect(item.isDone, false);
    });

    test('fromMap with done item', () {
      final map = {'text': 'Walk dog', 'is_done': true};
      final item = TodoItem.fromMap(map);
      expect(item.text, 'Walk dog');
      expect(item.isDone, true);
    });

    test('asMap returns correct map', () {
      const item = TodoItem(text: 'Test task', isDone: true);
      final map = item.asMap();
      expect(map['text'], 'Test task');
      expect(map['is_done'], true);
    });

    test('roundtrip fromMap -> asMap preserves data', () {
      final original = {'text': 'Roundtrip', 'is_done': false};
      final item = TodoItem.fromMap(original);
      final result = item.asMap();
      expect(result['text'], original['text']);
      expect(result['is_done'], original['is_done']);
    });
  });

  group('CheckList', () {
    final now = DateTime.now();
    final timestampNow = Timestamp.fromDate(now);

    test('fromMap creates correct CheckList', () {
      final map = {
        'id': 'checklist-1',
        'title': 'Shopping List',
        'is_all_checked': false,
        'list': [
          {'text': 'Apples', 'is_done': false},
          {'text': 'Bread', 'is_done': true},
        ],
        'color': Colors.blue.toARGB32(),
        'creation_time': timestampNow,
        'last_time': timestampNow,
        'is_important': true,
        'is_my_day': false,
        'due_date': timestampNow,
        'reminder_time': null,
        'repeat': 'weekly',
        'note': 'Get organic if possible',
      };

      final checklist = CheckList.fromMap(map);

      expect(checklist.id, 'checklist-1');
      expect(checklist.title, 'Shopping List');
      expect(checklist.isAllChecked, false);
      expect(checklist.list.length, 2);
      expect(checklist.list[0].text, 'Apples');
      expect(checklist.list[0].isDone, false);
      expect(checklist.list[1].text, 'Bread');
      expect(checklist.list[1].isDone, true);
      expect(checklist.colorValue, Colors.blue.toARGB32());
      expect(checklist.isImportant, true);
      expect(checklist.isMyDay, false);
      expect(checklist.repeat, 'weekly');
      expect(checklist.note, 'Get organic if possible');
    });

    test('fromMap handles null optional fields', () {
      final map = {
        'id': 'checklist-2',
        'title': 'Minimal',
        'is_all_checked': true,
        'list': <Map<String, dynamic>>[],
        'color': null,
        'creation_time': null,
        'last_time': null,
        'is_important': null,
        'is_my_day': null,
        'due_date': null,
        'reminder_time': null,
        'repeat': null,
        'note': null,
      };

      final checklist = CheckList.fromMap(map);

      expect(checklist.id, 'checklist-2');
      expect(checklist.title, 'Minimal');
      expect(checklist.isAllChecked, true);
      expect(checklist.list, isEmpty);
      expect(checklist.colorValue, Colors.white.toARGB32());
      expect(checklist.creationTime, isNull);
      expect(checklist.modificationTime, isNull);
      expect(checklist.isImportant, false);
      expect(checklist.isMyDay, false);
    });

    test('asMap returns correct map', () {
      final checklist = CheckList(
        id: 'cl-3',
        title: 'Tasks',
        list: const [
          TodoItem(text: 'Do laundry', isDone: false),
        ],
        isAllChecked: false,
        color: Colors.green,
        creationTime: now,
        modificationTime: now,
        isImportant: true,
        isMyDay: true,
        dueDate: now,
        note: 'Important tasks',
      );

      final map = checklist.asMap();

      expect(map['id'], 'cl-3');
      expect(map['title'], 'Tasks');
      expect(map['is_all_checked'], false);
      expect(map['list'], isA<List>());
      expect((map['list'] as List).length, 1);
      expect(map['color'], Colors.green.toARGB32());
      expect(map['is_important'], true);
      expect(map['is_my_day'], true);
      expect(map['note'], 'Important tasks');
    });

    test('listMap returns list of TodoItem maps', () {
      final checklist = CheckList(
        id: 'cl-4',
        title: 'Test',
        list: const [
          TodoItem(text: 'A', isDone: false),
          TodoItem(text: 'B', isDone: true),
        ],
      );

      final listMap = checklist.listMap;
      expect(listMap.length, 2);
      expect(listMap[0], {'text': 'A', 'is_done': false});
      expect(listMap[1], {'text': 'B', 'is_done': true});
    });

    test('empty list is handled correctly', () {
      final checklist = CheckList(
        id: 'cl-5',
        title: 'Empty',
        list: const [],
      );

      expect(checklist.list, isEmpty);
      expect(checklist.listMap, isEmpty);
      expect(checklist.asMap()['list'], isEmpty);
    });
  });

  group('CheckList.nextOccurrence', () {
    final now = DateTime(2026, 3, 1, 12);

    CheckList task({String? repeat, DateTime? due, DateTime? reminder}) =>
        CheckList(
          id: 'task-1',
          title: 'Water the plants',
          list: const [TodoItem(text: 'Balcony', isDone: true)],
          isAllChecked: true,
          isImportant: true,
          isMyDay: true,
          dueDate: due,
          reminderTime: reminder,
          repeat: repeat,
          note: 'Not too much',
        );

    test('is null for a task that does not repeat', () {
      expect(task(due: now).nextOccurrence(id: 'next', now: now), isNull);
    });

    test('is due on the next date, unchecked, with the reminder moved', () {
      final next = task(
        repeat: 'Weekly',
        due: DateTime(2026, 3, 2),
        reminder: DateTime(2026, 3, 2, 8, 15),
      ).nextOccurrence(id: 'next', now: now)!;

      expect(next.id, 'next');
      expect(next.isAllChecked, isFalse);
      expect(next.list.single.isDone, isFalse);
      expect(next.list.single.text, 'Balcony');
      expect(next.dueDate, DateTime(2026, 3, 9));
      expect(next.reminderTime, DateTime(2026, 3, 9, 8, 15));
      expect(next.repeat, 'Weekly');
      expect(next.isImportant, isTrue);
      expect(next.isMyDay, isFalse);
      expect(next.note, 'Not too much');
      expect(next.creationTime, now);
    });

    test('a reminder without a due date repeats from the reminder', () {
      final next = task(repeat: 'Daily', reminder: DateTime(2026, 3, 1, 7))
          .nextOccurrence(id: 'next', now: now)!;
      expect(next.dueDate, isNull);
      expect(next.reminderTime, DateTime(2026, 3, 2, 7));
    });

    test('a task without dates repeats from now', () {
      final next = task(repeat: 'Daily').nextOccurrence(id: 'next', now: now)!;
      expect(next.dueDate, DateTime(2026, 3, 2, 12));
    });
  });
}
