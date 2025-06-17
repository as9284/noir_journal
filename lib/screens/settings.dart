import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import '../constants/ui_constants.dart';
import '../utils/notification_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadTheme();
    _loadNotificationSettings();
    NotificationService.initialize();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _loadingNotification = true);
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    final hour = prefs.getInt('notification_hour');
    final minute = prefs.getInt('notification_minute');
    setState(() {
      _notificationsEnabled = enabled;
      _notificationTime =
          (hour != null && minute != null)
              ? TimeOfDay(hour: hour, minute: minute)
              : null;
      _loadingNotification = false;
    });
  }

  Future<void> _toggleDarkTheme(bool value) async {
    setState(() {
      _isDarkTheme = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
    widget.themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleNotifications(bool value) async {
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
                      AppSettings.openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
        );
        await NotificationService.cancelNotifications();
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
          return;
        }
        setState(() => _notificationTime = picked);
        await NotificationService.scheduleDailyNotification(picked);
      } else {
        await NotificationService.scheduleDailyNotification(_notificationTime!);
      }
      if (!mounted) return;
      setState(() => _notificationsEnabled = true);
    } else {
      await NotificationService.cancelNotifications();
      if (!mounted) return;
      setState(() => _notificationsEnabled = false);
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
      if (!mounted) return;
      setState(() => _notificationsEnabled = true);
    }
  }

  Future<void> _confirmDeleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete All Data?'),
            content: const Text(
              'Are you sure you want to delete all your data? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All data deleted.')));
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
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data'),
            onTap: _confirmDeleteData,
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
