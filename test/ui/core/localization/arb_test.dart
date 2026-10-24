import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `app_en.arb` is the template; every other language must translate each
/// message, with the same placeholders.
void main() {
  const dir = 'lib/ui/core/localization';

  Map<String, String> messages(String file) {
    final json = jsonDecode(File('$dir/$file').readAsStringSync())
        as Map<String, dynamic>;
    return {
      for (final entry in json.entries)
        if (!entry.key.startsWith('@')) entry.key: entry.value as String,
    };
  }

  // `{name}` or `{name, plural, ...}`, but not plural branches like `=1{day}`.
  Set<String> placeholders(String message) => RegExp(r'(?<![\w=])\{(\w+)[,}]')
      .allMatches(message)
      .map((m) => m.group(1)!)
      .toSet();

  final en = messages('app_en.arb');
  final translations = Directory(dir)
      .listSync()
      .map((f) => f.uri.pathSegments.last)
      .where((name) => name.endsWith('.arb') && name != 'app_en.arb');

  test('there is at least one translation', () {
    expect(translations, contains('app_fr.arb'));
  });

  for (final file in translations) {
    group(file, () {
      final other = messages(file);

      test('has exactly the keys of app_en.arb', () {
        expect(other.keys.toSet(), en.keys.toSet());
      });

      test('uses the same placeholders', () {
        for (final key in en.keys) {
          expect(placeholders(other[key] ?? ''), placeholders(en[key]!),
              reason: key);
        }
      });
    });
  }
}
