class DiaryEntry {
  final String title;
  final DateTime createdAt;

  DiaryEntry({required this.title, required this.createdAt});

  Map<String, dynamic> toJson() => {
    'title': title,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    title: json['title'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
