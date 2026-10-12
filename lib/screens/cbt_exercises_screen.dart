import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';

class CbtExercisesScreen extends StatefulWidget {
  const CbtExercisesScreen({super.key});

  @override
  State<CbtExercisesScreen> createState() => _CbtExercisesScreenState();
}

class _CbtExercisesScreenState extends State<CbtExercisesScreen> {
  String? _selectedCategory;
  final List<String> _categories = ['Semua', 'Pernapasan', 'Kecemasan', 'CBT Reframing', 'Refleksi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Latihan Coping'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 20),
            onPressed: () {},
            tooltip: 'Favorit',
          ),
        ],
      ),
      body: Column(
          children: [
            // Category Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (sel) =>
                        setState(() => _selectedCategory = sel ? cat : null),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.sagePale,
                    labelStyle: TextStyle(
                      color:
                          isSel ? AppColors.sageDeep : AppColors.textBody,
                      fontWeight:
                          isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSel ? AppColors.sage : AppColors.border,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
            // Exercise List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: AppConstants.sampleExercises.length,
                itemBuilder: (context, index) {
                  final ex = AppConstants.sampleExercises[index];
                  final matches =
                      _selectedCategory == null ||
                      _selectedCategory == 'Semua' ||
                      ex.category == _selectedCategory;
                  if (!matches) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.sagePale,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              _getIcon(ex.iconName),
                              color: AppColors.sage,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.title,
                                  style: AppText.titleSmall,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      ex.duration,
                                      style: AppText.caption,
                                    ),
                                    const Spacer(),
                                    Icon(
                                      ex.isCompleted
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      size: 20,
                                      color: ex.isCompleted
                                          ? AppColors.sage
                                          : AppColors.textLight,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ex.description,
                                  style: AppText.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'air':
        return Icons.air;
      case 'spa':
        return Icons.spa;
      case 'psychology':
        return Icons.psychology;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.menu_book;
    }
  }
}