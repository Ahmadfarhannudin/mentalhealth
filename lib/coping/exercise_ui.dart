import 'package:flutter/material.dart';

import '../core/theme/app_background.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/ui/components.dart';

/// Background for the coping flow. Same quiet wash as the rest of the app.
class ExerciseBackground extends StatelessWidget {
  final Widget child;
  const ExerciseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppBackground(child: child);
  }
}

/// Flat card with a hairline outline. Depth stays reserved for floating chrome.
BoxDecoration softCard({Color? color, double radius = 20}) {
  return BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.borderLight),
  );
}

ButtonStyle primaryButtonStyle() {
  return FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: AppText.button,
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl, bottom: Space.md),
      child: Text(text, style: AppText.titleMedium),
    );
  }
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final double size;
  const IconTile({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.forestMist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: AppColors.forestDeep, size: size * 0.44),
    );
  }
}
