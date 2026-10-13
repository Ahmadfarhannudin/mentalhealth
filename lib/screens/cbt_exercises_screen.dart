import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../coping/coping_exercises.dart';
import '../coping/exercise_ui.dart';
import '../coping/exercise_detail_screen.dart';

class CbtExercisesScreen extends StatefulWidget {
  const CbtExercisesScreen({super.key});

  @override
  State<CbtExercisesScreen> createState() => _CbtExercisesScreenState();
}

class _CbtExercisesScreenState extends State<CbtExercisesScreen> {
  String _category = 'Semua';
  bool _favoritesOnly = false;

  // TODO: simpan ke penyimpanan lokal / backend agar tidak hilang saat app ditutup.
  final Set<String> _favorites = {};
  final Set<String> _done = {};

  List<CopingExercise> get _filtered => copingExercises.where((e) {
        final catOk = _category == 'Semua' || e.category == _category;
        final favOk = !_favoritesOnly || _favorites.contains(e.id);
        return catOk && favOk;
      }).toList();

  Future<void> _open(CopingExercise ex) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exercise: ex,
          isFavorite: _favorites.contains(ex.id),
          onToggleFavorite: () => setState(() {
            _favorites.contains(ex.id) ? _favorites.remove(ex.id) : _favorites.add(ex.id);
          }),
        ),
      ),
    );
    if (completed == true) setState(() => _done.add(ex.id));
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Latihan Coping',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.sageDeep),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: _favoritesOnly ? 'Tampilkan semua' : 'Tampilkan favorit',
            icon: Icon(
              _favoritesOnly ? Icons.favorite : Icons.favorite_border,
              size: 22,
              color: _favoritesOnly ? AppColors.sage : null,
            ),
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: _ProgressCard(done: _done.length, total: copingExercises.length),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: exerciseCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = exerciseCategories[i];
                final sel = cat == _category;
                return ChoiceChip(
                  label: Text(cat),
                  selected: sel,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _category = cat),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.sage,
                  side: BorderSide(color: sel ? AppColors.sage : AppColors.border),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textBody,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    // ruang ekstra agar tidak tertutup bottom navigation melayang
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final ex = items[i];
                      return _ExerciseCard(
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

class _ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: softCard(radius: 22),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  backgroundColor: AppColors.sagePale,
                  valueColor: const AlwaysStoppedAnimation(AppColors.sage),
                ),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sageDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rutin kecil, dampak nyata',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sageDeep,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Latihan singkat yang diulang lebih efektif daripada sesekali lama.',
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final CopingExercise exercise;
  final bool done;
  final bool favorite;
  final VoidCallback onTap;
  const _ExerciseCard({
    required this.exercise,
    required this.done,
    required this.favorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = categoryAccent(exercise.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x143B5A40), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.borderLight, width: 1.2),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'ex-icon-${exercise.id}',
                    child: IconTile(icon: exercise.icon, accent: accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                            if (favorite)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.favorite, size: 14, color: AppColors.sage),
                              ),
                            Icon(
                              done ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 20,
                              color: done ? AppColors.sage : AppColors.textLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.title,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: AppColors.sageDeep,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exercise.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 15, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${exercise.minutes} menit',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.sagePale,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  exercise.kindLabel,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.sageDeep,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 40, color: AppColors.textLight),
            SizedBox(height: 12),
            Text(
              'Belum ada latihan favorit',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.sageDeep),
            ),
            SizedBox(height: 4),
            Text(
              'Buka sebuah latihan lalu ketuk ikon hati untuk menyimpannya di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}