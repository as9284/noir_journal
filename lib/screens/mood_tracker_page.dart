import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/diary_entry.dart';
import '../models/mood.dart';
import '../services/secure_storage_service.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final entries = await SecureStorageService.loadEntries();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<DiaryEntry> get _currentMonthEntries {
    return _entries.where((entry) {
      return entry.createdAt.year == _selectedMonth.year &&
          entry.createdAt.month == _selectedMonth.month &&
          entry.mood != null;
    }).toList();
  }

  double get _monthlyAverageMoodScore {
    if (_currentMonthEntries.isEmpty) return 0.55;

    double totalScore = 0.0;
    for (final entry in _currentMonthEntries) {
      totalScore += _getMoodScore(entry.mood!);
    }
    return totalScore / _currentMonthEntries.length;
  }

  String get _monthlyAverageMoodDescription {
    final score = _monthlyAverageMoodScore;
    if (score < 0.35) return 'Very Negative';
    if (score < 0.5) return 'Negative';
    if (score < 0.65) return 'Neutral';
    if (score < 0.8) return 'Positive';
    return 'Very Positive';
  }

  double _getMoodScore(Mood mood) {
    const moodScores = {
      Mood.overwhelmed: 0.0,
      Mood.angry: 0.1,
      Mood.sad: 0.2,
      Mood.lonely: 0.3,
      Mood.frustrated: 0.35,
      Mood.anxious: 0.4,
      Mood.stressed: 0.45,
      Mood.tired: 0.5,
      Mood.neutral: 0.55,
      Mood.content: 0.6,
      Mood.hopeful: 0.65,
      Mood.peaceful: 0.7,
      Mood.grateful: 0.8,
      Mood.happy: 0.85,
      Mood.loved: 0.9,
      Mood.excited: 1.0,
    };
    return moodScores[mood] ?? 0.55;
  }

  Map<Mood, int> get _moodCounts {
    final Map<Mood, int> counts = {};
    for (final entry in _currentMonthEntries) {
      if (entry.mood != null) {
        counts[entry.mood!] = (counts[entry.mood!] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<PieChartSectionData> get _pieChartSections {
    final moodCounts = _moodCounts;
    if (moodCounts.isEmpty) return [];

    final total = moodCounts.values.reduce((a, b) => a + b);
    final sections = <PieChartSectionData>[];

    moodCounts.forEach((mood, count) {
      final moodData = MoodHelper.getMoodData(mood);
      final percentage = (count / total * 100);

      sections.add(
        PieChartSectionData(
          color: moodData.color,
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: moodData.textColor,
          ),
        ),
      );
    });

    return sections;
  }

  Map<int, List<Mood>> get _dailyMoods {
    final Map<int, List<Mood>> dailyMoods = {};

    for (final entry in _currentMonthEntries) {
      if (entry.mood != null) {
        final day = entry.createdAt.day;
        dailyMoods[day] = dailyMoods[day] ?? [];
        dailyMoods[day]!.add(entry.mood!);
      }
    }

    return dailyMoods;
  }

  Color _getColorFromScore(double score) {
    if (score <= 0.5) {
      final t = score * 2;
      return Color.lerp(const Color(0xFFD32F2F), const Color(0xFFFFA726), t)!;
    } else {
      final t = (score - 0.5) * 2;
      return Color.lerp(const Color(0xFFFFA726), const Color(0xFF4CAF50), t)!;
    }
  }

  double? _getAverageMoodScoreForDay(int day) {
    final moods = _dailyMoods[day];
    if (moods == null || moods.isEmpty) return null;

    double totalScore = 0.0;
    for (final mood in moods) {
      totalScore += _getMoodScore(mood);
    }
    return totalScore / moods.length;
  }

  Widget _buildMoodCalendar() {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayWeekday =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children:
              ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 8),

        ...List.generate((daysInMonth + firstDayWeekday - 1) ~/ 7 + 1, (
          weekIndex,
        ) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber =
                    weekIndex * 7 + dayIndex - firstDayWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final averageScore = _getAverageMoodScoreForDay(dayNumber);
                final moodCount = (_dailyMoods[dayNumber]?.length ?? 0);
                final opacity =
                    moodCount > 0
                        ? (0.3 + (moodCount * 0.15)).clamp(0.3, 1.0)
                        : 0.3;

                final moodColor =
                    averageScore != null
                        ? _getColorFromScore(averageScore)
                        : null;

                return Expanded(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color:
                          moodColor?.withValues(alpha: opacity) ??
                          Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            moodColor ??
                            Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Color Guide',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD32F2F),
                    Color(0xFFFF5722),
                    Color(0xFFFF9800),
                    Color(0xFFFFA726),
                    Color(0xFF8BC34A),
                    Color(0xFF4CAF50),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Very Negative',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Neutral',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Very Positive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'No mood logged',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          'Opacity indicates number of moods logged that day',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodLegend() {
    final moodCounts = _moodCounts;
    if (moodCounts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...moodCounts.entries.map((entry) {
          final moodData = MoodHelper.getMoodData(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: moodData.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${moodData.emoji} ${moodData.name}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed:
              _selectedMonth.year < DateTime.now().year ||
                      (_selectedMonth.year == DateTime.now().year &&
                          _selectedMonth.month < DateTime.now().month)
                  ? () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                  }
                  : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
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

  Widget _buildStatsCards() {
    final moodCounts = _moodCounts;
    final totalEntries = _currentMonthEntries.length;
    final daysWithEntries =
        _currentMonthEntries.map((e) => e.createdAt.day).toSet().length;

    final positiveCount = moodCounts.entries
        .where((e) => MoodHelper.getPositiveMoods().any((m) => m.mood == e.key))
        .fold(0, (sum, e) => sum + e.value);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _monthlyAverageMoodScore < 0.35
                    ? Icons.sentiment_very_dissatisfied
                    : _monthlyAverageMoodScore < 0.5
                    ? Icons.sentiment_dissatisfied
                    : _monthlyAverageMoodScore < 0.65
                    ? Icons.sentiment_neutral
                    : _monthlyAverageMoodScore < 0.8
                    ? Icons.sentiment_satisfied
                    : Icons.sentiment_very_satisfied,
                color: _getColorFromScore(_monthlyAverageMoodScore),
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Average',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    _monthlyAverageMoodDescription,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getColorFromScore(_monthlyAverageMoodScore),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Entries',
                totalEntries.toString(),
                Icons.edit_note,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Days',
                daysWithEntries.toString(),
                Icons.calendar_today,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Positive Moods',
                positiveCount.toString(),
                Icons.sentiment_very_satisfied,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadEntries,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthSelector(),
                      const SizedBox(height: 24),

                      if (_currentMonthEntries.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.sentiment_neutral,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).iconTheme.color?.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _currentMonthEntries.isEmpty
                                    ? 'No mood data for this month'
                                    : 'No entries match your search criteria',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _buildStatsCards(),
                        const SizedBox(height: 32),
                        const Text(
                          'Mood Distribution',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 220,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          child: PieChart(
                            PieChartData(
                              sections: _pieChartSections,
                              borderData: FlBorderData(show: false),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          child: _buildMoodLegend(),
                        ),
                        const SizedBox(height: 32),

                        if (_dailyMoods.isNotEmpty) ...[
                          const Text(
                            'Mood Calendar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'See your daily mood patterns at a glance. Each day shows the average mood score as a color - from red (negative) to green (positive).',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.1),
                              ),
                            ),
                            child: _buildMoodCalendar(),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
