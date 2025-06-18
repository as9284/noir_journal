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
import 'package:noir_journal/widgets/app_drawer.dart';
import 'package:noir_journal/utils/entry_dialogs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DiaryEntry> _entries = [];
  final Set<DiaryEntry> _selectedEntries = {};
  bool get _isSelecting => _selectedEntries.isNotEmpty;
  String _searchQuery = '';
  DateTime? _searchDate;

  List<DiaryEntry> get _filteredEntries {
    var filtered = _entries;
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (e) =>
                    e.title.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }
    if (_searchDate != null) {
      filtered =
          filtered
              .where(
                (e) =>
                    e.createdAt.year == _searchDate!.year &&
                    e.createdAt.month == _searchDate!.month &&
                    e.createdAt.day == _searchDate!.day,
              )
              .toList();
    }
    return filtered;
  }

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

  void _onSettingsPressed(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SettingsPage(themeModeNotifier: globalThemeModeNotifier!),
      ),
    );
    // Refresh entries when returning from settings (in case data was imported)
    await _loadEntries();
  }

  Future<void> _onAddEntryPressed(BuildContext _) async {
    final result = await showTitleDialog(context);
    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      final desc = await showDescriptionDialog(context);
      if (!mounted) return;
      final iconIndex = await showIconPickerDialog(context);
      if (!mounted) return;
      setState(() {
        _entries.insert(
          0,
          DiaryEntry(
            title: result,
            createdAt: DateTime.now(),
            description: desc ?? '',
            iconIndex: iconIndex ?? 0,
          ),
        );
      });
      await _saveEntries();
    }
  }

  void _onEntryTap(DiaryEntry entry) async {
    if (_isSelecting) {
      setState(() {
        if (_selectedEntries.contains(entry)) {
          _selectedEntries.remove(entry);
        } else {
          _selectedEntries.add(entry);
        }
      });
    } else {
      final result = await Navigator.push(
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
      if (result == 'deleted') {
        await _loadEntries();
      }
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
      drawer: AppDrawer(
        entries: _entries,
        onSearchTitle: (query) {
          setState(() {
            _searchQuery = query;
            _searchDate = null;
          });
        },
        onSearchDate: (picked) {
          setState(() {
            _searchDate = picked;
            _searchQuery = '';
          });
        },
        onSettings: () => _onSettingsPressed(context),
        version: 'v1.0.0',
      ),
      appBar: AppBar(
        title: Text(
          _isSelecting
              ? '${_selectedEntries.length} selected'
              : 'Your Journal',
        ),
        titleSpacing: 0,
        centerTitle: !(_searchQuery.isNotEmpty || _searchDate != null),
        actions: [
          if (_searchQuery.isNotEmpty || _searchDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Search',
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchDate = null;
                });
              },
            ),
          if (_isSelecting)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: () {
                setState(() {
                  _selectedEntries.clear();
                });
              },
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
                  entries: _filteredEntries,
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
                        (dialogContext) => AlertDialog(
                          title: const Text('Delete Entries?'),
                          content: Text(
                            'Are you sure you want to delete ${_selectedEntries.length} selected entr${_selectedEntries.length == 1 ? 'y' : 'ies'}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pop(dialogContext, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                  if (!mounted) return;
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
