import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Latar lembut senada tema sage. Ganti dengan background ilustrasi
/// aplikasi kamu bila ingin tampilan yang sama persis dengan shell utama.
class ExerciseBackground extends StatelessWidget {
  final Widget child;
  const ExerciseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3F6EE), Color(0xFFE3EBDC)],
        ),
      ),
      child: child,
    );
  }
}

BoxDecoration softCard({Color? color, double radius = 24}) {
  return BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.borderLight, width: 1.2),
    boxShadow: const [
      BoxShadow(color: Color(0x143B5A40), blurRadius: 20, offset: Offset(0, 8)),
    ],
  );
}

ButtonStyle primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: AppColors.sage,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(54),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.sageDeep,
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final double size;
  const IconTile({super.key, required this.icon, required this.accent, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withAlpha(38),
        borderRadius: BorderRadius.circular(size * 0.36),
      ),
      child: Icon(icon, color: accent, size: size * 0.46),
    );
  }
}