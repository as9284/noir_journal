import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/services/secure_storage_service.dart';
import '../utils/dialog_utils.dart';
import '../models/mood.dart';
import '../widgets/entry_title_section.dart';
import '../widgets/entry_description_section.dart';
import '../widgets/entry_icon_section.dart';
import '../widgets/entry_mood_section.dart';
import '../widgets/entry_metadata_section.dart';

class EntryPage extends StatefulWidget {
  final DiaryEntry entry;
  final void Function(DiaryEntry updated)? onUpdate;
  const EntryPage({super.key, required this.entry, this.onUpdate});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final ScrollController _scrollController;
  late int _selectedIconIndex;
  late Mood? _selectedMood;
  late DiaryEntry _currentEntry;
  bool _isEditing = false;
  bool _hasChanges = false;
  double _baseFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
    _titleController = TextEditingController(text: _currentEntry.title);
    _descriptionController = TextEditingController(
      text: _currentEntry.description,
    );
    _scrollController = ScrollController();
    _selectedIconIndex = _currentEntry.iconIndex;
    _selectedMood = _currentEntry.mood;

    _titleController.addListener(_onTextChanged);
    _descriptionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasChanges =
        _titleController.text != _currentEntry.title ||
        _descriptionController.text != _currentEntry.description ||
        _selectedIconIndex != _currentEntry.iconIndex ||
        _selectedMood != _currentEntry.mood;

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _titleController.text = _currentEntry.title;
      _descriptionController.text = _currentEntry.description;
      _selectedIconIndex = _currentEntry.iconIndex;
      _selectedMood = _currentEntry.mood;
      _hasChanges = false;
    });
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }
    final updatedEntry = DiaryEntry(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: _currentEntry.createdAt,
      iconIndex: _selectedIconIndex,
      mood: _selectedMood,
    );

    widget.onUpdate?.call(updatedEntry);
    await _saveToPreferences(updatedEntry);

    setState(() {
      _currentEntry = updatedEntry; // Update the current entry
      _isEditing = false;
      _hasChanges = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveToPreferences(DiaryEntry updatedEntry) async {
    try {
      final allEntries = await SecureStorageService.loadEntries();
      final updatedEntries =
          allEntries.map((entry) {
            if (entry.title == _currentEntry.title &&
                entry.createdAt == _currentEntry.createdAt) {
              return updatedEntry;
            }
            return entry;
          }).toList();

      await SecureStorageService.saveEntries(updatedEntries);
    } catch (e) {
      debugPrint('Error updating entry: $e');
    }
  }

  Future<void> _deleteEntry() async {
    final confirmed = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Delete Entry?',
      message:
          'Are you sure you want to delete this entry? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) {
      try {
        final allEntries = await SecureStorageService.loadEntries();
        final filteredEntries =
            allEntries.where((entry) {
              return !(entry.title == _currentEntry.title &&
                  entry.createdAt == _currentEntry.createdAt);
            }).toList();
        await SecureStorageService.saveEntries(filteredEntries);

        if (mounted) {
          Navigator.of(context).pop('deleted');
        }
      } catch (e) {
        debugPrint('Error deleting entry: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Entry' : '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.9),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.8),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isEditing) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    onPressed: _startEditing,
                    tooltip: 'Edit Entry',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 4),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    onPressed: _deleteEntry,
                    tooltip: 'Delete Entry',
                    colorScheme: colorScheme,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: _hasChanges ? _saveChanges : null,
                icon: Icon(
                  Icons.check,
                  size: 18,
                  color:
                      _hasChanges
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                label: Text(
                  'Save',
                  style: TextStyle(
                    color:
                        _hasChanges
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor:
                      _hasChanges
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: _isEditing ? _buildEditingView(theme) : _buildReadingView(theme),
      floatingActionButton:
          _isEditing
              ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _cancelEditing,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface.withValues(alpha: 0.8),
                  elevation: 0,
                  child: const Icon(Icons.close, size: 22),
                ),
              )
              : SpeedDial(
                icon: Icons.tune,
                activeIcon: Icons.close,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                activeForegroundColor: colorScheme.onPrimaryContainer,
                activeBackgroundColor: colorScheme.primaryContainer,
                buttonSize: const Size(56, 56),
                animationCurve: Curves.elasticOut,
                animationDuration: const Duration(milliseconds: 300),
                overlayColor: colorScheme.surface.withValues(alpha: 0.8),
                overlayOpacity: 0.8,
                spacing: 12,
                spaceBetweenChildren: 8,
                elevation: 0,
                shape: const CircleBorder(),
                closeManually: true,
                children: [
                  _buildSpeedDialChild(
                    icon: Icons.keyboard_arrow_up_rounded,
                    label: 'Scroll to top',
                    onTap: _scrollToTop,
                    colorScheme: colorScheme,
                  ),
                  _buildSpeedDialChild(
                    icon: Icons.keyboard_arrow_down_rounded,
                    label: 'Scroll to bottom',
                    onTap: _scrollToBottom,
                    colorScheme: colorScheme,
                  ),
                  _buildSpeedDialChild(
                    icon: Icons.text_increase_rounded,
                    label: 'Increase font size',
                    onTap: _increaseFontSize,
                    colorScheme: colorScheme,
                  ),
                  _buildSpeedDialChild(
                    icon: Icons.text_decrease_rounded,
                    label: 'Decrease font size',
                    onTap: _decreaseFontSize,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required ColorScheme colorScheme,
    bool isDestructive = false,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color:
            isDestructive
                ? colorScheme.error.withValues(alpha: 0.8)
                : colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  SpeedDialChild _buildSpeedDialChild({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return SpeedDialChild(
      child: Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.8)),
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      foregroundColor: colorScheme.onSurface,
      label: label,
      labelStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelBackgroundColor: colorScheme.surface.withValues(alpha: 0.9),
      onTap: onTap,
      shape: const CircleBorder(),
      elevation: 2,
    );
  }

  Widget _buildEditingView(ThemeData theme) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            EntryTitleSection(
              titleController: _titleController,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 24),
            EntryDescriptionSection(
              descriptionController: _descriptionController,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 24),
            EntryMoodSection(
              selectedMood: _selectedMood,
              onMoodChanged: (mood) {
                setState(() {
                  _selectedMood = mood;
                  _onTextChanged();
                });
              },
            ),
            const SizedBox(height: 24),
            EntryIconSection(
              selectedIconIndex: _selectedIconIndex,
              onIconChanged: (index) {
                setState(() {
                  _selectedIconIndex = index;
                  _onTextChanged();
                });
              },
            ),
            const SizedBox(height: 80), // Extra space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildReadingView(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: BoxDecoration(
                  gradient:
                      isDark
                          ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colorScheme.surface,
                              colorScheme.surface.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 1.0],
                          )
                          : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Premium content container that expands to fill available space
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.4)
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border:
                                isDark
                                    ? Border.all(
                                      color: colorScheme.outline.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 1,
                                    )
                                    : null,
                            boxShadow:
                                isDark
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                        spreadRadius: -4,
                                      ),
                                    ]
                                    : [
                                      BoxShadow(
                                        color: colorScheme.shadow.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                        spreadRadius: -4,
                                      ),
                                      BoxShadow(
                                        color: colorScheme.shadow.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                        spreadRadius: 0,
                                      ),
                                    ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Premium title with enhanced styling
                              Text(
                                _titleController.text,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                  height: 1.3,
                                  letterSpacing: -0.5,
                                  fontSize: _baseFontSize + 8,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Enhanced description with better typography - expands to fill space
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    _descriptionController.text.isEmpty
                                        ? 'No description added yet.\n\nTap the edit button to add your thoughts, experiences, or memories to this entry.'
                                        : _descriptionController.text,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          _descriptionController.text.isEmpty
                                              ? colorScheme.onSurface
                                                  .withValues(alpha: 0.5)
                                              : colorScheme.onSurface
                                                  .withValues(alpha: 0.9),
                                      fontStyle:
                                          _descriptionController.text.isEmpty
                                              ? FontStyle.italic
                                              : null,
                                      height: 1.8,
                                      fontSize: _baseFontSize,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Fixed gap between content and metadata
                      const SizedBox(
                        height: 16,
                      ), // Premium metadata section with clean styling - always at bottom
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.6)
                                  : colorScheme.surfaceContainerLow.withValues(
                                    alpha: 0.8,
                                  ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isDark
                                    ? colorScheme.outline.withValues(
                                      alpha: 0.15,
                                    )
                                    : colorScheme.outline.withValues(
                                      alpha: 0.1,
                                    ),
                            width: 1,
                          ),
                        ),
                        child: EntryMetadataSection(
                          createdAt: _currentEntry.createdAt,
                          mood: _currentEntry.mood,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _increaseFontSize() {
    if (_baseFontSize < 24.0) {
      setState(() {
        _baseFontSize += 2.0;
      });
    }
  }

  void _decreaseFontSize() {
    if (_baseFontSize > 12.0) {
      setState(() {
        _baseFontSize -= 2.0;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
}
