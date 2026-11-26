import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/domain/models/folder.dart';

void main() {
  group('NoteFolder', () {
    test('asMap and fromMap round-trip', () {
      final created = DateTime(2026, 11, 25);
      final folder = NoteFolder(id: 'f1', name: 'Work', creationTime: created);

      expect(NoteFolder.fromMap(folder.asMap()), folder);
    });

    test('reads a Firestore timestamp', () {
      final created = DateTime(2026, 11, 25);
      final folder = NoteFolder.fromMap({
        'id': 'f1',
        'name': 'Work',
        'creation_time': Timestamp.fromDate(created),
      });

      expect(folder.creationTime, created);
    });

    test('is defensive about malformed documents', () {
      final folder =
          NoteFolder.fromMap({'id': 3, 'name': null, 'creation_time': 'x'});

      expect(folder.id, '');
      expect(folder.name, '');
      expect(folder.creationTime, isNull);
    });
  });
}
