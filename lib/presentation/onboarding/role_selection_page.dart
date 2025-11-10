import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/presentation/onboarding/create_account_page.dart';

enum UserRole { aluno, personal }

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  UserRole? _selected;

  void _continue() {
    if (_selected == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateAccountPage(role: _selected!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Como você usará o app?', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Escolha seu perfil para personalizar sua experiência.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.s4),
            _RoleCard(
              title: 'Sou Aluno',
              subtitle: 'Para encontrar treinos e conectar-se a um personal.',
              icon: Icons.sports_gymnastics,
              selected: _selected == UserRole.aluno,
              onTap: () => setState(() => _selected = UserRole.aluno),
            ),
            const SizedBox(height: AppSpacing.s3),
            _RoleCard(
              title: 'Sou Personal',
              subtitle: 'Para gerenciar alunos e criar programas de treino.',
              icon: Icons.badge,
              selected: _selected == UserRole.personal,
              onTap: () => setState(() => _selected = UserRole.personal),
            ),
            const Spacer(),
            PrimaryButton(label: 'Continuar', onPressed: _selected != null ? _continue : null),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r2),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.surface2,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 28),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.s1),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}