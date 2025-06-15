import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/ui_constants.dart';

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

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadTheme();
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

  Future<void> _toggleDarkTheme(bool value) async {
    setState(() {
      _isDarkTheme = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
    widget.themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
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
    if (confirmed == true) {
      if (!mounted) return;
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
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: const Icon(Icons.notifications),
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
