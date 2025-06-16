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
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: Text(
              'Noir Journal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search by Title'),
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
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Search by Date'),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
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
