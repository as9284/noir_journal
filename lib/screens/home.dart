import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noir_journal/screens/settings.dart';
import 'package:noir_journal/main.dart';
import 'package:noir_journal/screens/entry_page.dart';
import 'package:noir_journal/screens/create_entry_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/widgets/diary_entry_grouped_list.dart';
import '../constants/ui_constants.dart';
import 'package:noir_journal/widgets/app_drawer.dart';

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
    await _loadEntries();
  }

  Future<void> _onAddEntryPressed(BuildContext _) async {
    final result = await Navigator.push<DiaryEntry>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEntryPage()),
    );

    if (result != null) {
      setState(() {
        _entries.insert(0, result);
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
        version: "",
      ),
      appBar: AppBar(
        title: Text(
          _isSelecting ? '${_selectedEntries.length} selected' : 'Your Journal',
        ),
        titleSpacing: 0,
        centerTitle: !(_searchQuery.isNotEmpty || _searchDate != null),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
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
      body:
          _entries.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: DiaryEntryGroupedList(
                  entries: _filteredEntries,
                  onTap: _onEntryTap,
                  onLongPress: _onEntryLongPress,
                  selectedEntries: _selectedEntries,
                ),
              ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withAlpha(25),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(51),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.book_outlined,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No diary entries yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your journaling journey by\ncreating your first entry',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return _isSelecting
        ? FloatingActionButton.extended(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder:
                  (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Delete Entries?'),
                    content: Text(
                      'Are you sure you want to delete ${_selectedEntries.length} selected entr${_selectedEntries.length == 1 ? 'y' : 'ies'}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.delete),
          label: Text('Delete (${_selectedEntries.length})'),
        )
        : FloatingActionButton(
          onPressed: () => _onAddEntryPressed(context),
          tooltip: 'Add Entry',
          child: const Icon(Icons.add),
        );
  }
}
