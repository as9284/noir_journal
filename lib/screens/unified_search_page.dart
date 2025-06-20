import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/diary_entry.dart';
import '../models/mood.dart';
import '../screens/entry_page.dart';

enum SearchFilter { all, title, content, mood }

enum DateFilter {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  custom,
}

class UnifiedSearchPage extends StatefulWidget {
  final List<DiaryEntry> entries;
  final Function(DiaryEntry)? onEntryUpdate;

  const UnifiedSearchPage({
    super.key,
    required this.entries,
    this.onEntryUpdate,
  });

  @override
  State<UnifiedSearchPage> createState() => _UnifiedSearchPageState();
}

class _UnifiedSearchPageState extends State<UnifiedSearchPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  SearchFilter _selectedSearchFilter = SearchFilter.all;
  DateFilter _selectedDateFilter = DateFilter.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  List<DiaryEntry> _filteredEntries = [];
  bool _isSearchActive = false;

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _filteredEntries = widget.entries;

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _searchController.addListener(_onSearchChanged);
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearchActive = _searchController.text.isNotEmpty;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<DiaryEntry> filtered = List.from(widget.entries);

    // Apply text search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered =
          filtered.where((entry) {
            switch (_selectedSearchFilter) {
              case SearchFilter.all:
                return _matchesAll(entry, query);
              case SearchFilter.title:
                return entry.title.toLowerCase().contains(query);
              case SearchFilter.content:
                return entry.description.toLowerCase().contains(query);
              case SearchFilter.mood:
                return _matchesMood(entry, query);
            }
          }).toList();
    }

    // Apply date filter
    filtered = _applyDateFilter(filtered);

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredEntries = filtered;
    });
  }

  bool _matchesAll(DiaryEntry entry, String query) {
    final titleMatch = entry.title.toLowerCase().contains(query);
    final contentMatch = entry.description.toLowerCase().contains(query);
    final moodMatch = _matchesMood(entry, query);
    return titleMatch || contentMatch || moodMatch;
  }

  bool _matchesMood(DiaryEntry entry, String query) {
    if (entry.mood == null) return false;
    final moodData = MoodHelper.getMoodData(entry.mood!);
    return moodData.name.toLowerCase().contains(query) ||
        moodData.emoji.contains(query);
  }

  List<DiaryEntry> _applyDateFilter(List<DiaryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedDateFilter) {
      case DateFilter.all:
        return entries;
      case DateFilter.today:
        return entries.where((e) {
          final entryDate = DateTime(
            e.createdAt.year,
            e.createdAt.month,
            e.createdAt.day,
          );
          return entryDate.isAtSameMomentAs(today);
        }).toList();
      case DateFilter.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return entries.where((e) {
          final entryDate = DateTime(
            e.createdAt.year,
            e.createdAt.month,
            e.createdAt.day,
          );
          return entryDate.isAtSameMomentAs(yesterday);
        }).toList();
      case DateFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        return entries.where((e) {
          final entryDate = DateTime(
            e.createdAt.year,
            e.createdAt.month,
            e.createdAt.day,
          );
          return !entryDate.isBefore(startOfWeek);
        }).toList();
      case DateFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return entries.where((e) {
          final entryDate = DateTime(
            e.createdAt.year,
            e.createdAt.month,
            e.createdAt.day,
          );
          return !entryDate.isBefore(startOfMonth);
        }).toList();
      case DateFilter.lastMonth:
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(
          now.year,
          now.month,
          1,
        ).subtract(const Duration(days: 1));
        return entries.where((e) {
          final entryDate = DateTime(
            e.createdAt.year,
            e.createdAt.month,
            e.createdAt.day,
          );
          return !entryDate.isBefore(startOfLastMonth) &&
              !entryDate.isAfter(endOfLastMonth);
        }).toList();
      case DateFilter.custom:
        if (_customStartDate == null) return entries;
        final startDate = _normalizeDate(_customStartDate!);
        final endDate =
            _customEndDate != null
                ? _normalizeDate(_customEndDate!)
                : _normalizeDate(DateTime.now());
        final filtered =
            entries.where((e) {
              final entryDate = _normalizeDate(e.createdAt);
              return !entryDate.isBefore(startDate) &&
                  !entryDate.isAfter(endDate);
            }).toList();

        return filtered;
    }
  }

  Future<void> _selectCustomDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange:
          _customStartDate != null && _customEndDate != null
              ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      setState(() {
        _customStartDate = dateRange.start;
        _customEndDate = dateRange.end;
        _selectedDateFilter = DateFilter.custom;
        _applyFilters();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSearchFilter = SearchFilter.all;
      _selectedDateFilter = DateFilter.all;
      _customStartDate = null;
      _customEndDate = null;
      _isSearchActive = false;
      _filteredEntries = widget.entries;
    });
    _searchFocusNode.unfocus();
  }

  /// Normalizes a DateTime to just the date part (year, month, day) for accurate comparisons
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Search & Filter'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          if (_isSearchActive || _selectedDateFilter != DateFilter.all)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all filters',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchHeader(theme, colorScheme),
            _buildFilterChips(theme, colorScheme),
            const SizedBox(height: 16),
            Expanded(child: _buildResultsList(theme, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search your journal entries...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _isSearchActive = false;
                              _applyFilters();
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),

          // Search filter chips
          if (_isSearchActive) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search in:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        SearchFilter.values.map((filter) {
                          final isSelected = _selectedSearchFilter == filter;
                          return FilterChip(
                            label: Text(_getSearchFilterLabel(filter)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSearchFilter = filter;
                                _applyFilters();
                              });
                            },
                            backgroundColor: colorScheme.surface,
                            selectedColor: colorScheme.primaryContainer,
                            checkmarkColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filter by date:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              if (_selectedDateFilter == DateFilter.custom)
                TextButton.icon(
                  onPressed: _selectCustomDateRange,
                  icon: const Icon(Icons.edit_calendar, size: 16),
                  label: const Text('Edit Range'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                DateFilter.values.map((filter) {
                  final isSelected = _selectedDateFilter == filter;
                  return FilterChip(
                    label: Text(_getDateFilterLabel(filter)),
                    selected: isSelected,
                    onSelected: (selected) async {
                      if (filter == DateFilter.custom) {
                        await _selectCustomDateRange();
                      } else {
                        setState(() {
                          _selectedDateFilter = filter;
                          _applyFilters();
                        });
                      }
                    },
                    backgroundColor: colorScheme.surface,
                    selectedColor: colorScheme.secondaryContainer,
                    checkmarkColor: colorScheme.secondary,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
          ),
          if (_selectedDateFilter == DateFilter.custom &&
              _customStartDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 14,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _customEndDate != null
                        ? '${_formatDate(_customStartDate!)} - ${_formatDate(_customEndDate!)}'
                        : 'From ${_formatDate(_customStartDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_customEndDate != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_customEndDate!.difference(_customStartDate!).inDays + 1} days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme, ColorScheme colorScheme) {
    if (_filteredEntries.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        return _buildEntryCard(entry, theme, colorScheme);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    final hasActiveFilters =
        _isSearchActive || _selectedDateFilter != DateFilter.all;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveFilters ? Icons.search_off : Icons.search,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters ? 'No entries found' : 'Start searching',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveFilters
                ? 'Try adjusting your search terms or filters'
                : 'Use the search bar above to find specific entries',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntryCard(
    DiaryEntry entry,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final moodData =
        entry.mood != null ? MoodHelper.getMoodData(entry.mood!) : null;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => _navigateToEntry(entry),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and mood
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (moodData != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: moodData.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: moodData.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            moodData.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            moodData.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: moodData.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Content preview
              if (entry.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  entry.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer with date and action hint
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(entry.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEntry(DiaryEntry entry) async {
    HapticFeedback.lightImpact();

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EntryPage(
              entry: entry,
              onUpdate: (updatedEntry) {
                if (widget.onEntryUpdate != null) {
                  widget.onEntryUpdate!(updatedEntry);
                }
                // Update the entry in our local list
                final index = widget.entries.indexWhere(
                  (e) =>
                      e.title == entry.title && e.createdAt == entry.createdAt,
                );
                if (index != -1) {
                  widget.entries[index] = updatedEntry;
                  _applyFilters(); // Refresh the filtered list
                }
              },
            ),
      ),
    );

    if (result == 'deleted') {
      // Remove deleted entry from our list
      widget.entries.removeWhere(
        (e) => e.title == entry.title && e.createdAt == entry.createdAt,
      );
      _applyFilters(); // Refresh the filtered list
    }
  }

  String _getSearchFilterLabel(SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return 'All';
      case SearchFilter.title:
        return 'Title';
      case SearchFilter.content:
        return 'Content';
      case SearchFilter.mood:
        return 'Mood';
    }
  }

  String _getDateFilterLabel(DateFilter filter) {
    switch (filter) {
      case DateFilter.all:
        return 'All Time';
      case DateFilter.today:
        return 'Today';
      case DateFilter.yesterday:
        return 'Yesterday';
      case DateFilter.thisWeek:
        return 'This Week';
      case DateFilter.thisMonth:
        return 'This Month';
      case DateFilter.lastMonth:
        return 'Last Month';
      case DateFilter.custom:
        return 'Custom Range';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
