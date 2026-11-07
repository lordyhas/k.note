import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:knote/data/services/reminder_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/user.dart';

class MockNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

final _now = DateTime(2026, 3, 1, 12);

CheckList _task(String id,
        {DateTime? reminder, bool done = false, String? note}) =>
    CheckList(
      id: id,
      title: 'Task $id',
      list: const [],
      isAllChecked: done,
      reminderTime: reminder,
      note: note,
    );

void main() {
  late MockNotificationsPlugin plugin;
  late ReminderService service;

  setUpAll(() {
    tz_data.initializeTimeZones();
    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(tz.TZDateTime.utc(2026));
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  setUp(() async {
    plugin = MockNotificationsPlugin();
    when(() => plugin.initialize(settings: any(named: 'settings')))
        .thenAnswer((_) async => true);
    when(() => plugin.cancelAllPendingNotifications()).thenAnswer((_) async {});
    when(() => plugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});
    service = ReminderService(plugin: plugin, isSupported: true);
    await service.initialize(channelName: 'Reminders', channelDescription: '');
  });

  List<String?> scheduledPayloads() => verify(() => plugin.zonedSchedule(
        id: any(named: 'id'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: captureAny(named: 'payload'),
      )).captured.cast<String?>();

  group('upcoming', () {
    test('keeps open tasks with a future reminder, soonest first', () {
      final tasks = [
        _task('later', reminder: _now.add(const Duration(days: 2))),
        _task('past', reminder: _now.subtract(const Duration(minutes: 1))),
        _task('done', reminder: _now.add(const Duration(hours: 1)), done: true),
        _task('none'),
        _task('soon', reminder: _now.add(const Duration(hours: 1))),
      ];

      expect(ReminderService.upcoming(tasks, now: _now).map((t) => t.id),
          ['soon', 'later']);
    });

    test('is limited to the iOS maximum', () {
      final tasks = [
        for (var i = 0; i < 70; i++)
          _task('$i', reminder: _now.add(Duration(minutes: i + 1))),
      ];
      expect(ReminderService.upcoming(tasks, now: _now), hasLength(64));
    });
  });

  test('notification ids are stable and positive', () {
    expect(ReminderService.notificationId('task-1'),
        ReminderService.notificationId('task-1'));
    expect(ReminderService.notificationId('task-1'),
        isNot(ReminderService.notificationId('task-2')));
    expect(ReminderService.notificationId('task-1'), isNonNegative);
  });

  test('syncTasks replaces the scheduled reminders', () async {
    await service.syncTasks([
      _task('a', reminder: _now.add(const Duration(hours: 1)), note: ' Milk '),
      _task('b'),
    ], now: _now);

    verify(() => plugin.cancelAllPendingNotifications()).called(1);
    final scheduled = verify(() => plugin.zonedSchedule(
          id: ReminderService.notificationId('a'),
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: 'Task a',
          body: 'Milk',
          payload: 'a',
        )).captured.single as tz.TZDateTime;
    expect(
        scheduled.isAtSameMomentAs(_now.add(const Duration(hours: 1))), isTrue);
  });

  test('syncTasks skips a schedule identical to the last one', () async {
    final tasks = [_task('a', reminder: _now.add(const Duration(hours: 1)))];
    await service.syncTasks(tasks, now: _now);
    await service.syncTasks(tasks, now: _now);

    verify(() => plugin.cancelAllPendingNotifications()).called(1);
    expect(scheduledPayloads(), ['a']);
  });

  test('does nothing where reminders are not supported', () async {
    final web = ReminderService(plugin: plugin, isSupported: false);
    await web.initialize(channelName: 'Reminders', channelDescription: '');
    await web.syncTasks(
        [_task('a', reminder: DateTime.now().add(const Duration(hours: 1)))]);

    verifyNever(() => plugin.cancelAllPendingNotifications());
  });

  test(
      'follow schedules the tasks of the signed-in user and cancels them '
      'on sign out', () async {
    const user = User(
        id: 'uid-1',
        email: 'me@example.com',
        name: null,
        photoMail: null,
        isCheckMail: true);
    final users = StreamController<User>();
    final tasks = StreamController<List<CheckList>>.broadcast();
    final watched = <String>[];
    final subscription = service.follow(users.stream, (user) {
      watched.add(user.id);
      return tasks.stream;
    });

    users.add(user);
    await pumpEventQueue();
    tasks.add([
      _task('a', reminder: DateTime.now().add(const Duration(hours: 1))),
    ]);
    await pumpEventQueue();
    expect(watched, ['uid-1']);
    expect(scheduledPayloads(), ['a']);

    users.add(User.empty);
    await pumpEventQueue();
    verify(() => plugin.cancelAllPendingNotifications()).called(2);

    await subscription.cancel();
    await users.close();
    await tasks.close();
  });

  test('follow ignores users who must verify their email', () async {
    final users = StreamController<User>();
    final subscription = service.follow(users.stream, (_) {
      fail('tasks must not be read');
    });

    users.add(const User(
        id: 'uid-1',
        email: 'me@example.com',
        name: null,
        photoMail: null,
        isCheckMail: false));
    await pumpEventQueue();

    await subscription.cancel();
    await users.close();
  });

  test('turning reminders off cancels them, and on schedules them again',
      () async {
    final tasks = [_task('a', reminder: _now.add(const Duration(hours: 1)))];
    await service.syncTasks(tasks, now: _now);
    expect(scheduledPayloads(), ['a']);

    await service.setEnabled(false, now: _now);
    verify(() => plugin.cancelAllPendingNotifications()).called(2);
    await service.syncTasks(tasks, now: _now);
    verifyNever(() => plugin.cancelAllPendingNotifications());

    await service.setEnabled(true, now: _now);
    verify(() => plugin.cancelAllPendingNotifications()).called(1);
    expect(scheduledPayloads(), ['a']);
  });
}
