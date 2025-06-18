import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/diary_entry_search_delegate.dart';

class AppDrawer extends StatelessWidget {
  final List<DiaryEntry> entries;
  final void Function(String query) onSearchTitle;
  final void Function(DateTime date) onSearchDate;
  final VoidCallback onSettings;
  final String version;

  const AppDrawer({
    super.key,
    required this.entries,
    required this.onSearchTitle,
    required this.onSearchDate,
    required this.onSettings,
    required this.version,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: Text(
              'Noir Journal',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DrawerTile(
            icon: Icons.search,
            label: 'Search by Title',
            onTap: () async {
              Navigator.pop(context);
              final query = await showSearch<String?>(
                context: context,
                delegate: DiaryEntrySearchDelegate(entries),
              );
              if (query != null) {
                onSearchTitle(query);
              }
            },
          ),
          _DrawerTile(
            icon: Icons.calendar_today,
            label: 'Search by Date',
            onTap: () async {
              Navigator.pop(context);
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                helpText: 'Search entries by date',
              );
              if (picked != null) {
                onSearchDate(picked);
              }
            },
          ),
          _DrawerTile(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Navigator.pop(context);
              onSettings();
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 16, top: 8),
            child: Text(
              version,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 18),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
