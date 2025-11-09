import 'package:flutter/material.dart';
import '../design_tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isFilled;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: isFilled ? AppColors.accent : Colors.transparent,
      foregroundColor: isFilled ? AppColors.background : AppColors.accent,
      elevation: isFilled ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r2),
        side: isFilled ? BorderSide.none : BorderSide(color: AppColors.accent),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s3, horizontal: AppSpacing.s5),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );

    if (isFilled) {
      return ElevatedButton(
          onPressed: onPressed, style: style, child: Text(label));
    } else {
      return OutlinedButton(
          onPressed: onPressed, style: style, child: Text(label));
    }
  }
}
