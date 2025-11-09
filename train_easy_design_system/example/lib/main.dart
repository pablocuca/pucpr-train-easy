import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainEasy Design System Example',
      theme: buildTrainEasyTheme(),
      home: const Scaffold(
        body: Center(child: ExampleHome()),
      ),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('App de Treino', style: AppTypography.h1),
        const SizedBox(height: AppSpacing.s4),
        PrimaryButton(label: 'Começar', onPressed: () {}),
        const SizedBox(height: AppSpacing.s2),
        PrimaryButton(label: 'Entrar', onPressed: () {}, isFilled: false),
        const SizedBox(height: AppSpacing.s4),
        CardProfile(name: 'Sofia Oliveira', subtitle: 'Personal Trainer'),
      ],
    );
  }
}
