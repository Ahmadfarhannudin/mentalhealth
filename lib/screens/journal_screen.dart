import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/ui/components.dart';
import '../data/models.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _selectedPrompt = 0;
  bool _referencesExpanded = false;

  final List<Map<String, String>> _prompts = [
    {
      'title': 'Hari ini',
      'prompt': 'Apa yang terasa berat hari ini? Apa yang terasa ringan?',
    },
    {
      'title': 'Perasaan',
      'prompt': 'Perasaan apa yang muncul dan mengapa? Apa yang memicu?',
    },
    {
      'title': 'Syukur',
      'prompt': 'Tiga hal kecil yang bisa aku syukuri hari ini.',
    },
    {
      'title': 'Pertumbuhan',
      'prompt': 'Satu hal yang aku pelajari tentang diri sendiri minggu ini.',
    },
  ];

  final List<JournalEntry> _entries = [];

  // Sumber primer dan tepercaya. Ringkasan tidak menggantikan artikel asli.
  final List<Map<String, String>> _references = [
    {
      'type': 'Systematic review',
      'title': 'Efficacy of journaling in the management of mental illness',
      'subtitle': 'BMJ Open · 2022',
      'summary': 'Tinjauan ini menemukan kemungkinan manfaat kecil hingga sedang dari journaling, tetapi hasil studi beragam dan masih membutuhkan penelitian lanjutan.',
      'source': 'PubMed · BMJ Open',
      'url': 'https://pubmed.ncbi.nlm.nih.gov/35304431/',
    },
    {
      'type': 'Meta-analysis',
      'title': 'The delayed, durable effect of expressive writing',
      'subtitle': 'British Journal of Clinical Psychology · 2023',
      'summary': 'Meta-analisis melaporkan efek rata-rata yang kecil pada gejala depresi, kecemasan, dan stres, dengan manfaat yang dapat muncul setelah jeda waktu.',
      'source': 'PubMed · Wiley',
      'url': 'https://pubmed.ncbi.nlm.nih.gov/36536513/',
    },
    {
      'type': 'Panduan kesehatan',
      'title': 'Doing What Matters in Times of Stress',
      'subtitle': 'World Health Organization · 2020',
      'summary': 'Panduan praktis WHO berisi latihan berbasis bukti untuk membantu menghadapi stres dan kesulitan sehari-hari.',
      'source': 'WHO · Panduan resmi',
      'url': 'https://www.who.int/publications/i/item/9789240003927',
    },
  ];

  Future<void> _openReference(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showMessage('Tautan referensi tidak valid.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Tautan tidak dapat dibuka. Periksa koneksi internet.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Tautan tidak dapat dibuka pada perangkat ini.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.page,
            Space.md,
            Space.page,
            140,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jurnal', style: AppText.displayMedium),
                      SizedBox(height: 2),
                      Text(
                        'Ruang refleksi pribadimu.',
                        style: AppText.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tentang privasi jurnal',
                  onPressed: () => _showPrivacyInfo(context),
                  icon: const Icon(Icons.lock_outline_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: Space.lg),
            _IntroCard(dateLabel: _dateLabel()),
            const SizedBox(height: Space.xl),
            const SectionHeading(
              title: 'Mau mulai dari mana?',
              subtitle: 'Pilih satu pemantik, lalu tulis dengan ritmemu.',
            ),
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: List.generate(_prompts.length, (index) {
                return QuietPill(
                  label: _prompts[index]['title']!,
                  selected: _selectedPrompt == index,
                  onTap: () => setState(() => _selectedPrompt = index),
                );
              }),
            ),
            const SizedBox(height: Space.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SoftCard(
                key: ValueKey(_selectedPrompt),
                color: AppColors.forestMist,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _prompts[_selectedPrompt]['prompt']!,
                      style: AppText.bodyLarge.copyWith(
                        color: AppColors.forestDeep,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    TextButton.icon(
                      onPressed: () => _showNewEntrySheet(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Mulai menulis'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(44, 44),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.xl),
            SectionHeading(
              title: 'Jurnal kamu',
              subtitle: _entries.isEmpty
                  ? 'Belum ada entri'
                  : '${_entries.length} entri tersimpan di sesi ini',
            ),
            const SizedBox(height: Space.md),
            if (_entries.isEmpty)
              QuietEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'Mulai dari satu cerita',
                message: 'Catatanmu akan tersusun di sini. Tidak perlu sempurna, cukup jujur.',
                action: OutlinedButton(
                  onPressed: () => _showNewEntrySheet(context),
                  child: const Text('Buat entri pertama'),
                ),
              )
            else
              for (final entry in _entries) ...[
                _EntryCard(entry: entry),
                const SizedBox(height: Space.md),
              ],
            const SizedBox(height: Space.lg),
            _ReferencesSection(
              expanded: _referencesExpanded,
              onToggle: () =>
                  setState(() => _referencesExpanded = !_referencesExpanded),
              references: _references,
              onOpen: _openReference,
            ),
            const SizedBox(height: Space.lg),
            const InfoNote(
              icon: Icons.spa_outlined,
              message: 'Tidak ada cara yang benar atau salah untuk menulis jurnal. Jika menulis membuatmu tidak nyaman, berhenti sejenak dan cari dukungan dari orang yang kamu percaya atau tenaga profesional.',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewEntrySheet(context),
        icon: const Icon(Icons.edit_outlined, size: 19),
        label: const Text('Tulis'),
      ),
    );
  }

  String _dateLabel() {
    final now = DateTime.now();
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
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.forest,
          size: 28,
        ),
        title: const Text('Ruang pribadimu'),
        content: const Text(
          'Entri jurnal pada versi ini disimpan di memori selama halaman berjalan dan belum tersimpan permanen. '
          'Hindari menulis informasi yang sangat sensitif sampai penyimpanan terenkripsi tersedia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showNewEntrySheet(BuildContext context) {
    final prompt = _prompts[_selectedPrompt]['prompt']!;

    showModalBottomSheet<JournalEntry?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final titleController = TextEditingController();
        final contentController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return Padding(
          padding: EdgeInsets.only(
            left: Space.page,
            right: Space.page,
            top: Space.sm,
            bottom: MediaQuery.of(context).viewInsets.bottom + Space.xl,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tuangkan isi pikiranmu', style: AppText.titleLarge),
                  const SizedBox(height: Space.sm),
                  Text(
                    'Ambil napas sejenak. Kamu bisa menulis dengan ritmemu sendiri.',
                    style: AppText.bodySmall,
                  ),
                  const SizedBox(height: Space.lg),
                  Container(
                    padding: const EdgeInsets.all(Space.md),
                    decoration: BoxDecoration(
                      color: AppColors.forestMist,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      prompt,
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.forestDeep,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  Text('Judul (opsional)', style: AppText.titleSmall),
                  const SizedBox(height: Space.sm),
                  TextFormField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Hari yang berarti',
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  Text('Ceritakan di sini', style: AppText.titleSmall),
                  const SizedBox(height: Space.sm),
                  TextFormField(
                    controller: contentController,
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 5000,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Apa yang kamu rasakan? Tidak perlu menyusun kata dengan sempurna.',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tuliskan sedikit refleksi sebelum menyimpan.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: Space.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final now = DateTime.now();
                        final title = titleController.text.trim();

                        final entry = JournalEntry(
                          id: now.microsecondsSinceEpoch.toString(),
                          title: title.isEmpty
                              ? 'Refleksi ${now.day}/${now.month}/${now.year}'
                              : title,
                          content: contentController.text.trim(),
                          prompt: prompt,
                          timestamp: now,
                        );

                        Navigator.of(sheetContext).pop(entry);
                      },
                      child: const Text('Simpan jurnal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((entry) {
      if (!mounted || entry == null) return;
      setState(() => _entries.insert(0, entry));
      _showMessage('Jurnal berhasil ditambahkan.');
    });
  }
}

class _IntroCard extends StatelessWidget {
  final String dateLabel;

  const _IntroCard({required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Space.xl),
      decoration: BoxDecoration(
        color: AppColors.forestMist,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.forestPale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                size: 16,
                color: AppColors.forestMid,
              ),
              const SizedBox(width: 6),
              Text(dateLabel, style: AppText.overline),
            ],
          ),
          const SizedBox(height: Space.md),
          const Text('Ruang kecil untuk dirimu.', style: AppText.titleLarge),
          const SizedBox(height: Space.sm),
          Text(
            'Tulis tanpa menghakimi diri sendiri. Tidak harus sempurna, cukup jujur dengan apa yang kamu rasakan.',
            style: AppText.bodySmall.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date =
        '${entry.timestamp.day.toString().padLeft(2, '0')}/${entry.timestamp.month.toString().padLeft(2, '0')}/${entry.timestamp.year}';

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(entry.title, style: AppText.titleSmall)),
              const SizedBox(width: Space.sm),
              Text(date, style: AppText.caption),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(
            entry.content,
            style: AppText.bodySmall.copyWith(
              color: AppColors.textBody,
              height: 1.65,
            ),
          ),
          const SizedBox(height: Space.md),
          Text(
            entry.prompt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption.copyWith(
              color: AppColors.forestMid,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferencesSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final List<Map<String, String>> references;
  final Future<void> Function(String url) onOpen;

  const _ReferencesSection({
    required this.expanded,
    required this.onToggle,
    required this.references,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_stories_outlined,
                      color: AppColors.forestMid,
                      size: 22,
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Referensi ilmiah', style: AppText.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            '${references.length} bacaan tepercaya tentang journaling dan stres',
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                0,
                Space.lg,
                Space.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: Space.md),
                  for (final reference in references) ...[
                    _ReferenceCard(
                      reference: reference,
                      onOpen: () => onOpen(reference['url']!),
                    ),
                    const SizedBox(height: Space.sm),
                  ],
                  const SizedBox(height: Space.xs),
                  Text(
                    'Ringkasan ini membantu memahami topik, bukan menggantikan artikel asli. Journaling bukan pengganti diagnosis atau perawatan profesional.',
                    style: AppText.caption.copyWith(height: 1.55),
                  ),
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  final Map<String, String> reference;
  final VoidCallback onOpen;

  const _ReferenceCard({required this.reference, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${reference['title']}, buka sumber eksternal',
      child: Material(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reference['type']!.toUpperCase(),
                        style: AppText.caption.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestMid,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(reference['title']!, style: AppText.titleSmall),
                const SizedBox(height: 2),
                Text(reference['subtitle']!, style: AppText.caption),
                const SizedBox(height: Space.sm),
                Text(reference['summary']!, style: AppText.bodySmall),
                const SizedBox(height: Space.sm),
                Text(
                  reference['source']!,
                  style: AppText.caption.copyWith(
                    color: AppColors.forestDeep,
                    fontWeight: FontWeight.w600,
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
