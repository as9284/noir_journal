import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/diary_icons.dart';
import '../utils/dialog_utils.dart';
import '../models/mood.dart';
import '../widgets/mood_selector.dart';

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
  late int _selectedIconIndex;
  late Mood? _selectedMood;
  bool _isEditing = false;
  bool _hasChanges = false;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _descriptionController = TextEditingController(
      text: widget.entry.description,
    );
    _selectedIconIndex = widget.entry.iconIndex;
    _selectedMood = widget.entry.mood;

    _titleController.addListener(_onTextChanged);
    _descriptionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasChanges =
        _titleController.text != widget.entry.title ||
        _descriptionController.text != widget.entry.description ||
        _selectedIconIndex != widget.entry.iconIndex ||
        _selectedMood != widget.entry.mood;

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
      _titleController.text = widget.entry.title;
      _descriptionController.text = widget.entry.description;
      _selectedIconIndex = widget.entry.iconIndex;
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
      createdAt: widget.entry.createdAt,
      iconIndex: _selectedIconIndex,
      mood: _selectedMood,
    );

    widget.onUpdate?.call(updatedEntry);
    await _saveToPreferences(updatedEntry);

    setState(() {
      _isEditing = false;
      _hasChanges = false;
    });
    if (!mounted) return;
    Navigator.of(context).pop(updatedEntry);
  }

  Future<void> _saveToPreferences(DiaryEntry updatedEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('diary_entries') ?? [];
    final updatedJson =
        entriesJson.map((e) {
          try {
            final decoded = DiaryEntry.fromJson(
              Map<String, dynamic>.from(jsonDecode(e)),
            );
            if (decoded.title == widget.entry.title &&
                decoded.createdAt == widget.entry.createdAt) {
              return jsonEncode(updatedEntry.toJson());
            }
          } catch (_) {}
          return e;
        }).toList();
    await prefs.setStringList('diary_entries', updatedJson);
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
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('diary_entries') ?? [];
      final updatedJson =
          entriesJson.where((e) {
            try {
              final decoded = DiaryEntry.fromJson(
                Map<String, dynamic>.from(jsonDecode(e)),
              );
              return !(decoded.title == widget.entry.title &&
                  decoded.createdAt == widget.entry.createdAt);
            } catch (_) {}
            return true;
          }).toList();
      await prefs.setStringList('diary_entries', updatedJson);

      if (mounted) {
        Navigator.of(context).pop('deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'Entry Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Entry',
              onPressed: _startEditing,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Entry',
              onPressed: _deleteEntry,
            ),
          ] else ...[
            TextButton(
              onPressed: _hasChanges ? _saveChanges : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color:
                      _hasChanges
                          ? theme.colorScheme.primary
                          : theme.disabledColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(theme),
            const SizedBox(height: 24),
            _buildTitleSection(theme),
            const SizedBox(height: 20),
            _buildDescriptionSection(theme),
            const SizedBox(height: 20),
            if (_isEditing) _buildMoodSection(theme),
            const SizedBox(height: 20),
            if (_isEditing) _buildIconSection(theme),
            if (!_isEditing) _buildMetadataSection(theme),
          ],
        ),
      ),
      floatingActionButton:
          _isEditing
              ? FloatingActionButton(
                onPressed: _cancelEditing,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
                child: const Icon(Icons.close),
              )
              : null,
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    final createdAt = widget.entry.createdAt;
    final timeString =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    final dateString =
        '${_getWeekday(createdAt.weekday)}, ${_getMonth(createdAt.month)} ${createdAt.day}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              theme.brightness == Brightness.dark
                  ? [Colors.grey[800]!, Colors.grey[850]!]
                  : [
                    theme.colorScheme.primary.withAlpha(25),
                    theme.colorScheme.primary.withAlpha(13),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(51),
                width: 1,
              ),
            ),
            child: Icon(
              DiaryIcons.all[_selectedIconIndex],
              size: 30,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeString,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateString,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.title, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Title',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                _isEditing
                    ? []
                    : [
                      BoxShadow(
                        color: theme.shadowColor.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            border: Border.all(
              color:
                  _isEditing
                      ? theme.colorScheme.primary.withAlpha(77)
                      : theme.dividerColor.withAlpha(51),
              width: 1,
            ),
          ),
          child:
              _isEditing
                  ? TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  )
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _titleController.text,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: _isEditing ? 120 : 80),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                _isEditing
                    ? []
                    : [
                      BoxShadow(
                        color: theme.shadowColor.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            border: Border.all(
              color:
                  _isEditing
                      ? theme.colorScheme.primary.withAlpha(77)
                      : theme.dividerColor.withAlpha(51),
              width: 1,
            ),
          ),
          child:
              _isEditing
                  ? TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Tell me about your day...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                    textCapitalization: TextCapitalization.sentences,
                  )
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _descriptionController.text.isEmpty
                          ? 'No description added'
                          : _descriptionController.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            _descriptionController.text.isEmpty
                                ? theme.colorScheme.onSurface.withAlpha(128)
                                : theme.colorScheme.onSurface,
                        fontStyle:
                            _descriptionController.text.isEmpty
                                ? FontStyle.italic
                                : null,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildIconSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_emotions,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Choose an Icon',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(77),
              width: 1,
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: DiaryIcons.all.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedIconIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIconIndex = index;
                    _onTextChanged();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? theme.colorScheme.primary.withAlpha(51)
                            : theme.colorScheme.primary.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    DiaryIcons.all[index],
                    size: 24,
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(128),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mood, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Mood',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(77),
              width: 1,
            ),
          ),
          child: MoodSelector(
            selectedMood: _selectedMood,
            onMoodChanged: (mood) {
              setState(() {
                _selectedMood = mood;
                _onTextChanged(); // Trigger change detection
              });
            },
            title: 'How were you feeling?',
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withAlpha(51), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
              const SizedBox(width: 8),
              Text(
                'Entry Details',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(128),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Created: ${_formatDateTime(widget.entry.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),
          if (widget.entry.mood != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Mood: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                MoodDisplay(
                  mood: widget.entry.mood!,
                  size: 14,
                  showLabel: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  String _getWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
