class DiaryEntry {
  final String title;
  final DateTime createdAt;
  final String description;

  DiaryEntry({
    required this.title,
    required this.createdAt,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    title: json['title'],
    createdAt: DateTime.parse(json['createdAt']),
    description: json['description'] ?? '',
  );
}
