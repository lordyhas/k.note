import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:knote/config/whats_new_releases.dart';

void main() {
  test('compares versions part by part', () {
    expect(compareVersions('0.7.10', '0.7.2'), 1);
    expect(compareVersions('0.7.2', '0.8.0'), -1);
    expect(compareVersions('0.7.2+107', '0.7.2'), 0);
    expect(compareVersions('1', '1.0.0'), 0);
  });

  test('lists the releases newest first, once each', () {
    for (var i = 1; i < whatsNewReleases.length; i++) {
      expect(
          compareVersions(
              whatsNewReleases[i - 1].version, whatsNewReleases[i].version),
          1,
          reason: whatsNewReleases[i].version);
    }
  });

  test('picks the changes between two versions', () {
    expect(whatsNewKeys(seen: '0.7.0', current: '0.7.2'), ['whatsNewFolders']);
    expect(whatsNewKeys(seen: '0.7.2', current: '0.7.3'), isEmpty);
    expect(whatsNewKeys(seen: '0.6.0', current: '0.7.0'),
        ['whatsNewEditor', 'whatsNewIcons', 'whatsNewSettings']);
    // Settings > What's new: the newest release up to the running version.
    expect(whatsNewKeys(current: '0.7.1'),
        ['whatsNewEditor', 'whatsNewIcons', 'whatsNewSettings']);
  });

  test('picks the changes of one version for its release notes', () {
    expect(whatsNewKeysOf('0.7.2'), ['whatsNewFolders']);
    expect(whatsNewKeysOf('0.7.1'), isEmpty);
  });

  test('tool/release_notes.dart writes both languages', () async {
    final result = await Process.run(
        'dart', ['run', 'tool/release_notes.dart', '0.7.2'],
        runInShell: true, stdoutEncoding: utf8);

    expect(result.exitCode, 0, reason: '${result.stderr}');
    final notes = result.stdout as String;
    expect(notes, contains("## What's new"));
    expect(notes, contains('- **Folders** — File your notes'));
    expect(notes, contains('## Quoi de neuf'));
    expect(notes, contains('- **Dossiers** — Rangez vos notes'));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
