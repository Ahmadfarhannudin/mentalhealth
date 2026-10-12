import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int _selectedMood = 5;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _tags = ['Pekerjaan', 'Keluarga', 'Tidur', 'Kesehatan', 'Hubungan', 'Sosial'];
  final Set<String> _selectedTags = {'Tidur'};

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Check-in Suasana Hati'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bagaimana perasaanmu\nsaat ini?',
                style: AppText.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ada penilaian di sini. Sadari saja apa yang ada.',
                style: AppText.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Mood Selector Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: AppConstants.moodOptions.map((mood) {
                  final isSelected = _selectedMood == mood['level'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = mood['level'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(mood['color']).withValues(alpha: 0.25) : AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? Color(mood['color']) : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(mood['color']).withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood['emoji'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood['label'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.textDark : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // Factor Tags
              Text('Apa yang paling memengaruhimu?', style: AppText.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _tags.map((tag) {
                  final isTagSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isTagSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
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
                      side: BorderSide(
                        color: isTagSelected ? AppColors.sage : AppColors.border,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Note Input
              Text('Catatan Singkat (opsional)', style: AppText.titleSmall),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan sedikit tentang hal yang membuatmu merasa begini...',
                  fillColor: AppColors.surface,
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catatan suasana hati tersimpan dengan tenang.'),
                      backgroundColor: AppColors.sage,
                    ),
                  );
                },
                child: const Text('Simpan Refleksi'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
