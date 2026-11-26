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

  Future<String?> seenVersion() =>
      SharedPreferencesAsync().getString(WhatsNewService.seenVersionKey);

  test('announces an update until it is marked as seen', () async {
    await service('0.7.0').markSeen('0.7.0');
    final whatsNew = service('0.7.2');

    final announcement = await whatsNew.toAnnounce();
    expect(announcement?.version, '0.7.2');
    expect(announcement?.keys, ['whatsNewFolders']);

    await whatsNew.markSeen('0.7.2');
    expect(await whatsNew.toAnnounce(), isNull);
  });

  test('announces every release skipped since the last one seen', () async {
    await service('0.6.1').markSeen('0.6.1');

    final announcement = await service('0.7.2').toAnnounce();

    expect(announcement?.keys, [
      'whatsNewFolders',
      'whatsNewEditor',
      'whatsNewIcons',
      'whatsNewSettings',
    ]);
  });

  test('announces nothing on a first install, then records the version',
      () async {
    expect(await service('0.7.2').toAnnounce(), isNull);
    expect(await seenVersion(), '0.7.2');
  });

  test('announces nothing for a release without changes listed', () async {
    await service('0.7.0').markSeen('0.7.0');

    expect(await service('0.7.1').toAnnounce(), isNull);
    expect(await seenVersion(), '0.7.1');
  });

  test('announces nothing when the version cannot be read', () async {
    final whatsNew = WhatsNewService(
        currentVersion: () async => throw Exception('no plugin'),
        preferences: SharedPreferencesAsync());

    expect(await whatsNew.toAnnounce(), isNull);
  });
}
