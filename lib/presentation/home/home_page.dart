import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/config/environment_config.dart';
import 'package:traineasy/core/usecase/usecase.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Train Easy', style: AppTypography.h1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.accent),
            onPressed: () async {
              await Injector.signOut(const NoParams());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('App de Treino', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.s4),
            const PrimaryButton(label: 'Começar'),
            const SizedBox(height: AppSpacing.s4),
            PrimaryButton(
              label: 'Testar Gemini',
              isFilled: false,
              onPressed: () async {
                try {
                  // Verifica chave antes de chamar o serviço
                  if (EnvironmentConfig.geminiApiKey.isEmpty) {
                    if (!context.mounted) return;
                    const msg =
                        'GEMINI_API_KEY ausente. Configure no .env e reinicie.';
                    debugPrint(msg);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                    return;
                  }
                  final texto = await Injector.gemini.generateText(
                      'Explique treino de força para iniciantes.');
                  if (!context.mounted) return;
                  final msg = texto.isEmpty ? 'Sem texto' : texto;
                  debugPrint(msg);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                } catch (e) {
                  if (!context.mounted) return;
                  final msg = 'Erro ao chamar Gemini: $e';
                  debugPrint(msg);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
