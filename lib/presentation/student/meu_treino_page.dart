import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

class MeuTreinoPage extends StatelessWidget {
  const MeuTreinoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Meu Treino de Hoje', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Treino A • Peito e Tríceps', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s3),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.fitness_center, color: AppColors.accent),
                    title: Text('Supino Reto'),
                    subtitle: Text('4x10 • 125 kg'),
                  ),
                  ListTile(
                    leading: Icon(Icons.fitness_center, color: AppColors.accent),
                    title: Text('Supino Inclinado'),
                    subtitle: Text('4x12 • 105 kg'),
                  ),
                  ListTile(
                    leading: Icon(Icons.fitness_center, color: AppColors.accent),
                    title: Text('Tríceps na Polia Alta'),
                    subtitle: Text('3x15 • 35 kg'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            PrimaryButton(label: 'Iniciar Treino', onPressed: () {}),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}