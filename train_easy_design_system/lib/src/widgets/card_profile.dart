import 'package:flutter/material.dart';
import '../design_tokens.dart';

class CardProfile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? imageUrl;

  const CardProfile(
      {super.key, required this.name, required this.subtitle, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surface2,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Icon(Icons.person, color: AppColors.accent)
                : null,
          ),
          const SizedBox(width: AppSpacing.s3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.s1),
              Text(subtitle, style: AppTypography.caption),
            ],
          )
        ],
      ),
    );
  }
}
