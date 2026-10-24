import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/ui/components.dart';
import '../coping/coping_exercises.dart';

class ProfileDraft {
  final String name;
  const ProfileDraft({required this.name});
}

class ProfileSheet extends StatefulWidget {
  final String name;

  const ProfileSheet({super.key, required this.name});

  static Future<ProfileDraft?> show(
    BuildContext context, {
    required String name,
  }) {
    return showModalBottomSheet<ProfileDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileSheet(name: name),
    );
  }

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late final TextEditingController _nameController;
  String? _error;
  int _activeSection = 0; // 0: Profil, 1: Preferensi, 2: Tentang

  static const _tags = [
    'Pekerjaan', 'Tidur', 'Keluarga',
    'Kesehatan', 'Sosial', 'Hubungan',
  ];

  static const _prompts = [
    ('Hari ini', 'Apa yang terasa berat, apa yang terasa ringan.'),
    ('Perasaan', 'Perasaan apa yang muncul, dan apa yang memicu.'),
    ('Syukur', 'Tiga hal kecil yang bisa disyukuri hari ini.'),
    ('Pertumbuhan', 'Satu hal yang dipelajari tentang diri minggu ini.'),
  ];

  static const _moods = [
    ('Tenang', AppColors.moodGreat),
    ('Baik', AppColors.moodGood),
    ('Biasa', AppColors.moodOkay),
    ('Lelah', AppColors.moodLow),
    ('Berat', AppColors.moodBad),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Isi nama panggilan dulu.');
      return;
    }
    Navigator.pop(context, ProfileDraft(name: name));
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final height = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SizedBox(
        height: height,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Handle ──
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // ── Hero header ──
              _ProfileHero(
                controller: _nameController,
                onSave: _save,
                error: _error,
                onNameChanged: () {
                  if (_error != null) setState(() => _error = null);
                },
              ),

              // ── Tab bar ──
              _SectionTabs(
                active: _activeSection,
                onChanged: (i) => setState(() => _activeSection = i),
              ),

              // ── Konten ──
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _activeSection == 0
                      ? _ProfileSection(
                          tags: _tags,
                          moods: _moods,
                        )
                      : _activeSection == 1
                          ? _PreferencesSection(
                              prompts: _prompts,
                              exercises: copingExercises,
                            )
                          : const _AboutSection(),
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
// Hero header
// ─────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final String? error;
  final VoidCallback onNameChanged;

  const _ProfileHero({
    required this.controller,
    required this.onSave,
    required this.error,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
      padding: const EdgeInsets.all(Space.xl),
      decoration: BoxDecoration(
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Tinted glass
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF74C69D).withValues(alpha: 0.22),
                      const Color(0xFF52B788).withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Highlight atas
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
                      const Color(0xFFB7E4C7).withValues(alpha: 0.60),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        final letter = value.text.trim().isEmpty
                            ? '?'
                            : value.text
                                .trim()
                                .characters
                                .first
                                .toUpperCase();
                        return Container(
                          width: 62,
                          height: 62,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFB7E4C7)
                                .withValues(alpha: 0.20),
                            border: Border.all(
                              color: const Color(0xFFB7E4C7)
                                  .withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            letter,
                            style: AppText.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller,
                            builder: (context, value, _) => Text(
                              value.text.trim().isEmpty
                                  ? 'Nama kamu'
                                  : value.text.trim(),
                              style: AppText.titleLarge.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB7E4C7)
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFB7E4C7)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'Pengguna Tenang',
                              style: AppText.caption.copyWith(
                                color: const Color(0xFFD8F3DC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol simpan
                    GestureDetector(
                      onTap: onSave,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB7E4C7)
                              .withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFB7E4C7)
                                .withValues(alpha: 0.40),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          style: AppText.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.lg),

                // Field nama
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => onNameChanged(),
                  style: AppText.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nama panggilan',
                    labelStyle: TextStyle(
                      color: const Color(0xFF95D5B2),
                      fontSize: 13,
                    ),
                    hintText: 'Dipakai di sapaan check-in',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    errorText: error,
                    filled: true,
                    fillColor: const Color(0xFF74C69D)
                        .withValues(alpha: 0.12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: const Color(0xFFB7E4C7)
                            .withValues(alpha: 0.30),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: const Color(0xFFB7E4C7)
                            .withValues(alpha: 0.70),
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: const Color(0xFF95D5B2),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab bar
// ─────────────────────────────────────────────

class _SectionTabs extends StatelessWidget {
  final int active;
  final ValueChanged<int> onChanged;

  const _SectionTabs({required this.active, required this.onChanged});

  static const _tabs = [
    (Icons.person_outline_rounded, 'Profil'),
    (Icons.tune_rounded, 'Preferensi'),
    (Icons.info_outline_rounded, 'Tentang'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final active = i == this.active;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tabs[i].$1,
                        size: 18,
                        color: active
                            ? AppColors.forest
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tabs[i].$2,
                        style: AppText.caption.copyWith(
                          color: active
                              ? AppColors.forestDeep
                              : AppColors.textMuted,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab: Profil
// ─────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  final List<String> tags;
  final List<(String, Color)> moods;

  const _ProfileSection({required this.tags, required this.moods});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('profil'),
      padding: const EdgeInsets.fromLTRB(
        Space.page, Space.lg, Space.page, Space.xxl,
      ),
      children: [
        _SettingsGroup(
          title: 'Skala mood',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.md, Space.lg, Space.lg,
              ),
              child: Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  for (final mood in moods)
                    StatusChip(
                      label: mood.$1,
                      color: mood.$2,
                      background: AppColors.surfaceAlt,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        _SettingsGroup(
          title: 'Tag check-in',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.md, Space.lg, Space.lg,
              ),
              child: Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  for (final tag in tags) QuietPill(label: tag),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        _SettingsGroup(
          title: 'Data',
          children: [
            _SettingsTile(
              icon: Icons.download_outlined,
              label: 'Ekspor data',
              subtitle: 'Unduh semua catatan sebagai file',
              onTap: () {},
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus semua data',
              subtitle: 'Tidak bisa dibatalkan',
              destructive: true,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tab: Preferensi
// ─────────────────────────────────────────────

class _PreferencesSection extends StatefulWidget {
  final List<(String, String)> prompts;
  final List<CopingExercise> exercises;

  const _PreferencesSection({
    required this.prompts,
    required this.exercises,
  });

  @override
  State<_PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<_PreferencesSection> {
  bool _notifEnabled = true;
  bool _reminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('preferensi'),
      padding: const EdgeInsets.fromLTRB(
        Space.page, Space.lg, Space.page, Space.xxl,
      ),
      children: [
        _SettingsGroup(
          title: 'Notifikasi',
          children: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Pengingat check-in',
              subtitle: 'Ingatkan setiap hari',
              trailing: Switch(
                value: _notifEnabled,
                onChanged: (v) => setState(() => _notifEnabled = v),
                activeColor: AppColors.forest,
              ),
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.bedtime_outlined,
              label: 'Pengingat malam',
              subtitle: 'Refleksi sebelum tidur',
              trailing: Switch(
                value: _reminderEnabled,
                onChanged: (v) => setState(() => _reminderEnabled = v),
                activeColor: AppColors.forest,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        _SettingsGroup(
          title: 'Prompt jurnal',
          children: [
            for (int i = 0; i < widget.prompts.length; i++) ...[
              _SettingsTile(
                icon: Icons.edit_note_rounded,
                label: widget.prompts[i].$1,
                subtitle: widget.prompts[i].$2,
              ),
              if (i < widget.prompts.length - 1) _SettingsDivider(),
            ],
          ],
        ),
        const SizedBox(height: Space.md),
        _SettingsGroup(
          title: 'Latihan tersedia',
          children: [
            for (int i = 0; i < widget.exercises.length; i++) ...[
              _SettingsTile(
                icon: widget.exercises[i].icon,
                label: widget.exercises[i].title,
                subtitle:
                    '${widget.exercises[i].category} · ${widget.exercises[i].minutes} menit',
              ),
              if (i < widget.exercises.length - 1) _SettingsDivider(),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tab: Tentang
// ─────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('tentang'),
      padding: const EdgeInsets.fromLTRB(
        Space.page, Space.lg, Space.page, Space.xxl,
      ),
      children: [
        _SettingsGroup(
          title: 'Aplikasi',
          children: [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'Versi',
              subtitle: '1.0.0',
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.article_outlined,
              label: 'Kebijakan privasi',
              onTap: () {},
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.description_outlined,
              label: 'Syarat penggunaan',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        _SettingsGroup(
          title: 'Dukungan',
          children: [
            _SettingsTile(
              icon: Icons.star_outline_rounded,
              label: 'Beri ulasan',
              onTap: () {},
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.bug_report_outlined,
              label: 'Laporkan masalah',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: Space.xl),
        const InfoNote(
          icon: Icons.lock_outline_rounded,
          message:
              'Catatan check-in, jurnal, dan obrolan dengan Teman tetap di perangkat ini. Tidak ada data yang dikirim ke server.',
        ),
        const SizedBox(height: Space.lg),
        Center(
          child: Text(
            'Dibuat dengan ❤️ untuk kesehatan mental',
            style: AppText.caption.copyWith(color: AppColors.textLight),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Komponen settings reusable
// ─────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: Space.sm),
          child: Text(
            title.toUpperCase(),
            style: AppText.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.moodBad : AppColors.forest;
    final textColor = destructive ? AppColors.moodBad : AppColors.textDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: destructive
                      ? AppColors.moodBadTint
                      : AppColors.forestMist,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.bodyMedium.copyWith(color: textColor),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppText.caption),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 68, endIndent: Space.lg);
  }
}