import 'package:flutter/material.dart';

enum Mood {
  happy,
  excited,
  grateful,
  loved,
  peaceful,
  content,
  hopeful,
  neutral,
  tired,
  stressed,
  anxious,
  sad,
  angry,
  frustrated,
  overwhelmed,
  lonely,
}

class MoodData {
  final Mood mood;
  final String name;
  final String emoji;
  final Color color;
  final Color textColor;
  final String description;

  const MoodData({
    required this.mood,
    required this.name,
    required this.emoji,
    required this.color,
    required this.textColor,
    required this.description,
  });
}

class MoodHelper {
  static const Map<Mood, MoodData> _moodData = {
    // Positive moods
    Mood.happy: MoodData(
      mood: Mood.happy,
      name: 'Happy',
      emoji: '😊',
      color: Color(0xFFFFD700), // Gold
      textColor: Colors.black, // Good contrast
      description: 'Feeling joyful and cheerful',
    ),
    Mood.excited: MoodData(
      mood: Mood.excited,
      name: 'Excited',
      emoji: '🤩',
      color: Color(0xFFFF6B35), // Orange-red
      textColor: Colors.white, // Good contrast
      description: 'Full of enthusiasm and energy',
    ),
    Mood.grateful: MoodData(
      mood: Mood.grateful,
      name: 'Grateful',
      emoji: '🙏',
      color: Color(0xFF8A2BE2), // Blue-violet
      textColor: Colors.white, // Good contrast
      description: 'Feeling thankful and appreciative',
    ),
    Mood.loved: MoodData(
      mood: Mood.loved,
      name: 'Loved',
      emoji: '🥰',
      color: Color(0xFFFF69B4), // Hot pink
      textColor: Colors.white, // Good contrast
      description: 'Feeling cherished and cared for',
    ),
    Mood.peaceful: MoodData(
      mood: Mood.peaceful,
      name: 'Peaceful',
      emoji: '😌',
      color: Color(0xFF87CEEB), // Sky blue
      textColor: Colors.black, // Good contrast
      description: 'Calm and tranquil state of mind',
    ),
    Mood.content: MoodData(
      mood: Mood.content,
      name: 'Content',
      emoji: '😊',
      color: Color(0xFF90EE90), // Light green
      textColor: Colors.black, // Good contrast
      description: 'Satisfied and at ease',
    ),
    Mood.hopeful: MoodData(
      mood: Mood.hopeful,
      name: 'Hopeful',
      emoji: '🌟',
      color: Color(0xFFFFE4B5), // Moccasin
      textColor: Colors.black, // Good contrast
      description: 'Optimistic about the future',
    ),

    // Neutral mood
    Mood.neutral: MoodData(
      mood: Mood.neutral,
      name: 'Neutral',
      emoji: '😐',
      color: Color(0xFF808080), // Gray
      textColor: Colors.white, // Good contrast
      description: 'Neither particularly positive nor negative',
    ),

    // Negative moods
    Mood.tired: MoodData(
      mood: Mood.tired,
      name: 'Tired',
      emoji: '😴',
      color: Color(0xFF696969), // Dim gray
      textColor: Colors.white, // Good contrast
      description: 'Feeling exhausted or drained',
    ),
    Mood.stressed: MoodData(
      mood: Mood.stressed,
      name: 'Stressed',
      emoji: '😰',
      color: Color(0xFFFF4500), // Orange-red
      textColor: Colors.white, // Good contrast
      description: 'Feeling pressured and tense',
    ),
    Mood.anxious: MoodData(
      mood: Mood.anxious,
      name: 'Anxious',
      emoji: '😟',
      color: Color(0xFFFFD700), // Gold (warning color)
      textColor: Colors.black, // Good contrast
      description: 'Feeling worried or uneasy',
    ),
    Mood.sad: MoodData(
      mood: Mood.sad,
      name: 'Sad',
      emoji: '😢',
      color: Color(0xFF4169E1), // Royal blue
      textColor: Colors.white, // Good contrast
      description: 'Feeling down or melancholy',
    ),
    Mood.angry: MoodData(
      mood: Mood.angry,
      name: 'Angry',
      emoji: '😠',
      color: Color(0xFFDC143C), // Crimson
      textColor: Colors.white, // Good contrast
      description: 'Feeling irritated or furious',
    ),
    Mood.frustrated: MoodData(
      mood: Mood.frustrated,
      name: 'Frustrated',
      emoji: '😤',
      color: Color(0xFFFF6347), // Tomato
      textColor: Colors.white, // Good contrast
      description: 'Feeling blocked or thwarted',
    ),
    Mood.overwhelmed: MoodData(
      mood: Mood.overwhelmed,
      name: 'Overwhelmed',
      emoji: '🤯',
      color: Color(0xFF8B0000), // Dark red
      textColor: Colors.white, // Good contrast
      description: 'Feeling like too much to handle',
    ),
    Mood.lonely: MoodData(
      mood: Mood.lonely,
      name: 'Lonely',
      emoji: '😔',
      color: Color(0xFF483D8B), // Dark slate blue
      textColor: Colors.white, // Good contrast
      description: 'Feeling isolated or disconnected',
    ),
  };

  static MoodData getMoodData(Mood mood) {
    return _moodData[mood]!;
  }

  static List<MoodData> getAllMoods() {
    return _moodData.values.toList();
  }

  static List<MoodData> getPositiveMoods() {
    return [
      _moodData[Mood.happy]!,
      _moodData[Mood.excited]!,
      _moodData[Mood.grateful]!,
      _moodData[Mood.loved]!,
      _moodData[Mood.peaceful]!,
      _moodData[Mood.content]!,
      _moodData[Mood.hopeful]!,
    ];
  }

  static List<MoodData> getNeutralMoods() {
    return [_moodData[Mood.neutral]!];
  }

  static List<MoodData> getNegativeMoods() {
    return [
      _moodData[Mood.tired]!,
      _moodData[Mood.stressed]!,
      _moodData[Mood.anxious]!,
      _moodData[Mood.sad]!,
      _moodData[Mood.angry]!,
      _moodData[Mood.frustrated]!,
      _moodData[Mood.overwhelmed]!,
      _moodData[Mood.lonely]!,
    ];
  }

  static Mood? moodFromString(String? moodString) {
    if (moodString == null) return null;
    try {
      return Mood.values.firstWhere((mood) => mood.toString() == moodString);
    } catch (e) {
      return null;
    }
  }

  static String moodToString(Mood mood) {
    return mood.toString();
  }
}
