import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';

class PendingValidationPage extends StatelessWidget {
  const PendingValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Conta em Análise', style: AppTypography.h2),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await TelemetryService.trackEvent('auth_logout', {'source': 'pending_validation'});
              await Injector.signOut(const NoParams());
            },
            icon: const Icon(Icons.logout, color: AppColors.accent),
            label: const Text('Sair', style: AppTypography.caption),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text('Seu cadastro como Personal está em análise.', style: AppTypography.body),
            SizedBox(height: AppSpacing.s2),
            Text('Você receberá uma notificação quando sua conta for validada.', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}