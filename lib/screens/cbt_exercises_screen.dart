import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/ui/components.dart';
import '../coping/coping_exercises.dart';
import '../coping/exercise_detail_screen.dart';

class CbtExercisesScreen extends StatefulWidget {
  const CbtExercisesScreen({super.key});

  @override
  State<CbtExercisesScreen> createState() => _CbtExercisesScreenState();
}

class _CbtExercisesScreenState extends State<CbtExercisesScreen> {
  String _category = 'Semua';
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  bool _favoritesOnly = false;

  // TODO: simpan favorit dan progres ke penyimpanan lokal.
  final Set<String> _favorites = {};
  final Set<String> _done = {};

  List<CopingExercise> get _filtered => copingExercises.where((e) {
    final catOk = _category == 'Semua' || e.category == _category;
    final favOk = !_favoritesOnly || _favorites.contains(e.id);
    final query = _query.trim().toLowerCase();
    final queryOk =
        query.isEmpty ||
        e.title.toLowerCase().contains(query) ||
        e.description.toLowerCase().contains(query) ||
        e.category.toLowerCase().contains(query) ||
        e.kindLabel.toLowerCase().contains(query);
    return catOk && favOk && queryOk;
  }).toList();

  Future<void> _open(CopingExercise ex) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exercise: ex,
          isFavorite: _favorites.contains(ex.id),
          onToggleFavorite: () => setState(() {
            _favorites.contains(ex.id)
                ? _favorites.remove(ex.id)
                : _favorites.add(ex.id);
          }),
        ),
      ),
    );
    if (completed == true) setState(() => _done.add(ex.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final progress = copingExercises.isEmpty
        ? 0.0
        : _done.length / copingExercises.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.md,
              Space.page,
              0,
            ),
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
                          Text('Latihan', style: AppText.displayMedium),
                          SizedBox(height: 2),
                          Text(
                            'Latihan singkat untuk meredakan pikiran yang ramai.',
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _favoritesOnly
                          ? 'Tampilkan semua latihan'
                          : 'Tampilkan favorit',
                      onPressed: () =>
                          setState(() => _favoritesOnly = !_favoritesOnly),
                      icon: Icon(
                        _favoritesOnly
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _favoritesOnly
                            ? AppColors.clayDeep
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.md),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.forestMist,
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.md),
                    Text(
                      '${_done.length} dari ${copingExercises.length} selesai',
                      style: AppText.caption,
                    ),
                  ],
                ),
                const SizedBox(height: Space.lg),
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari latihan atau topik',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: Space.page),
              scrollDirection: Axis.horizontal,
              itemCount: exerciseCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: Space.sm),
              itemBuilder: (_, i) {
                final cat = exerciseCategories[i];
                return QuietPill(
                  label: cat,
                  selected: cat == _category,
                  onTap: () => setState(() => _category = cat),
                );
              },
            ),
          ),
          const SizedBox(height: Space.md),
          Expanded(
            child: items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Space.page,
                      Space.sm,
                      Space.page,
                      Space.xxl,
                    ),
                    children: [
                      QuietEmptyState(
                        icon: _favoritesOnly
                            ? Icons.favorite_border_rounded
                            : Icons.search_off_rounded,
                        title: _query.trim().isNotEmpty
                            ? 'Latihan tidak ditemukan'
                            : _favoritesOnly
                            ? 'Belum ada favorit'
                            : 'Belum ada latihan di kategori ini',
                        message: _query.trim().isNotEmpty
                            ? 'Coba kata kunci lain, atau pilih kategori lain.'
                            : _favoritesOnly
                            ? 'Buka sebuah latihan, lalu simpan dengan ikon hati.'
                            : 'Pilih kategori lain untuk melihat latihan yang tersedia.',
                        action: _favoritesOnly
                            ? TextButton(
                                onPressed: () =>
                                    setState(() => _favoritesOnly = false),
                                child: const Text('Tampilkan semua'),
                              )
                            : null,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Space.page,
                      0,
                      Space.page,
                      Space.xxl,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Space.md),
                    itemBuilder: (_, i) {
                      final ex = items[i];
                      return _ExerciseRow(
                        exercise: ex,
                        done: _done.contains(ex.id),
                        favorite: _favorites.contains(ex.id),
                        onTap: () => _open(ex),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final CopingExercise exercise;
  final bool done;
  final bool favorite;
  final VoidCallback onTap;

  const _ExerciseRow({
    required this.exercise,
    required this.done,
    required this.favorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${exercise.title}, ${exercise.minutes} menit, ${done ? 'selesai' : 'belum selesai'}',
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(Space.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: done ? AppColors.forestPale : AppColors.forestMist,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(exercise.icon, size: 22, color: AppColors.forestDeep),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(exercise.title, style: AppText.titleSmall),
                      ),
                      if (favorite)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 14,
                            color: AppColors.clay,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        size: 19,
                        color: done ? AppColors.forest : AppColors.textLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall,
                  ),
                  const SizedBox(height: Space.sm),
                  Row(
                    children: [
                      Text('${exercise.minutes} menit', style: AppText.caption),
                      const SizedBox(width: Space.sm),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.textLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: Space.sm),
                      Flexible(
                        child: Text(
                          exercise.category,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption,
                        ),
                      ),
                      if (done) ...[
                        const SizedBox(width: Space.sm),
                        const StatusChip(
                          label: 'Selesai',
                          color: AppColors.forestDeep,
                          background: AppColors.forestPale,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
