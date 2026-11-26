/// The "What's new" of each release: the app version (`x.y.z`, as in
/// `pubspec.yaml` before the `+`) and the keys of its changes, newest release
/// first. A key `k` has its texts in `kTitle` and `kBody` of the `.arb` files
/// and its icon in `whatsNewEntry` (`ui/settings/widgets/whats_new_dialog.dart`).
///
/// The app shows the changes of the releases a device has not seen yet, and
/// the release workflow writes those of the version it publishes at the top of
/// the GitHub release (`tool/release_notes.dart`). This file is read outside
/// Flutter, so it must import nothing from Flutter.
const whatsNewReleases = <WhatsNewRelease>[
  (version: '0.7.2', keys: ['whatsNewFolders']),
  (
    version: '0.7.0',
    keys: ['whatsNewEditor', 'whatsNewIcons', 'whatsNewSettings'],
  ),
];

typedef WhatsNewRelease = ({String version, List<String> keys});

/// Compares two `x.y.z` versions like [Comparable.compare]. A missing or
/// non-numeric part counts as 0.
int compareVersions(String a, String b) {
  List<int> parts(String version) => version
      .split('+')
      .first
      .split('.')
      .map((part) => int.tryParse(part) ?? 0)
      .toList();
  final left = parts(a);
  final right = parts(b);
  for (var i = 0; i < 3; i++) {
    final diff =
        (i < left.length ? left[i] : 0) - (i < right.length ? right[i] : 0);
    if (diff != 0) return diff.sign;
  }
  return 0;
}

/// The keys of the changes released after [seen] and up to [current], newest
/// first. With no [seen] version, those of the newest release up to
/// [current] (what Settings > What's new shows).
List<String> whatsNewKeys({String? seen, required String current}) {
  final released = whatsNewReleases
      .where((release) => compareVersions(release.version, current) <= 0);
  if (seen == null) return released.isEmpty ? [] : released.first.keys;
  return [
    for (final release in released)
      if (compareVersions(release.version, seen) > 0) ...release.keys,
  ];
}

/// The keys of the changes of exactly [version], for its release notes.
List<String> whatsNewKeysOf(String version) => [
      for (final release in whatsNewReleases)
        if (compareVersions(release.version, version) == 0) ...release.keys,
    ];
