import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';

/// Satu catatan suasana hati (sementara disimpan di memori).
/// Ganti dengan model/database milikmu bila sudah ada.
class MoodEntry {
  final DateTime date; // hanya tanggal (tanpa jam)
  final int level; // 1..5, sesuai AppConstants.moodOptions
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
  /// Nama pengguna untuk ucapan di bagian atas.
  final String userName;

  /// Callback navigasi tab dari parent (HomeScreen).
  final ValueChanged<int>? onTabChanged;

  const MoodTrackerScreen({super.key, this.userName = 'Teman', this.onTabChanged});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  /// Ubah ke false untuk melihat tampilan keadaan kosong.
  static const bool _seedSampleData = true;

  /// Minimal jumlah catatan agar grafik & ringkasan ditampilkan.
  static const int _minEntries = 3;

  static const _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  int _selectedMood = 5;
  bool _isEditing = false;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _tags = ['Pekerjaan', 'Keluarga', 'Tidur', 'Kesehatan', 'Hubungan', 'Sosial'];
  final Set<String> _selectedTags = {'Tidur'};
  late List<MoodEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _seedSampleData ? _sampleEntries() : [];
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ───────────────────────── Data helpers ─────────────────────────

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  List<MoodEntry> _sampleEntries() {
    final t = _today();
    final levels = [4, 3, 5, 2, 3, 4, 4, 1, 3, 5, 4, 3];
    final days = [1, 2, 3, 4, 6, 7, 9, 11, 13, 15, 18, 20];
    final tagSets = [
      ['Tidur', 'Pekerjaan'], ['Pekerjaan'], ['Keluarga'], ['Pekerjaan', 'Tidur'],
      ['Sosial'], ['Tidur'], ['Kesehatan'], ['Pekerjaan', 'Hubungan'],
      ['Tidur'], ['Keluarga', 'Sosial'], ['Pekerjaan'], ['Tidur'],
    ];
    return List.generate(levels.length, (i) {
      return MoodEntry(
        date: t.subtract(Duration(days: days[i] - 1)),
        level: levels[i],
        tags: tagSets[i],
      );
    });
  }

  /// Emoji ekspresi wajah per level mood (1 = paling berat, 5 = paling tenang).
  static const Map<int, String> _moodEmojis = {
    5: '😊',
    4: '🙂',
    3: '😐',
    2: '😔',
    1: '😢',
  };

  String _emoji(dynamic level) => _moodEmojis[level] ?? '🙂';

  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 4 && h < 11) return 'Selamat pagi';
    if (h >= 11 && h < 15) return 'Selamat siang';
    if (h >= 15 && h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _dateLabel {
    final n = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return '${days[n.weekday - 1]}, ${n.day} ${_monthNames[n.month - 1]} ${n.year}';
  }

  Map<String, dynamic> _moodByLevel(int level) {
    return AppConstants.moodOptions.firstWhere(
      (m) => m['level'] == level,
      orElse: () => AppConstants.moodOptions.first,
    );
  }

  List<MoodEntry> get _monthEntries {
    final t = _today();
    return _entries.where((e) => e.date.year == t.year && e.date.month == t.month).toList();
  }

  /// Nilai mood 7 hari terakhir (null = tidak ada catatan).
  List<int?> get _weekValues {
    final t = _today();
    return List.generate(7, (i) {
      final d = t.subtract(Duration(days: 6 - i));
      final match = _entries.where((e) => e.date == d);
      return match.isEmpty ? null : match.last.level;
    });
  }

  List<String> get _weekLabels {
    final t = _today();
    return List.generate(7, (i) => _dayNames[t.subtract(Duration(days: 6 - i)).weekday - 1]);
  }

  int get _streak {
    final dates = _entries.map((e) => e.date).toSet();
    var d = _today();
    if (!dates.contains(d)) d = d.subtract(const Duration(days: 1));
    var count = 0;
    while (dates.contains(d)) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  void _save() {
    final t = _today();
    setState(() {
      _entries.removeWhere((e) => e.date == t);
      _entries.add(MoodEntry(
        date: t,
        level: _selectedMood,
        tags: _selectedTags.toList(),
        note: _noteController.text.trim(),
      ));
      _noteController.clear();
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan suasana hati tersimpan dengan tenang.'),
        backgroundColor: AppColors.sage,
      ),
    );
  }

  /// Hapus catatan hari ini dan kembalikan form ke kondisi awal.
  void _deleteToday() {
    final t = _today();
    setState(() {
      _entries.removeWhere((e) => e.date == t);
      _isEditing = false;
      _selectedMood = 5;
      _selectedTags.clear();
      _noteController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan hari ini dihapus.'),
        backgroundColor: AppColors.sage,
      ),
    );
  }

  /// Muat catatan hari ini ke form agar bisa diperbarui.
  void _startEditing() {
    final e = _entries.firstWhere((e) => e.date == _today());
    setState(() {
      _isEditing = true;
      _selectedMood = e.level;
      _selectedTags
        ..clear()
        ..addAll(e.tags);
      _noteController.text = e.note;
    });
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasLoggedToday = _entries.any((e) => e.date == _today());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingHeader(hasLoggedToday),
              const SizedBox(height: 20),
              if (_entries.isEmpty) ...[
                _buildEmptyStateCard(),
                const SizedBox(height: 20),
              ] else ...[
                _buildQuickStatsRow(),
                const SizedBox(height: 20),
                _buildQuickActionsRow(),
                const SizedBox(height: 28),
              ],
              _buildCheckInCard(showSummary: hasLoggedToday && !_isEditing),
              const SizedBox(height: 28),
              _sectionHeader('Wawasan untukmu', 'Gambaran dari catatanmu sendiri'),
              const SizedBox(height: 14),
              _buildLoggingCard(),
              const SizedBox(height: 14),
              _buildWeekChartCard(),
              const SizedBox(height: 14),
              _buildTriggersCard(),
              const SizedBox(height: 20),
              _buildDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sagePale,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.sageLight),
      ),
      child: Column(
        children: [
          const AnimatedLeafBadge(size: 64),
          const SizedBox(height: 14),
          const Text(
            'Belum ada catatan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mulai hari ini dengan mencatat perasaanmu. Tidak ada yang terlambat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    final streak = _streak;
    final monthCount = _monthEntries.length;
    final avgMood = _monthEntries.isNotEmpty
        ? (_monthEntries.fold(0, (sum, e) => sum + e.level) / _monthEntries.length).toStringAsFixed(1)
        : '0.0';

    return Row(
      children: [
        Expanded(
          child: _quickStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Konsisten',
            value: streak == 0 ? 'Mulai lagi' : '$streak hari',
            color: AppColors.peach,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStatCard(
            icon: Icons.calendar_month_rounded,
            label: 'Bulan ini',
            value: monthCount == 0 ? 'Belum ada' : '$monthCount catatan',
            color: AppColors.mintLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Rata-rata',
            value: avgMood,
            color: AppColors.lavenderLight,
          ),
        ),
      ],
    );
  }

  Widget _quickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.sageDeep),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            icon: Icons.auto_stories_rounded,
            label: 'Mulai Jurnal',
            color: AppColors.sage,
            onTap: () => widget.onTabChanged?.call(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionButton(
            icon: Icons.fitness_center_rounded,
            label: 'Coping Skill',
            color: AppColors.terracotta,
            onTap: () => widget.onTabChanged?.call(2),
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Greeting ─────────────────────────

  Widget _buildGreetingHeader(bool hasLoggedToday) {
    final name = widget.userName.trim().isEmpty ? 'Teman' : widget.userName.trim();
    final subtitle = hasLoggedToday
        ? 'Perasaanmu hari ini sudah tercatat. Terima kasih sudah meluangkan waktu untuk dirimu.'
        : 'Luangkan satu menit untuk menyadari apa yang kamu rasakan hari ini.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sageDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_greeting,',
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.3,
                    color: AppColors.textBody,
                  ),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const AnimatedLeafBadge(size: 56),
        ],
      ),
    );
  }

  // ───────────────────────── Check-in ─────────────────────────

  Widget _buildCheckInCard({required bool showSummary}) {
    if (showSummary) {
      return _card(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success),
                SizedBox(width: 10),
                Text(
                  'Sudah tercatat hari ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lakukan update kapan pun jika ada perubahan perasaan.',
              style: AppText.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startEditing,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.sage,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.sageLight),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showTodayDetails,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Lihat Detail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sage,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bagaimana perasaanmu saat ini?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text('Tidak ada penilaian di sini. Sadari saja apa yang ada.',
              style: AppText.bodyMedium),
          const SizedBox(height: 18),
          Row(
            children: [
              for (int i = 0; i < AppConstants.moodOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _moodTile(AppConstants.moodOptions[i])),
              ],
            ],
          ),
          const SizedBox(height: 22),
          Text('Apa yang paling memengaruhimu?', style: AppText.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              final isTagSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isTagSelected,
                onSelected: (selected) {
                  setState(() {
                    selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                  });
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.sagePale,
                labelStyle: TextStyle(
                  color: isTagSelected ? AppColors.sageDeep : AppColors.textBody,
                  fontWeight: isTagSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isTagSelected ? AppColors.sage : AppColors.border),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Text('Catatan Singkat (opsional)', style: AppText.titleSmall),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan sedikit tentang hal yang membuatmu merasa begini...',
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Perbarui Refleksi' : 'Simpan Refleksi'),
            ),
          ),
        ],
      ),
    );
  }

  void _showTodayDetails() {
    final todayEntry = _entries.firstWhere((e) => e.date == _today());
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Hari Ini',
                  style: AppText.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(_emoji(todayEntry.level), style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _moodByLevel(todayEntry.level)['label'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dicatat: $_dateLabel',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (todayEntry.tags.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('Pengaruh utama:', style: AppText.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: todayEntry.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: AppColors.sagePale,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sageDeep,
                    ),
                  );
                }).toList(),
              ),
            ],
            if (todayEntry.note.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('Catatan:', style: AppText.titleSmall),
              const SizedBox(height: 8),
              Text(
                todayEntry.note,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textBody,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Hapus catatan hari ini?'),
                      content: const Text(
                        'Catatan suasana hati hari ini akan dihapus dan tidak bisa dikembalikan.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: TextButton.styleFrom(foregroundColor: AppColors.terracotta),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _deleteToday();
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Hapus Entri'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                  side: const BorderSide(color: AppColors.terracotta),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodTile(Map<String, dynamic> mood) {
    final isSelected = _selectedMood == mood['level'];
    final color = Color(mood['color']);
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood['level']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(_emoji(mood['level']), style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                mood['label'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Insight cards ─────────────────────────

  Widget _buildLoggingCard() {
    final t = _today();
    final daysInMonth = DateTime(t.year, t.month + 1, 0).day;
    final logged = _monthEntries.map((e) => e.date).toSet().length;
    final progress = daysInMonth == 0 ? 0.0 : logged / daysInMonth;

    return _card(
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.sagePale,
                    valueColor: const AlwaysStoppedAnimation(AppColors.sage),
                  ),
                ),
                Text('$logged',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.sageDeep)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$logged dari $daysInMonth hari tercatat',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(
                  _streak > 0
                      ? 'Kamu mencatat $_streak hari berturut-turut.'
                      : 'Mulai lagi kapan pun kamu siap. Tidak ada yang tertinggal.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekChartCard() {
    final values = _weekValues;
    final count = values.where((v) => v != null).length;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.show_chart_rounded, 'Mood 7 hari terakhir'),
          const SizedBox(height: 14),
          if (count < _minEntries)
            _emptyState(
              icon: Icons.insights_outlined,
              message: 'Catat minimal $_minEntries hari dalam seminggu agar grafik bisa ditampilkan. '
                  'Sekarang baru $count hari.',
            )
          else ...[
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 26,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int l = 5; l >= 1; l--)
                          Text(_emoji(l), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(
                      painter: _WeekChartPainter(
                        values: values,
                        lineColor: AppColors.sage,
                        gridColor: AppColors.borderLight,
                        colorFor: (v) => Color(_moodByLevel(v)['color']),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 26),
                for (final label in _weekLabels)
                  Expanded(
                    child: Center(
                      child: Text(label,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static const List<Color> _factorColors = [
    AppColors.sageDeep,
    AppColors.sage,
    AppColors.terracotta,
    AppColors.peach,
    AppColors.sageLight,
    AppColors.lavenderLight,
  ];

  /// Faktor yang sering dipilih: grafik donat porsi tiap faktor + legenda.
  Widget _buildTriggersCard() {
    final month = _monthEntries;
    final counts = <String, int>{};
    for (final e in month) {
      for (final tag in e.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final shown = sorted.take(_factorColors.length).toList();
    final total = shown.fold<int>(0, (sum, e) => sum + e.value);
    final hasData = month.length >= _minEntries && shown.isNotEmpty;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.label_outline_rounded, 'Faktor yang paling sering dipilih'),
          const SizedBox(height: 16),
          if (!hasData)
            _emptyState(
              icon: Icons.label_outline_rounded,
              message: 'Pilih faktor saat check-in, lalu polanya akan tampil di sini.',
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 124,
                  height: 124,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(124, 124),
                        painter: _DonutPainter(
                          values: [for (final e in shown) e.value.toDouble()],
                          colors: _factorColors,
                          trackColor: AppColors.sagePale,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(shown.first.value / total * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: 64,
                            child: Text(
                              shown.first.key,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 0; i < shown.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == shown.length - 1 ? 0 : 9),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _factorColors[i],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  shown[i].key,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.textBody),
                                ),
                              ),
                              Text(
                                '${(shown[i].value / total * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
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
            const SizedBox(height: 14),
            const Text(
              'Porsi dari seluruh faktor yang kamu pilih bulan ini.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sagePale.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.sageDeep),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ringkasan ini hanya merangkum catatan yang kamu isi sendiri. '
              'Ini bukan diagnosis atau penilaian kondisi kesehatan mental. '
              'Jika kamu merasa kewalahan, pertimbangkan berbicara dengan orang '
              'tepercaya atau tenaga profesional.',
              style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Reusable widgets ─────────────────────────

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.titleSmall.copyWith(fontSize: 18)),
        const SizedBox(height: 2),
        Text(subtitle, style: AppText.bodyMedium),
      ],
    );
  }

  Widget _cardTitle(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.sagePale,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.sageDeep),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ),
      ],
    );
  }

  Widget _emptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Lencana daun dengan animasi bergoyang pelan.
/// Bisa dipakai ulang, misalnya untuk logo "Tenang" di app bar:
/// `const AnimatedLeafBadge(size: 32)`.
class AnimatedLeafBadge extends StatefulWidget {
  final double size;
  const AnimatedLeafBadge({super.key, this.size = 56});

  @override
  State<AnimatedLeafBadge> createState() => _AnimatedLeafBadgeState();
}

class _AnimatedLeafBadgeState extends State<AnimatedLeafBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);

  late final Animation<double> _sway = Tween<double>(begin: -0.14, end: 0.14).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sagePale,
        border: Border.all(color: AppColors.sageLight, width: 1.5),
      ),
      child: AnimatedBuilder(
        animation: _sway,
        builder: (context, child) => Transform.rotate(
          angle: _sway.value,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
        child: Icon(Icons.eco_rounded, size: widget.size * 0.52, color: AppColors.sageDeep),
      ),
    );
  }
}

/// Grafik donat dengan celah kecil antar segmen.
class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color trackColor;

  _DonutPainter({required this.values, required this.colors, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    canvas.drawArc(
      rect, 0, 6.2832, false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    const gap = 0.05; // radian
    var start = -1.5708; // mulai dari atas
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 6.2832;
      final drawSweep = values.length > 1 ? (sweep - gap).clamp(0.01, 6.2832) : sweep;
      canvas.drawArc(
        rect, start + (values.length > 1 ? gap / 2 : 0), drawSweep, false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}

/// Grafik garis mood 7 hari. Nilai null = hari tanpa catatan (garis terputus).
class _WeekChartPainter extends CustomPainter {
  final List<int?> values;
  final Color lineColor;
  final Color gridColor;
  final Color Function(int) colorFor;

  _WeekChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.colorFor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padY = 8.0;
    final h = size.height - padY * 2;
    final stepX = size.width / values.length;

    double yFor(int v) => padY + (5 - v) / 4 * h;
    double xFor(int i) => stepX * (i + 0.5);

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int l = 1; l <= 5; l++) {
      canvas.drawLine(Offset(0, yFor(l)), Offset(size.width, yFor(l)), grid);
    }

    final line = Paint()
      ..color = lineColor.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    var penDown = false;
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) {
        penDown = false;
        continue;
      }
      final p = Offset(xFor(i), yFor(v));
      if (penDown) {
        path.lineTo(p.dx, p.dy);
      } else {
        path.moveTo(p.dx, p.dy);
        penDown = true;
      }
    }
    canvas.drawPath(path, line);

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      final p = Offset(xFor(i), yFor(v));
      canvas.drawCircle(p, 7, Paint()..color = Colors.white);
      canvas.drawCircle(p, 5.5, Paint()..color = colorFor(v));
    }
  }

  @override
  bool shouldRepaint(covariant _WeekChartPainter old) => old.values != values;
}