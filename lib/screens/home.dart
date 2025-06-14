import 'package:flutter/material.dart';
import 'package:noir_journal/screens/settings.dart';
import 'package:noir_journal/main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onSettingsPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SettingsPage(themeModeNotifier: globalThemeModeNotifier!),
      ),
    );
  }

  void _onAddEntryPressed(BuildContext context) {
    // TODO: Open add diary entry dialog or page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noir Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _onSettingsPressed(context),
            tooltip: 'Settings',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Placeholder for diary entries list
          child: Text(
            'No diary entries yet.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddEntryPressed(context),
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
