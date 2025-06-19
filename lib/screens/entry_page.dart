import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dialog_utils.dart';
import '../models/mood.dart';
import '../widgets/entry_header_section.dart';
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
      body:
          _isEditing
              ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EntryHeaderSection(
                      selectedIconIndex: _selectedIconIndex,
                      createdAt: widget.entry.createdAt,
                    ),
                    const SizedBox(height: 24),
                    EntryTitleSection(
                      titleController: _titleController,
                      isEditing: _isEditing,
                    ),
                    const SizedBox(height: 20),
                    EntryDescriptionSection(
                      descriptionController: _descriptionController,
                      isEditing: _isEditing,
                    ),
                    const SizedBox(height: 20),
                    EntryMoodSection(
                      selectedMood: _selectedMood,
                      onMoodChanged: (mood) {
                        setState(() {
                          _selectedMood = mood;
                          _onTextChanged();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    EntryIconSection(
                      selectedIconIndex: _selectedIconIndex,
                      onIconChanged: (index) {
                        setState(() {
                          _selectedIconIndex = index;
                          _onTextChanged();
                        });
                      },
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EntryHeaderSection(
                      selectedIconIndex: _selectedIconIndex,
                      createdAt: widget.entry.createdAt,
                    ),
                    const SizedBox(height: 24),
                    EntryTitleSection(
                      titleController: _titleController,
                      isEditing: _isEditing,
                    ),
                    const SizedBox(height: 20),
                    // Description takes up remaining space in non-edit mode
                    Expanded(
                      child: EntryDescriptionSection(
                        descriptionController: _descriptionController,
                        isEditing: _isEditing,
                        expandToFill: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Slim entry details pushed to bottom
                    EntryMetadataSection(
                      createdAt: widget.entry.createdAt,
                      mood: widget.entry.mood,
                    ),
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
}
