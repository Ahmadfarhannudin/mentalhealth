import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'coping_exercises.dart';
import 'exercise_ui.dart';
import 'exercise_session_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final CopingExercise exercise;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late bool _fav = widget.isFavorite;

  Future<void> _start() async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ExerciseSessionScreen(exercise: widget.exercise)),
    );
    if (completed == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final accent = categoryAccent(ex.category);

    return ExerciseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              tooltip: 'Favorit',
              icon: Icon(
                _fav ? Icons.favorite : Icons.favorite_border,
                color: _fav ? AppColors.sage : null,
              ),
              onPressed: () {
                widget.onToggleFavorite();
                setState(() => _fav = !_fav);
              },
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: FilledButton.icon(
              style: primaryButtonStyle(),
              onPressed: _start,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Mulai latihan'),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(22),
              decoration: softCard(radius: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'ex-icon-${ex.id}',
                        child: IconTile(icon: ex.icon, accent: accent, size: 64),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ex.category,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    ex.title,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.sageDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ex.description,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _Stat(icon: Icons.timer_outlined, label: '${ex.minutes} menit'),
                      const SizedBox(width: 10),
                      _Stat(icon: Icons.touch_app_outlined, label: ex.kindLabel),
                      const SizedBox(width: 10),
                      _Stat(icon: Icons.format_list_numbered, label: '${ex.steps.length} langkah'),
                    ],
                  ),
                ],
              ),
            ),

            const SectionTitle('Tentang latihan'),
            Text(
              ex.overview,
              style: const TextStyle(fontSize: 14.5, height: 1.6, color: AppColors.textBody),
            ),

            const SectionTitle('Manfaat'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ex.benefits
                  .map(
                    (b) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Text(b, style: const TextStyle(fontSize: 13, color: AppColors.textBody)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SectionTitle('Langkah-langkah'),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
              decoration: softCard(radius: 22),
              child: Column(
                children: [
                  for (int i = 0; i < ex.steps.length; i++)
                    _StepRow(
                      index: i + 1,
                      step: ex.steps[i],
                      accent: accent,
                      isLast: i == ex.steps.length - 1,
                    ),
                ],
              ),
            ),

            const SectionTitle('Dasar ilmiah'),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.sagePale,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.science_outlined, size: 22, color: AppColors.sageDeep),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ex.evidence,
                      style: const TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.textBody),
                    ),
                  ),
                ],
              ),
            ),

            if (ex.caution != null) ...[
              const SizedBox(height: 14),
              _Note(icon: Icons.info_outline, text: ex.caution!),
            ],
            const SizedBox(height: 14),
            const _Note(icon: Icons.health_and_safety_outlined, text: safetyNote),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.sagePale,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.sageDeep),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.sageDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final ExerciseStep step;
  final Color accent;
  final bool isLast;
  const _StepRow({
    required this.index,
    required this.step,
    required this.accent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: accent.withAlpha(60))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sageDeep,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.body,
                    style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Note({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFDDBB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9A7434)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xFF6B5428)),
            ),
          ),
        ],
      ),
    );
  }
}