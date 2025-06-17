import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const int dailyNotificationId = 1;
  static const String dailyChannelKey = 'daily_journal_reminder';

  static Future<void> initialize() async {
    await AwesomeNotifications()
        .initialize('resource://drawable/ic_stat_notification_icon', [
          NotificationChannel(
            channelKey: dailyChannelKey,
            channelName: 'Daily Journal Reminder',
            channelDescription: 'Reminds you to write in your journal',
            defaultColor: Colors.deepPurple,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            icon: 'resource://drawable/ic_stat_notification_icon',
          ),
        ], debug: false);
  }

  static Future<bool> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  static Future<void> scheduleDailyNotification(
    TimeOfDay time, {
    BuildContext? context,
  }) async {
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
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: dailyNotificationId,
        channelKey: dailyChannelKey,
        title: 'Daily Journal Reminder',
        body: 'Don\'t forget to write your thoughts today!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: firstNotificationTime.hour,
        minute: firstNotificationTime.minute,
        second: 0,
        repeats: true,
        preciseAlarm: true,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
    await prefs.setBool('notifications_enabled', true);
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);
  }

  static Future<TimeOfDay?> getScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour');
    final minute = prefs.getInt('notification_minute');
    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }
}
