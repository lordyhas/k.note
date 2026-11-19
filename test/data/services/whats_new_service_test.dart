import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:knote/data/services/whats_new_service.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  WhatsNewService service(String version) => WhatsNewService(
      currentVersion: () async => version,
      preferences: SharedPreferencesAsync());

  test('announces a version until it is marked as seen', () async {
    final whatsNew = service('0.7.0');
    expect(await whatsNew.versionToAnnounce(), '0.7.0');

    await whatsNew.markSeen('0.7.0');
    expect(await whatsNew.versionToAnnounce(), isNull);
  });

  test('announces again after an update', () async {
    await service('0.6.1').markSeen('0.6.1');

    expect(await service('0.7.0').versionToAnnounce(), '0.7.0');
  });

  test('announces nothing when the version cannot be read', () async {
    final whatsNew = WhatsNewService(
        currentVersion: () async => throw Exception('no plugin'),
        preferences: SharedPreferencesAsync());

    expect(await whatsNew.versionToAnnounce(), isNull);
  });
}
