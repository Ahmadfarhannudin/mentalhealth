import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _selectedPrompt = 0;

  final List<Map<String, String>> _prompts = [
    {'title': 'Hari ini', 'prompt': 'Apa yang terasa berat hari ini? Apa yang terasa ringan?'},
    {'title': 'Perasaan', 'prompt': 'Perasaan apa yang muncul dan mengapa? Apa yang memicu?'},
    {'title': 'Terima Kasih', 'prompt': 'Tiga hal kecil yang bisa aku syukuri hari ini.'},
    {'title': 'Pertumbuhan', 'prompt': 'Satu hal yang aku pelajari tentang diri sendiri minggu ini.'},
  ];

  final List<JournalEntry> _entries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Jurnal Terpandu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, size: 20),
            onPressed: () {},
            tooltip: 'Privasi',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Prompt Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih prompt hari ini', style: AppText.titleSmall),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_prompts.length, (i) {
                      final isSel = _selectedPrompt == i;
                      return FilterChip(
                        label: Text(_prompts[i]['title']!),
                        selected: isSel,
                        onSelected: (sel) => setState(() => _selectedPrompt = i),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.sagePale,
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.sageDeep : AppColors.textBody,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSel ? AppColors.sage : AppColors.border,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.sagePale,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.format_quote, color: AppColors.sageDeep, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _prompts[_selectedPrompt]['prompt']!,
                            style: AppText.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
            // Entry List
            Expanded(
              child: _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_stories_outlined, size: 64, color: AppColors.textLight),
                          const SizedBox(height: 16),
                          Text('Belum ada entri', style: AppText.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Mulai menulis refleksi hari ini.',
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.title, style: AppText.titleSmall),
                              const SizedBox(height: 8),
                              Text(
                                entry.content,
                                style: AppText.bodyMedium,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${entry.timestamp.day}/${entry.timestamp.month}',
                                style: AppText.caption,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewEntrySheet(context),
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('Tulis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.sage,
        elevation: 0,
      ),
    );
  }

  void _showNewEntrySheet(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.sagePale,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _prompts[_selectedPrompt]['prompt']!,
                style: AppText.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Judul jurnal...'),
              style: AppText.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(hintText: 'Tulis perasaanmu di sini...'),
              maxLines: 5,
              style: AppText.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  setState(() {
                    _entries.insert(
                      0,
                      JournalEntry(
                        id: DateTime.now().toString(),
                        title: titleController.text.isEmpty
                            ? 'Refleksi ${DateTime.now().day}/${DateTime.now().month}'
                            : titleController.text,
                        content: contentController.text,
                        prompt: _prompts[_selectedPrompt]['prompt']!,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Simpan Jurnal'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
