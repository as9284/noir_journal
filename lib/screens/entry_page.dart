import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/entry_description_field.dart';

class EntryPage extends StatefulWidget {
  final DiaryEntry entry;
  final void Function(DiaryEntry updated)? onUpdate;
  const EntryPage({super.key, required this.entry, this.onUpdate});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> with TickerProviderStateMixin {
  late TextEditingController _descController;
  bool _editing = false;
  late String _currentDescription;
  late AnimationController _openCloseController;
  late Animation<double> _openCloseAnim;
  late AnimationController _editAnimController;
  late Animation<double> _editAnim;

  @override
  void initState() {
    super.initState();
    _currentDescription = widget.entry.description;
    _descController = TextEditingController(text: widget.entry.description);
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
    _openCloseController.forward();
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
        });
      }
    });
  }

  Future<void> _saveDescription() async {
    final updated = DiaryEntry(
      title: widget.entry.title,
      createdAt: widget.entry.createdAt,
      description: _descController.text.trim(),
    );
    widget.onUpdate?.call(updated);
    setState(() {
      _editing = false;
      _currentDescription = updated.description;
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

  void _closePage() async {
    await _openCloseController.reverse();
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 10));
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
        title: Text(widget.entry.title),
        centerTitle: true,
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Description',
              onPressed: _startEdit,
            ),
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
                      Icons.book_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.entry.title,
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
