import 'dart:math' as math;
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
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
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
            _buildForestCard(),
            const SizedBox(height: 14),
            _buildWeekChartCard(),
            const SizedBox(height: 14),
            _buildTriggersCard(),
            const SizedBox(height: 20),
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(Icons.spa_outlined, size: 48, color: AppColors.sage),
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
            icon: Icons.wb_sunny_rounded,
            label: 'Konsisten',
            value: streak == 0 ? 'Mulai lagi' : '$streak hari',
            color: _Nature.sandTint,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStatCard(
            icon: Icons.forest_rounded,
            label: 'Bulan ini',
            value: monthCount == 0 ? 'Belum ada' : '$monthCount catatan',
            color: _Nature.mintTint,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStatCard(
            icon: Icons.spa_rounded,
            label: 'Rata-rata',
            value: avgMood,
            color: _Nature.lakeTint,
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

  // ───────────────────────── Greeting (nuansa alam minimalis) ─────────────────────────

  Widget _buildGreetingHeader(bool hasLoggedToday) {
    final name = widget.userName.trim().isEmpty
        ? 'Teman'
        : widget.userName.trim();

    final subtitle = hasLoggedToday
        ? 'Perasaanmu hari ini sudah tercatat. Terima kasih sudah meluangkan waktu untuk dirimu.'
        : 'Luangkan satu menit untuk menyadari apa yang kamu rasakan hari ini.';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC9D9BE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F7D55).withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // Ilustrasi bukit hanya di tepi bawah, tidak menimpa konten.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 20,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GreetingNaturePainter(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 16, 27),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dateLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF607D5D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_greeting,',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            color: Color(0xFF62716B),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 27,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: Color(0xFF34433D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.55,
                            color: Color(0xFF62716B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDCE9D3),
                      border: Border.all(
                        color: const Color(0xFF91B185),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF527452),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CustomPaint(painter: _MoodTreePainter(todayEntry.level)),
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

  /// Kalender bulanan berbentuk hutan: tiap hari tercatat menjadi satu pohon.
  /// Jenis pohon mengikuti mood hari itu. Hari yang belum dicatat tetap berupa tunas.
  Widget _buildForestCard() {
    final t = _today();
    final daysInMonth = DateTime(t.year, t.month + 1, 0).day;
    final offset = DateTime(t.year, t.month, 1).weekday - 1; // Senin = 0
    final levels = <int, int>{for (final e in _monthEntries) e.date.day: e.level};
    final logged = levels.length;
    final rows = ((offset + daysInMonth) / 7).ceil();
    const weekdayHeads = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.forest_rounded, 'Hutan ${_monthNames[t.month - 1]}'),
          const SizedBox(height: 12),
          Text('$logged dari $daysInMonth hari sudah tumbuh',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 3),
          Text(
            _streak > 0
                ? 'Kamu mencatat $_streak hari berturut-turut.'
                : 'Mulai lagi kapan pun kamu siap. Tidak ada yang tertinggal.',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final d in weekdayHeads)
                Expanded(
                  child: Center(
                    child: Text(d,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (int r = 0; r < rows; r++)
            Row(
              children: [
                for (int c = 0; c < 7; c++)
                  Expanded(
                    child: () {
                      final d = r * 7 + c - offset + 1;
                      if (d < 1 || d > daysInMonth) return const SizedBox(height: 50);
                      return _dayCell(d, t, levels);
                    }(),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              for (final mood in AppConstants.moodOptions)
                _legendItem(mood['level'] as int, mood['label'] as String),
              _legendItem(0, 'Belum dicatat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayCell(int d, DateTime t, Map<int, int> levels) {
    final isToday = d == t.day;
    final level = levels[d] ?? (d > t.day ? -1 : 0);
    return Container(
      height: 50,
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: isToday ? AppColors.sagePale : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CustomPaint(painter: _MoodTreePainter(level)),
          ),
          const SizedBox(height: 1),
          Text(
            '$d',
            style: TextStyle(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              color: isToday ? AppColors.sageDeep : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(int level, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CustomPaint(painter: _MoodTreePainter(level)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildWeekChartCard() {
    final values = _weekValues;
    final count = values.where((v) => v != null).length;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.spa_rounded, 'Mood 7 hari terakhir'),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int l = 5; l >= 1; l--)
                            Text(_emoji(l), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(
                      painter: _WeekChartPainter(
                        values: values,
                        gridColor: AppColors.border,
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
    _Nature.moss,
    _Nature.bark,
    _Nature.clay,
    _Nature.fern,
    _Nature.lake,
    _Nature.sand,
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
          _cardTitle(Icons.park_rounded, 'Faktor yang paling sering dipilih'),
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

  /// Kartu dengan ranting daun tipis di pojok kanan atas.
  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    bool sprig = true,
  }) {
    return Container(
      width: double.infinity,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            if (sprig)
              const Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: CustomPaint(painter: _SprigPainter()),
                  ),
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
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

// ═══════════════════════════════════════════════════════════════════════
//  NATURE KIT: palet, pohon, pemandangan, dan painter
//  Semua digambar sebagai bentuk datar (flat), bukan gradasi.
// ═══════════════════════════════════════════════════════════════════════

class _Nature {
  static const bark = Color(0xFF7A5C45);
  static const moss = Color(0xFF6F8F5A);
  static const fern = Color(0xFF9DB87C);
  static const pine = Color(0xFF4F7355);
  static const blossom = Color(0xFFE7A7B4);
  static const blossomLight = Color(0xFFF6D3DA);
  static const autumn = Color(0xFFD9894B);
  static const autumnDeep = Color(0xFFB9692F);
  static const rain = Color(0xFF8FA7B5);
  static const sand = Color(0xFFE0CFA9);
  static const clay = Color(0xFFC98B6B);
  static const lake = Color(0xFF8FB5B0);

  static const sandTint = Color(0xFFF3E9CF);
  static const mintTint = Color(0xFFDDEBCB);
  static const lakeTint = Color(0xFFD6E8E3);
}

enum _TreeKind { pine, round, blossom, autumn, bare, bush }

const List<Offset> _canopyDots = [
  Offset(-0.20, -0.62),
  Offset(0.18, -0.55),
  Offset(0.02, -0.80),
  Offset(-0.12, -0.92),
  Offset(0.22, -0.74),
];

/// Menggambar satu pohon dengan pangkal di [base], tinggi [h].
void _paintTree(
  Canvas c,
  _TreeKind kind,
  Offset base,
  double h, {
  required Color trunk,
  required Color leaf,
  Color? accent,
  double sway = 0,
}) {
  c.save();
  c.translate(base.dx, base.dy);
  c.rotate(sway);
  final tp = Paint()..color = trunk;
  final lp = Paint()..color = leaf;

  switch (kind) {
    case _TreeKind.pine:
      {
        final tw = h * 0.07;
        c.drawRect(Rect.fromLTWH(-tw / 2, -h * 0.18, tw, h * 0.18), tp);
        for (int i = 0; i < 3; i++) {
          final apex = -h + i * h * 0.24;
          final bot = apex + h * 0.42;
          final hw = h * (0.19 + 0.08 * i);
          c.drawPath(
            Path()
              ..moveTo(0, apex)
              ..lineTo(-hw, bot)
              ..lineTo(hw, bot)
              ..close(),
            lp,
          );
        }
      }
    case _TreeKind.round:
    case _TreeKind.blossom:
    case _TreeKind.autumn:
      {
        final tw = h * 0.08;
        c.drawRect(Rect.fromLTWH(-tw / 2, -h * 0.4, tw, h * 0.4), tp);
        c.drawCircle(Offset(0, -h * 0.62), h * 0.3, lp);
        c.drawCircle(Offset(-h * 0.2, -h * 0.5), h * 0.22, lp);
        c.drawCircle(Offset(h * 0.2, -h * 0.5), h * 0.22, lp);
        c.drawCircle(Offset(0, -h * 0.78), h * 0.2, lp);
        if (accent != null) {
          final ap = Paint()..color = accent;
          for (final o in _canopyDots) {
            c.drawCircle(Offset(o.dx * h, o.dy * h), h * 0.045, ap);
          }
        }
      }
    case _TreeKind.bare:
      {
        final bp = Paint()
          ..color = trunk
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = h * 0.07;
        c.drawLine(Offset.zero, Offset(0, -h * 0.58), bp);
        bp.strokeWidth = h * 0.04;
        c.drawLine(Offset(0, -h * 0.35), Offset(-h * 0.22, -h * 0.62), bp);
        c.drawLine(Offset(0, -h * 0.45), Offset(h * 0.22, -h * 0.76), bp);
        c.drawLine(Offset(0, -h * 0.58), Offset(-h * 0.1, -h * 0.96), bp);
        c.drawLine(Offset(0, -h * 0.58), Offset(h * 0.12, -h * 0.9), bp);
      }
    case _TreeKind.bush:
      {
        c.drawCircle(Offset(-h * 0.45, -h * 0.3), h * 0.35, lp);
        c.drawCircle(Offset(h * 0.45, -h * 0.3), h * 0.35, lp);
        c.drawCircle(Offset(0, -h * 0.5), h * 0.45, lp);
      }
  }
  c.restore();
}

/// Menggambar sehelai daun. [angle] 0 = menunjuk ke kanan.
void _drawLeaf(Canvas c, Offset o, double angle, double len, Paint fill, {Paint? outline}) {
  c.save();
  c.translate(o.dx, o.dy);
  c.rotate(angle);
  final path = Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(len * 0.5, -len * 0.45, len, 0)
    ..quadraticBezierTo(len * 0.5, len * 0.45, 0, 0);
  c.drawPath(path, fill);
  if (outline != null) c.drawPath(path, outline);
  c.restore();
}

// ───────────────────────── Pohon mood (ikon kalender) ─────────────────────────

/// level 1..5 = pohon sesuai mood, 0 = belum dicatat (tunas), -1 = hari yang belum tiba.
class _MoodTreePainter extends CustomPainter {
  final int level;
  const _MoodTreePainter(this.level);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final base = Offset(w / 2, h * 0.9);

    if (level < 0) {
      canvas.drawCircle(base - const Offset(0, 2), 1.6, Paint()..color = _Nature.sand);
      return;
    }

    canvas.drawOval(
      Rect.fromCenter(center: base, width: w * 0.64, height: h * 0.1),
      Paint()..color = _Nature.sand.withValues(alpha: 0.85),
    );

    if (level == 0) {
      final stem = Paint()
        ..color = _Nature.moss.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(base, base - Offset(0, h * 0.3), stem);
      final lf = Paint()..color = _Nature.moss.withValues(alpha: 0.5);
      final top = base - Offset(0, h * 0.2);
      _drawLeaf(canvas, top, -0.7, h * 0.2, lf);
      _drawLeaf(canvas, top, -math.pi + 0.7, h * 0.2, lf);
      return;
    }

    final th = h * 0.8;
    switch (level) {
      case 5:
        _paintTree(canvas, _TreeKind.blossom, base, th,
            trunk: _Nature.bark, leaf: _Nature.blossom, accent: _Nature.blossomLight);
      case 4:
        _paintTree(canvas, _TreeKind.round, base, th,
            trunk: _Nature.bark, leaf: _Nature.moss, accent: _Nature.fern);
      case 3:
        _paintTree(canvas, _TreeKind.pine, base, th,
            trunk: _Nature.bark, leaf: _Nature.pine);
      case 2:
        _paintTree(canvas, _TreeKind.autumn, base, th,
            trunk: _Nature.bark, leaf: _Nature.autumn, accent: _Nature.autumnDeep);
      default:
        _paintTree(canvas, _TreeKind.bare, base, th,
            trunk: _Nature.bark.withValues(alpha: 0.85), leaf: _Nature.bark);
        final rp = Paint()
          ..color = _Nature.rain
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 3; i++) {
          final x = w * (0.28 + 0.22 * i);
          final y = h * (0.10 + 0.06 * (i % 2));
          canvas.drawLine(Offset(x, y), Offset(x - 1.5, y + h * 0.12), rp);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _MoodTreePainter old) => old.level != level;
}

// ───────────────────────── Ranting hias di kartu ─────────────────────────

class _SprigPainter extends CustomPainter {
  const _SprigPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p0 = Offset(w, 0);
    final p1 = Offset(w * 0.55, h * 0.1);
    final p2 = Offset(w * 0.18, h * 0.78);

    canvas.drawPath(
      Path()
        ..moveTo(p0.dx, p0.dy)
        ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy),
      Paint()
        ..color = _Nature.moss.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    final leaf = Paint()..color = _Nature.moss.withValues(alpha: 0.16);
    for (int i = 1; i <= 5; i++) {
      final t = i / 6;
      final mt = 1 - t;
      final x = mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx;
      final y = mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy;
      final dx = 2 * mt * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx);
      final dy = 2 * mt * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy);
      final ang = math.atan2(dy, dx);
      final side = i.isEven ? 1.0 : -1.0;
      _drawLeaf(canvas, Offset(x, y), ang + side * 0.9, 15, leaf);
    }
  }

  @override
  bool shouldRepaint(covariant _SprigPainter old) => false;
}

// ───────────────────────── Lencana daun ─────────────────────────

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

// ───────────────────────── Grafik ─────────────────────────

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

/// Grafik mood 7 hari berbentuk sulur: garis melengkung dengan daun
/// berwarna sesuai mood. Nilai null = hari tanpa catatan (sulur terputus).
class _WeekChartPainter extends CustomPainter {
  final List<int?> values;
  final Color gridColor;
  final Color Function(int) colorFor;

  _WeekChartPainter({
    required this.values,
    required this.gridColor,
    required this.colorFor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padY = 18.0;
    final h = size.height - padY * 2;
    final stepX = size.width / values.length;

    double yFor(int v) => padY + (5 - v) / 4 * h;
    double xFor(int i) => stepX * (i + 0.5);

    // garis bantu putus-putus
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int l = 1; l <= 5; l++) {
      final y = yFor(l);
      for (double x = 0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 4, size.width), y), grid);
      }
    }

    // sulur
    final vine = Paint()
      ..color = _Nature.bark.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < values.length - 1; i++) {
      final a = values[i], b = values[i + 1];
      if (a == null || b == null) continue;
      final p0 = Offset(xFor(i), yFor(a));
      final p1 = Offset(xFor(i + 1), yFor(b));
      final cx = (p0.dx + p1.dx) / 2;
      canvas.drawPath(
        Path()
          ..moveTo(p0.dx, p0.dy)
          ..cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy),
        vine,
      );
    }

    // daun + simpul
    final outline = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      final p = Offset(xFor(i), yFor(v));
      final ang = i.isEven ? -0.9 : -math.pi + 0.9;
      _drawLeaf(canvas, p, ang, 17, Paint()..color = colorFor(v), outline: outline);
      canvas.drawCircle(p, 4.6, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.1, Paint()..color = _Nature.bark);
    }
  }

  @override
  bool shouldRepaint(covariant _WeekChartPainter old) => old.values != values;
}

/// Ilustrasi bukit minimalis untuk bagian bawah kartu sapaan.
/// Dibuat ringan dan tidak menutupi teks maupun avatar.
class _GreetingNaturePainter extends CustomPainter {
  const _GreetingNaturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final backHill = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.24, h * 0.12, w * 0.49, h * 0.64)
      ..quadraticBezierTo(w * 0.76, h * 1.05, w, h * 0.38)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      backHill,
      Paint()..color = const Color(0xFFD8E7CE),
    );

    final frontHill = Path()
      ..moveTo(0, h * 0.84)
      ..quadraticBezierTo(w * 0.32, h * 0.42, w * 0.62, h * 0.82)
      ..quadraticBezierTo(w * 0.83, h * 1.05, w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      frontHill,
      Paint()..color = const Color(0xFFBBD3A9),
    );

    final grassPaint = Paint()
      ..color = const Color(0xFF6F9665).withValues(alpha: 0.78)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (final x in [w * 0.07, w * 0.13, w * 0.77, w * 0.84, w * 0.94]) {
      canvas.drawLine(Offset(x, h), Offset(x - 2, h * 0.65), grassPaint);
      canvas.drawLine(Offset(x, h), Offset(x + 3, h * 0.73), grassPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GreetingNaturePainter oldDelegate) => false;
}

