import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_widgets.dart';

class SettingsSections {
  static Widget buildAppearanceSection(
    ThemeData theme,
    SettingsController controller,
    ValueNotifier<ThemeMode> themeModeNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsWidgets.buildSectionHeader(theme, 'Appearance', Icons.palette),
        SettingsWidgets.buildSettingsCard(
          theme,
          children: [
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Dark Theme',
              subtitle: 'Toggle between light and dark mode',
              icon: controller.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
              trailing: Switch.adaptive(
                value: controller.isDarkTheme,
                onChanged:
                    (value) =>
                        controller.toggleDarkTheme(value, themeModeNotifier),
                activeColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildSecuritySection(
    BuildContext context,
    ThemeData theme,
    SettingsController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsWidgets.buildSectionHeader(
          theme,
          'Security & Privacy',
          Icons.security,
        ),
        SettingsWidgets.buildSettingsCard(
          theme,
          children: [
            SettingsWidgets.buildModernTile(
              theme,
              title: 'App Lock',
              subtitle: 'Secure your journal with PIN protection',
              icon: Icons.lock,
              trailing: Switch.adaptive(
                value: controller.lockEnabled,
                onChanged: (value) async {
                  if (value) {
                    await controller.enableAppLock(context);
                  } else {
                    final success = await controller.disableAppLock(context);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('App lock not disabled.')),
                      );
                    }
                  }
                },
                activeColor: theme.colorScheme.primary,
              ),
            ),
            if (controller.lockEnabled) ...[
              SettingsWidgets.buildDivider(theme),
              SettingsWidgets.buildModernTile(
                theme,
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face recognition',
                icon: Icons.fingerprint,
                trailing: Switch.adaptive(
                  value: controller.biometricEnabled,
                  onChanged: controller.toggleBiometric,
                  activeColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  static Widget buildDataManagementSection(
    BuildContext context,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsWidgets.buildSectionHeader(
          theme,
          'Data Management',
          Icons.folder,
        ),
        SettingsWidgets.buildSettingsCard(
          theme,
          children: [
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Export Data',
              subtitle: 'Export your journal entries',
              icon: Icons.file_download,
              onTap: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export feature coming soon!'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildAboutSection(
    BuildContext context,
    ThemeData theme,
    SettingsController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsWidgets.buildSectionHeader(theme, 'About', Icons.info),
        SettingsWidgets.buildSettingsCard(
          theme,
          children: [
            SettingsWidgets.buildModernTile(
              theme,
              title: 'App Version',
              subtitle:
                  controller.version.isEmpty
                      ? 'Loading...'
                      : 'Version ${controller.version}',
              icon: Icons.info_outline,
            ),
            SettingsWidgets.buildDivider(theme),
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              icon: Icons.privacy_tip,
              onTap: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy coming soon!'),
                    ),
                  );
                }
              },
            ),
            SettingsWidgets.buildDivider(theme),
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Terms of Service',
              subtitle: 'Terms and conditions',
              icon: Icons.description,
              onTap: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terms of service coming soon!'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
