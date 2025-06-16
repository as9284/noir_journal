import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/entry_description_field.dart';
import '../constants/ui_constants.dart';
import '../constants/diary_icons.dart';

class EntryPage extends StatefulWidget {
  final DiaryEntry entry;
  final void Function(DiaryEntry updated)? onUpdate;
  const EntryPage({super.key, required this.entry, this.onUpdate});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> with TickerProviderStateMixin {
  late TextEditingController _descController;
  late TextEditingController _titleController;
  bool _editing = false;
  late String _currentDescription;
  late int _currentIconIndex;
  late AnimationController _openCloseController;
  late Animation<double> _openCloseAnim;
  late AnimationController _editAnimController;
  late Animation<double> _editAnim;

  @override
  void initState() {
    super.initState();
    _currentDescription = widget.entry.description;
    _currentIconIndex = widget.entry.iconIndex;
    _descController = TextEditingController(text: widget.entry.description);
    _titleController = TextEditingController(text: widget.entry.title);
    _openCloseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _openCloseAnim = CurvedAnimation(
      parent: _openCloseController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _editAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _editAnim = CurvedAnimation(
      parent: _editAnimController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 120), () {
        _openCloseController.forward();
      });
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _openCloseController.dispose();
    _editAnimController.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() => _editing = true);
    _editAnimController.duration = const Duration(milliseconds: 350);
    _editAnimController.forward(from: 0);
  }

  void _cancelEdit() {
    _editAnimController.duration = const Duration(milliseconds: 180);
    _editAnimController.reverse();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() {
          _editing = false;
          _descController.text = _currentDescription;
          _currentIconIndex = widget.entry.iconIndex;
          _titleController.text = widget.entry.title;
        });
      }
    });
  }

  Future<void> _saveDescription() async {
    final updated = DiaryEntry(
      title: _titleController.text.trim(),
      createdAt: widget.entry.createdAt,
      description: _descController.text.trim(),
      iconIndex: _currentIconIndex,
    );
    widget.onUpdate?.call(updated);
    setState(() {
      _editing = false;
      _currentDescription = updated.description;
      _currentIconIndex = updated.iconIndex;
      _titleController.text = updated.title;
    });
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
              return jsonEncode(updated.toJson());
            }
          } catch (_) {}
          return e;
        }).toList();
    await prefs.setStringList('diary_entries', updatedJson);
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Entry?'),
            content: const Text('Are you sure you want to delete this entry?'),
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

  void _closePage() async {
    await _openCloseController.reverse();
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 10));
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? Colors.black.withAlpha(128) : Colors.white.withAlpha(128),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _closePage,
        ),
        title: Text("Diary Entry"),
        centerTitle: true,
        titleSpacing: DiaryPaddings.horizontal,
        actions: [
          if (!_editing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Description',
              onPressed: _startEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Entry',
              onPressed: _deleteEntry,
            ),
          ],
          if (_editing) ...[
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: _cancelEdit,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: _saveDescription,
            ),
          ],
          const SizedBox(width: DiaryPaddings.horizontal),
        ],
      ),
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _openCloseAnim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(_openCloseAnim),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      DiaryIcons.all[_currentIconIndex],
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _editing
                              ? TextField(
                                controller: _titleController,
                                maxLines: 2,
                                minLines: 1,
                                autofocus: true,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Title',
                                  contentPadding: EdgeInsets.zero,
                                ),
                              )
                              : Text(
                                _titleController.text,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: EntryDescriptionField(
                    editing: _editing,
                    controller: _descController,
                    currentDescription: _currentDescription,
                    editAnim: _editAnim,
                    isDark: isDark,
                    selectedIcon: DiaryIcons.all[_currentIconIndex],
                    onIconChanged:
                        _editing
                            ? (icon) {
                              setState(() {
                                _currentIconIndex = DiaryIcons.all.indexOf(
                                  icon,
                                );
                              });
                            }
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: _editing ? 1 : 0.5,
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'Created:  ${_formatDate(widget.entry.createdAt)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
