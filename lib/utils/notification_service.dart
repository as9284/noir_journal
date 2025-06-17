import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const int dailyNotificationId = 1;
  static const String dailyChannelKey = 'scheduled';

  static Future<void> initialize() async {
    await AwesomeNotifications()
        .initialize('resource://drawable/ic_stat_notification_icon', [
          NotificationChannel(
            channelKey: dailyChannelKey,
            channelName: 'Daily Journal Reminder',
            channelDescription: 'Reminds you to write in your journal',
            defaultColor: Colors.black,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            icon: 'resource://drawable/ic_stat_notification_icon',
            criticalAlerts: false,
            playSound: true,
            enableVibration: true,
          ),
        ], debug: false);
  }

  static Future<bool> requestPermission() async {
    var isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  static Future<void> scheduleDailyNotification(TimeOfDay time) async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final firstNotificationTime =
        scheduledTime.isAfter(now)
            ? scheduledTime
            : scheduledTime.add(const Duration(days: 1));
    await AwesomeNotifications().cancel(dailyNotificationId);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: dailyNotificationId,
        channelKey: dailyChannelKey,
        title: 'Daily Journal Reminder',
        body: 'Don\'t forget to write your thoughts today!',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        hour: firstNotificationTime.hour,
        minute: firstNotificationTime.minute,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
  }

  static Future<void> cancelDailyNotification() async {
    await AwesomeNotifications().cancel(dailyNotificationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);
  }
}
