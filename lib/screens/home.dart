import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noir_journal/screens/settings.dart';
import 'package:noir_journal/main.dart';
import 'package:noir_journal/screens/entry_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/widgets/diary_entry_grouped_list.dart';
import '../constants/ui_constants.dart';
import '../widgets/icon_picker_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DiaryEntry> _entries = [];
  Set<DiaryEntry> _selectedEntries = {};
  bool get _isSelecting => _selectedEntries.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('diary_entries') ?? [];
    setState(() {
      _entries =
          entriesJson.map((e) {
            try {
              final decoded = jsonDecode(e);
              if (decoded is Map<String, dynamic>) {
                return DiaryEntry.fromJson(decoded);
              }
            } catch (_) {}
            // Legacy string entry
            return DiaryEntry(
              title: e,
              createdAt: DateTime.now(),
              iconIndex: 0,
            );
          }).toList();
    });
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = _entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('diary_entries', entriesJson);
  }

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

  void _onAddEntryPressed(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Diary Entry'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      final descController = TextEditingController();
      final desc = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Describe your day'),
              content: TextField(
                controller: descController,
                autofocus: true,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.pop(context, descController.text.trim()),
                  child: const Text('Save'),
                ),
              ],
            ),
      );
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: 'Select entry date (for testing)',
      );
      final iconIndex = await showIconPickerDialog(context);
      setState(() {
        _entries.insert(
          0,
          DiaryEntry(
            title: result,
            createdAt: pickedDate ?? DateTime.now(),
            description: desc ?? '',
            iconIndex: iconIndex ?? 0,
          ),
        );
      });
      await _saveEntries();
    }
  }

  void _onEntryTap(DiaryEntry entry) {
    if (_isSelecting) {
      setState(() {
        if (_selectedEntries.contains(entry)) {
          _selectedEntries.remove(entry);
        } else {
          _selectedEntries.add(entry);
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => EntryPage(
                entry: entry,
                onUpdate: (updated) async {
                  setState(() {
                    final idx = _entries.indexWhere(
                      (e) =>
                          e.title == entry.title &&
                          e.createdAt == entry.createdAt,
                    );
                    if (idx != -1) _entries[idx] = updated;
                  });
                  await _saveEntries();
                },
              ),
        ),
      );
    }
  }

  void _onEntryLongPress(DiaryEntry entry) {
    setState(() {
      _selectedEntries.add(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelecting ? '${_selectedEntries.length} selected' : 'Noir Journal',
        ),
        titleSpacing: DiaryPaddings.horizontal,
        actions: [
          if (_isSelecting)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: () {
                setState(() {
                  _selectedEntries.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _onSettingsPressed(context),
              tooltip: 'Settings',
            ),
          const SizedBox(width: DiaryPaddings.horizontal),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _entries.isEmpty
                ? Center(
                  child: Text(
                    'No diary entries yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
                : DiaryEntryGroupedList(
                  entries: _entries,
                  onTap: _onEntryTap,
                  onLongPress: _onEntryLongPress,
                  selectedEntries: _selectedEntries,
                ),
      ),
      floatingActionButton:
          _isSelecting
              ? FloatingActionButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Entries?'),
                          content: Text(
                            'Are you sure you want to delete ${_selectedEntries.length} selected entries?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                  if (confirmed == true) {
                    setState(() {
                      _entries.removeWhere((e) => _selectedEntries.contains(e));
                      _selectedEntries.clear();
                    });
                    await _saveEntries();
                  }
                },
                tooltip: 'Delete',
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete),
              )
              : FloatingActionButton(
                onPressed: () => _onAddEntryPressed(context),
                tooltip: 'Add Entry',
                child: const Icon(Icons.add),
              ),
    );
  }
}
