import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';
import 'dart:convert' as convert;

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  bool _generating = false;

  Future<void> _selectPersonal(String personalId, String nome) async {
    if (_generating) return;
    setState(() { _generating = true; });
    TelemetryService.trackEvent('marketplace_select_personal', {'personalId': personalId});
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      setState(() { _generating = false; });
      return;
    }
    try {
      final alunoSnapshot = await FirebaseDatabase.instance.ref('users/${u.uid}').get();
      final personalSnapshot = await FirebaseDatabase.instance.ref('users/$personalId').get();
      final aluno = alunoSnapshot.value as Map<dynamic, dynamic>? ?? {};
      final anamnese = (aluno['anamnese'] ?? {}) as Map;
      final objetivo = anamnese['objetivo'] ?? '';
      final nivel = anamnese['nivel'] ?? '';
      final dias = anamnese['dias_semana'] ?? 3;
      final restricoes = anamnese['restricoes'] ?? '';
      final personalData = personalSnapshot.value as Map<dynamic, dynamic>? ?? {};
      final pm = personalData['prompt_mestre']?.toString() ?? '';

      final prompt = 'Crie um plano SEMANAL estruturado apenas em JSON. '
          'Use o seguinte schema: {"orientation": string, "days": [{"label": string, "exercises": [{"name": string, "sets": string, "notes": string}]}]}. '
          'Sem texto fora do JSON. '
          'Metodologia do personal: ${pm.isEmpty ? 'N/A' : pm}. '
          'Aluno -> Objetivo: $objetivo; Nível: $nivel; Dias/semana: $dias; Restrições: $restricoes.';

      TelemetryService.trackEvent('generate_training_start', {'mode': 'ia_personal'});
      final planText = await Injector.gemini.generateText(prompt);
      Map<String, dynamic>? plan;
      try { plan = convert.jsonDecode(planText) as Map<String, dynamic>; } catch (_) {}

      await FirebaseDatabase.instance.ref('users/${u.uid}').update({
        'treino': {
          'status': 'pendente',
          'gerado_em': DateTime.now().toIso8601String(),
          'fonte': 'ia_personal',
          'plano_texto': planText,
          if (plan != null) 'plan': plan,
          'personalId': personalId,
          'personalNome': nome,
        },
        'treino_ativo': false,
      });

      TelemetryService.trackEvent('generate_training_success', {'mode': 'ia_personal'});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitado ao personal $nome')), 
      );
      Navigator.of(context).pop();
    } catch (e) {
      await TelemetryService.recordError(e, StackTrace.current);
      TelemetryService.trackEvent('generate_training_failure', {'mode': 'ia_personal'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao solicitar ao personal')),
        );
        setState(() { _generating = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TelemetryService.trackEvent('marketplace_open', {});
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
            const SizedBox(height: AppSpacing.s2),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref('users')
                    .orderByChild('role')
                    .equalTo('personal')
                    .onValue,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    TelemetryService.trackEvent('marketplace_error', {
                      'message': snap.error.toString(),
                    });
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Erro ao carregar personals', style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.s2),
                          Text(snap.error.toString(), style: AppTypography.caption),
                        ],
                      ),
                    );
                  }
                  final data = snap.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};
                  // Filter for validated personals (since RTDB can only filter by one field)
                  final validPersonals = data.entries.where((e) {
                    final m = e.value as Map<dynamic, dynamic>;
                    return m['status_validacao'] == 'validado';
                  }).toList();
                  
                  if (validPersonals.isEmpty) {
                    return const Center(child: Text('Nenhum personal validado encontrado'));
                  }
                  return ListView.separated(
                    itemCount: validPersonals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s2),
                    itemBuilder: (context, index) {
                      final entry = validPersonals[index];
                      final d = entry.value as Map<dynamic, dynamic>;
                      final nome = (d['nome'] ?? '') as String;
                      final espec = (d['especialidade'] ?? '') as String;
                      final id = (d['uid'] ?? entry.key) as String;
                      return ListTile(
                        leading: const Icon(Icons.person, color: AppColors.accent),
                        title: Text(nome.isEmpty ? 'Personal' : nome, style: AppTypography.body),
                        subtitle: Text(espec.isEmpty ? 'Personal validado' : espec, style: AppTypography.caption),
                        trailing: PrimaryButton(
                          label: _generating ? 'Aguarde...' : 'Selecionar',
                          onPressed: _generating ? null : () => _selectPersonal(id, nome),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}