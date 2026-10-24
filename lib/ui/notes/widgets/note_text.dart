import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

import 'package:knote/domain/models/note.dart';

/// The plain text of a note body, which is stored as a Quill delta in JSON.
/// Notes written before the rich text editor hold plain text, returned as is.
String notePlainText(String? content) {
  if (content == null || content.isEmpty) return '';
  try {
    // Quill ends every document with a newline.
    return Document.fromJson(jsonDecode(content) as List).toPlainText().trim();
  } catch (_) {
    return content;
  }
}

/// The [notes] whose title or text contain every word of [query], ignoring
/// case and accents ("ete" finds "Été"). An empty query keeps every note.
List<NoteModel> searchNotes(List<NoteModel> notes, String query) {
  final words = _fold(query).split(RegExp(r'\s+'))
    ..removeWhere((w) => w.isEmpty);
  if (words.isEmpty) return notes;
  return notes.where((note) {
    final haystack = _fold('${note.title ?? ''}\n${notePlainText(note.text)}');
    return words.every(haystack.contains);
  }).toList();
}

const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'å': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'í': 'i',
  'ì': 'i',
  'ñ': 'n',
  'ô': 'o',
  'ö': 'o',
  'ó': 'o',
  'ò': 'o',
  'õ': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ú': 'u',
  'ÿ': 'y',
  'ý': 'y',
  'œ': 'oe',
  'æ': 'ae',
};

String _fold(String text) {
  final lower = text.toLowerCase();
  final buffer = StringBuffer();
  for (final char in lower.split('')) {
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString();
}
