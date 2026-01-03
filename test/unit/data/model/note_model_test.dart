import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knote/data/database/model/note_model.dart';

void main() {
  group('NoteModel', () {
    // Timestamp uses seconds and nanoseconds.
    // We use a fixed time to ensure stability, but converting to/from can lose precision
    // if we aren't careful. For this test we just want to ensure the flow works.
    final now = DateTime.now();
    final timestampNow = Timestamp.fromDate(now);

    test('fromMap creates correct NoteModel from Firestore-like map', () {
      final map = {
        'id': '123',
        'title': 'Test Title',
        'text': 'Test Text',
        'creation_time': timestampNow,
        'last_time': timestampNow,
        'is_deleted': false,
        'permanent_delete_date': null,
        'color': Colors.red.value,
        'reminder_date': timestampNow,
        'email': 'test@example.com',
        'is_archived': true,
        'is_locked': false,
        'saving_mode': 1, // local
      };

      final note = NoteModel.fromMap(map);

      expect(note.id, '123');
      expect(note.title, 'Test Title');
      expect(note.text, 'Test Text');
      // Timestamp.toDate() returns a DateTime.
      expect(note.creationTime, timestampNow.toDate());
      expect(note.modificationTime, timestampNow.toDate());
      expect(note.isDeleted, false);
      expect(note.colorValue, Colors.red.value);
      expect(note.email, 'test@example.com');
      expect(note.isArchived, true);
      // saving_mode 1 corresponds to SavingMode.local (index 1)
      expect(note.savingModeValue, 1);
    });

    test('asMap returns correct map with DateTime objects', () {
      final note = NoteModel(
        id: '123',
        title: 'Test Title',
        text: 'Test Text',
        creationTime: now,
        modificationTime: now,
        isDeleted: false,
        color: Colors.red,
        reminderDate: now,
        email: 'test@example.com',
        isArchived: true,
        isLocked: false,
        savingMode: SavingMode.local,
      );

      final map = note.asMap();

      expect(map['id'], '123');
      expect(map['title'], 'Test Title');
      expect(map['text'], 'Test Text');
      // NoteModel fields are DateTime, so asMap should return DateTime
      expect(map['creation_time'], now);
      expect(map['last_time'], now);
      expect(map['color'], Colors.red.value);
      expect(map['saving_mode'], 1);
    });
  });
}
