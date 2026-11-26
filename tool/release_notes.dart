// Writes the "What's new" of a version, in English and French, as Markdown
// for its GitHub release. Prints nothing when the version announces nothing.
//
//   dart run tool/release_notes.dart 0.7.2

import 'dart:convert';
import 'dart:io';

import 'package:knote/config/whats_new_releases.dart';

const _languages = ['en', 'fr'];

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/release_notes.dart <version>');
    exit(64);
  }
  final keys = whatsNewKeysOf(args.single);
  if (keys.isEmpty) return;

  final notes = StringBuffer();
  for (final language in _languages) {
    final file = File('lib/ui/core/localization/app_$language.arb');
    final arb = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    String text(String key) {
      final value = arb[key];
      if (value is! String) {
        stderr.writeln('${file.path} has no "$key"');
        exit(1);
      }
      return value;
    }

    notes.writeln('## ${text('whatsNewTitle')}');
    notes.writeln();
    for (final key in keys) {
      notes.writeln('- **${text('${key}Title')}** — ${text('${key}Body')}');
    }
    notes.writeln();
  }
  stdout
    ..encoding = utf8
    ..write(notes);
}
