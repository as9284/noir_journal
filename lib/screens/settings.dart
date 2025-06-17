import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/ui_constants.dart';
import '../utils/notification_service.dart';
import '../utils/settings_prefs.dart';
import '../widgets/user_name_dialog.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  const SettingsPage({super.key, required this.themeModeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;
  String _version = '';
  bool _notificationsEnabled = false;
  TimeOfDay? _notificationTime;
  bool _loadingNotification = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
    NotificationService.initialize();
  }

  Future<void> _loadAllSettings() async {
    final version = await PackageInfo.fromPlatform();
    final isDark = await SettingsPrefs.getDarkTheme();
    final notifEnabled = await SettingsPrefs.getNotificationsEnabled();
    final notifTime = await SettingsPrefs.getNotificationTime();
    final userName = await SettingsPrefs.getUserName();
    setState(() {
      _version = version.version;
      _isDarkTheme = isDark;
      _notificationsEnabled = notifEnabled;
      _notificationTime = notifTime;
      _userName = userName;
      _loadingNotification = false;
    });
  }

  Future<void> _toggleDarkTheme(bool value) async {
    setState(() {
      _isDarkTheme = value;
    });
    await SettingsPrefs.setDarkTheme(value);
    widget.themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _loadingNotification = true);
    if (value) {
      if (!mounted) return;
      final granted = await NotificationService.requestPermission();
      if (!mounted) return;
      if (!granted) {
        setState(() => _notificationsEnabled = false);
        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Enable Notifications'),
                content: const Text(
                  'Please enable notifications for Noir Journal in your system settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await openAppSettings();
                      final granted =
                          await NotificationService.requestPermission();
                      if (!granted) {
                        setState(() => _notificationsEnabled = false);
                      } else {
                        setState(() => _notificationsEnabled = true);
                      }
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
        );
        await NotificationService.cancelNotifications();
        setState(() => _loadingNotification = false);
        return;
      }
      bool alarmGranted = true;
      if (Platform.isAndroid) {
        final status = await Permission.scheduleExactAlarm.status;
        if (!status.isGranted) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Allow Alarms & Reminders'),
                  content: const Text(
                    'To ensure notifications work reliably, please enable "Alarms & Reminders" permission in the app settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx, true);
                        await openAppSettings();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
          );
          if (confirmed != true) {
            setState(() => _notificationsEnabled = false);
            await NotificationService.cancelNotifications();
            setState(() => _loadingNotification = false);
            return;
          }
          final alarmStatus = await Permission.scheduleExactAlarm.request();
          alarmGranted = alarmStatus.isGranted;
        }
      }
      if (!alarmGranted) {
        setState(() => _notificationsEnabled = false);
        await NotificationService.cancelNotifications();
        await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Alarms & Reminders permission is required for notifications to work.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        setState(() => _loadingNotification = false);
        return;
      }
      if (_notificationTime == null) {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (!mounted) return;
        if (picked == null) {
          setState(() => _notificationsEnabled = false);
          await NotificationService.cancelNotifications();
          setState(() => _loadingNotification = false);
          return;
        }
        setState(() => _notificationTime = picked);
        await NotificationService.scheduleDailyNotification(picked);
        await SettingsPrefs.setNotificationTime(picked);
      } else {
        await NotificationService.scheduleDailyNotification(_notificationTime!);
      }
      setState(() {
        _notificationsEnabled = true;
        _loadingNotification = false;
      });
      await SettingsPrefs.setNotificationsEnabled(true);
    } else {
      await NotificationService.cancelNotifications();
      setState(() {
        _notificationsEnabled = false;
        _loadingNotification = false;
      });
      await SettingsPrefs.setNotificationsEnabled(false);
    }
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? TimeOfDay.now(),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _notificationTime = picked);
      await NotificationService.scheduleDailyNotification(picked);
      setState(() => _notificationsEnabled = true);
      await SettingsPrefs.setNotificationTime(picked);
    }
  }

  Future<void> _changeUserName(BuildContext context) async {
    final result = await showUserNameDialog(context, initialName: _userName);
    if (result != null && result.trim().isNotEmpty) {
      await SettingsPrefs.setUserName(result.trim());
      setState(() {
        _userName = result.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        titleSpacing: DiaryPaddings.horizontal,
        actions: const [SizedBox(width: DiaryPaddings.horizontal)],
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: _isDarkTheme,
            onChanged: _toggleDarkTheme,
            secondary: const Icon(Icons.dark_mode),
          ),
          Column(
            children: [
              SwitchListTile(
                title: const Text('Daily Journal Notification'),
                value: _notificationsEnabled,
                onChanged: _loadingNotification ? null : _toggleNotifications,
                secondary: const Icon(Icons.notifications_active),
              ),
              if (_notificationsEnabled && _notificationTime != null)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Notification Time'),
                  subtitle: Text(_notificationTime!.format(context)),
                  trailing: TextButton(
                    onPressed: _pickNotificationTime,
                    child: const Text('Change'),
                  ),
                ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Your Name'),
            subtitle: Text(_userName ?? 'Not set'),
            trailing: TextButton(
              onPressed: () => _changeUserName(context),
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(_version.isEmpty ? 'Loading...' : _version),
          ),
        ],
      ),
    );
  }
}
