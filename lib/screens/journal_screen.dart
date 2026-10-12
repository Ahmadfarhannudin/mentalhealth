import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'title': 'Terima Kasih',
      'prompt': 'Tiga hal kecil yang bisa aku syukuri hari ini.',
    },
    {
      'title': 'Pertumbuhan',
      'prompt': 'Satu hal yang aku pelajari tentang diri sendiri minggu ini.',
    },
  ];

  final List<JournalEntry> _entries = [];

  // Tautan menuju sumber primer/tepercaya. Ringkasan tidak menggantikan artikel asli.
  final List<Map<String, String>> _references = [
    {
      'type': 'SYSTEMATIC REVIEW',
      'title': 'Efficacy of journaling in the management of mental illness',
      'subtitle': 'Systematic review and meta-analysis · 2022',
      'summary': 'Tinjauan ini menemukan kemungkinan manfaat kecil hingga sedang dari journaling, tetapi hasil studi beragam dan masih membutuhkan penelitian lebih lanjut.',
      'source': 'PubMed · BMJ Open',
      'url': 'https://pubmed.ncbi.nlm.nih.gov/35304431/',
      'color': 'sage',
    },
    {
      'type': 'META-ANALYSIS',
      'title': 'The delayed, durable effect of expressive writing',
      'subtitle': 'British Journal of Clinical Psychology · 2023',
      'summary': 'Meta-analisis melaporkan efek rata-rata yang kecil pada gejala depresi, kecemasan, dan stres, dengan manfaat yang dapat muncul setelah jeda waktu.',
      'source': 'PubMed · Wiley',
      'url': 'https://pubmed.ncbi.nlm.nih.gov/36536513/',
      'color': 'peach',
    },
    {
      'type': 'PANDUAN KESEHATAN',
      'title': 'Doing What Matters in Times of Stress',
      'subtitle': 'World Health Organization · 2020',
      'summary': 'Panduan praktis WHO berisi latihan berbasis bukti untuk membantu menghadapi stres dan kesulitan sehari-hari.',
      'source': 'WHO · Panduan resmi',
      'url': 'https://www.who.int/publications/i/item/9789240003927',
      'color': 'blue',
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
        _showMessage(
          'Tautan tidak dapat dibuka. Coba periksa koneksi internet.',
        );
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
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF425D48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A9B7E), Color(0xFF5C7A5F)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Jurnal Terpandu',
                  style: TextStyle(
                    color: Color(0xFF34433D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Ruang refleksi pribadimu',
                  style: TextStyle(
                    color: Color(0xFF7A8B84),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Privasi jurnal',
            icon: const Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: Color(0xFF40574A),
            ),
            onPressed: () => _showPrivacyInfo(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.sizeOf(context).width >= 600 ? 28 : 18,
              8,
              MediaQuery.sizeOf(context).width >= 600 ? 28 : 18,
              112,
            ),
            children: [
              _buildIntro(),
              const SizedBox(height: 24),
              _buildPromptSection(),
              const SizedBox(height: 26),
              _buildEntriesSection(),
              const SizedBox(height: 28),
              _buildReferencesSection(),
              const SizedBox(height: 18),
              _buildGentleReminder(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewEntrySheet(context),
        backgroundColor: const Color(0xFF789A7A),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.edit_rounded, size: 19),
        label: const Text(
          'Tulis jurnal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildIntro() {
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
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF1E3), Color(0xFFF4F4E9)],
        ),
        border: Border.all(color: const Color(0xFFDCE7D4)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -12,
            child: Icon(
              Icons.spa_rounded,
              size: 78,
              color: const Color(0xFF9DB695).withValues(alpha: 0.16),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    size: 16,
                    color: Color(0xFF718D68),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF61765D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Ruang kecil untuk dirimu.',
                style: TextStyle(
                  fontSize: 23,
                  height: 1.18,
                  letterSpacing: -0.7,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF34433D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tulis tanpa menghakimi diri sendiri. Tidak harus sempurna, cukup jujur dengan apa yang kamu rasakan.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: Color(0xFF62716A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'MULAI DARI SINI',
          title: 'Apa yang ingin kamu ceritakan?',
          icon: Icons.chat_bubble_outline_rounded,
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 9,
          children: List.generate(_prompts.length, (index) {
            final selected = _selectedPrompt == index;
            final icons = [
              Icons.wb_twilight_rounded,
              Icons.favorite_border_rounded,
              Icons.volunteer_activism_outlined,
              Icons.spa_outlined,
            ];

            return ChoiceChip(
              avatar: Icon(
                icons[index],
                size: 16,
                color: selected
                    ? const Color(0xFF496B4B)
                    : const Color(0xFF829087),
              ),
              label: Text(_prompts[index]['title']!),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedPrompt = index),
              backgroundColor: const Color(0xFFF8F8F2),
              selectedColor: const Color(0xFFDDE9D5),
              side: BorderSide(
                color: selected
                    ? const Color(0xFFA9C49D)
                    : const Color(0xFFE0E6DB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF496B4B)
                    : const Color(0xFF586760),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            );
          }),
        ),
        const SizedBox(height: 14),
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDDE),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD7E4CE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFD2E1C9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.format_quote_rounded,
                  size: 21,
                  color: Color(0xFF527451),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _prompts[_selectedPrompt]['prompt']!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF42574A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showNewEntrySheet(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mulai menulis',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF527451),
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Color(0xFF527451),
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
      ],
    );
  }

  Widget _buildEntriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'CATATAN PRIBADI',
          title: 'Jurnal kamu',
          icon: Icons.auto_stories_rounded,
          trailing: _entries.isNotEmpty
              ? Text(
                  '${_entries.length} entri',
                  style: const TextStyle(
                    color: Color(0xFF75877B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 14),
        if (_entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F2),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: const Color(0xFFE1E7DB)),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7EEDF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 29,
                    color: Color(0xFF7F9B7D),
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Mulai dari satu cerita',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E4E45),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Catatanmu akan tersusun di sini.\nAmbil waktumu, tidak perlu terburu-buru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.55,
                    color: Color(0xFF829087),
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () => _showNewEntrySheet(context),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Buat entri pertama'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF527451),
                    side: const BorderSide(color: Color(0xFFB9CEAE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._entries.map(_buildEntryCard),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final date =
        '${entry.timestamp.day.toString().padLeft(2, '0')}/${entry.timestamp.month.toString().padLeft(2, '0')}/${entry.timestamp.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFAFBF6).withValues(alpha: 0.92),
            const Color(0xFFEEF4E8).withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFD4E3C8).withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF647B5E).withValues(alpha: 0.055),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7EEDF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF668566),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF394940),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(fontSize: 10, color: Color(0xFF829087)),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            entry.content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF596960),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              entry.prompt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 1.35,
                color: Color(0xFF60785D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE5D5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  setState(() => _referencesExpanded = !_referencesExpanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 17, 15, 17),
                child: Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1EAD9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Color(0xFF5F805E),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BACAAN PILIHAN',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF82927F),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Referensi ilmiah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.25,
                              color: Color(0xFF34433D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Bacaan tepercaya tentang journaling dan stres',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Color(0xFF7A8980),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7EEDF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '3 sumber',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5E7A5B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    AnimatedRotation(
                      turns: _referencesExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF668566),
                        size: 23,
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
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFDDE5D5)),
                  const SizedBox(height: 14),
                  ..._references.map(_buildReferenceCard),
                  const SizedBox(height: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Color(0xFF829087),
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Ringkasan ini untuk membantu memahami topik, bukan menggantikan artikel asli. Journaling bukan pengganti diagnosis atau perawatan profesional; hasil penelitian juga bervariasi.',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.55,
                              color: Color(0xFF7D8A81),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _referencesExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 260),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(Map<String, String> reference) {
    final colorName = reference['color'];
    final Color accent;
    final Color pale;
    final Color cardStart;
    final Color cardEnd;

    switch (colorName) {
      case 'peach':
        accent = const Color(0xFFB77D5F);
        pale = const Color(0xFFF5E8DE);
        cardStart = const Color(0xFFFDF9F5);
        cardEnd = const Color(0xFFF9EFE6);
        break;
      case 'blue':
        accent = const Color(0xFF648B88);
        pale = const Color(0xFFE4EFEB);
        cardStart = const Color(0xFFF6FAF9);
        cardEnd = const Color(0xFFEBF3F1);
        break;
      default:
        accent = const Color(0xFF668566);
        pale = const Color(0xFFE7EEDF);
        cardStart = const Color(0xFFF8FBF4);
        cardEnd = const Color(0xFFEEF4E8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardStart.withValues(alpha: 0.90),
            cardEnd.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pale.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openReference(reference['url']!),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: pale,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      color: accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: pale,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            reference['type']!,
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          reference['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF394940),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reference['subtitle']!,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.4,
                            color: Color(0xFF849087),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new_rounded, size: 16, color: accent),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                reference['summary']!,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: Color(0xFF627169),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.link_rounded, size: 15, color: accent),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      reference['source']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                  Text(
                    'Buka sumber',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading({
    required String eyebrow,
    required String title,
    required IconData icon,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDDE),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 19, color: const Color(0xFF668566)),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF82927F),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: Color(0xFF34433D),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[trailing],
      ],
    );
  }

  Widget _buildGentleReminder() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0E5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.spa_outlined, color: Color(0xFF668566), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tidak ada cara yang benar atau salah untuk menulis jurnal. Jika menulis membuatmu semakin tidak nyaman, berhenti sejenak dan cari dukungan dari orang yang kamu percaya atau tenaga profesional.',
              style: TextStyle(
                fontSize: 11,
                height: 1.55,
                color: Color(0xFF627169),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF8F9F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFF668566),
          size: 30,
        ),
        title: const Text(
          'Ruang pribadimu',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF34433D),
          ),
        ),
        content: const Text(
          'Tulisan di halaman ini dikelola oleh aplikasi. Pada versi saat ini, entri disimpan di memori selama halaman berjalan dan belum tersimpan permanen ke database. Hindari menulis informasi yang sangat sensitif.',
          style: TextStyle(height: 1.5, color: Color(0xFF627169)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                color: Color(0xFF527451),
                fontWeight: FontWeight.w700,
              ),
            ),
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
      backgroundColor: const Color(0xFFF5F6EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        final titleController = TextEditingController();
        final contentController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7D2C0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Tuangkan isi pikiranmu',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF34433D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ambil napas sejenak. Kamu bisa menulis dengan ritmemu sendiri.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Color(0xFF75847A),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EDDE),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.format_quote_rounded,
                              color: Color(0xFF668566),
                              size: 22,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                prompt,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Color(0xFF42574A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Judul (opsional)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF526258),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          'Contoh: Hari yang berarti',
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF34433D),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Ceritakan di sini',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF526258),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: contentController,
                        minLines: 5,
                        maxLines: 8,
                        maxLength: 5000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          'Apa yang kamu rasakan? Tidak perlu menyusun kata dengan sempurna...',
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: Color(0xFF34433D),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tuliskan sedikit refleksi sebelum menyimpan.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
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
                          icon: const Icon(Icons.check_rounded, size: 19),
                          label: const Text(
                            'Simpan jurnal',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF789A7A),
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
                ),
              ),
            );
          },
        );
      },
    ).then((entry) {
      if (!mounted || entry == null) return;
      setState(() {
        _entries.insert(0, entry);
      });
      _showMessage('Jurnal berhasil ditambahkan.');
    });
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        height: 1.45,
        color: Color(0xFF9AA59B),
      ),
      filled: true,
      fillColor: const Color(0xFFFBFCF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFDCE5D6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFDCE5D6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF8EAD85), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFCC8275)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFCC8275), width: 1.5),
      ),
      counterStyle: const TextStyle(fontSize: 10, color: Color(0xFF89968C)),
    );
  }
}
