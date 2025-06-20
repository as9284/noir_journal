import 'package:flutter/material.dart';
import 'package:noir_journal/screens/settings.dart';
import 'package:noir_journal/main.dart';
import 'package:noir_journal/screens/entry_page.dart';
import 'package:noir_journal/screens/create_entry_page.dart';
import 'package:noir_journal/services/secure_storage_service.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/widgets/diary_entry_grouped_list.dart';
import '../constants/ui_constants.dart';
import 'package:noir_journal/widgets/app_drawer.dart';
import '../utils/dialog_utils.dart';
import '../utils/app_lock_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DiaryEntry> _entries = [];
  final Set<DiaryEntry> _selectedEntries = {};
  bool get _isSelecting => _selectedEntries.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadEntries();

    // Listen to global data refresh notifier
    globalDataRefreshNotifier.addListener(_onDataRefresh);
  }

  @override
  void dispose() {
    globalDataRefreshNotifier.removeListener(_onDataRefresh);
    super.dispose();
  }

  void _onDataRefresh() {
    if (mounted) {
      // Force a rebuild by updating the state even if entries are empty
      setState(() {
        // Clear current entries first to ensure proper state reset
        _entries.clear();
        _selectedEntries.clear();
      });
      // Then load entries
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    try {
      final loadedEntries = await SecureStorageService.loadEntries();

      if (mounted) {
        setState(() {
          _entries = loadedEntries;
        });
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      if (mounted) {
        setState(() {
          _entries = [];
        });
      }
    }
  }

  Future<void> _saveEntries() async {
    await SecureStorageService.saveEntries(_entries);
  }

  void _onSettingsPressed(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(themeNotifier: globalThemeNotifier!),
      ),
    );
    // Always reload entries when returning from settings
    // This ensures we get any newly imported entries
    if (mounted) {
      await _loadEntries();
      // Refresh app lock state to ensure synchronization
      await _refreshAppLockState();
    }
  }

  /// Refresh the app lock state to ensure synchronization
  Future<void> _refreshAppLockState() async {
    try {
      // Don't refresh app lock state if a file operation is in progress
      // This prevents unwanted lock triggers after operations like import/export/wipe
      if (globalFileOperationInProgress.value) {
        return;
      }

      final lockEnabled = await AppLockService.isLockEnabled();
      globalAppLockNotifier.value = lockEnabled;
    } catch (e) {
      // Silently handle refresh errors
    }
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

  String _getAppBarTitle() {
    if (_isSelecting) {
      return '${_selectedEntries.length} selected';
    }

    return 'Your Journal';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(
        entries: _entries,
        onEntryUpdate: (updatedEntry) {
          setState(() {
            final index = _entries.indexWhere(
              (e) =>
                  e.title == updatedEntry.title &&
                  e.createdAt == updatedEntry.createdAt,
            );
            if (index != -1) {
              _entries[index] = updatedEntry;
            }
          });
          _saveEntries();
        },
        onSettings: () => _onSettingsPressed(context),
      ),
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        titleSpacing: 0,
        centerTitle: !_isSelecting,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
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
                  entries: _entries,
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
            final confirmed = await DialogUtils.showConfirmationDialog(
              context: context,
              title: 'Delete Entries?',
              message:
                  'Are you sure you want to delete ${_selectedEntries.length} selected entr${_selectedEntries.length == 1 ? 'y' : 'ies'}?',
              confirmText: 'Delete',
              isDestructive: true,
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
