import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/presentation/auth/login_page_v2.dart';
import 'package:traineasy/presentation/onboarding/role_selection_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo simples com gradiente escuro
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, AppColors.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.fitness_center,
                          color: AppColors.accent, size: 40),
                      SizedBox(width: AppSpacing.s2),
                      Text('Train Easy', style: AppTypography.h1),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  const Text(
                    'Seu treino, seu personal, sua evolução',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Cadastrar-se',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RoleSelectionPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Entrar',
                      isFilled: false,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginPageV2(),
                          ),
                        );
                      },
                    ),
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
