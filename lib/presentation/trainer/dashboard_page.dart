import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/usecase/usecase.dart';

class TrainerDashboardPage extends StatelessWidget {
  const TrainerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Painel do Personal', style: AppTypography.h2),
        centerTitle: true,
        actions: const [
          _LogoutButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pendentes de Avaliação', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s2),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.timer, color: AppColors.accent),
                    title: Text('Aluno: João — Treino IA aguardando aprovação'),
                  ),
                  ListTile(
                    leading: Icon(Icons.timer, color: AppColors.accent),
                    title: Text('Aluno: Ana — Treino modificado pendente'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            const Text('Meus Alunos', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s2),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _StudentChip(name: 'Ana Silva'),
                  _StudentChip(name: 'Bruno Costa'),
                  _StudentChip(name: 'Carla Nunes'),
                  _StudentChip(name: 'Daniela Lima'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: AppColors.accent),
      onPressed: () async {
        await Injector.signOut(const NoParams());
      },
      tooltip: 'Sair',
    );
  }
}

class _StudentChip extends StatelessWidget {
  final String name;
  const _StudentChip({required this.name});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s2),
      child: Chip(
        label: Text(name),
        backgroundColor: AppColors.surface2,
      ),
    );
  }
}