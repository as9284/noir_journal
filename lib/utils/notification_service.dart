import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class NotificationService {
  static const int dailyNotificationId = 1;
  static const String dailyChannelKey = 'daily_journal_reminder';
  static Future<void> initialize() async {
    try {
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

      developer.log('NotificationService initialized successfully');
    } catch (e) {
      developer.log('Error initializing notifications: $e');
    }
  }

  static Future<bool> requestPermission() async {
    try {
      var isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      developer.log('Notification permission granted: $isAllowed');
      return isAllowed;
    } catch (e) {
      developer.log('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<void> scheduleDailyNotification(
    TimeOfDay time, {
    BuildContext? context,
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        developer.log(
          'Notification permission not granted, cannot schedule notification',
        );
        return;
      }

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
      developer.log(
        'Daily notification scheduled successfully for ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      developer.log('Error scheduling daily notification: $e');
    }
  }

  static Future<void> cancelDailyNotification() async {
    try {
      await AwesomeNotifications().cancel(dailyNotificationId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
      developer.log('Daily notification cancelled successfully');
    } catch (e) {
      developer.log('Error cancelling daily notification: $e');
    }
  }
}
