import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Encontre seu Personal', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por especialidade...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            Expanded(
              child: ListView(
                children: const [
                  CardProfile(name: 'Ana Silva', subtitle: 'Musculação • 4.8'),
                  SizedBox(height: AppSpacing.s2),
                  CardProfile(name: 'Bruno Costa', subtitle: 'Emagrecimento • 4.6'),
                  SizedBox(height: AppSpacing.s2),
                  CardProfile(name: 'Carla Nunes', subtitle: 'Cross • 4.7'),
                  SizedBox(height: AppSpacing.s2),
                  CardProfile(name: 'Daniela Lima', subtitle: 'Funcional • 4.9'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}