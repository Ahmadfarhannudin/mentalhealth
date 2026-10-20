class MoodEntry {
  final String id;
  final int level; // 1 to 5
  final String label;
  final String note;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.level,
    required this.label,
    required this.note,
    required this.timestamp,
  });
}

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String prompt;
  final DateTime timestamp;
  final bool isPrivate;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.prompt,
    required this.timestamp,
    this.isPrivate = true,
  });
}

class CbtExercise {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String description;
  final String iconName;
  final bool isCompleted;

  CbtExercise({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.description,
    required this.iconName,
    this.isCompleted = false,
  });
}

class AppConstants {
  static final List<Map<String, dynamic>> moodOptions = [
    {'level': 5, 'label': 'Tenang', 'color': 0xFF4F7D63},
    {'level': 4, 'label': 'Baik', 'color': 0xFF7FA588},
    {'level': 3, 'label': 'Biasa', 'color': 0xFFC9B98F},
    {'level': 2, 'label': 'Lelah', 'color': 0xFFD9A183},
    {'level': 1, 'label': 'Berat', 'color': 0xFFC08476},
  ];

  static final List<CbtExercise> sampleExercises = [
    CbtExercise(
      id: '1',
      title: 'Pernapasan Kotak 4-4-4-4',
      category: 'Pernapasan',
      duration: '3 menit',
      description:
          'Tenangkan sistem saraf parasimpatis dengan pola napas terstruktur.',
      iconName: 'air',
    ),
    CbtExercise(
      id: '2',
      title: 'Grounding 5-4-3-2-1',
      category: 'Kecemasan',
      duration: '5 menit',
      description:
          'Kembalikan fokus ke saat ini dengan melibatkan panca indra.',
      iconName: 'spa',
    ),
    CbtExercise(
      id: '3',
      title: 'Restrukturisasi Pikiran Negatif',
      category: 'CBT Reframing',
      duration: '7 menit',
      description: 'Identifikasi distorsi kognitif dan ganti dengan perspektif yang seimbang.',
      iconName: 'psychology',
    ),
    CbtExercise(
      id: '4',
      title: 'Meditasi Syukur Harian',
      category: 'Refleksi',
      duration: '4 menit',
      description:
          'Fokus pada hal kecil yang menenangkan dan memberi energi positif.',
      iconName: 'favorite',
    ),
  ];
}
