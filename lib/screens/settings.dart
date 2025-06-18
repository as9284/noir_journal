import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/settings_sections.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const SettingsPage({super.key, required this.themeModeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsWidgets.buildProfileSection(theme),
                const SizedBox(height: 24),

                SettingsSections.buildAppearanceSection(
                  theme,
                  _controller,
                  widget.themeModeNotifier,
                ),
                const SizedBox(height: 20),

                SettingsSections.buildSecuritySection(
                  context,
                  theme,
                  _controller,
                ),
                const SizedBox(height: 20),

                SettingsSections.buildDataManagementSection(
                  context,
                  theme,
                  _controller,
                ),
                const SizedBox(height: 20),

                SettingsSections.buildAboutSection(context, theme, _controller),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
