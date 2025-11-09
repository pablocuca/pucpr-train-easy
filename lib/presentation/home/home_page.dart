import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

import 'package:traineasy/core/di/injector.dart';
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
          children: const [
            Text('App de Treino', style: AppTypography.h1),
            SizedBox(height: AppSpacing.s4),
            PrimaryButton(label: 'Começar'),
          ],
        ),
      ),
    );
  }
}
