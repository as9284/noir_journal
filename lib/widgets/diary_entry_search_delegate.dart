import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class DiaryEntrySearchDelegate extends SearchDelegate<String?> {
  final List<DiaryEntry> entries;
  DiaryEntrySearchDelegate(this.entries);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results =
        entries
            .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
    if (results.isEmpty) {
      return Center(child: Text('No entries found.'));
    }
    return ListView(
      children:
          results
              .map(
                (e) => ListTile(
                  title: Text(e.title),
                  subtitle: Text(
                    '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')}',
                  ),
                  onTap: () => close(context, e.title),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        entries
            .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return ListView(
      children:
          suggestions
              .map(
                (e) => ListTile(
                  title: Text(e.title),
                  subtitle: Text(
                    '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')}',
                  ),
                  onTap: () => close(context, e.title),
                ),
              )
              .toList(),
    );
  }
}
