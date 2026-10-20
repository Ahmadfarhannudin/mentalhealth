import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/ui/components.dart';
import 'scan_expression_screen.dart';

class MoodEntry {
  final DateTime date;
  final int level;
  final List<String> tags;
  final String note;

  const MoodEntry({
    required this.date,
    required this.level,
    this.tags = const [],
    this.note = '',
  });
}

class MoodTrackerScreen extends StatefulWidget {
  final String userName;
  final ValueChanged<int>? onTabChanged;

  const MoodTrackerScreen({
    super.key,
    this.userName = 'Teman',
    this.onTabChanged,
  });

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  static const _moods = [
    _MoodData(
      level: 1,
      label: 'Berat',
      icon: Icons.sentiment_very_dissatisfied_rounded,
      color: AppColors.moodBad,
      tint: AppColors.moodBadTint,
    ),
    _MoodData(
      level: 2,
      label: 'Lelah',
      icon: Icons.sentiment_dissatisfied_rounded,
      color: AppColors.moodLow,
      tint: AppColors.moodLowTint,
    ),
    _MoodData(
      level: 3,
      label: 'Biasa',
      icon: Icons.sentiment_neutral_rounded,
      color: AppColors.moodOkay,
      tint: AppColors.moodOkayTint,
    ),
    _MoodData(
      level: 4,
      label: 'Baik',
      icon: Icons.sentiment_satisfied_rounded,
      color: AppColors.moodGood,
      tint: AppColors.moodGoodTint,
    ),
    _MoodData(
      level: 5,
      label: 'Tenang',
      icon: Icons.sentiment_very_satisfied_rounded,
      color: AppColors.moodGreat,
      tint: AppColors.moodGreatTint,
    ),
  ];

  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selectedTags = {};
  final List<MoodEntry> _entries = [];
  final PageController _insightPageController = PageController(
    viewportFraction: 0.92,
  );
  int _selectedMood = 3;
  int _activeInsightPage = 0;
  bool _isEditing = false;
  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final raw = [
      (0, 4, ['Pekerjaan', 'Tidur'], 'Hari yang cukup produktif.'),
      (1, 3, ['Keluarga'], 'Ngobrol lama sama keluarga.'),
      (2, 5, ['Tidur', 'Kesehatan'], 'Tidur lebih awal, badan terasa segar.'),
      (3, 4, ['Pekerjaan'], 'Deadline selesai tepat waktu.'),
      (4, 2, ['Pekerjaan', 'Tidur'], 'Begadang, badan terasa berat.'),
      (5, 3, ['Sosial'], 'Kopi sore sama teman lama.'),
      (6, 4, ['Kesehatan'], 'Olahraga pagi, mood membaik.'),
      (7, 3, ['Pekerjaan'], 'Meeting panjang, cukup melelahkan.'),
      (8, 1, ['Hubungan', 'Tidur'], 'Hari yang terasa sangat berat.'),
      (9, 2, ['Kesehatan'], 'Kurang enak badan sejak kemarin.'),
      (10, 3, ['Keluarga', 'Sosial'], 'Makan malam ramai-ramai.'),
      (11, 4, ['Tidur'], 'Tidur cukup, bangun segar.'),
      (12, 5, ['Kesehatan', 'Sosial'], 'Hari yang menyenangkan dan tenang.'),
      (13, 4, ['Pekerjaan'], 'Proyek baru dimulai dengan baik.'),
      (14, 3, ['Hubungan'], 'Ada salah paham kecil, tapi oke.'),
      (16, 2, ['Tidur', 'Pekerjaan'], 'Tekanan kerja cukup tinggi.'),
      (17, 3, ['Sosial'], 'Nonton bareng teman.'),
      (18, 4, ['Kesehatan'], 'Jalan pagi, udara segar.'),
      (19, 5, ['Keluarga', 'Tidur'], 'Weekend tenang bersama keluarga.'),
      (20, 4, ['Pekerjaan'], 'Ide baru muncul, semangat lagi.'),
      (21, 3, ['Hubungan', 'Sosial'], 'Hangout sore, cukup menyenangkan.'),
      (22, 2, ['Tidur'], 'Susah tidur malam, badan kurang fit.'),
      (23, 3, ['Pekerjaan'], 'Rutinitas biasa, tidak ada yang spesial.'),
      (24, 4, ['Kesehatan', 'Tidur'], 'Istirahat cukup, tubuh lebih ringan.'),
      (25, 5, ['Sosial', 'Keluarga'], 'Reuni kecil, sangat menyenangkan.'),
      (26, 4, ['Pekerjaan'], 'Presentasi berjalan lancar.'),
      (27, 3, ['Tidur'], 'Tidur tidak nyenyak.'),
      (28, 2, ['Hubungan'], 'Perasaan campur aduk hari ini.'),
      (29, 4, ['Kesehatan'], 'Mulai rutin olahraga lagi.'),
    ];

    for (final (daysAgo, level, tags, note) in raw) {
      _entries.add(
        MoodEntry(
          date: DateTime(today.year, today.month, today.day - daysAgo),
          level: level,
          tags: List.unmodifiable(tags),
          note: note,
        ),
      );
    }
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  MoodEntry? get _todayEntry {
    for (final entry in _entries.reversed) {
      if (entry.date == _today) return entry;
    }
    return null;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _insightPageController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _dateLabel {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  _MoodData _moodData(int level) =>
      _moods.firstWhere((mood) => mood.level == level);

  void _startEditingEntry(MoodEntry entry) {
    setState(() {
      _isEditing = true;
      _selectedMood = entry.level;
      _selectedTags
        ..clear()
        ..addAll(entry.tags);
      _noteController.text = entry.note;
    });
  }

  void _beginEditing() {
    final entry = _todayEntry;
    if (entry != null) {
      _startEditingEntry(entry);
      return;
    }
    setState(() {
      _isEditing = true;
      _selectedMood = 3;
      _selectedTags.clear();
      _noteController.clear();
    });
  }

  void _deleteEntry(MoodEntry entry) {
    setState(() {
      _entries.removeWhere((item) => identical(item, entry));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Check-in ${_entryLabel(entry)} dihapus.'),
        action: SnackBarAction(
          label: 'Batal',
          onPressed: () => setState(() {
            if (!_entries.contains(entry)) _entries.add(entry);
          }),
        ),
      ),
    );
  }

  String _entryLabel(MoodEntry entry) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (entry.date == today) return 'hari ini';
    final difference = today.difference(entry.date).inDays;
    if (difference == 1) return 'kemarin';
    return '$difference hari lalu';
  }

  void _saveCheckIn() {
    final entry = MoodEntry(
      date: _today,
      level: _selectedMood,
      tags: List.unmodifiable(_selectedTags),
      note: _noteController.text.trim(),
    );

    setState(() {
      _entries.removeWhere((item) => item.date == _today);
      _entries.add(entry);
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in hari ini tersimpan.')),
    );
  }

  Future<void> _scanExpression() async {
    final result = await Navigator.push<ExpressionResult>(
      context,
      MaterialPageRoute(builder: (_) => const ScanExpressionScreen()),
    );

    if (!mounted || result == null) return;
    setState(() {
      _selectedMood = result.moodLevel;
      _noteController.text = 'Hasil scan: ${result.label}';
      _isEditing = true;
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayEntry = _todayEntry;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.lg,
          Space.page,
          Space.xxl,
        ),
        children: [
          _PageIntro(
            greeting: _greeting,
            name: widget.userName.trim().isEmpty
                ? 'Teman'
                : widget.userName.trim(),
            date: _dateLabel,
            hasEntry: todayEntry != null,
          ),
          const SizedBox(height: Space.xl),
          if (todayEntry == null || _isEditing)
            _CheckInForm(
              selectedMood: _selectedMood,
              selectedTags: _selectedTags,
              noteController: _noteController,
              isEditing: _isEditing,
              onMoodChanged: (level) => setState(() => _selectedMood = level),
              onTagToggled: _toggleTag,
              onScan: _scanExpression,
              onSave: _saveCheckIn,
            )
          else
            _TodaySummary(
              entry: todayEntry,
              mood: _moodData(todayEntry.level),
              onEdit: _beginEditing,
            ),
          const SizedBox(height: Space.lg),
          _InspirationCarousel(
            pageController: _insightPageController,
            activePage: _activeInsightPage,
            onPageChanged: (page) => setState(() => _activeInsightPage = page),
          ),
          const SizedBox(height: Space.xl),
          _SectionTitle(
            title: 'Progres mingguan',
            subtitle: _entries.isEmpty
                ? 'Progres muncul setelah kamu mulai check-in.'
                : 'Mood yang tercatat dalam tujuh hari terakhir.',
          ),
          const SizedBox(height: Space.md),
          _WeeklyChartCard(
            entries: _entries,
            today: _today,
            moodData: _moodData,
          ),
          const SizedBox(height: Space.lg),
          _FrequensiCard(entries: _entries, moodData: _moodData),
          const SizedBox(height: Space.xl),
          _SectionTitle(
            title: 'Riwayat check-in',
            subtitle: _entries.isEmpty
                ? 'Catatanmu akan muncul di sini setelah check-in.'
                : '${_entries.length} catatan tersimpan di perangkat ini.',
          ),
          const SizedBox(height: Space.md),
          if (_entries.isEmpty)
            const QuietEmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'Belum ada riwayat',
              message: 'Mulai dari satu check-in. Tidak perlu menulis panjang, cukup pilih mood yang paling mendekati.',
            )
          else
            _HistoryCard(
              entries: _entries,
              moodData: _moodData,
              onEditEntry: _startEditingEntry,
              onDeleteEntry: _deleteEntry,
            ),
          const SizedBox(height: Space.xl),
          const InfoNote(
            icon: Icons.privacy_tip_outlined,
            message: 'Check-in membantu melihat pola perasaanmu, bukan memberi diagnosis. Jika terasa sangat berat atau tidak aman, hubungi orang tepercaya atau tenaga profesional.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

class _MoodData {
  final int level;
  final String label;
  final IconData icon;
  final Color color;
  final Color tint;

  const _MoodData({
    required this.level,
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
  });
}

const _moodOptions = [
  _MoodData(
    level: 1,
    label: 'Berat',
    icon: Icons.sentiment_very_dissatisfied_rounded,
    color: AppColors.moodBad,
    tint: AppColors.moodBadTint,
  ),
  _MoodData(
    level: 2,
    label: 'Lelah',
    icon: Icons.sentiment_dissatisfied_rounded,
    color: AppColors.moodLow,
    tint: AppColors.moodLowTint,
  ),
  _MoodData(
    level: 3,
    label: 'Biasa',
    icon: Icons.sentiment_neutral_rounded,
    color: AppColors.moodOkay,
    tint: AppColors.moodOkayTint,
  ),
  _MoodData(
    level: 4,
    label: 'Baik',
    icon: Icons.sentiment_satisfied_rounded,
    color: AppColors.moodGood,
    tint: AppColors.moodGoodTint,
  ),
  _MoodData(
    level: 5,
    label: 'Tenang',
    icon: Icons.sentiment_very_satisfied_rounded,
    color: AppColors.moodGreat,
    tint: AppColors.moodGreatTint,
  ),
];

const _tagOptions = [
  'Pekerjaan',
  'Keluarga',
  'Tidur',
  'Kesehatan',
  'Hubungan',
  'Sosial',
];

// ─────────────────────────────────────────────
// Header hero
// ─────────────────────────────────────────────

class _PageIntro extends StatelessWidget {
  final String greeting;
  final String name;
  final String date;
  final bool hasEntry;

  const _PageIntro({
    required this.greeting,
    required this.name,
    required this.date,
    required this.hasEntry,
  });

  IconData get _timeIcon {
    final hour = DateTime.now().hour;
    if (hour < 11) return Icons.wb_sunny_rounded;
    if (hour < 15) return Icons.light_mode_rounded;
    if (hour < 18) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '$greeting, $name. $date. ${hasEntry ? 'Check-in hari ini sudah tersimpan' : 'Belum check-in hari ini'}',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D6A4F), Color(0xFF1B4332), Color(0xFF081C15)],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D6A4F).withValues(alpha: 0.45),
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // ── Lapisan kaca buram ──
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Orb besar kiri atas ──
                Positioned(
                  left: -60,
                  top: -60,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF52B788).withValues(alpha: 0.35),
                          const Color(0xFF52B788).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Orb kecil kanan bawah ──
                Positioned(
                  right: -30,
                  bottom: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF74C69D).withValues(alpha: 0.2),
                          const Color(0xFF74C69D).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Garis highlight kaca atas ──
                Positioned(
                  top: 0,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Konten utama ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.xl,
                    Space.xl,
                    Space.xl,
                    Space.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris atas: pill tanggal + ikon waktu
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  date,
                                  style: AppText.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Ikon waktu — kaca bulat
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _timeIcon,
                              color: const Color(0xFFB7E4C7),
                              size: 22,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: Space.xl),

                      // Sapaan
                      Text(
                        '$greeting,',
                        style: AppText.bodyLarge.copyWith(
                          color: const Color(0xFF95D5B2),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.displayLarge.copyWith(
                          color: Colors.white,
                          height: 1.08,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Space.lg),

                      // Status check-in — panel kaca
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasEntry
                                    ? const Color(0xFF52B788)
                                          .withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.10),
                                border: Border.all(
                                  color: hasEntry
                                      ? const Color(0xFF74C69D)
                                            .withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Icon(
                                hasEntry
                                    ? Icons.check_rounded
                                    : Icons.favorite_border_rounded,
                                color: hasEntry
                                    ? const Color(0xFFB7E4C7)
                                    : Colors.white.withValues(alpha: 0.7),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: Space.sm),
                            Expanded(
                              child: Text(
                                hasEntry
                                    ? 'Check-in hari ini sudah tersimpan. Kamu bisa memperbaruinya kapan saja.'
                                    : 'Luangkan satu menit untuk menyadari apa yang sedang kamu rasakan.',
                                style: AppText.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────
// Check-in form
// ─────────────────────────────────────────────

class _CheckInForm extends StatelessWidget {
  final int selectedMood;
  final Set<String> selectedTags;
  final TextEditingController noteController;
  final bool isEditing;

  final ValueChanged<int> onMoodChanged;
  final ValueChanged<String> onTagToggled;
  final VoidCallback onScan;
  final VoidCallback onSave;

  const _CheckInForm({
    required this.selectedMood,
    required this.selectedTags,
    required this.noteController,
    required this.isEditing,
    required this.onMoodChanged,
    required this.onTagToggled,
    required this.onScan,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(Space.xl),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check-in sekarang', style: AppText.titleLarge),
                    SizedBox(height: Space.xs),
                    Text(
                      'Pilih yang paling mendekati. Tidak ada jawaban benar atau salah.',
                      style: AppText.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Gunakan scan ekspresi',
                onPressed: onScan,
                icon: const Icon(Icons.center_focus_strong_rounded),
              ),
            ],
          ),
          const SizedBox(height: Space.xl),
          const Text('Suasana hati', style: AppText.titleSmall),
          const SizedBox(height: Space.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 32) / 5;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _moodOptions
                    .map(
                      (mood) => SizedBox(
                        width: itemWidth,
                        child: _MoodOption(
                          mood: mood,
                          selected: selectedMood == mood.level,
                          onTap: () => onMoodChanged(mood.level),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: Space.xl),
          const Text('Apa yang paling memengaruhi?', style: AppText.titleSmall),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: _tagOptions
                .map(
                  (tag) => QuietPill(
                    label: tag,
                    selected: selectedTags.contains(tag),
                    onTap: () => onTagToggled(tag),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: Space.xl),
          const Text('Catatan singkat', style: AppText.titleSmall),
          const SizedBox(height: Space.sm),
          TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 4,
            maxLength: 280,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Apa yang ingin kamu ingat dari momen ini?',
              counterText: '',
            ),
          ),
          const SizedBox(height: Space.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSave,
              child: Text(isEditing ? 'Simpan perubahan' : 'Simpan check-in'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mood option tile
// ─────────────────────────────────────────────

class _MoodOption extends StatelessWidget {
  final _MoodData mood;
  final bool selected;
  final VoidCallback onTap;

  const _MoodOption({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${mood.label}, ${selected ? 'dipilih' : 'belum dipilih'}',
      child: Material(
        color: selected ? mood.tint : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? mood.color : AppColors.borderLight,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 82),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mood.icon,
                    size: 26,
                    color: selected ? mood.color : AppColors.textMuted,
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      mood.label,
                      style: AppText.caption.copyWith(
                        color: selected
                            ? AppColors.textDark
                            : AppColors.textMuted,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Today summary
// ─────────────────────────────────────────────

class _TodaySummary extends StatelessWidget {
  final MoodEntry entry;
  final _MoodData mood;
  final VoidCallback onEdit;

  const _TodaySummary({
    required this.entry,
    required this.mood,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Space.xl),
            decoration: BoxDecoration(
              color: mood.tint,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: mood.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(mood.icon, color: mood.color, size: 28),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Check-in hari ini', style: AppText.caption),
                      const SizedBox(height: 2),
                      Text(mood.label, style: AppText.titleLarge),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Perbarui check-in',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.tags.isNotEmpty) ...[
                  const Text('Yang memengaruhi', style: AppText.titleSmall),
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: entry.tags
                        .map(
                          (tag) => StatusChip(
                            label: tag,
                            color: AppColors.forestDeep,
                            background: AppColors.forestMist,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (entry.note.isNotEmpty) ...[
                  if (entry.tags.isNotEmpty) const SizedBox(height: Space.lg),
                  const Text('Catatan', style: AppText.titleSmall),
                  const SizedBox(height: Space.sm),
                  Text(entry.note, style: AppText.bodyMedium),
                ],
                if (entry.tags.isEmpty && entry.note.isEmpty)
                  Text(
                    'Tidak ada catatan tambahan untuk hari ini.',
                    style: AppText.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Inspiration carousel
// ─────────────────────────────────────────────

class _InspirationCarousel extends StatelessWidget {
  final PageController pageController;
  final int activePage;
  final ValueChanged<int> onPageChanged;

  const _InspirationCarousel({
    required this.pageController,
    required this.activePage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    const banner = <_InspirationCard>[
      _InspirationCard(
        quote: 'It always seems impossible until it\'s done.',
        source: 'Nelson Mandela · English',
      ),
      _InspirationCard(
        quote: 'Rasa sakitmu adalah pecahnya cangkang yang membungkus pemahamanmu.',
        source: 'Kahlil Gibran · terjemahan Indonesia',
      ),
      _InspirationCard(
        quote: 'There is no greater agony than bearing an untold story inside you.',
        source: 'Maya Angelou · English',
      ),
      _InspirationCard(
        quote: 'Bahkan malam yang paling gelap akan berakhir dan matahari akan terbit.',
        source: 'Victor Hugo · terjemahan Indonesia',
      ),
      _InspirationCard(
        quote: 'Your pain is the breaking of the shell that encloses your understanding.',
        source: 'Kahlil Gibran · English',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionTitle(
                title: 'Penyeimbang hari ini',
                subtitle: 'Pilih pesan yang ingin kamu simpan dekat.',
              ),
            ),
            Semantics(
              label: 'Pesan ${activePage + 1} dari ${banner.length}',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.sm,
                  vertical: Space.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.forestMist,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activePage + 1}/${banner.length}',
                  style: AppText.caption.copyWith(
                    color: AppColors.forestDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        SizedBox(
          height: MediaQuery.sizeOf(context).width < 400 ? 220 : 196,
          child: PageView.builder(
            controller: pageController,
            itemCount: banner.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) => AnimatedBuilder(
              animation: pageController,
              builder: (context, child) {
                var page = activePage.toDouble();
                if (pageController.hasClients) {
                  page = pageController.page ?? page;
                }
                final distance = (page - index).abs().clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 1 - (distance * 0.035),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: banner[index],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(
                  banner.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: index == activePage ? 24 : 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: index == activePage
                          ? AppColors.forest
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Icon(
              Icons.swipe_left_rounded,
              size: 18,
              color: AppColors.textLight,
            ),
            const SizedBox(width: Space.xs),
            Text('Geser', style: AppText.caption),
          ],
        ),
      ],
    );
  }
}

class _InspirationCard extends StatelessWidget {
  final String quote;
  final String source;

  const _InspirationCard({required this.quote, required this.source});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 400;
    return Semantics(
      label: 'Kata penyeimbang: $quote',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D6A4F),
              Color(0xFF1E5C3A),
              Color(0xFF144D2E),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // ── Tinted glass hijau bening ──
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF74C69D).withValues(alpha: 0.22),
                        Color(0xFF52B788).withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Highlight kaca atas ──
              Positioned(
                top: 0,
                left: 16,
                right: 16,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFFB7E4C7).withValues(alpha: 0.60),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Highlight kaca kiri ──
              Positioned(
                top: 16,
                left: 0,
                bottom: 16,
                child: Container(
                  width: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB7E4C7).withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Konten ──
              Padding(
                padding: EdgeInsets.all(compact ? Space.lg : Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon kutip
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFB7E4C7).withValues(alpha: 0.20),
                        border: Border.all(
                          color: Color(0xFFB7E4C7).withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.format_quote_rounded,
                        color: Color(0xFFD8F3DC),
                        size: 20,
                      ),
                    ),

                    const Spacer(),

                    // Teks kutipan
                    Text(
                      '"$quote"',
                      style: AppText.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        letterSpacing: 0.15,
                        shadows: [
                          Shadow(
                            color: Color(0xFF1B4332).withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: Space.md),

                    // Sumber — pill kaca
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFB7E4C7).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFFB7E4C7).withValues(alpha: 0.40),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD8F3DC),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption.copyWith(
                                color: const Color(0xFFD8F3DC),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.titleMedium),
        const SizedBox(height: 2),
        Text(subtitle, style: AppText.bodySmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Weekly chart — crypto style
// ─────────────────────────────────────────────

class _WeeklyChartCard extends StatefulWidget {
  final List<MoodEntry> entries;
  final DateTime today;
  final _MoodData Function(int level) moodData;

  const _WeeklyChartCard({
    required this.entries,
    required this.today,
    required this.moodData,
  });

  @override
  State<_WeeklyChartCard> createState() => _WeeklyChartCardState();
}

class _WeeklyChartCardState extends State<_WeeklyChartCard> {
  static const _ranges = [7, 14, 30];
  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  int _range = 7;
  int? _touch;

  DateTime _daysAgo(int d) =>
      DateTime(widget.today.year, widget.today.month, widget.today.day - d);

  MoodEntry? _entryOn(DateTime day) {
    MoodEntry? found;
    for (final e in widget.entries) {
      if (e.date == day) found = e;
    }
    return found;
  }

  double? _average(int fromAgo, int toAgo) {
    var sum = 0;
    var count = 0;
    for (var d = toAgo; d <= fromAgo; d++) {
      final e = _entryOn(_daysAgo(d));
      if (e != null) {
        sum += e.level;
        count++;
      }
    }
    return count == 0 ? null : sum / count;
  }

  String _dateText(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    // Mulai dari Senin di minggu pertama rentang, akhiri hari ini
    final rangeStart = widget.today.subtract(Duration(days: _range - 1));
    final monday = rangeStart.subtract(
      Duration(days: (rangeStart.weekday - 1) % 7),
    );
    final totalDays = widget.today.difference(monday).inDays + 1;
    final days = List.generate(totalDays, (i) {
      final day = monday.add(Duration(days: i));
      return (day: day, entry: _entryOn(day));
    });
    final n = days.length;

    final logged = days.where((d) => d.entry != null).toList();
    final levels = logged.map((d) => d.entry!.level).toList();
    final avg = levels.isEmpty
        ? null
        : levels.reduce((a, b) => a + b) / levels.length;
    final prevAvg = _average(n * 2 - 1, n);
    final delta = (avg != null && prevAvg != null) ? avg - prevAvg : null;
    final up = (delta ?? 0) >= 0;
    final trendColor = up ? AppColors.forest : AppColors.moodLow;

    final touched = (_touch != null && _touch! < n) ? days[_touch!] : null;

    final xLabels = List.generate(n, (i) {
      final d = days[i].day;
      if (_range == 7) {
        // Tampilkan semua nama hari
        return _weekdays[d.weekday - 1];
      } else {
        // Hanya tampilkan label di hari Senin (awal minggu)
        if (d.weekday != DateTime.monday) return '';
        return '${d.day}/${d.month}';
      }
    });

    final tooltips = days.map((d) {
      final label = d.entry == null
          ? 'Belum check-in'
          : widget.moodData(d.entry!.level).label;
      return '$label · ${d.day.day} ${_months[d.day.month - 1]}';
    }).toList();

    final maxLevel = levels.isEmpty
        ? null
        : levels.reduce((a, b) => a > b ? a : b);
    final minLevel = levels.isEmpty
        ? null
        : levels.reduce((a, b) => a < b ? a : b);

    return SoftCard(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Progres mingguan', style: AppText.titleLarge),
              ),
              _RangeTabs(
                options: _ranges,
                selected: _range,
                onChanged: (value) => setState(() {
                  _range = value;
                  _touch = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Text(
            touched != null
                ? _dateText(touched.day)
                : 'Rata-rata $n hari terakhir',
            style: AppText.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: touched != null
                    ? Text(
                        touched.entry == null
                            ? 'Belum check-in'
                            : widget.moodData(touched.entry!.level).label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.displayLarge.copyWith(
                          fontSize: 34,
                          height: 1.1,
                          color: touched.entry == null
                              ? AppColors.textMuted
                              : widget.moodData(touched.entry!.level).color,
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            avg == null ? '—' : avg.toStringAsFixed(1),
                            style: AppText.displayLarge.copyWith(
                              fontSize: 34,
                              height: 1.1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 3),
                            child: Text(
                              '/ 5',
                              style: AppText.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: Space.md),
              if (touched == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: delta == null
                          ? AppColors.surfaceSunken
                          : trendColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (delta != null)
                          Icon(
                            up
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_rounded,
                            size: 18,
                            color: trendColor,
                          ),
                        Text(
                          delta == null
                              ? 'Belum ada pembanding'
                              : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
                          style: AppText.caption.copyWith(
                            color: delta == null
                                ? AppColors.textMuted
                                : trendColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          SizedBox(
            height: 220,
            child: LayoutBuilder(
              builder: (context, c) {
                void update(double dx) {
                  final w =
                      c.maxWidth -
                      _TrendPainter.leftPad -
                      _TrendPainter.rightPad;
                  final t = ((dx - _TrendPainter.leftPad) / w).clamp(0.0, 1.0);
                  final idx = (t * (n - 1)).round();
                  if (idx != _touch) setState(() => _touch = idx);
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    final before = _touch;
                    update(d.localPosition.dx);
                    if (before != null && before == _touch) {
                      setState(() => _touch = null);
                    }
                  },
                  onHorizontalDragStart: (d) => update(d.localPosition.dx),
                  onHorizontalDragUpdate: (d) => update(d.localPosition.dx),
                  onHorizontalDragEnd: (_) => setState(() => _touch = null),
                  onHorizontalDragCancel: () => setState(() => _touch = null),
                  child: Semantics(
                    label:
                        'Grafik mood $n hari terakhir. ${logged.length} hari tercatat.',
                    child: ExcludeSemantics(
                      child: CustomPaint(
                        size: Size(c.maxWidth, 220),
                        painter: _TrendPainter(
                          levels: days.map((d) => d.entry?.level).toList(),
                          colors: days
                              .map(
                                (d) => d.entry == null
                                    ? null
                                    : widget.moodData(d.entry!.level).color,
                              )
                              .toList(),
                          xLabels: xLabels,
                          tooltips: tooltips,
                          yLabels: List.generate(
                            5,
                            (i) => widget.moodData(i + 1).label,
                          ),
                          lineColor: trendColor,
                          touchIndex: _touch,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Space.sm),
          Row(
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Sentuh atau geser grafik untuk melihat detail',
                  style: AppText.caption.copyWith(color: AppColors.textLight),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Tertinggi',
                  value: maxLevel == null
                      ? '—'
                      : widget.moodData(maxLevel).label,
                  color: maxLevel == null
                      ? AppColors.textMuted
                      : widget.moodData(maxLevel).color,
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: _StatTile(
                  label: 'Terendah',
                  value: minLevel == null
                      ? '—'
                      : widget.moodData(minLevel).label,
                  color: minLevel == null
                      ? AppColors.textMuted
                      : widget.moodData(minLevel).color,
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: _StatTile(
                  label: 'Tercatat',
                  value: '${logged.length}/$n',
                  color: AppColors.forest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeTabs extends StatelessWidget {
  final List<int> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const _RangeTabs({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.forestMist,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((value) {
          final active = value == selected;
          return Semantics(
            button: true,
            selected: active,
            label: '$value hari',
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${value}H',
                  style: AppText.caption.copyWith(
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? AppColors.forestDeep : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: AppText.titleSmall),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<int?> levels;
  final List<Color?> colors;
  final List<String> xLabels;
  final List<String> tooltips;
  final List<String> yLabels;
  final Color lineColor;
  final int? touchIndex;

  const _TrendPainter({
    required this.levels,
    required this.colors,
    required this.xLabels,
    required this.tooltips,
    required this.yLabels,
    required this.lineColor,
    required this.touchIndex,
  });

  static const double leftPad = 6;
  static const double rightPad = 50;
  static const double topPad = 34;
  static const double bottomPad = 24;
  static const double innerV = 12;

  TextPainter _tp(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      leftPad,
      topPad,
      size.width - rightPad,
      size.height - bottomPad,
    );
    final n = levels.length;

    double xAt(int i) =>
        n == 1 ? plot.center.dx : plot.left + plot.width * i / (n - 1);
    double yAt(int level) =>
        plot.bottom - innerV - (plot.height - innerV * 2) * (level - 1) / 4;

    // Grid + label Y
    final grid = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1;
    for (var level = 1; level <= 5; level++) {
      final y = yAt(level);
      _dashed(canvas, Offset(plot.left, y), Offset(plot.right, y), grid);
      final tp = _tp(
        yLabels[level - 1],
        TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      );
      tp.paint(canvas, Offset(plot.right + 8, y - tp.height / 2));
    }

    // Titik data
    final pts = <int, Offset>{};
    for (var i = 0; i < n; i++) {
      final l = levels[i];
      if (l != null) pts[i] = Offset(xAt(i), yAt(l));
    }
    final ordered = pts.keys.toList()..sort();

    // Garis + area
    if (ordered.length >= 2) {
      final list = ordered.map((i) => pts[i]!).toList();
      final line = Path()..moveTo(list.first.dx, list.first.dy);
      for (var i = 1; i < list.length; i++) {
        final cx = (list[i - 1].dx + list[i].dx) / 2;
        line.cubicTo(
          cx,
          list[i - 1].dy,
          cx,
          list[i].dy,
          list[i].dx,
          list[i].dy,
        );
      }
      final area = Path.from(line)
        ..lineTo(list.last.dx, plot.bottom)
        ..lineTo(list.first.dx, plot.bottom)
        ..close();

      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.28),
              lineColor.withValues(alpha: 0.0),
            ],
          ).createShader(plot),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Titik kecil (hanya rentang pendek)
    if (n <= 14) {
      for (final i in ordered) {
        canvas.drawCircle(pts[i]!, 4.5, Paint()..color = AppColors.surface);
        canvas.drawCircle(pts[i]!, 3, Paint()..color = colors[i] ?? lineColor);
      }
    }

    // Titik terakhir bercahaya
    if (ordered.isNotEmpty) {
      final last = pts[ordered.last]!;
      final c = colors[ordered.last] ?? lineColor;
      canvas.drawCircle(last, 12, Paint()..color = c.withValues(alpha: 0.14));
      canvas.drawCircle(last, 7, Paint()..color = AppColors.surface);
      canvas.drawCircle(last, 4.5, Paint()..color = c);
    }

    // Label X
    for (var i = 0; i < n; i++) {
      if (xLabels[i].isEmpty) continue;
      final isLast = i == n - 1;
      final tp = _tp(
        xLabels[i],
        TextStyle(
          fontSize: 10.5,
          fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
          color: isLast ? AppColors.forestDeep : AppColors.textMuted,
        ),
      );
      final dx = (xAt(i) - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, plot.bottom + 8));
    }

    // Crosshair + tooltip
    final ti = touchIndex;
    if (ti != null && ti < n) {
      final x = xAt(ti);
      final cross = Paint()
        ..color = AppColors.textMuted.withValues(alpha: 0.5)
        ..strokeWidth = 1;
      _dashedV(canvas, Offset(x, plot.top - 4), Offset(x, plot.bottom), cross);

      final p = pts[ti];
      if (p != null) {
        final c = colors[ti] ?? lineColor;
        canvas.drawCircle(p, 10, Paint()..color = c.withValues(alpha: 0.2));
        canvas.drawCircle(p, 6, Paint()..color = AppColors.surface);
        canvas.drawCircle(p, 4.5, Paint()..color = c);
      }

      final tp = _tp(
        tooltips[ti],
        const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
      final w = tp.width + 20;
      final left = (x - w / 2).clamp(0.0, size.width - w);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, w, 26),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, Paint()..color = AppColors.forestDeep);
      tp.paint(canvas, Offset(left + 10, (26 - tp.height) / 2));
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    var x = a.dx;
    while (x < b.dx) {
      canvas.drawLine(
        Offset(x, a.dy),
        Offset((x + 4).clamp(a.dx, b.dx), a.dy),
        paint,
      );
      x += 8;
    }
  }

  void _dashedV(Canvas canvas, Offset a, Offset b, Paint paint) {
    var y = a.dy;
    while (y < b.dy) {
      canvas.drawLine(
        Offset(a.dx, y),
        Offset(a.dx, (y + 4).clamp(a.dy, b.dy)),
        paint,
      );
      y += 8;
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => true;
}

// ─────────────────────────────────────────────
// Distribusi mood
// ─────────────────────────────────────────────

class _FrequensiCard extends StatelessWidget {
  final List<MoodEntry> entries;
  final _MoodData Function(int level) moodData;

  const _FrequensiCard({required this.entries, required this.moodData});

  @override
  Widget build(BuildContext context) {
    final counts = <int, int>{for (var l = 1; l <= 5; l++) l: 0};
    for (final e in entries) {
      counts[e.level] = (counts[e.level] ?? 0) + 1;
    }
    final total = entries.length;

    int? topLevel;
    if (total > 0) {
      topLevel = counts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return SoftCard(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Distribusi mood', style: AppText.titleLarge),
              ),
              if (topLevel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: moodData(topLevel).tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Paling sering: ${moodData(topLevel).label}',
                    style: AppText.caption.copyWith(
                      color: moodData(topLevel).color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Seberapa sering tiap mood muncul di seluruh catatanmu.',
            style: AppText.bodySmall,
          ),
          const SizedBox(height: Space.xl),
          if (total == 0)
            const Text(
              'Belum ada data. Distribusi muncul setelah kamu check-in.',
              style: AppText.bodySmall,
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: [
                    for (var l = 1; l <= 5; l++)
                      if (counts[l]! > 0)
                        Expanded(
                          flex: counts[l]!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: ColoredBox(color: moodData(l).color),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.lg),
            for (var l = 5; l >= 1; l--) ...[
              _DistributionRow(
                mood: moodData(l),
                count: counts[l]!,
                percent: total == 0 ? 0 : (counts[l]! * 100 / total).round(),
              ),
              if (l > 1) const SizedBox(height: Space.md),
            ],
          ],
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final _MoodData mood;
  final int count;
  final int percent;

  const _DistributionRow({
    required this.mood,
    required this.count,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final muted = count == 0;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: muted ? AppColors.border : mood.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: Space.sm),
        Expanded(
          child: Text(
            mood.label,
            style: AppText.bodySmall.copyWith(
              color: muted ? AppColors.textLight : AppColors.textDark,
            ),
          ),
        ),
        Text(
          '$count kali',
          style: AppText.caption.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: Space.md),
        SizedBox(
          width: 40,
          child: Text(
            '$percent%',
            textAlign: TextAlign.end,
            style: AppText.titleSmall.copyWith(
              color: muted ? AppColors.textLight : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// History
// ─────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final List<MoodEntry> entries;
  final _MoodData Function(int level) moodData;
  final ValueChanged<MoodEntry> onEditEntry;
  final ValueChanged<MoodEntry> onDeleteEntry;

  const _HistoryCard({
    required this.entries,
    required this.moodData,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
    final visible = sorted.take(5).toList();

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Column(
        children: [
          for (int index = 0; index < visible.length; index++) ...[
            _HistoryRow(
              entry: visible[index],
              mood: moodData(visible[index].level),
              onEdit: () => onEditEntry(visible[index]),
              onDelete: () => onDeleteEntry(visible[index]),
            ),
            if (index < visible.length - 1)
              const Divider(height: 1, indent: 72, endIndent: Space.lg),
          ],
          if (entries.length > 5)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.md,
                Space.lg,
                Space.sm,
              ),
              child: Text(
                'Menampilkan 5 check-in terakhir.',
                style: AppText.caption,
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final MoodEntry entry;
  final _MoodData mood;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HistoryRow({
    required this.entry,
    required this.mood,
    required this.onEdit,
    required this.onDelete,
  });

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus check-in ini?'),
        content: Text(
          'Catatan untuk tanggal ${_formatDate(entry.date)} akan dihapus. Tindakan ini bisa dibatalkan lewat snackbar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDelete();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isToday =
        entry.date ==
        DateTime.now().copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: mood.tint, shape: BoxShape.circle),
            child: Icon(mood.icon, color: mood.color, size: 22),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Hari ini' : _formatDate(entry.date),
                  style: AppText.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    mood.label,
                    if (entry.tags.isNotEmpty) entry.tags.take(2).join(', '),
                  ].join(' · '),
                  style: AppText.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Perbarui check-in ${_formatDate(entry.date)}',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Hapus check-in ${_formatDate(entry.date)}',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
