import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, on this device, the last app version whose "What's new" was
/// shown, so it is shown once after each update (and after installing).
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

  /// The version to announce, or null when its "What's new" was already
  /// seen on this device or the version can't be read.
  Future<String?> versionToAnnounce() async {
    try {
      final version = await _currentVersion();
      if (version.isEmpty) return null;
      final seen = await _store.getString(seenVersionKey);
      return seen == version ? null : version;
    } catch (e) {
      // Never block the app over a missing plugin or storage error.
      debugPrint('What\'s new: could not read the versions: $e');
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
