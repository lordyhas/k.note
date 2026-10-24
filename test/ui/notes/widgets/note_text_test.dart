import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/notes/widgets/note_text.dart';

String _delta(String text) => jsonEncode([
      {'insert': '$text\n'}
    ]);

NoteModel _note(String id, {String? title, String? text}) =>
    NoteModel(id: id, title: title, text: text);

void main() {
  group('notePlainText', () {
    test('extracts the text of a Quill delta', () {
      expect(notePlainText(_delta('Hello world')), 'Hello world');
    });

    test('keeps legacy plain text notes as they are', () {
      expect(notePlainText('Just text'), 'Just text');
    });

    test('is empty for a missing body', () {
      expect(notePlainText(null), '');
      expect(notePlainText(''), '');
    });
  });

  group('searchNotes', () {
    final notes = [
      _note('1', title: 'Été à Paris', text: _delta('Visiter le Louvre')),
      _note('2', title: 'Groceries', text: _delta('Milk, eggs, bread')),
      _note('3', title: null, text: 'Legacy note about EGGS'),
    ];

    List<String> ids(String query) =>
        searchNotes(notes, query).map((n) => n.id as String).toList();

    test('keeps every note for an empty query', () {
      expect(ids(''), ['1', '2', '3']);
      expect(ids('   '), ['1', '2', '3']);
    });

    test('matches the title and the text, ignoring case', () {
      expect(ids('groceries'), ['2']);
      expect(ids('eggs'), ['2', '3']);
    });

    test('ignores accents both ways', () {
      expect(ids('ete'), ['1']);
      expect(ids('été'), ['1']);
      expect(ids('LOUVRE'), ['1']);
    });

    test('needs every word, in any order', () {
      expect(ids('bread milk'), ['2']);
      expect(ids('milk paris'), isEmpty);
    });
  });
}
