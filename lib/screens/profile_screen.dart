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
  bool _editingName = false;
  int _activeSection = 0;

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
              // Handle
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

              // Header bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.page, Space.md, Space.md, 0,
                ),
                child: Row(
                  children: [
                    Text('Akun', style: AppText.titleLarge),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.page, Space.lg, Space.page, Space.xxl,
                  ),
                  children: [
                    // ── Hero profil ──
                    _ProfileHeroCard(
                      controller: _nameController,
                      error: _error,
                      editing: _editingName,
                      onEditTap: () => setState(() {
                        _editingName = !_editingName;
                        _error = null;
                      }),
                      onNameChanged: () {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSave: _save,
                    ),

                    const SizedBox(height: Space.xl),

                    // ── Pengaturan ──
                    _SettingsGroup(
                      title: 'Notifikasi',
                      children: [
                        _SwitchTile(
                          icon: Icons.notifications_outlined,
                          label: 'Pengingat check-in',
                          subtitle: 'Ingatkan setiap hari untuk check-in',
                          value: true,
                          onChanged: (_) {},
                        ),
                        _SettingsDivider(),
                        _SwitchTile(
                          icon: Icons.bedtime_outlined,
                          label: 'Refleksi malam',
                          subtitle: 'Pengingat jurnal sebelum tidur',
                          value: false,
                          onChanged: (_) {},
                        ),
                      ],
                    ),

                    const SizedBox(height: Space.md),

                    _SettingsGroup(
                      title: 'Tampilan',
                      children: [
                        _SettingsTile(
                          icon: Icons.palette_outlined,
                          label: 'Tema',
                          subtitle: 'Mengikuti sistem',
                          onTap: () {},
                        ),
                        _SettingsDivider(),
                        _SettingsTile(
                          icon: Icons.text_fields_rounded,
                          label: 'Ukuran teks',
                          subtitle: 'Normal',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: Space.md),

                    _SettingsGroup(
                      title: 'Data & Privasi',
                      children: [
                        _SettingsTile(
                          icon: Icons.download_outlined,
                          label: 'Ekspor data',
                          subtitle: 'Unduh semua catatan sebagai file',
                          onTap: () {},
                        ),
                        _SettingsDivider(),
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Kebijakan privasi',
                          onTap: () {},
                        ),
                        _SettingsDivider(),
                        _SettingsTile(
                          icon: Icons.delete_outline_rounded,
                          label: 'Hapus semua data',
                          subtitle: 'Tindakan ini tidak bisa dibatalkan',
                          destructive: true,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: Space.md),

                    _SettingsGroup(
                      title: 'Tentang',
                      children: [
                        _SettingsTile(
                          icon: Icons.info_outline_rounded,
                          label: 'Versi aplikasi',
                          subtitle: '1.0.0',
                        ),
                        _SettingsDivider(),
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
                      icon: Icons.shield_outlined,
                      message:
                          'Semua catatan tersimpan hanya di perangkat ini. Tidak ada data yang dikirim ke server.',
                    ),

                    const SizedBox(height: Space.lg),
                    Center(
                      child: Text(
                        'Tenang · v1.0.0',
                        style: AppText.caption.copyWith(
                          color: AppColors.textLight,
                        ),
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
// Hero profil
// ─────────────────────────────────────────────

class _ProfileHeroCard extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final bool editing;
  final VoidCallback onEditTap;
  final VoidCallback onNameChanged;
  final VoidCallback onSave;

  const _ProfileHeroCard({
    required this.controller,
    required this.error,
    required this.editing,
    required this.onEditTap,
    required this.onNameChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              top: 0, left: 16, right: 16,
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

            Padding(
              padding: const EdgeInsets.all(Space.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFB7E4C7)
                                  .withValues(alpha: 0.18),
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
                                fontSize: 28,
                                height: 1,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: Space.lg),

                      // Nama + badge
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
                                  fontSize: 22,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4,
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

                      // Tombol edit
                      GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFB7E4C7)
                                .withValues(alpha: 0.18),
                            border: Border.all(
                              color: const Color(0xFFB7E4C7)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Icon(
                            editing
                                ? Icons.close_rounded
                                : Icons.edit_outlined,
                            color: const Color(0xFFD8F3DC),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Form edit nama — muncul saat editing
                  if (editing) ...[
                    const SizedBox(height: Space.lg),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => onNameChanged(),
                      onSubmitted: (_) => onSave(),
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
                          borderSide: const BorderSide(
                            color: Color(0xFFB7E4C7),
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF95D5B2),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB7E4C7)
                              .withValues(alpha: 0.25),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: const Color(0xFFB7E4C7)
                                  .withValues(alpha: 0.40),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Simpan perubahan',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Komponen settings
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
    final iconColor = destructive ? AppColors.moodBad : AppColors.forest;
    final iconBg = destructive
        ? AppColors.moodBadTint
        : AppColors.forestMist;
    final labelColor =
        destructive ? AppColors.moodBad : AppColors.textDark;

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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.bodyMedium.copyWith(
                        color: labelColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppText.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
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

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: widget.icon,
      label: widget.label,
      subtitle: widget.subtitle,
      trailing: Switch(
        value: _value,
        onChanged: (v) {
          setState(() => _value = v);
          widget.onChanged(v);
        },
        activeColor: AppColors.forest,
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 66, endIndent: Space.lg);
  }
}