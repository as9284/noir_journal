import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_widgets.dart';
import '../theme/app_theme.dart';

class SettingsSections {
  static Widget buildAppearanceSection(
    BuildContext context,
    ThemeData theme,
    SettingsController controller,
    ValueNotifier<ThemeData> themeNotifier,
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
                    (value) => controller.toggleDarkTheme(value, themeNotifier),
                activeColor: theme.colorScheme.primary,
              ),
            ),
            SettingsWidgets.buildDivider(theme),
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Color Theme',
              subtitle: colorThemes[controller.selectedColorTheme]!.name,
              icon: Icons.color_lens,
              onTap:
                  () =>
                      _showColorThemeDialog(context, controller, themeNotifier),
            ),
          ],
        ),
      ],
    );
  }

  static void _showColorThemeDialog(
    BuildContext context,
    SettingsController controller,
    ValueNotifier<ThemeData> themeNotifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Color Theme'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppColorTheme.values.length,
                itemBuilder: (context, index) {
                  final colorTheme = AppColorTheme.values[index];
                  final colorData = colorThemes[colorTheme]!;
                  final isSelected =
                      controller.selectedColorTheme == colorTheme;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            controller.isDarkTheme
                                ? colorData.darkPrimary
                                : colorData.lightPrimary,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            isSelected
                                ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                                : null,
                      ),
                      child:
                          isSelected
                              ? Icon(
                                Icons.check,
                                color: colorData.lightSecondary,
                                size: 20,
                              )
                              : null,
                    ),
                    title: Text(colorData.name),
                    onTap: () {
                      controller.changeColorTheme(colorTheme, themeNotifier);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
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
    SettingsController controller,
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
              subtitle: 'Share your journal entries as backup file',
              icon: Icons.file_download,
              onTap: () => controller.exportData(context),
            ),
            SettingsWidgets.buildDivider(theme),
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Import Data',
              subtitle: 'Restore journal entries from backup file',
              icon: Icons.file_upload,
              onTap: () => controller.importData(context),
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
