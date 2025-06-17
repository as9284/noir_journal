import 'package:flutter/material.dart';
import '../constants/diary_icons.dart';

class DiaryEntry {
  final String title;
  final DateTime createdAt;
  final String description;
  final int iconIndex;

  const DiaryEntry({
    required this.title,
    required this.createdAt,
    this.description = '',
    this.iconIndex = 0,
  });

  IconData get icon => DiaryIcons.all[iconIndex];

  Map<String, dynamic> toJson() => {
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
    'iconIndex': iconIndex,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    title: json['title'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    description: json['description'] ?? '',
    iconIndex: (json['iconIndex'] is int) ? json['iconIndex'] : 0,
  );
}
