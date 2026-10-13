import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'coping_exercises.dart';
import 'exercise_ui.dart';

enum _Stage { before, run, after }

class ExerciseSessionScreen extends StatefulWidget {
  final CopingExercise exercise;
  const ExerciseSessionScreen({super.key, required this.exercise});

  @override
  State<ExerciseSessionScreen> createState() => _ExerciseSessionScreenState();
}

class _ExerciseSessionScreenState extends State<ExerciseSessionScreen> {
  _Stage _stage = _Stage.before;
  double _before = 5;
  double _after = 5;

  // TODO: kirim _before, _after, dan jawaban jurnal ke penyimpanan/riwayat.
  Map<String, String> _answers = {};

  Future<void> _confirmExit() async {
    if (_stage != _Stage.run) {
      Navigator.of(context).pop(false);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Keluar dari latihan?'),
        content: const Text('Progres latihan ini tidak akan tersimpan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Lanjutkan')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return ExerciseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _confirmExit),
          title: Text(
            ex.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.sageDeep),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey(_stage),
              child: _buildStage(ex),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStage(CopingExercise ex) {
    switch (_stage) {
      case _Stage.before:
        return _RatingPage(
          title: 'Sebelum mulai',
          question: 'Seberapa berat perasaan tidak nyaman yang kamu rasakan sekarang?',
          value: _before,
          onChanged: (v) => setState(() => _before = v),
          buttonLabel: 'Mulai',
          onPressed: () => setState(() => _stage = _Stage.run),
        );
      case _Stage.run:
        if (ex.kind == ExerciseKind.breathing) {
          return _BreathingRunner(
            exercise: ex,
            onDone: () => setState(() => _stage = _Stage.after),
          );
        }
        return _StepRunner(
          exercise: ex,
          onDone: (answers) => setState(() {
            _answers = answers;
            _stage = _Stage.after;
          }),
        );
      case _Stage.after:
        return _RatingPage(
          title: 'Latihan selesai',
          question: 'Bagaimana perasaanmu sekarang? Seberapa berat rasa tidak nyamannya?',
          value: _after,
          onChanged: (v) => setState(() => _after = v),
          buttonLabel: 'Simpan & selesai',
          before: _before,
          showSafety: _after >= 8,
          answerCount: _answers.values.where((v) => v.trim().isNotEmpty).length,
          onPressed: () => Navigator.of(context).pop(true),
        );
    }
  }
}

// ───────────────────────── Rating sebelum / sesudah ─────────────────────────

class _RatingPage extends StatelessWidget {
  final String title;
  final String question;
  final double value;
  final ValueChanged<double> onChanged;
  final String buttonLabel;
  final VoidCallback onPressed;
  final double? before;
  final bool showSafety;
  final int answerCount;

  const _RatingPage({
    required this.title,
    required this.question,
    required this.value,
    required this.onChanged,
    required this.buttonLabel,
    required this.onPressed,
    this.before,
    this.showSafety = false,
    this.answerCount = 0,
  });

  String get _feedback {
    if (before == null) return '';
    final diff = (before! - value).round();
    if (diff > 0) {
      return 'Rasa tidak nyamanmu turun $diff poin. Kerja bagus sudah meluangkan waktu untuk dirimu.';
    }
    return 'Tidak apa-apa jika belum terasa berbeda. Manfaatnya biasanya makin terasa setelah latihan diulang.';
  }

  @override
  Widget build(BuildContext context) {
    final isAfter = before != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: softCard(radius: 28),
          child: Column(
            children: [
              if (isAfter)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Icon(Icons.check_circle, size: 48, color: AppColors.sage),
                ),
              Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.sageDeep),
              ),
              const SizedBox(height: 10),
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14.5, height: 1.5, color: AppColors.textBody),
              ),
              const SizedBox(height: 24),
              Text(
                value.round().toString(),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.sage),
              ),
              Slider(
                value: value,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppColors.sage,
                inactiveColor: AppColors.sagePale,
                label: value.round().toString(),
                onChanged: onChanged,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 · Tenang', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text('10 · Sangat berat', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isAfter) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.sagePale,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Chip('Sebelum ${before!.round()}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 16, color: AppColors.sageDeep),
                    ),
                    _Chip('Sesudah ${value.round()}'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_feedback, style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textBody)),
                if (answerCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$answerCount catatan tersimpan dari sesi ini.',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (showSafety) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF3E6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEFDDBB)),
            ),
            child: const Text(
              'Perasaanmu masih terasa sangat berat. Kamu tidak harus melaluinya sendirian. '
              'Pertimbangkan berbicara dengan orang tepercaya atau tenaga profesional, '
              'dan jika merasa tidak aman, hubungi layanan darurat atau layanan kesehatan jiwa (119 ext. 8).',
              style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF6B5428)),
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(style: primaryButtonStyle(), onPressed: onPressed, child: Text(buttonLabel)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.sageDeep),
      ),
    );
  }
}

// ───────────────────────── Napas terpandu ─────────────────────────

class _BreathingRunner extends StatefulWidget {
  final CopingExercise exercise;
  final VoidCallback onDone;
  const _BreathingRunner({required this.exercise, required this.onDone});

  @override
  State<_BreathingRunner> createState() => _BreathingRunnerState();
}

class _BreathingRunnerState extends State<_BreathingRunner> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  int _phase = 0;
  int _cycle = 0;
  bool _running = false;

  List<BreathPhase> get _phases => widget.exercise.breathPhases;
  BreathPhase get _cur => _phases[_phase];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(seconds: _cur.seconds))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      });
  }

  void _next() {
    var phase = _phase + 1;
    var cycle = _cycle;
    if (phase >= _phases.length) {
      phase = 0;
      cycle++;
    }
    if (cycle >= widget.exercise.cycles) {
      setState(() => _running = false);
      widget.onDone();
      return;
    }
    setState(() {
      _phase = phase;
      _cycle = cycle;
    });
    _c.duration = Duration(seconds: _cur.seconds);
    _c.forward(from: 0);
  }

  void _toggle() {
    if (_running) {
      _c.stop();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = categoryAccent(widget.exercise.category);
    final started = _running || _c.value > 0 || _cycle > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Text(
            'Siklus ${_cycle + 1} dari ${widget.exercise.cycles}',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_cycle + (_phase / _phases.length)) / widget.exercise.cycles,
              minHeight: 6,
              backgroundColor: AppColors.sagePale,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final t = Curves.easeInOut.transform(_c.value);
                  final scale = _cur.scaleFrom + (_cur.scaleTo - _cur.scaleFrom) * t;
                  final remaining = (_cur.seconds * (1 - _c.value)).ceil().clamp(1, _cur.seconds);
                  return SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 280 * scale,
                          height: 280 * scale,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withAlpha(36)),
                        ),
                        Container(
                          width: 210 * scale,
                          height: 210 * scale,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withAlpha(70)),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              started ? _cur.label : 'Siap?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.sageDeep,
                              ),
                            ),
                            if (started)
                              Text(
                                '$remaining',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.sageDeep,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            started ? _cur.hint : 'Duduk nyaman, bahu rileks. Ketuk Mulai saat siap.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.5, height: 1.5, color: AppColors.textBody),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: primaryButtonStyle(),
            onPressed: _toggle,
            icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_running ? 'Jeda' : (started ? 'Lanjutkan' : 'Mulai')),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Langkah terpandu & jurnal ─────────────────────────

class _StepRunner extends StatefulWidget {
  final CopingExercise exercise;
  final ValueChanged<Map<String, String>> onDone;
  const _StepRunner({required this.exercise, required this.onDone});

  @override
  State<_StepRunner> createState() => _StepRunnerState();
}

class _StepRunnerState extends State<_StepRunner> {
  int _i = 0;
  late final List<TextEditingController> _ctrls =
      widget.exercise.steps.map((_) => TextEditingController()).toList();

  List<ExerciseStep> get _steps => widget.exercise.steps;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_i == _steps.length - 1) {
      final answers = <String, String>{};
      for (int k = 0; k < _steps.length; k++) {
        if (_steps[k].inputHint != null) answers[_steps[k].title] = _ctrls[k].text;
      }
      widget.onDone(answers);
    } else {
      setState(() => _i++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_i];
    final accent = categoryAccent(widget.exercise.category);
    final isLast = _i == _steps.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Langkah ${_i + 1} dari ${_steps.length}',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_i + 1) / _steps.length,
              minHeight: 6,
              backgroundColor: AppColors.sagePale,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(_i),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: softCard(radius: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTile(icon: widget.exercise.icon, accent: accent, size: 48),
                      const SizedBox(height: 18),
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 21,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.sageDeep,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.body,
                        style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textBody),
                      ),
                      if (step.inputHint != null) ...[
                        const SizedBox(height: 18),
                        TextField(
                          controller: _ctrls[_i],
                          minLines: 4,
                          maxLines: 8,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: step.inputHint,
                            hintStyle: const TextStyle(color: AppColors.textLight),
                            filled: true,
                            fillColor: AppColors.sagePale.withAlpha(120),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: AppColors.sage, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_i > 0) ...[
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      foregroundColor: AppColors.sageDeep,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () => setState(() => _i--),
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 3,
                child: FilledButton(
                  style: primaryButtonStyle(),
                  onPressed: _next,
                  child: Text(isLast ? 'Selesai' : 'Lanjut'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}