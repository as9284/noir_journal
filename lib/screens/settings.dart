import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/ui_constants.dart';
import '../utils/settings_prefs.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  const SettingsPage({super.key, required this.themeModeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    final version = await PackageInfo.fromPlatform();
    final isDark = await SettingsPrefs.getDarkTheme();
    setState(() {
      _version = version.version;
      _isDarkTheme = isDark;
    });
  }

  Future<void> _toggleDarkTheme(bool value) async {
    setState(() {
      _isDarkTheme = value;
    });
    await SettingsPrefs.setDarkTheme(value);
    widget.themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
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
          const Divider(endIndent: 15, indent: 15),
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
