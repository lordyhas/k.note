import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knote/config/whats_new_releases.dart';

/// Remembers, on this device, the last app version whose "What's new" was
/// shown, so that an update announces the changes of the releases the device
/// has not seen ([whatsNewReleases]) once, and an install announces nothing.
class WhatsNewService {
  WhatsNewService({
    Future<String> Function()? currentVersion,
    SharedPreferencesAsync? preferences,
  })  : _currentVersion = currentVersion ?? _packageVersion,
        _preferences = preferences;

  static const seenVersionKey = 'whats_new_seen_version';

  final Future<String> Function() _currentVersion;
  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _store =>
      _preferences ??= SharedPreferencesAsync();

  static Future<String> _packageVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  /// The running version and the keys of the changes to announce, or null
  /// when there are none: already seen, a first install, a release without
  /// changes listed in [whatsNewReleases], or the version can't be read.
  ///
  /// A first install or a release without changes is recorded as seen here;
  /// otherwise call [markSeen] once the changes are shown.
  Future<({String version, List<String> keys})?> toAnnounce() async {
    try {
      final version = await _currentVersion();
      if (version.isEmpty) return null;
      final seen = await _store.getString(seenVersionKey);
      if (seen == version) return null;
      // A new user has nothing to compare with: nothing is "new" to them.
      final keys = seen == null
          ? const <String>[]
          : whatsNewKeys(seen: seen, current: version);
      if (keys.isEmpty) {
        await markSeen(version);
        return null;
      }
      return (version: version, keys: keys);
    } catch (e) {
      // Never block the app over a missing plugin or storage error.
      debugPrint("What's new: could not read the versions: $e");
      return null;
    }
  }

  /// Records that the "What's new" of [version] was shown.
  Future<void> markSeen(String version) async {
    try {
      await _store.setString(seenVersionKey, version);
    } catch (e) {
      debugPrint('What\'s new: could not save the version: $e');
    }
  }
}
