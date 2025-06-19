import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_widgets.dart';
import '../theme/app_theme.dart';
import '../lock/app_lock_manager.dart';
import '../main.dart';

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
  ) async {
    // Check app lock before showing dialog
    final canProceed = await _checkAppLockBeforeAction(context);
    if (!canProceed || !context.mounted) return;

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
          'Data Management (Encrypted)',
          Icons.security,
        ),
        SettingsWidgets.buildSettingsCard(
          theme,
          children: [
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Export Encrypted Backup',
              subtitle:
                  'Create a secure, password-protected backup file of all your journal entries that can be safely shared or stored',
              icon: Icons.file_upload,
              onTap: () => controller.exportData(context),
            ),
            SettingsWidgets.buildDivider(theme),
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Import Encrypted Backup',
              subtitle:
                  'Restore journal entries from a password-protected backup file created by this app',
              icon: Icons.file_download,
              onTap: () => controller.importData(context),
            ),
            SettingsWidgets.buildDivider(theme),
            SettingsWidgets.buildModernTile(
              theme,
              title: 'Delete All Data',
              subtitle:
                  'Permanently remove all journal entries, settings, and encryption keys from this device',
              icon: Icons.delete_forever,
              onTap: () => _showDeleteAllDataDialog(context, controller),
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

  static void _showDeleteAllDataDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    // Check app lock before showing sensitive dialog
    final canProceed = await _checkAppLockBeforeAction(context);
    if (!canProceed || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _DeleteAllDataDialog(controller: controller),
    );
  }

  /// Helper function to check app lock before executing sensitive operations
  static Future<bool> _checkAppLockBeforeAction(BuildContext context) async {
    if (!globalAppLockNotifier.value) {
      return true; // No lock enabled, proceed
    }

    return await AppLockManager.checkAndUnlock(context);
  }
}

class _DeleteAllDataDialog extends StatefulWidget {
  final SettingsController controller;

  const _DeleteAllDataDialog({required this.controller});

  @override
  State<_DeleteAllDataDialog> createState() => _DeleteAllDataDialogState();
}

class _DeleteAllDataDialogState extends State<_DeleteAllDataDialog> {
  late TextEditingController _confirmationController;

  @override
  void initState() {
    super.initState();
    _confirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning, color: theme.colorScheme.error, size: 24),
          const SizedBox(width: 12),
          const Text('Delete All Data'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This action will permanently delete all your journal entries and cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'To confirm, type "Delete my data" below:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Delete my data',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed:
              _confirmationController.text.trim() == 'Delete my data'
                  ? () {
                    Navigator.of(context).pop();
                    _showFinalDeleteConfirmation(context, widget.controller);
                  }
                  : null,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  void _showFinalDeleteConfirmation(
    BuildContext context,
    SettingsController controller,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Final Confirmation',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            content: const Text(
              'Are you absolutely sure you want to delete all your data? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.deleteAllData(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('Delete Everything'),
              ),
            ],
          ),
    );
  }
}
