import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/user.dart';

/// Shows a local notification at the reminder time of each task.
///
/// Reminders are scheduled on the device (Android, iOS) by the system, so
/// they fire even when the app is closed. The list of scheduled reminders
/// is rebuilt from the tasks whenever they change ([syncTasks]), which also
/// picks up reminders set on another device the next time the app runs.
///
/// The web has no scheduled local notifications: there, this class does
/// nothing.
class ReminderService {
  ReminderService({
    FlutterLocalNotificationsPlugin? plugin,
    @visibleForTesting bool? isSupported,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        isSupported = isSupported ??
            (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS));

  final FlutterLocalNotificationsPlugin _plugin;

  /// Whether this platform can schedule reminders.
  final bool isSupported;

  static const _channelId = 'task_reminders';

  /// Android small icon, `android/app/src/main/res/drawable`.
  static const _androidIcon = 'ic_stat_reminder';

  /// Translated by the caller: the data layer has no text of its own.
  String _channelName = 'Task reminders';
  String _channelDescription = 'Reminders set on your tasks';

  Future<void>? _initialization;
  bool _askedPermission = false;
  String _lastSchedule = '';

  /// Prepares the plugin; [channelName] and [channelDescription] are shown
  /// in the Android notification settings.
  Future<void> initialize({
    required String channelName,
    required String channelDescription,
  }) {
    _channelName = channelName;
    _channelDescription = channelDescription;
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    if (!isSupported) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        // Permission is asked once a task has a reminder, not at launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  /// The tasks that need a notification at [now]: not completed, with a
  /// reminder still to come, soonest first. iOS keeps at most 64 pending
  /// notifications, so only the first [limit] are scheduled.
  @visibleForTesting
  static List<CheckList> upcoming(
    Iterable<CheckList> tasks, {
    required DateTime now,
    int limit = 64,
  }) {
    final upcoming = tasks
        .where((task) =>
            !task.isAllChecked &&
            task.reminderTime != null &&
            task.reminderTime!.isAfter(now))
        .toList()
      ..sort((a, b) => a.reminderTime!.compareTo(b.reminderTime!));
    return upcoming.take(limit).toList();
  }

  /// A stable notification id for a task id (FNV-1a, 31 bits).
  @visibleForTesting
  static int notificationId(String taskId) {
    var hash = 0x811c9dc5;
    for (final unit in taskId.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  /// Schedules the reminders of [tasks] and cancels every other one.
  ///
  /// Errors are only logged: a reminder that cannot be scheduled must not
  /// break the task lists.
  Future<void> syncTasks(Iterable<CheckList> tasks, {DateTime? now}) async {
    if (!isSupported) return;
    try {
      await _initialization;
      final upcoming =
          ReminderService.upcoming(tasks, now: now ?? DateTime.now());
      // The task stream emits on every change; skip identical schedules.
      final schedule = upcoming
          .map((task) =>
              '${task.id}|${task.reminderTime!.millisecondsSinceEpoch}|${task.title}')
          .join('\n');
      if (schedule == _lastSchedule) return;
      _lastSchedule = schedule;

      await _plugin.cancelAllPendingNotifications();
      if (upcoming.isEmpty) return;
      await _requestPermissionOnce();
      final mode = await _androidScheduleMode();
      for (final task in upcoming) {
        await _plugin.zonedSchedule(
          id: notificationId(task.id.toString()),
          title: task.title,
          body: (task.note?.trim().isEmpty ?? true) ? null : task.note!.trim(),
          scheduledDate: tz.TZDateTime.from(task.reminderTime!.toUtc(), tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
              category: AndroidNotificationCategory.reminder,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: mode,
          payload: task.id.toString(),
        );
      }
    } catch (e) {
      _lastSchedule = '';
      debugPrint('Scheduling reminders failed: $e');
    }
  }

  /// Cancels every reminder, e.g. when the user signs out.
  Future<void> cancelAll() async {
    if (!isSupported) return;
    _lastSchedule = '';
    try {
      await _initialization;
      await _plugin.cancelAllPendingNotifications();
    } catch (e) {
      debugPrint('Cancelling reminders failed: $e');
    }
  }

  /// Keeps the reminders of the signed-in user's tasks scheduled: follows
  /// [users] and, for a verified user, the tasks returned by [watchTasks].
  /// Signing out cancels them. Returns the subscription to cancel.
  StreamSubscription<User> follow(
    Stream<User> users,
    Stream<List<CheckList>> Function(User user) watchTasks,
  ) {
    StreamSubscription<List<CheckList>>? tasks;
    String? userId;
    return users.listen((user) {
      final canRead = user.isNotEmpty && !user.needsEmailVerification;
      final id = canRead ? user.id : null;
      if (id == userId) return;
      userId = id;
      tasks?.cancel();
      tasks = null;
      if (!canRead) {
        cancelAll();
        return;
      }
      tasks = watchTasks(user).listen(
        syncTasks,
        onError: (Object e) => debugPrint('Watching tasks for reminders: $e'),
      );
    });
  }

  Future<void> _requestPermissionOnce() async {
    if (_askedPermission) return;
    _askedPermission = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Exact alarms need a permission the user may not have granted (Android
  /// 12+); without it the system may deliver the reminder a few minutes late.
  Future<AndroidScheduleMode> _androidScheduleMode() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final exact = await android?.canScheduleExactNotifications() ?? false;
    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }
}
