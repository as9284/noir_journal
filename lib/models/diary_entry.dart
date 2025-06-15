import 'package:flutter/material.dart';

class DiaryEntry {
  final String title;
  final DateTime createdAt;
  final String description;
  final IconData icon;

  DiaryEntry({
    required this.title,
    required this.createdAt,
    this.description = '',
    this.icon = Icons.book_rounded,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'iconMatchTextDirection': icon.matchTextDirection,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    title: json['title'],
    createdAt: DateTime.parse(json['createdAt']),
    description: json['description'] ?? '',
    icon: IconData(
      json['icon'] ?? Icons.book_rounded.codePoint,
      fontFamily: json['iconFontFamily'] ?? Icons.book_rounded.fontFamily,
      fontPackage: json['iconFontPackage'],
      matchTextDirection: json['iconMatchTextDirection'] ?? false,
    ),
  );
}
