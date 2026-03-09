import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knote/data/database/model/note_model.dart';

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
        'color': Colors.blue.value,
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
      expect(checklist.colorValue, Colors.blue.value);
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
      expect(checklist.colorValue, Colors.white.value);
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
      expect(map['color'], Colors.green.value);
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
}
