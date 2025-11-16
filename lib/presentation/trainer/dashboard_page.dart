import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traineasy/presentation/profile/cref_validation_page.dart';
import 'package:traineasy/presentation/profile/profile_page.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';
import 'dart:convert' as convert;

class TrainerDashboardPage extends StatefulWidget {
  const TrainerDashboardPage({super.key});

  @override
  State<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
  int _currentIndex = 0;

  void _onTab(int i) {
    setState(() => _currentIndex = i);
    final label =
        switch (i) { 0 => 'home', 1 => 'perfil', 2 => 'alunos', _ => 'config' };
    TelemetryService.trackEvent('trainer_tab', {'tab': label});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Personal', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: switch (_currentIndex) {
        0 => _buildHome(),
        1 => const ProfilePage(),
        2 => _buildAlunos(),
        _ => _buildConfig(),
      },
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface2,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Alunos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PromptConfigBanner(),
          const Text('Pendentes de Avaliação', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.s2),
          Expanded(
            child: Builder(builder: (context) {
              final u = Injector.authRepository.currentUser;
              if (u == null) {
                return const Center(child: Text('Usuário não autenticado'));
              }
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'aluno')
                    .where('treino.personalId', isEqualTo: u.uid)
                    .where('treino.status', isEqualTo: 'pendente')
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Erro ao carregar pendentes',
                              style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.s2),
                          Text(snap.error.toString(),
                              style: AppTypography.caption),
                        ],
                      ),
                    );
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('Nenhum aluno listado'));
                  }
                  return ListView(
                    children: docs.map((d) {
                      final data = d.data();
                      final nome = (data['nome'] ?? '') as String;

                      final alunoId = (data['uid'] ?? d.id) as String;
                      return ListTile(
                        leading:
                            const Icon(Icons.timer, color: AppColors.accent),
                        title: Text(nome.isEmpty ? 'Aluno' : nome),
                        subtitle: const Text('Plano pendente'),
                        trailing: PrimaryButton(
                            label: 'Avaliar',
                            onPressed: () => _openEvaluation(context, alunoId)),
                      );
                    }).toList(),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAlunos() {
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'aluno')
            .where('treino.personalId', isEqualTo: u.uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Erro ao carregar alunos',
                      style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.s2),
                  Text(snap.error.toString(), style: AppTypography.caption),
                ],
              ),
            );
          }
          final all = snap.data?.docs ?? [];
          final docs = all
              .where((d) =>
                  (((d.data()['treino'] ?? {}) as Map)['status']?.toString() ??
                      '') !=
                  'pendente')
              .toList();
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum aluno aprovado'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s2),
            itemBuilder: (context, idx) {
              final data = docs[idx].data();
              final nome = (data['nome'] ?? '') as String;
              return ListTile(
                leading: const Icon(Icons.person, color: AppColors.accent),
                title: Text(nome.isEmpty ? 'Aluno' : nome),
                subtitle: const Text('Plano aprovado'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConfig() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Configurações', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.s3),
          PrimaryButton(
              label: 'Atualizar CREF',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CrefValidationPage()));
              }),
          const SizedBox(height: AppSpacing.s2),
          OutlinedButton(
              onPressed: () async {
                await Injector.signOut(const NoParams());
              },
              child: const Text('Sair')),
        ],
      ),
    );
  }
}

// AppBar actions removidos; ações estão na aba Config.

class _PromptConfigBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(u.uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final data = snap.data?.data() ?? {};
        final pm = (data['prompt_mestre'] ?? '') as String;
        if (pm.isNotEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s3),
          padding: const EdgeInsets.all(AppSpacing.s3),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.r2),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates, color: AppColors.accent),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Configure sua Metodologia',
                        style: AppTypography.body),
                    SizedBox(height: AppSpacing.s1),
                    Text(
                        'Descreva sua metodologia para personalizar os treinos dos alunos.',
                        style: AppTypography.caption),
                  ],
                ),
              ),
              PrimaryButton(
                  label: 'Configurar', onPressed: () => _openDialog(context)),
            ],
          ),
        );
      },
    );
  }

  void _openDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Metodologia (prompt_mestre)'),
          content: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText:
                  'Ex.: Priorizar mobilidade, aquecimento específico, progressão linear em compostos...',
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar')),
            PrimaryButton(
                label: 'Salvar',
                onPressed: () async {
                  final txt = controller.text.trim();
                  final u = Injector.authRepository.currentUser;
                  if (u == null || txt.isEmpty) {
                    Navigator.of(context).pop();
                    return;
                  }
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(u.uid)
                      .update({'prompt_mestre': txt});
                  await TelemetryService.trackEvent(
                      'prompt_mestre_save', {'source': 'personal'});
                  nav.pop();
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Metodologia salva')));
                }),
          ],
        );
      },
    );
  }
}

void _openEvaluation(BuildContext context, String alunoId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + AppSpacing.s4,
            left: AppSpacing.s4,
            right: AppSpacing.s4,
            bottom: AppSpacing.s4,
          ),
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(alunoId)
                .get(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snap.data?.data() ?? {};
              final nome = (data['nome'] ?? '') as String;
              final treino = (data['treino'] ?? {}) as Map;
              final plano = (treino['plano_texto'] ?? '') as String;
              final planMap = (treino['plan'] as Map?)?.cast<String, dynamic>();
              final controller = TextEditingController(text: plano);
              final sourcePlan = planMap ?? _tryParseJsonPlan(plano);
              final editedPlan = sourcePlan == null
                  ? null
                  : convert.jsonDecode(convert.jsonEncode(sourcePlan))
                      as Map<String, dynamic>;
              return StatefulBuilder(builder: (context, setModalState) {
                return SafeArea(
                  top: true,
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.s6),
                      Text('Avaliação — $nome', style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.s2),
                      if (editedPlan != null) ...[
                        const Text('Plano Estruturado',
                            style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.s2),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: List<Widget>.from(
                              List<Map<String, dynamic>>.from(
                                      editedPlan['days'] as List? ?? const [])
                                  .asMap()
                                  .entries
                                  .map((entry) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue:
                                                      (entry.value['label'] ??
                                                          'Dia') as String,
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              'Label do Dia'),
                                                  onChanged: (v) {
                                                    editedPlan['days']
                                                            [entry.key]
                                                        ['label'] = v;
                                                    setModalState(() {});
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_upward),
                                                onPressed: entry.key == 0
                                                    ? null
                                                    : () {
                                                        final days = List<
                                                                Map<String,
                                                                    dynamic>>.from(
                                                            editedPlan['days']
                                                                as List);
                                                        final tmp =
                                                            days[entry.key - 1];
                                                        days[entry.key - 1] =
                                                            days[entry.key];
                                                        days[entry.key] = tmp;
                                                        editedPlan['days'] =
                                                            days;
                                                        setModalState(() {});
                                                      },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_downward),
                                                onPressed: () {
                                                  final days = List<
                                                          Map<String,
                                                              dynamic>>.from(
                                                      editedPlan['days']
                                                          as List);
                                                  if (entry.key <
                                                      days.length - 1) {
                                                    final tmp =
                                                        days[entry.key + 1];
                                                    days[entry.key + 1] =
                                                        days[entry.key];
                                                    days[entry.key] = tmp;
                                                    editedPlan['days'] = days;
                                                    setModalState(() {});
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppSpacing.s1),
                                          ...List<Map<String, dynamic>>.from(
                                                  entry.value['exercises']
                                                          as List? ??
                                                      const [])
                                              .asMap()
                                              .entries
                                              .map((exEntry) => ListTile(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                                AppSpacing.s1),
                                                    minLeadingWidth: 0,
                                                    leading: const Icon(
                                                        Icons.fitness_center,
                                                        color:
                                                            AppColors.accent),
                                                    title: TextFormField(
                                                      initialValue: (exEntry
                                                              .value['name'] ??
                                                          '') as String,
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'Exercício'),
                                                      onChanged: (v) {
                                                        editedPlan['days'][entry
                                                                        .key][
                                                                    'exercises']
                                                                [exEntry.key]
                                                            ['name'] = v;
                                                        setModalState(() {});
                                                      },
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextFormField(
                                                          initialValue:
                                                              (exEntry.value[
                                                                      'sets'] ??
                                                                  '') as String,
                                                          decoration:
                                                              const InputDecoration(
                                                                  labelText:
                                                                      'Séries/Reps'),
                                                          onChanged: (v) {
                                                            editedPlan['days'][
                                                                        entry
                                                                            .key]
                                                                    [
                                                                    'exercises']
                                                                [exEntry
                                                                    .key]['sets'] = v;
                                                            setModalState(
                                                                () {});
                                                          },
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                ((exEntry.value['notes'] ??
                                                                                '')
                                                                            as String)
                                                                        .isEmpty
                                                                    ? 'Sem notas'
                                                                    : (exEntry.value[
                                                                            'notes']
                                                                        as String),
                                                                style:
                                                                    AppTypography
                                                                        .caption,
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width:
                                                                    AppSpacing
                                                                        .s2),
                                                            IconButton(
                                                              tooltip:
                                                                  'Editar notas',
                                                              icon: const Icon(Icons
                                                                  .sticky_note_2_outlined),
                                                              onPressed: () {
                                                                final ctrl = TextEditingController(
                                                                    text: (exEntry.value['notes'] ??
                                                                            '')
                                                                        as String);
                                                                showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  isScrollControlled:
                                                                      true,
                                                                  useSafeArea:
                                                                      true,
                                                                  builder: (_) {
                                                                    return Padding(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .only(
                                                                        left: AppSpacing
                                                                            .s4,
                                                                        right: AppSpacing
                                                                            .s4,
                                                                        top: MediaQuery.of(context).padding.top +
                                                                            AppSpacing.s4,
                                                                        bottom: MediaQuery.of(context).viewInsets.bottom +
                                                                            AppSpacing.s4,
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.stretch,
                                                                        children: [
                                                                          const Text(
                                                                              'Notas do Exercício',
                                                                              style: AppTypography.h3),
                                                                          const SizedBox(
                                                                              height: AppSpacing.s2),
                                                                          TextField(
                                                                            controller:
                                                                                ctrl,
                                                                            keyboardType:
                                                                                TextInputType.multiline,
                                                                            textInputAction:
                                                                                TextInputAction.newline,
                                                                            minLines:
                                                                                6,
                                                                            maxLines:
                                                                                16,
                                                                            decoration:
                                                                                const InputDecoration(hintText: 'Inclua instruções específicas, ajustes e cuidados.'),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: AppSpacing.s3),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextButton(
                                                                                  onPressed: () => Navigator.of(context).pop(),
                                                                                  child: const Text('Cancelar'),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: AppSpacing.s2),
                                                                              Expanded(
                                                                                child: PrimaryButton(
                                                                                  label: 'Salvar',
                                                                                  onPressed: () {
                                                                                    editedPlan['days'][entry.key]['exercises'][exEntry.key]['notes'] = ctrl.text.trim();
                                                                                    setModalState(() {});
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    trailing: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: AppSpacing
                                                                  .s1),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors
                                                                .redAccent),
                                                        onPressed: () {
                                                          final ex = List<
                                                                  Map<String,
                                                                      dynamic>>.from(
                                                              editedPlan['days']
                                                                              [entry.key]
                                                                          [
                                                                          'exercises']
                                                                      as List? ??
                                                                  const []);
                                                          ex.removeAt(
                                                              exEntry.key);
                                                          editedPlan['days']
                                                                  [entry.key][
                                                              'exercises'] = ex;
                                                          setModalState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  )),
                                          const SizedBox(height: AppSpacing.s2),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                final ex = List<
                                                        Map<String,
                                                            dynamic>>.from(
                                                    editedPlan['days']
                                                                    [entry.key]
                                                                ['exercises']
                                                            as List? ??
                                                        const []);
                                                ex.add({
                                                  'name': '',
                                                  'sets': '',
                                                  'notes': ''
                                                });
                                                editedPlan['days'][entry.key]
                                                    ['exercises'] = ex;
                                                setModalState(() {});
                                              },
                                              child: const Text(
                                                  'Adicionar exercício'),
                                            ),
                                          ),
                                        ],
                                      )),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.sticky_note_2),
                            label: const Text('Orientações'),
                            onPressed: () {
                              final ctrl = TextEditingController(
                                  text: (editedPlan['orientation'] ?? '')
                                      as String);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (_) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: AppSpacing.s4,
                                      right: AppSpacing.s4,
                                      top: MediaQuery.of(context).padding.top +
                                          AppSpacing.s4,
                                      bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          AppSpacing.s4,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text('Orientações do Plano',
                                            style: AppTypography.h3),
                                        const SizedBox(height: AppSpacing.s2),
                                        TextField(
                                          controller: ctrl,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction:
                                              TextInputAction.newline,
                                          minLines: 6,
                                          maxLines: 16,
                                          decoration: const InputDecoration(
                                              hintText:
                                                  'Descreva orientações gerais, cuidados e notas.'),
                                        ),
                                        const SizedBox(height: AppSpacing.s3),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancelar'),
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.s2),
                                            Expanded(
                                              child: PrimaryButton(
                                                label: 'Salvar',
                                                onPressed: () {
                                                  editedPlan['orientation'] =
                                                      ctrl.text.trim();
                                                  setModalState(() {});
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        const Text('Plano Proposto', style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.s2),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: _buildParsedTextPlan(plano),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        TextField(
                          controller: controller,
                          maxLines: 8,
                          decoration: const InputDecoration(
                              labelText: 'Modificar Texto do Plano (opcional)'),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s3),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Voltar'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s2),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Aprovar',
                              onPressed: () async {
                                final texto = controller.text.trim();
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(alunoId)
                                    .update({
                                  'treino.status': 'aprovado',
                                  'treino.plano_texto': texto,
                                  if (editedPlan != null)
                                    'treino.plan': editedPlan,
                                  'treino_ativo': true,
                                });
                                await TelemetryService.trackEvent(
                                    'trainer_approve', {'alunoId': alunoId});
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s2),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      );
    },
  );
}

List<Widget> _buildParsedTextPlan(String text) {
  final sections = _findDaySectionsText(text);
  if (sections.isEmpty) {
    return [Text(text, style: AppTypography.body)];
  }
  final widgets = <Widget>[];
  for (final entry in sections.entries) {
    widgets.addAll([
      Text(entry.key, style: AppTypography.h3),
      const SizedBox(height: AppSpacing.s1),
    ]);
    final lines = entry.value
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    for (final l in lines) {
      final parts = l.split('•');
      if (parts.length > 1) {
        widgets.add(ListTile(
          leading: const Icon(Icons.fitness_center, color: AppColors.accent),
          title: Text(parts[0].trim(), style: AppTypography.body),
          subtitle: Text(parts.sublist(1).join('•').trim(),
              style: AppTypography.caption),
        ));
      } else {
        final colon = l.split(':');
        if (colon.length > 1) {
          widgets.add(ListTile(
            leading: const Icon(Icons.fitness_center, color: AppColors.accent),
            title: Text(colon[0].trim(), style: AppTypography.body),
            subtitle: Text(colon.sublist(1).join(':').trim(),
                style: AppTypography.caption),
          ));
        } else {
          widgets.add(ListTile(
            leading: const Icon(Icons.fitness_center, color: AppColors.accent),
            title: Text(l, style: AppTypography.body),
          ));
        }
      }
    }
    widgets.add(const SizedBox(height: AppSpacing.s2));
  }
  return widgets;
}

Map<String, String> _findDaySectionsText(String text) {
  final lines = text.split('\n');
  final headers = <String>[
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo'
  ];
  final out = <String, String>{};
  String? current;
  final buf = <String>[];
  for (final raw in lines) {
    final line = raw.trim();
    final isHeaderWeek =
        headers.any((h) => line.toLowerCase().startsWith(h.toLowerCase()));
    final diaMatch =
        RegExp(r'^Dia\s*(\d+)', caseSensitive: false).firstMatch(line);
    if (isHeaderWeek || diaMatch != null) {
      if (current != null) {
        out[current] = buf.join('\n');
        buf.clear();
      }
      current = isHeaderWeek
          ? headers
              .firstWhere((h) => line.toLowerCase().startsWith(h.toLowerCase()))
          : 'Dia ${diaMatch!.group(1)}';
    } else {
      if (current != null) buf.add(line);
    }
  }
  if (current != null && buf.isNotEmpty) {
    out[current] = buf.join('\n');
  }
  return out;
}

Map<String, dynamic>? _tryParseJsonPlan(String text) {
  var s = text.trim();
  s = s.replaceAll(RegExp(r'```[a-zA-Z]*'), '').trim();
  final start = s.indexOf('{');
  final end = s.lastIndexOf('}');
  if (start != -1 && end != -1 && end > start) {
    s = s.substring(start, end + 1);
  }
  try {
    final obj = convert.jsonDecode(s);
    if (obj is Map<String, dynamic>) return obj;
  } catch (_) {}
  return null;
}

// Placeholder removido
